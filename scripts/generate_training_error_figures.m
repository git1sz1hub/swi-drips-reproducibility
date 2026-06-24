function generate_training_error_figures(cfg)
%GENERATE_TRAINING_ERROR_FIGURES Regenerate the training-error PDFs.

close all;
[paraMat, ~] = load_stage_parameters(cfg);

largeStep = load(fullfile(cfg.resultDir, 'training_errors_large_step_DMD.mat'), ...
    'error_relative_RMSE');
standardCoarse = load(fullfile(cfg.resultDir, 'training_errors_standard_DMD_coarse.mat'), ...
    'error_relative_RMSE_stdDMD_coarse');

largeStepErr = largeStep.error_relative_RMSE(1:cfg.nTrainingCases);
standardCoarseErr = standardCoarse.error_relative_RMSE_stdDMD_coarse(1:cfg.nTrainingCases);

fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 800], ...
    'PaperPositionMode', 'auto');
logErr = log10(largeStepErr);

scatter3(paraMat(1, :), paraMat(2, :), paraMat(3, :), ...
    120, logErr, 'filled', 'Marker', 'o', 'MarkerEdgeColor', 'k', ...
    'LineWidth', 0.8, 'MarkerFaceAlpha', 0.85);

xlabel('Flux rate [kg/s]', 'FontName', 'Times New Roman', 'FontSize', 24, ...
    'FontWeight', 'bold', 'Interpreter', 'latex');
ylabel('Porosity [-]', 'FontName', 'Times New Roman', 'FontSize', 24, ...
    'FontWeight', 'bold', 'Interpreter', 'latex');
zlabel('$\log_{10}$ Permeability [-]', 'FontName', 'Times New Roman', ...
    'FontSize', 24, 'FontWeight', 'bold', 'Interpreter', 'latex');

grid off;
ax = gca;
set(ax, 'GridAlpha', 0.3, 'GridLineStyle', '-', 'FontName', ...
    'Times New Roman', 'FontSize', 24);
set(ax, 'Box', 'on', 'LineWidth', 1.2, 'TickDir', 'out', ...
    'TickLength', [0.01 0.01]);

cmin = -6;
cmax = -1;
cb = colorbar('Location', 'eastoutside');
cb.Label.String = 'log_{10}(err)';
cb.Label.Interpreter = 'tex';
cb.Label.FontName = 'Times New Roman';
cb.Label.FontSize = 24;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = 270;
cb.Label.VerticalAlignment = 'bottom';
colormap(parula);
clim([cmin cmax]);
cb.Ticks = cmin:1:cmax;

view(45, 20);
axis vis3d;
xlim([1, 3]);
ylim([0.4, 0.6]);
zlim([3, 5]);
set(fig, 'Color', 'white', 'InvertHardcopy', 'off');

exportgraphics(fig, fullfile(cfg.figureDir, 'training_error_parameter_space.pdf'), ...
    'ContentType', 'vector', 'BackgroundColor', 'white');
close(fig);

fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 800], ...
    'PaperPositionMode', 'auto');
hold on;

logErr = log10(standardCoarseErr);
blowupThreshold = 10;
isBlowup = (logErr > blowupThreshold) | ~isfinite(logErr);
isStable = ~isBlowup;
logErrClip = min(max(logErr(isStable), cmin), cmax);

scatter3(paraMat(1, isStable), paraMat(2, isStable), paraMat(3, isStable), ...
    140, logErrClip, 'filled', 'Marker', 'o', 'MarkerEdgeColor', 'k', ...
    'LineWidth', 0.8, 'MarkerFaceAlpha', 0.85);
scatter3(paraMat(1, isBlowup), paraMat(2, isBlowup), paraMat(3, isBlowup), ...
    170, 'kx', 'LineWidth', 3.0);

hStable = scatter3(nan, nan, nan, 450, 0, 'filled', 'Marker', 'o', ...
    'MarkerEdgeColor', 'k', 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.85);
hBlowup = scatter3(nan, nan, nan, 450, 'kx', 'LineWidth', 3.0);
lgd = legend([hStable, hBlowup], {'\ Stable cases (colored)', '\ Blow-up cases'}, ...
    'FontName', 'Times New Roman', 'FontSize', 24, 'Interpreter', 'latex', ...
    'Box', 'off', 'Position', [0.60, 0.75, 0.1, 0.1]);
lgd.AutoUpdate = 'off';

xlabel('Flux rate [kg/s]', 'FontName', 'Times New Roman', 'FontSize', 24, ...
    'FontWeight', 'bold', 'Interpreter', 'latex');
ylabel('Porosity [-]', 'FontName', 'Times New Roman', 'FontSize', 24, ...
    'FontWeight', 'bold', 'Interpreter', 'latex');
zlabel('$\log_{10}$ Permeability [-]', 'FontName', 'Times New Roman', ...
    'FontSize', 24, 'FontWeight', 'bold', 'Interpreter', 'latex');

grid off;
ax = gca;
set(ax, 'GridAlpha', 0.3, 'GridLineStyle', '-', 'FontName', ...
    'Times New Roman', 'FontSize', 24);
set(ax, 'Box', 'on', 'LineWidth', 1.5, 'TickDir', 'out', ...
    'TickLength', [0.01 0.01]);
colormap(parula);
clim([cmin cmax]);
cb = colorbar('Location', 'eastoutside');
cb.Label.String = 'log_{10}(err)';
cb.Label.FontName = 'Times New Roman';
cb.Label.FontSize = 24;
cb.Label.Interpreter = 'tex';
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = 270;
cb.Label.VerticalAlignment = 'bottom';
set(cb, 'FontName', 'Times New Roman', 'FontSize', 24);
cb.Ticks = cmin:1:cmax;

view(45, 20);
axis vis3d;
xlim([1, 3]);
ylim([0.4, 0.6]);
zlim([3, 5]);
set(fig, 'Color', 'white', 'InvertHardcopy', 'off');
hold off;

exportgraphics(fig, fullfile(cfg.figureDir, ...
    'training_error_parameter_space_with_blowups.pdf'), ...
    'ContentType', 'vector', 'BackgroundColor', 'white');
close(fig);
end
