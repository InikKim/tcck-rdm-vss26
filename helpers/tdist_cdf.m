function p = tdist_cdf(t, df)
% TDIST_CDF  CDF of Student's t-distribution, P(T <= t).
%
%   p = tdist_cdf(t, df)
%
% Implemented via the regularized incomplete beta function (betainc),
% which is base MATLAB (no Statistics and Machine Learning Toolbox
% dependency) -- used instead of the toolbox's tcdf/ttest so this cannot
% break due to a shadowed or missing toolbox function on the path.
%
% Works elementwise on t; df must be scalar or the same size as t.

x = df ./ (df + t.^2);
p = zeros(size(t));
lower = t < 0;
p(lower)  = 0.5 * betainc(x(lower), df/2, 0.5);
p(~lower) = 1 - 0.5 * betainc(x(~lower), df/2, 0.5);
end
