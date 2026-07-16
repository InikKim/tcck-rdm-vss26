function T = load_exp_data(matfile)
% LOAD_EXP_DATA  Read a behavioral .mat file into a long-form table.
%
%   T = load_exp_data('data_exp1.mat')
%
% Expected variable inside the .mat file:
%   BehavioralData with cell-array fields error, motionSD, motionCoh, subID
%   (one cell per subject, vectors of trial-level values).
%
% Output table columns:
%   subject, trial, error, motionSD, motionCoh

s   = load(matfile);
bd  = s.BehavioralData;
nS  = numel(bd.error);

rows = {};
for i = 1:nS
    err = bd.error{i}(:);
    sd  = bd.motionSD{i}(:);
    coh = bd.motionCoh{i}(:);
    if isfield(bd,'subID') && ~isempty(bd.subID{i})
        sid = double(bd.subID{i}(1));
    else
        sid = i;
    end
    nT  = numel(err);
    rows = [rows; {repmat(sid, nT,1), (1:nT)', err, sd, coh}]; %#ok<AGROW>
end

% Vertically concatenate column cells
subject  = vertcat(rows{:,1});
trial    = vertcat(rows{:,2});
error    = vertcat(rows{:,3});
motionSD = vertcat(rows{:,4});
motionCoh= vertcat(rows{:,5});

T = table(subject, trial, error, motionSD, motionCoh);
end
