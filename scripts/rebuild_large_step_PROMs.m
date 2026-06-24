function rebuild_large_step_PROMs(cfg)
%REBUILD_LARGE_STEP_PROMS Rebuild stage-3 large-step DMD PROM artifacts.

error_relative_RMSE = zeros(1, cfg.nTrainingCases);
offset = 0;

for stage = 1:numel(cfg.stageNames)
    nCases = cfg.stageCaseCounts(stage);
    ROBs = zeros(cfg.nSpatial, cfg.rLargeStep, nCases);
    Krs = zeros(cfg.rLargeStep, cfg.rLargeStep, nCases);
    Brs = zeros(cfg.rLargeStep, 1, nCases);

    for localId = 1:nCases
        salinity = load_salinity_case(cfg, stage, localId);
        salinity = salinity(1:cfg.sparseTime:end, :, :);
        dataFlat = flattenMatrix(salinity).';
        X = dataFlat(:, 1:end-1);
        Y = dataFlat(:, 2:end);

        [ROB, Kr, Br] = xDMD_affine(X, Y, cfg.rLargeStep);
        ROBs(:, :, localId) = ROB;
        Krs(:, :, localId) = Kr;
        Brs(:, :, localId) = Br;

        yReduced = zeros(cfg.rLargeStep, size(dataFlat, 2));
        yReduced(:, 1) = ROB' * X(:, 1);
        for t = 2:size(yReduced, 2)
            yReduced(:, t) = Kr * yReduced(:, t - 1) + Br;
        end
        err = norm(ROB * yReduced - dataFlat) / norm(dataFlat);
        error_relative_RMSE(offset + localId) = err;
    end

    save(cfg.promFiles{stage}, 'ROBs', 'Krs', 'Brs', '-mat');
    offset = offset + nCases;
end

save(fullfile(cfg.resultDir, 'training_errors_large_step_DMD.mat'), ...
    'error_relative_RMSE');
end
