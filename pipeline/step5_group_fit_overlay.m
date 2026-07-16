function group_fits = step5_group_fit_overlay(df1, df2, figDir, outDir)
% STEP5_GROUP_FIT_OVERLAY  Pool every subject's trials within a condition,
% fit one aggregate (group-MLE) TCC + von Mises model, and overlay it on
% the group error histogram (with R^2 against the binned histogram).
%
%   group_fits = step5_group_fit_overlay(df1, df2, figDir, outDir)
%
% df1, df2      : long-form tables from step1_load_data
% figDir        : folder to write modelfit_exp1.png/pdf, modelfit_exp2.png/pdf
% outDir        : folder to write group_fits.csv into
%
% group_fits : table of pooled-trial fits, one row per experiment x condition
%              (experiment, condition, n_trials, kappa, dprime, nll, r2)
%
% Requires modelfit_overlay.m + fit_tcc_vm.m + tcc_vm_pdf.m (helpers/).

if ~exist(figDir, 'dir'), mkdir(figDir); end
if ~exist(outDir, 'dir'), mkdir(outDir); end

exp1_colors = {'#4c72b0','#55a868','#c44e52'};
exp2_colors = {'#4c72b0','#c44e52'};

fprintf('[step5] Group-pooled fit + histogram overlay for Exp 1...\n');
gf1 = modelfit_overlay(df1, 'motionSD', [8 16 32], ...
    {'8','16','32'}, exp1_colors, fullfile(figDir,'modelfit_exp1.png'));

fprintf('[step5] Group-pooled fit + histogram overlay for Exp 2...\n');
gf2 = modelfit_overlay(df2, 'motionCoh', [0.6 1.0], ...
    {'0.6 (low)','1.0 (high)'}, exp2_colors, fullfile(figDir,'modelfit_exp2.png'));

group_fits = [gf1; gf2];
writetable(group_fits, fullfile(outDir, 'group_fits.csv'));

fprintf('[step5] Wrote modelfit_exp{1,2}.png/pdf to %s and group_fits.csv to %s\n', ...
    figDir, outDir);
end
