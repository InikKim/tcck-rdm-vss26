function [rmA1, pw1, rmA2, pw2] = step3_compare_conditions(fits1, fits2, outDir)
% STEP3_COMPARE_CONDITIONS  Compare precision (kappa) and memory strength
% (d') across conditions, within subjects.
%
%   [rmA1, pw1, rmA2, pw2] = step3_compare_conditions(fits1, fits2, outDir)
%
% fits1 : Exp 1 per-subject fits (3 levels: motionSD 8/16/32)
%           -> one-way repeated-measures ANOVA + Holm-corrected pairwise
%              paired t-tests
% fits2 : Exp 2 per-subject fits (2 levels: motionCoh 0.6/1.0)
%           -> paired t-test + Wilcoxon signed-rank
% outDir : folder to write the stats CSVs into
%
% Returns:
%   rmA1, rmA2 : omnibus test results (one row per parameter)
%   pw1,  pw2  : pairwise comparisons
%
% Requires compare_conditions.m + holm_correct.m (helpers/).

if ~exist(outDir, 'dir'), mkdir(outDir); end

fprintf('\n[step3] ===== Exp 1 -- motion SD {8, 16, 32} deg =====\n');
[rmA1, pw1] = compare_conditions(fits1, [8 16 32], {'SD8','SD16','SD32'});
writetable(rmA1, fullfile(outDir, 'stats_rm_anova_exp1.csv'));
writetable(pw1,  fullfile(outDir, 'stats_pairwise_exp1.csv'));

fprintf('\n[step3] ===== Exp 2 -- motion coherence {0.6, 1.0} =====\n');
[rmA2, pw2] = compare_conditions(fits2, [0.6 1.0], {'Coh0_6','Coh1_0'});
writetable(rmA2, fullfile(outDir, 'stats_rm_anova_exp2.csv'));
writetable(pw2,  fullfile(outDir, 'stats_pairwise_exp2.csv'));

fprintf('\n[step3] Wrote stats_rm_anova_exp{1,2}.csv and stats_pairwise_exp{1,2}.csv to %s\n', outDir);
end
