function flagged = tukey_outlier_subjects(fits, kappaUB)
% TUKEY_OUTLIER_SUBJECTS  Subjects whose kappa lies outside the per-condition
% Tukey fence (Q1-1.5*IQR..Q3+1.5*IQR), or hits the kappa upper bound.
%
%   flagged = tukey_outlier_subjects(fits, 49.5)

if nargin < 2, kappaUB = 49.5; end
conds = unique(fits.condition);
flagged = [];
for c = 1:numel(conds)
    sub = fits(fits.condition == conds(c), :);
    q   = quantile(sub.kappa, [0.25 0.75]);
    iqr = q(2) - q(1);
    lo  = q(1) - 1.5*iqr;
    hi  = q(2) + 1.5*iqr;
    bad = sub.subject(sub.kappa >= kappaUB | sub.kappa < lo | sub.kappa > hi);
    flagged = unique([flagged; bad]);
end
end
