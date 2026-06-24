function [ROBTrain, KrTrain, BrTrain] = load_stage_PROMs(cfg)
%LOAD_STAGE_PROMS Assemble the included stage-3 large-step DMD PROMs.

ROBTrain = zeros(cfg.nSpatial, cfg.rLargeStep, cfg.nTrainingCases);
KrTrain = zeros(cfg.rLargeStep, cfg.rLargeStep, cfg.nTrainingCases);
BrTrain = zeros(cfg.rLargeStep, 1, cfg.nTrainingCases);

offset = 0;
for stage = 1:numel(cfg.stageNames)
    S = load(cfg.promFiles{stage}, 'ROBs', 'Krs', 'Brs');
    expectedCount = cfg.stageCaseCounts(stage);
    ids = offset + (1:expectedCount);

    if size(S.ROBs, 3) ~= expectedCount
        error('Unexpected PROM count in %s.', cfg.promFiles{stage});
    end

    ROBTrain(:, :, ids) = S.ROBs;
    KrTrain(:, :, ids) = S.Krs;
    BrTrain(:, :, ids) = S.Brs;
    offset = offset + expectedCount;
end
end
