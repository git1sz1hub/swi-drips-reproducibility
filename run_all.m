% Reproduce the stage-3 DRIPS paper figures from the cleaned release folder.
%
% The default path uses the included PROM and error-cache artifacts. Set
% rebuildLargeStepPROMs to true to rebuild the large-step DMD PROMs from the
% included stage_1, stage_2, and stage_3 salinity snapshots before plotting.

clear;
clc;
close all;

releaseRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(releaseRoot, 'scripts'));
addpath(fullfile(releaseRoot, 'scripts', 'helpers'));

cfg = release_config(releaseRoot);
if ~exist(cfg.figureDir, 'dir')
    mkdir(cfg.figureDir);
end
warning('off', 'MATLAB:print:ContentTypeImageSuggested');
ensure_data_available(cfg);

rebuildLargeStepPROMs = false;

fprintf('SWI DRIPS reproducibility package\n');
fprintf('Release root: %s\n', cfg.releaseRoot);
fprintf('Output figures: %s\n\n', cfg.figureDir);

if rebuildLargeStepPROMs
    fprintf('Rebuilding large-step DMD PROMs from stage_1-stage_3 data...\n');
    rebuild_large_step_PROMs(cfg);
end

fprintf('Precomputing DRIPS interpolation quantities...\n');
precomp = precompute_drips_interpolation(cfg);

fprintf('Generating training-error figures...\n');
generate_training_error_figures(cfg);

fprintf('Generating spectral-analysis figures...\n');
generate_spectral_analysis_figures(cfg);

fprintf('Generating interpolation-error distribution figure...\n');
plot_interpolation_error_distribution(cfg);

fprintf('Generating DRIPS vs. ground-truth figures...\n');
generate_DRIPS_vs_ground_truth_figures(cfg, precomp);

fprintf('\nDone. Regenerated figures are in:\n%s\n', cfg.figureDir);
