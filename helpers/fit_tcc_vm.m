function [k, d, nll] = fit_tcc_vm(errors)
% FIT_TCC_VM  MLE fit of TCC+vonMises to a single condition's errors.
%
%   [kappa, dprime, nll] = fit_tcc_vm(errors)
%
% errors : vector of response errors in degrees, range (-180, 180]
%
% Tries multiple starting points and uses fmincon (or fminsearchbnd).

KBND = [0.1, 50];
DBND = [0.0,  6];

errors = errors(~isnan(errors));
if numel(errors) < 5
    k = NaN; d = NaN; nll = NaN; return
end

% Map error degree to 1..360 index
e_idx = round(errors + 180);
e_idx(e_idx == 0) = 360;
e_idx = max(min(e_idx, 360), 1);

starts = [5, 2; 10, 1.5; 20, 2.5];
% 'sqp' is much faster than 'interior-point' for a smooth, box-constrained
% 2-parameter problem like this (no barrier subproblem overhead), and
% 1e-4 tolerances are already far tighter than the 3-decimal precision
% anything downstream reports -- this is the main fitting-speed lever.
opts = optimoptions('fmincon','Display','off','Algorithm','sqp', ...
                    'SpecifyObjectiveGradient',false, ...
                    'OptimalityTolerance',1e-4,'StepTolerance',1e-6);

best.x   = [NaN NaN];
best.fun = inf;
for s = 1:size(starts,1)
    x0 = starts(s,:);
    try
        [x, fv] = fmincon(@(p) nll_tcc_vm(p, e_idx, KBND, DBND), ...
                          x0, [], [], [], [], [KBND(1) DBND(1)], [KBND(2) DBND(2)], ...
                          [], opts);
        if fv < best.fun
            best.x = x; best.fun = fv;
        end
    catch
        % fall through
    end
end
k   = best.x(1);
d   = best.x(2);
nll = best.fun;
end
