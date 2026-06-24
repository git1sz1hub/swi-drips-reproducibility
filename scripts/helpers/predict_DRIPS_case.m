function [XRaw, XClipped, Vstar, KrStar, BrStar] = predict_DRIPS_case(cfg, precomp, pStar, salinityFlat)
%PREDICT_DRIPS_CASE Interpolate the PROM and roll out one held-out case.

w = baryWeightsIDW(pStar, precomp.paraMat, ...
    'Power', cfg.idwPower, ...
    'Epsilon', cfg.idwEpsilon, ...
    'Scale', precomp.invRange, ...
    'K', cfg.idwK);

gammaStar = sum(precomp.GammaTrain .* reshape(w, 1, 1, []), 3);
[Ustar, Ostar, Wstar] = svd(gammaStar, 'econ');
cosO = diag(cos(diag(Ostar)));
sinO = diag(sin(diag(Ostar)));
Vstar = precomp.V0 * Wstar * cosO * Wstar.' + Ustar * sinO * Wstar.';

[Uq, ~, Zq] = svd(Vstar.' * precomp.V0, 'econ');
Qstar = Uq * Zq.';

gammaKStar = sum(precomp.LogKrTrain .* reshape(w, 1, 1, []), 3);
btildeStar = sum(precomp.BrTrain .* reshape(w, 1, 1, []), 3);
ktildeStar = precomp.Kref + gammaKStar;

KrStar = Qstar * ktildeStar * Qstar.';
BrStar = Qstar * btildeStar;

nReduced = size(KrStar, 1);
nTimes = size(salinityFlat, 2);
y0 = Vstar' * salinityFlat(:, 1);

augmentedKr = [KrStar, BrStar; zeros(1, nReduced), 1];
if cfg.refineFactor == 1
    fineKr = augmentedKr;
else
    [Q, T] = schur(augmentedKr, 'real');
    rootFun = @(x, varargin) x.^(1 / cfg.refineFactor);
    tRoot = real(funm(T, rootFun));
    fineKr = Q * tRoot / Q;
end

augmentedY = zeros(nReduced + 1, nTimes);
augmentedY(:, 1) = [y0; 1];
for t = 2:nTimes
    augmentedY(:, t) = fineKr * augmentedY(:, t - 1);
end

XRaw = Vstar * augmentedY(1:end-1, :);
XClipped = XRaw;
XClipped(XClipped < 0) = 0;
XClipped(XClipped > 35) = 35;
end
