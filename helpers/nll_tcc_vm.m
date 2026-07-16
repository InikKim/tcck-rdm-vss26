function v = nll_tcc_vm(params, errs_idx, kBnd, dBnd)
% NLL_TCC_VM  Negative log-likelihood of TCC+vonMises for one condition.
%
%   v = nll_tcc_vm([kappa dprime], errs_idx, kBnd, dBnd)
%
% errs_idx are 1-based indices into the length-360 pdf returned by
% tcc_vm_pdf (i.e. round(error+180), clipped to [1,360]).
%
% Returns 1e12 if parameters fall outside provided bounds.

k = params(1);
d = params(2);
if k < kBnd(1) || k > kBnd(2) || d < dBnd(1) || d > dBnd(2)
    v = 1e12; return
end
pdf = tcc_vm_pdf(k, d);
p   = max(pdf(errs_idx), 1e-12);
v   = -sum(log(p));
end
