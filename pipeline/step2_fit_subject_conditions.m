function [fits1, fits2] = step2_fit_subject_conditions(df1, df2, outDir)
% STEP2_FIT_SUBJECT_CONDITIONS  Fit TCC + von Mises to every participant's
% recall errors, separately for each condition (per-subject x per-condition
% MLE).
%
%   [fits1, fits2] = step2_fit_subject_conditions(df1, df2, outDir)
%
% df1, df2 : long-form tables from step1_load_data
% outDir   : folder to write fits_exp1.csv / fits_exp2.csv into
%
% fits1, fits2 : tables with columns subject, condition, n_trials,
%                kappa, dprime, nll
%
% Requires run_subject_fits.m + fit_tcc_vm.m + nll_tcc_vm.m + tcc_vm_pdf.m
% (helpers/) on the path.

if ~exist(outDir, 'dir'), mkdir(outDir); end

fprintf('[step2] Fitting Exp 1 (motionSD) per subject x condition...\n');
fits1 = run_subject_fits(df1, 'motionSD');
writetable(fits1, fullfile(outDir, 'fits_exp1.csv'));

fprintf('[step2] Fitting Exp 2 (motionCoh) per subject x condition...\n');
fits2 = run_subject_fits(df2, 'motionCoh');
writetable(fits2, fullfile(outDir, 'fits_exp2.csv'));

fprintf('[step2] Wrote %s and %s\n', ...
    fullfile(outDir,'fits_exp1.csv'), fullfile(outDir,'fits_exp2.csv'));
end
