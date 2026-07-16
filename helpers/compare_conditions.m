function [rmTab, pwTab] = compare_conditions(fits, condOrder, condNames)
% COMPARE_CONDITIONS  Repeated-measures comparison of kappa and d' across
% within-subject conditions (complete cases only).
%
%   [rmTab, pwTab] = compare_conditions(fits, condOrder, condNames)
%
% fits      : table with columns subject, condition, kappa, dprime
%             (as produced by run_subject_fits.m)
% condOrder : numeric vector of condition values, e.g. [8 16 32]
% condNames : cell array of valid-identifier condition labels,
%             e.g. {'SD8','SD16','SD32'}
%
%   numel(condOrder) == 2  -> paired t-test (+ Wilcoxon signed-rank)
%   numel(condOrder)  > 2  -> one-way repeated-measures ANOVA (sums-of-
%                             squares form, matches the Python pipeline's
%                             rm_anova_oneway()) + Holm-corrected pairwise
%                             paired t-tests
%
% Returns:
%   rmTab : omnibus test, one row per parameter (kappa, dprime)
%           columns: parameter, F (or t if nC==2), df1, df2, p, eta_p2
%   pwTab : pairwise comparisons, one row per parameter x condition pair
%           columns: parameter, cond_A, cond_B, t, df, p, p_corrected, cohens_dz

nC   = numel(condOrder);
subj = unique(fits.subject);
K = nan(numel(subj), nC);
D = nan(numel(subj), nC);
for i = 1:numel(subj)
    for j = 1:nC
        m = fits.subject == subj(i) & fits.condition == condOrder(j);
        if any(m)
            K(i,j) = fits.kappa(m);
            D(i,j) = fits.dprime(m);
        end
    end
end
keep = ~any(isnan(K),2) & ~any(isnan(D),2);
K = K(keep,:); D = D(keep,:);
nSubj = size(K,1);
fprintf('  N = %d (complete cases)\n', nSubj);

params = {'kappa','dprime'};
mats   = {K, D};
rmRows = {};
pwRows = {};

for p = 1:2
    W = mats{p};
    pname = params{p};

    for j = 1:nC
        fprintf('    %-7s %-8s M=%7.3f  SD=%6.3f  SEM=%6.3f\n', ...
            pname, condNames{j}, mean(W(:,j)), std(W(:,j)), std(W(:,j))/sqrt(nSubj));
    end

    if nC == 2
        % ---- paired t-test (dependency-free, see paired_ttest.m) ----
        % + Wilcoxon signed-rank (best-effort: falls back to NaN if
        % signrank isn't available/behaves unexpectedly on this MATLAB
        % install, same as before).
        [t_stat, df_t, p_t] = paired_ttest(W(:,1), W(:,2));
        try
            p_w = signrank(W(:,1), W(:,2));
        catch
            p_w = NaN;
        end
        dd = W(:,2) - W(:,1);
        dz = mean(dd) / std(dd);
        fprintf('    paired t(%d) = %.3f, p = %.4g, dz = %.3f  (Wilcoxon p = %.4g)\n', ...
            df_t, t_stat, p_t, dz, p_w);

        rmRows(end+1,:) = {pname, t_stat, df_t, NaN, p_t, NaN}; %#ok<AGROW>
        pwRows(end+1,:) = {pname, condNames{1}, condNames{2}, t_stat, ...
                            df_t, p_t, p_t, dz}; %#ok<AGROW>
    else
        % ---- one-way repeated-measures ANOVA (sums-of-squares form) ----
        % Same formula as the Python pipeline's rm_anova_oneway() in
        % analyze_relabeled.py, so F/p/partial-eta^2 match the originally
        % reported numbers. Avoids fitrm/ranova, which requires the
        % Statistics and Machine Learning Toolbox's RepeatedMeasuresModel
        % and can throw a spurious "rank" error on some MATLAB versions.
        n = size(W,1); k = size(W,2);
        grand    = mean(W(:));
        colMeans = mean(W,1);
        rowMeans = mean(W,2);
        SS_cond = n * sum((colMeans - grand).^2);
        SS_subj = k * sum((rowMeans - grand).^2);
        SS_tot  = sum((W(:) - grand).^2);
        SS_err  = SS_tot - SS_cond - SS_subj;
        df1 = k - 1;
        df2 = (n - 1) * (k - 1);
        F      = (SS_cond/df1) / (SS_err/df2);
        pval   = 1 - fcdf(F, df1, df2);
        eta_p2 = SS_cond / (SS_cond + SS_err);
        fprintf('    RM-ANOVA F(%d,%d) = %.3f, p = %.4g, partial eta^2 = %.3f\n', ...
            df1, df2, F, pval, eta_p2);
        rmRows(end+1,:) = {pname, F, df1, df2, pval, eta_p2}; %#ok<AGROW>

        % ---- Holm-corrected pairwise paired t-tests ----
        pairs = nchoosek(1:nC, 2);
        rawP  = nan(size(pairs,1),1);
        tstat = nan(size(pairs,1),1);
        dfv   = nan(size(pairs,1),1);
        dz    = nan(size(pairs,1),1);
        for r = 1:size(pairs,1)
            i = pairs(r,1); j = pairs(r,2);
            [tstat(r), dfv(r), rawP(r)] = paired_ttest(W(:,i), W(:,j));
            dd = W(:,j) - W(:,i);
            dz(r) = mean(dd) / std(dd);
        end
        pHolm = holm_correct(rawP);
        for r = 1:size(pairs,1)
            i = pairs(r,1); j = pairs(r,2);
            fprintf('      %s vs %s: t(%.0f) = %+.3f, p = %.4g (Holm = %.4g), dz = %+.3f\n', ...
                condNames{i}, condNames{j}, dfv(r), tstat(r), rawP(r), pHolm(r), dz(r));
            pwRows(end+1,:) = {pname, condNames{i}, condNames{j}, tstat(r), ...
                                dfv(r), rawP(r), pHolm(r), dz(r)}; %#ok<AGROW>
        end
    end
    fprintf('\n');
end

rmTab = cell2table(rmRows, 'VariableNames', ...
    {'parameter','F','df1','df2','p','eta_p2'});
pwTab = cell2table(pwRows, 'VariableNames', ...
    {'parameter','cond_A','cond_B','t','df','p','p_corrected','cohens_dz'});
end
