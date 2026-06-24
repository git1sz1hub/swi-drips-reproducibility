function salinity = load_salinity_case(cfg, stageId, caseId)
%LOAD_SALINITY_CASE Load one training salinity snapshot tensor.

filename = fullfile(cfg.dataDir, cfg.stageNames{stageId}, 'salinity_splits', ...
    sprintf('salinity_%02d.mat', caseId));
S = load(filename, 'salinity');
salinity = S.salinity;
end
