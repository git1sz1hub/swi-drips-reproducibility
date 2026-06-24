function recompute_standard_DMD_training_errors(cfg)
%RECOMPUTE_STANDARD_DMD_TRAINING_ERRORS Recompute full and coarse DMD errors.

rankFile = fullfile(cfg.resultDir, 'standard_DMD_rank_values.mat');
if exist(rankFile, 'file')
    rankData = load(rankFile, 'r_values');
    r_values = rankData.r_values;
else
    r_values = determine_standard_DMD_ranks(cfg);
end
rStandard = max(r_values);

error_relative_RMSE_stdDMD = zeros(1, cfg.nTrainingCases);
error_relative_RMSE_stdDMD_coarse = zeros(1, cfg.nTrainingCases);
offset = 0;

for stage = 1:numel(cfg.stageNames)
    for localId = 1:cfg.stageCaseCounts(stage)
        salinity = load_salinity_case(cfg, stage, localId);
        dataFlat = flattenMatrix(salinity).';
        X = dataFlat(:, 1:end-1);
        Y = dataFlat(:, 2:end);

        [ROB, Kr, Br] = xDMD_affine(X, Y, rStandard);
        yReduced = zeros(rStandard, size(dataFlat, 2));
        yReduced(:, 1) = ROB' * X(:, 1);
        for t = 2:size(yReduced, 2)
            yReduced(:, t) = Kr * yReduced(:, t - 1) + Br;
        end

        globalId = offset + localId;
        predicted = ROB * yReduced;
        error_relative_RMSE_stdDMD(globalId) = norm(predicted - dataFlat) / norm(dataFlat);
        error_relative_RMSE_stdDMD_coarse(globalId) = ...
            norm(predicted(:, 1:cfg.sparseTime:end) - dataFlat(:, 1:cfg.sparseTime:end)) / ...
            norm(dataFlat(:, 1:cfg.sparseTime:end));
    end
    offset = offset + cfg.stageCaseCounts(stage);
end

save(fullfile(cfg.resultDir, 'training_errors_standard_DMD.mat'), ...
    'error_relative_RMSE_stdDMD');
save(fullfile(cfg.resultDir, 'training_errors_standard_DMD_coarse.mat'), ...
    'error_relative_RMSE_stdDMD_coarse');
end
