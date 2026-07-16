function fits = run_subject_fits(df, condCol)
% RUN_SUBJECT_FITS  Loop over each subject x condition and fit TCC+vonMises.
%
%   fits = run_subject_fits(df, 'motionSD')
%
% df      : long-form table with columns subject, error, <condCol>
% condCol : name of the condition column (e.g. 'motionSD' or 'motionCoh')
%
% Returns a table with subject, condition, n_trials, kappa, dprime, nll.

subs  = unique(df.subject);
conds = unique(df.(condCol));

rows = [];
fprintf('  %d subjects x %d conditions = %d fits\n', ...
    numel(subs), numel(conds), numel(subs)*numel(conds));
t0 = tic;
for i = 1:numel(subs)
    for j = 1:numel(conds)
        sel = df.subject == subs(i) & df.(condCol) == conds(j);
        e   = df.error(sel);
        if isempty(e), continue; end
        [k, d, nll] = fit_tcc_vm(e);
        rows(end+1,:) = [subs(i), conds(j), numel(e), k, d, nll]; %#ok<AGROW>
    end
    if mod(i, 5) == 0
        fprintf('    %d/%d subjects fit (%.1fs)\n', i, numel(subs), toc(t0));
    end
end

fits = array2table(rows, 'VariableNames', ...
    {'subject','condition','n_trials','kappa','dprime','nll'});
end
