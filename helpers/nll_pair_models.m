function v = nll_pair_models(params, ia, ib, mode, kBnd, dBnd)
% NLL_PAIR_MODELS  Negative log-likelihood across two conditions.
%
%   v = nll_pair_models(params, ia, ib, mode, kBnd, dBnd)
%
% mode:
%   'A'    params = [kappa, d_a, d_b]    fixed kappa, free d'
%   'B'    params = [kappa_a, kappa_b, d]  free kappa, fixed d'
%   'Full' params = [kappa_a, d_a, kappa_b, d_b]
%
% ia, ib : 1-based pdf indices (1..360) for the two conditions.

switch mode
    case 'A'
        k   = params(1); d_a = params(2); d_b = params(3);
        if any([k < kBnd(1), k > kBnd(2), d_a < dBnd(1), d_a > dBnd(2), ...
                d_b < dBnd(1), d_b > dBnd(2)])
            v = 1e12; return
        end
        pdf_a = tcc_vm_pdf(k, d_a);
        pdf_b = tcc_vm_pdf(k, d_b);
    case 'B'
        k_a = params(1); k_b = params(2); d = params(3);
        if any([k_a < kBnd(1), k_a > kBnd(2), k_b < kBnd(1), k_b > kBnd(2), ...
                d < dBnd(1), d > dBnd(2)])
            v = 1e12; return
        end
        pdf_a = tcc_vm_pdf(k_a, d);
        pdf_b = tcc_vm_pdf(k_b, d);
    case 'Full'
        k_a = params(1); d_a = params(2); k_b = params(3); d_b = params(4);
        if any([k_a < kBnd(1), k_a > kBnd(2), k_b < kBnd(1), k_b > kBnd(2), ...
                d_a < dBnd(1), d_a > dBnd(2), d_b < dBnd(1), d_b > dBnd(2)])
            v = 1e12; return
        end
        pdf_a = tcc_vm_pdf(k_a, d_a);
        pdf_b = tcc_vm_pdf(k_b, d_b);
end
pa = max(pdf_a(ia), 1e-12);
pb = max(pdf_b(ib), 1e-12);
v  = -sum(log(pa)) - sum(log(pb));
end
