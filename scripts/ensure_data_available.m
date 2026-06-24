function ensure_data_available(cfg)
%ENSURE_DATA_AVAILABLE Stop early if Git LFS salinity files are missing.

requiredFiles = {};
for stageId = 1:numel(cfg.stageNames)
    for caseId = 1:cfg.stageCaseCounts(stageId)
        requiredFiles{end + 1} = fullfile(cfg.dataDir, cfg.stageNames{stageId}, ...
            'salinity_splits', sprintf('salinity_%02d.mat', caseId)); %#ok<AGROW>
    end
end

for caseId = 1:cfg.nHeldoutCases
    requiredFiles{end + 1} = fullfile(cfg.heldoutDir, 'salinity_splits', ...
        sprintf('salinity_%02d.mat', caseId)); %#ok<AGROW>
end

missing = requiredFiles(~cellfun(@(f) exist(f, 'file') == 2, requiredFiles));
if isempty(missing)
    return;
end

fprintf('\nMissing salinity data. First missing file:\n%s\n\n', missing{1});
fprintf('These salinity splits are tracked with Git LFS. After cloning, run:\n');
fprintf('  cd ''%s''\n', cfg.releaseRoot);
fprintf('  git lfs install\n');
fprintf('  git lfs pull\n\n');

error('Required salinity data are missing.');
end
