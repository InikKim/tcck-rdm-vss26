function step4_plot_parameters(fits1, fits2, figDir)
% STEP4_PLOT_PARAMETERS  Bar + per-subject swarm plots of kappa and d'
% across conditions, with significance brackets from pairwise paired
% t-tests (Bonferroni-corrected for Exp 1's 3 pairwise comparisons).
%
%   step4_plot_parameters(fits1, fits2, figDir)
%
% fits1, fits2 : per-subject fits from step2_fit_subject_conditions
% figDir       : folder to write fits_exp1.png/pdf, fits_exp2.png/pdf into
%
% Requires bar_swarm_plot.m (helpers/) on the path.

if ~exist(figDir, 'dir'), mkdir(figDir); end

exp1_colors = {'#4c72b0','#55a868','#c44e52'};   % low / middle / high
exp2_colors = {'#4c72b0','#c44e52'};             % low coh / high coh

bar_swarm_plot(fits1, [8 16 32], {'low','middle','high'}, ...
    'motion SD (deg)', exp1_colors, fullfile(figDir,'fits_exp1.png'), true);
bar_swarm_plot(fits2, [0.6 1.0], {'low','high'}, ...
    'motion coherence', exp2_colors, fullfile(figDir,'fits_exp2.png'), false);

fprintf('[step4] Wrote fits_exp1.png/pdf and fits_exp2.png/pdf to %s\n', figDir);
end
