function pdf = tcc_vm_pdf(kappa, dprime)
% TCC_VM_PDF  Discrete (length-360) error pdf for TCC + vonMises similarity.
%
%   pdf = tcc_vm_pdf(kappa, dprime)
%
% Returns a 1x360 vector p such that p(i) is the probability of an error
% of (i-180) degrees, i = 1..360 maps to errors -179..180.
%
% Implementation matches the Python port (fit_TCC_vonMises.py).

% This function is called thousands of times per fit (once per fmincon
% objective/gradient evaluation), so everything that doesn't depend on
% kappa/dprime is computed once and cached with `persistent` rather than
% rebuilt on every call -- DEGS/THETA/XVALS/Xgrid/gauss never change.
persistent DEGS THETA XVALS Xgrid nX gauss
if isempty(DEGS)
    DEGS  = -179:180;
    THETA = deg2rad(DEGS);
    XVALS = -10:0.05:15;
    nX    = numel(XVALS);
    Xgrid = repmat(XVALS(:)', numel(DEGS), 1);   % 360 x nX, kappa/dprime-independent

    motorErr = 2;
    w        = round(motorErr * 3);
    gx       = -w:w;
    gauss    = normpdf(gx, 0, motorErr);
    gauss    = gauss ./ sum(gauss);
end

% Confusion vector: vonMises similarity scaled to peak of 1
confVec = exp(kappa .* cos(THETA));
confVec = confVec ./ max(confVec);

% CDF of N(mean = confVec*dprime, sd=1) at each evidence x.
% Mgrid (depends on kappa/dprime) must still be rebuilt each call; Xgrid
% is cached above. Built as an explicit 360 x nX grid rather than relying
% on normcdf to broadcast a 1xN row against an Mx1 column -- not all
% MATLAB/Statistics Toolbox versions implicitly expand mismatched
% non-singleton dims here.
means   = confVec(:) .* dprime;                  % 360x1
Mgrid   = repmat(means, 1, nX);                  % 360 x nX
normals = normcdf(Xgrid, Mgrid, 1);              % 360 x nX

% Log of CDFs, sum across angles -> log-CDF of the maximum
logN   = log(max(normals, 1e-300));
logMax = sum(logN, 1);                           % 1 x nX

% For each angle a, P(max=a) = exp( logMax - logN(a) )
logCur = logMax - logN;                          % 360 x nX
cur    = exp(logCur);
d      = diff([zeros(size(cur,1),1) cur], 1, 2); % 360 x nX, prepend 0
s      = sum(d, 2);
d      = bsxfun(@rdivide, d, max(s, eps));
chance = 1 - normals;
pdf    = sum(d .* chance, 2, 'omitnan')';        % 1 x 360

% Circular motor noise (Gaussian, sd=2 deg) -- gauss kernel cached above
triple   = [pdf pdf pdf];
triple   = conv(triple, gauss, 'same');
pdf      = triple(361:720);

% Renormalise
s = sum(pdf);
if s > 0, pdf = pdf ./ s; end
end
