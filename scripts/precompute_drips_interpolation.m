function precomp = precompute_drips_interpolation(cfg)
%PRECOMPUTE_DRIPS_INTERPOLATION Precompute stage-3 DRIPS interpolation data.

[paraMat, stageIds] = load_stage_parameters(cfg);
[ROBTrain, KrTrain, BrTrain] = load_stage_PROMs(cfg);

[n, r, nCases] = size(ROBTrain);
if nCases ~= cfg.nTrainingCases
    error('PROM count does not match the configured stage-3 training count.');
end

refId = cfg.referenceTrainingIndex;
V0 = ROBTrain(:, :, refId);
GammaTrain = zeros(n, r, nCases);

for caseId = 1:nCases
    Vi = ROBTrain(:, :, caseId);
    T = V0.' * Vi;
    M = Vi - V0 * (V0.' * Vi);
    G = M / T;

    [U, S, W] = svd(G, 'econ');
    theta = atan(diag(S));
    GammaTrain(:, :, caseId) = U * diag(theta) * W.';
end

Kref = KrTrain(:, :, refId);
for caseId = 1:nCases
    if caseId == refId
        continue;
    end

    Vi = ROBTrain(:, :, caseId);
    [U, ~, Z] = svd(Vi.' * V0, 'econ');
    Qi = U * Z.';
    KrTrain(:, :, caseId) = Qi.' * KrTrain(:, :, caseId) * Qi;
    BrTrain(:, :, caseId) = Qi.' * BrTrain(:, :, caseId);
end

LogKrTrain = zeros(size(KrTrain));
for caseId = 1:nCases
    if caseId == refId
        LogKrTrain(:, :, caseId) = zeros(r, r);
    else
        LogKrTrain(:, :, caseId) = KrTrain(:, :, caseId) - Kref;
    end
end

paramRange = max(paraMat, [], 2) - min(paraMat, [], 2);
invRange = (1 ./ paramRange) .* cfg.idwScale;

precomp = struct();
precomp.paraMat = paraMat;
precomp.stageIds = stageIds;
precomp.V0 = V0;
precomp.GammaTrain = GammaTrain;
precomp.Kref = Kref;
precomp.LogKrTrain = LogKrTrain;
precomp.BrTrain = BrTrain;
precomp.invRange = invRange;
end
