function cfg = release_config(releaseRoot)
%RELEASE_CONFIG Central configuration for the cleaned stage-3 release.

if nargin < 1 || isempty(releaseRoot)
    releaseRoot = fileparts(fileparts(mfilename('fullpath')));
end

cfg.releaseRoot = releaseRoot;
cfg.dataDir = fullfile(releaseRoot, 'data');
cfg.resultDir = fullfile(cfg.dataDir, 'results');
cfg.romDir = fullfile(releaseRoot, 'roms', 'large_step_DMD');
cfg.figureDir = fullfile(releaseRoot, 'figures', 'generated');

cfg.stageNames = {'stage_1', 'stage_2', 'stage_3'};
cfg.stageCaseCounts = [27, 20, 20];
cfg.nTrainingCases = sum(cfg.stageCaseCounts);
cfg.promFiles = { ...
    fullfile(cfg.romDir, 'stage_1_PROMs.mat'), ...
    fullfile(cfg.romDir, 'stage_2_PROMs.mat'), ...
    fullfile(cfg.romDir, 'stage_3_PROMs.mat')};

cfg.gridSize = [200, 100];
cfg.nSpatial = prod(cfg.gridSize);
cfg.rLargeStep = 29;
cfg.sparseTime = 50;
cfg.referenceTrainingIndex = 24;

cfg.idwPower = 7.5;
cfg.idwScale = [1, 1.2, 3.8]';
cfg.idwK = 12;
cfg.idwEpsilon = 1e-3;

cfg.heldoutDir = fullfile(cfg.dataDir, 'heldout_cases');
cfg.heldoutParameterFile = fullfile(cfg.heldoutDir, 'parameters', 'rand_samples.txt');
cfg.nHeldoutCases = 100;
cfg.selectedHeldoutRankPositions = [1, 11, 12];
cfg.refineFactor = 1;
end
