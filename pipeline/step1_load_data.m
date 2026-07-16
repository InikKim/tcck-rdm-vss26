function [df1, df2] = step1_load_data(dataDir)
% STEP1_LOAD_DATA  Load the two behavioral datasets into long-form tables.
%
%   [df1, df2] = step1_load_data(dataDir)
%
% dataDir : folder containing data_exp1.mat and data_exp2.mat
%
% df1 : Exp 1 -- motion-direction-noise manipulation (motionSD: 8/16/32 deg)
% df2 : Exp 2 -- motion-coherence manipulation (motionCoh: 0.6/1.0)
%
% Both .mat files already contain only the subjects used in the reported
% analysis (N=38 for Exp 1, N=36 for Exp 2) -- no exclusion happens here.
%
% Table columns: subject, trial, error, motionSD, motionCoh
%
% Requires load_exp_data.m (helpers/) on the path.

fprintf('[step1] Loading behavioral data from %s ...\n', dataDir);
df1 = load_exp_data(fullfile(dataDir, 'data_exp1.mat'));
df2 = load_exp_data(fullfile(dataDir, 'data_exp2.mat'));

fprintf('[step1]   Exp 1: %d subjects, motionSD  = %s\n', ...
    numel(unique(df1.subject)), mat2str(unique(df1.motionSD)'));
fprintf('[step1]   Exp 2: %d subjects, motionCoh = %s\n', ...
    numel(unique(df2.subject)), mat2str(unique(df2.motionCoh)'));
end
