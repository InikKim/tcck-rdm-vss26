function [t, df, p] = paired_ttest(a, b)
% PAIRED_TTEST  Two-sided paired t-test, computed directly rather than via
% MATLAB's built-in ttest(), so it can't be broken by a shadowed/older
% ttest.m elsewhere on the path (seen in the wild: "Too many output
% arguments" when some other ttest.m wins path priority).
%
%   [t, df, p] = paired_ttest(a, b)
%
% a, b : paired samples (same length)
% t    : t-statistic on the paired differences (a - b)
% df   : degrees of freedom (n - 1)
% p    : two-sided p-value (via tdist_cdf.m, itself dependency-free)

d  = a(:) - b(:);
n  = numel(d);
df = n - 1;
t  = mean(d) / (std(d) / sqrt(n));
p  = 2 * (1 - tdist_cdf(abs(t), df));
end
