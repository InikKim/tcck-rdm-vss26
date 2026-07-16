%% run_all.m
% Single entry point for the TCC + von Mises analysis pipeline.
% Runs each stage as a separate, independently-readable step -- see
% pipeline/step*.m for what each one does on its own.
%
%   step1_load_data              -> load data_exp1.mat / data_exp2.mat
%   step2_fit_subject_conditions -> per-subject x per-condition MLE fits
%   step3_compare_conditions     -> RM-ANOVA / paired t-tests on kappa, d'
%   step4_plot_parameters        -> bar + swarm plots of kappa, d'
%   step5_group_fit_overlay      -> pooled-trial group fit + histogram + R^2
%   step6_model_comparison_ABC   -> 3-model (fixed kappa / fixed d' / full)
%                                   BIC comparison (slowest step)
%
% Requires: Statistics and Machine Learning Toolbox (ttest, signrank,
% fcdf) and Optimization Toolbox (fmincon).
%
% Outputs land in output/ (CSVs) and figure/ (PNG/PDF figures).

clearvars; close all; clc;

THIS_DIR = fileparts(mfilename('fullpath'));
addpath(fullfile(THIS_DIR, 'helpers'));
addpath(fullfile(THIS_DIR, 'pipeline'));

DATA_DIR = fullfile(THIS_DIR, 'data');
OUT_DIR  = fullfile(THIS_DIR, 'output');
FIG_DIR  = fullfile(THIS_DIR, 'figure');

rng(0);

[df1, df2]           = step1_load_data(DATA_DIR);
[fits1, fits2]        = step2_fit_subject_conditions(df1, df2, OUT_DIR);
[rmA1, pw1, rmA2, pw2] = step3_compare_conditions(fits1, fits2, OUT_DIR);
step4_plot_parameters(fits1, fits2, FIG_DIR);
group_fits            = step5_group_fit_overlay(df1, df2, FIG_DIR, OUT_DIR);
[mc1, mc2]            = step6_model_comparison_ABC(df1, df2, OUT_DIR, FIG_DIR);

fprintf('\nAll done.\n  CSVs    -> %s\n  Figures -> %s\n', OUT_DIR, FIG_DIR);
