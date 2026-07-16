function T = run_pair_models(df, condCol, pairs)
% RUN_PAIR_MODELS  Loop subjects x condition pairs, fit 3 nested models.
%
%   T = run_pair_models(df, 'motionSD', [8 16; 16 32; 8 32])

subs = unique(df.subject);
rows = [];
for r = 1:size(pairs,1)
    ca = pairs(r,1); cb = pairs(r,2);
    fprintf('  pair %g vs %g\n', ca, cb);
    for i = 1:numel(subs)
        ea = df.error(df.subject==subs(i) & df.(condCol)==ca);
        eb = df.error(df.subject==subs(i) & df.(condCol)==cb);
        if numel(ea) < 5 || numel(eb) < 5, continue; end
        R = fit_pair_models(ea, eb);
        rows(end+1,:) = [subs(i), ca, cb, R.n_total, ...
            R.nll_full, R.bic_full, R.k_a_full, R.d_a_full, R.k_b_full, R.d_b_full, ...
            R.nll_A, R.bic_A, R.k_A, R.d_a_A, R.d_b_A, ...
            R.nll_B, R.bic_B, R.k_a_B, R.k_b_B, R.d_B];        %#ok<AGROW>
    end
end

T = array2table(rows, 'VariableNames', { ...
    'subject','cond_a','cond_b','n_total', ...
    'nll_full','bic_full','k_a_full','d_a_full','k_b_full','d_b_full', ...
    'nll_A','bic_A','k_A','d_a_A','d_b_A', ...
    'nll_B','bic_B','k_a_B','k_b_B','d_B'});
end
