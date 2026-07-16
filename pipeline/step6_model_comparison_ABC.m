function [mc1, mc2] = step6_model_comparison_ABC(df1, df2, outDir, figDir)
% STEP6_MODEL_COMPARISON_ABC  For each subject and each pair of adjacent
% conditions, fit three nested TCC + von Mises models and compare them by
% BIC, to test whether a condition-driven change is better explained by a
% shift in kappa, in d', or both:
%
%   Model A    : fixed kappa (shared across the pair), free d'   (3 params)
%   Model B    : free kappa, fixed d' (shared across the pair)   (3 params)
%   Model Full : free kappa, free d'                             (4 params)
%
%   [mc1, mc2] = step6_model_comparison_ABC(df1, df2, outDir, figDir)
%
% df1, df2 : long-form tables from step1_load_data
% outDir   : folder to write model_compare_exp1.csv / _exp2.csv
% figDir   : folder to write model_compare_exp1.png/pdf / _exp2.png/pdf
%            (bar chart of how many subjects each model "wins" on BIC)
%
% mc1 : Exp 1 (motionSD), pairs = [8 vs 16, 16 vs 32]
% mc2 : Exp 2 (motionCoh), pair  = [1.0 vs 0.6]
%
% Requires run_pair_models.m + fit_pair_models.m + nll_pair_models.m +
% modelcompare_bar.m (helpers/) on the path. This step is the
% slowest -- it fits 3 models per subject per condition pair.

if ~exist(outDir, 'dir'), mkdir(outDir); end
if ~exist(figDir, 'dir'), mkdir(figDir); end

fprintf('[step6] Running 3-model (A/B/Full) comparison for Exp 1...\n');
mc1 = run_pair_models(df1, 'motionSD', [8 16; 16 32]);
writetable(mc1, fullfile(outDir, 'model_compare_exp1.csv'));

fprintf('[step6] Running 3-model (A/B/Full) comparison for Exp 2...\n');
mc2 = run_pair_models(df2, 'motionCoh', [1.0 0.6]);
writetable(mc2, fullfile(outDir, 'model_compare_exp2.csv'));

modelcompare_bar(mc1, ...
    {[8 16],'low vs middle'; [16 32],'middle vs high'}, ...
    'Exp 1', fullfile(figDir, 'model_compare_exp1.png'));
modelcompare_bar(mc2, ...
    {[1.0 0.6],'low vs high'}, ...
    'Exp 2', fullfile(figDir, 'model_compare_exp2.png'));

fprintf('[step6] Wrote model_compare_exp{1,2}.csv to %s and .png/pdf to %s\n', ...
    outDir, figDir);
end
