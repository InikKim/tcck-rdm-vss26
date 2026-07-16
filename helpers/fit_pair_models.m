function R = fit_pair_models(errs_a, errs_b)
% FIT_PAIR_MODELS  Fit three nested TCC+vonMises models to one subject's
% data across two conditions.
%
%   R = fit_pair_models(errs_a, errs_b)
%
% Returns a struct with NLL, BIC for models A, B, Full plus the parameter
% estimates.

KBND = [0.1, 50];
DBND = [0.0,  6];

% Map errors to 1..360 indices
ia = round(errs_a + 180); ia(ia==0)=360; ia = max(min(ia,360),1);
ib = round(errs_b + 180); ib(ib==0)=360; ib = max(min(ib,360),1);
n_total = numel(ia) + numel(ib);

% 'sqp' is much faster than 'interior-point' for these small, smooth,
% box-constrained problems (3-4 params) -- see fit_tcc_vm.m for the same
% change and rationale. This is step 6's main speed lever since it fits
% 3 models x N subjects x condition pairs.
opts = optimoptions('fmincon','Display','off','Algorithm','sqp', ...
                    'OptimalityTolerance',1e-4,'StepTolerance',1e-6);

% --- Model Full (= sum of two independent fits) ---------------------------
[k_a, d_a, nll_a] = fit_tcc_vm(errs_a);
[k_b, d_b, nll_b] = fit_tcc_vm(errs_b);
nll_full = nll_a + nll_b;
bic_full = 2*nll_full + 4*log(n_total);

% --- Model A (fixed kappa, free d') ---------------------------------------
starts_A = [5 2 2; 10 1.5 2.5; 3 3 1.5; (k_a+k_b)/2 d_a d_b];
lb_A = [KBND(1) DBND(1) DBND(1)];
ub_A = [KBND(2) DBND(2) DBND(2)];
best_A = struct('x',[NaN NaN NaN],'fun',inf);
for s = 1:size(starts_A,1)
    try
        [x, fv] = fmincon(@(p) nll_pair_models(p, ia, ib, 'A', KBND, DBND), ...
                          starts_A(s,:), [], [], [], [], lb_A, ub_A, [], opts);
        if fv < best_A.fun, best_A.x = x; best_A.fun = fv; end
    catch
    end
end
nll_A = best_A.fun;
bic_A = 2*nll_A + 3*log(n_total);

% --- Model B (free kappa, fixed d') ---------------------------------------
starts_B = [5 5 2; 10 3 1.5; 3 8 2.5; k_a k_b (d_a+d_b)/2];
lb_B = [KBND(1) KBND(1) DBND(1)];
ub_B = [KBND(2) KBND(2) DBND(2)];
best_B = struct('x',[NaN NaN NaN],'fun',inf);
for s = 1:size(starts_B,1)
    try
        [x, fv] = fmincon(@(p) nll_pair_models(p, ia, ib, 'B', KBND, DBND), ...
                          starts_B(s,:), [], [], [], [], lb_B, ub_B, [], opts);
        if fv < best_B.fun, best_B.x = x; best_B.fun = fv; end
    catch
    end
end
nll_B = best_B.fun;
bic_B = 2*nll_B + 3*log(n_total);

R = struct('n_total', n_total, ...
    'nll_full',nll_full,'bic_full',bic_full, ...
    'k_a_full',k_a,'d_a_full',d_a,'k_b_full',k_b,'d_b_full',d_b, ...
    'nll_A',nll_A,'bic_A',bic_A, ...
    'k_A',best_A.x(1),'d_a_A',best_A.x(2),'d_b_A',best_A.x(3), ...
    'nll_B',nll_B,'bic_B',bic_B, ...
    'k_a_B',best_B.x(1),'k_b_B',best_B.x(2),'d_B',best_B.x(3));
end
