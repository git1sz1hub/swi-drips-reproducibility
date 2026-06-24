function r_values = determine_standard_DMD_ranks(cfg)
%DETERMINE_STANDARD_DMD_RANKS Compute energy-based standard-DMD ranks.

r_values = zeros(1, cfg.nTrainingCases);
offset = 0;

for stage = 1:numel(cfg.stageNames)
    for localId = 1:cfg.stageCaseCounts(stage)
        salinity = load_salinity_case(cfg, stage, localId);
        dataFlat = flattenMatrix(salinity).';
        X = dataFlat(:, 1:end-1);

        [~, S, ~] = svd(X, 'econ');
        singularValues = diag(S);
        energy = cumsum(singularValues.^2) / sum(singularValues.^2);
        r_values(offset + localId) = find(energy >= 1 - 1e-9, 1);
    end
    offset = offset + cfg.stageCaseCounts(stage);
end

save(fullfile(cfg.resultDir, 'standard_DMD_rank_values.mat'), 'r_values');
end
