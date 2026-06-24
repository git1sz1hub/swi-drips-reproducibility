function plot_interpolation_error_distribution(cfg)
%PLOT_INTERPOLATION_ERROR_DISTRIBUTION Plot cached held-out interpolation errors.

S = load(fullfile(cfg.resultDir, 'interpolation_errors.mat'), 'Mtest', 'errPDE');

fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 800], ...
    'PaperPositionMode', 'auto');
scatter3(S.Mtest(1, :), S.Mtest(2, :), S.Mtest(3, :), ...
    120, S.errPDE, 'filled', 'Marker', 'o', 'MarkerEdgeColor', 'k', ...
    'LineWidth', 0.8, 'MarkerFaceAlpha', 0.8);

xlabel('Flux Rate [kg/s]', 'FontName', 'Times New Roman', 'FontSize', 24, ...
    'FontWeight', 'bold');
ylabel('Porosity [-]', 'FontName', 'Times New Roman', 'FontSize', 24, ...
    'FontWeight', 'bold');
zlabel('log_{10} Permeability [-]', 'FontName', 'Times New Roman', ...
    'FontSize', 24, 'FontWeight', 'bold');

grid on;
set(gca, 'GridAlpha', 0.3, 'GridLineStyle', '-', 'GridColor', [0.5 0.5 0.5]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 24, 'Box', 'on', ...
    'LineWidth', 1.2, 'TickDir', 'out', 'TickLength', [0.01 0.01]);

cb = colorbar('Location', 'eastoutside');
cb.Label.String = 'Relative RMSE [-]';
cb.Label.FontName = 'Times New Roman';
cb.Label.FontSize = 14;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = 270;
cb.Label.VerticalAlignment = 'bottom';
set(cb, 'FontName', 'Times New Roman', 'FontSize', 24);

colormap(parula);
view(45, 20);
xlim([1, 3]);
ylim([0.4, 0.6]);
zlim([3, 5]);
set(fig, 'Color', 'white', 'InvertHardcopy', 'off');

exportgraphics(fig, fullfile(cfg.figureDir, 'interpolation_error_parameter_space.pdf'), ...
    'ContentType', 'vector', 'BackgroundColor', 'white', 'Resolution', 600);
close(fig);
end
