function [parameters, stageIds] = load_stage_parameters(cfg)
%LOAD_STAGE_PARAMETERS Load standardized 3 x N parameter matrices.

parameters = zeros(3, cfg.nTrainingCases);
stageIds = zeros(1, cfg.nTrainingCases);

offset = 0;
for stage = 1:numel(cfg.stageNames)
    stageName = cfg.stageNames{stage};
    parameterFile = fullfile(cfg.dataDir, stageName, 'parameters', 'parameter_samples.mat');
    S = load(parameterFile, 'parameters');

    expectedCount = cfg.stageCaseCounts(stage);
    if ~isequal(size(S.parameters), [3, expectedCount])
        error('Unexpected parameter size in %s.', parameterFile);
    end

    ids = offset + (1:expectedCount);
    parameters(:, ids) = S.parameters;
    stageIds(ids) = stage;
    offset = offset + expectedCount;
end
end
