function padj = holm_correct(p)
% HOLM_CORRECT  Holm-Bonferroni step-down p-value correction.
%
%   padj = holm_correct(p)
%
% p    : vector of raw p-values
% padj : Holm-corrected p-values, same order as p

n = numel(p);
[ps, ord] = sort(p);
padj_sorted = nan(n,1);
running = 0;
for r = 1:n
    running = max(running, (n-r+1)*ps(r));
    padj_sorted(r) = min(running, 1);
end
padj = nan(n,1);
padj(ord) = padj_sorted;
end
