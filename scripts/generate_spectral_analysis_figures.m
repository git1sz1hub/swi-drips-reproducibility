function generate_spectral_analysis_figures(cfg)
%GENERATE_SPECTRAL_ANALYSIS_FIGURES Regenerate unstable-PROM spectra.

close all;
rankData = load(fullfile(cfg.resultDir, 'standard_DMD_rank_values.mat'), 'r_values');
rStandard = max(rankData.r_values);

errData = load(fullfile(cfg.resultDir, 'training_errors_standard_DMD_coarse.mat'), ...
    'error_relative_RMSE_stdDMD_coarse');
[~, unstableIndices] = maxk(errData.error_relative_RMSE_stdDMD_coarse, 3);

for i = 1:numel(unstableIndices)
    globalId = unstableIndices(i);
    [stageId, localId] = global_to_stage_case(globalId, cfg.stageCaseCounts);

    salinity = load_salinity_case(cfg, stageId, localId);
    dataFlat = flattenMatrix(salinity).';
    X = dataFlat(:, 1:end-1);
    Y = dataFlat(:, 2:end);
    [~, KrStandard, ~] = xDMD_affine(X, Y, rStandard);

    promData = load(cfg.promFiles{stageId}, 'Krs');
    KrLargeStep = promData.Krs(:, :, localId);

    fig = figure('Visible', 'off', 'Position', [100, 100, 800, 600], ...
        'PaperPositionMode', 'auto');
    hold on;

    eigStandard = eig(KrStandard);
    plot(real(eigStandard), imag(eigStandard), 'o', ...
        'DisplayName', '\ Standard DMD', 'LineWidth', 0.8, 'MarkerSize', 10);

    eigLargeStep = eig(KrLargeStep);
    plot(real(eigLargeStep), imag(eigLargeStep), 'x', ...
        'DisplayName', '\ Large-step DMD', 'MarkerSize', 15, 'LineWidth', 2);

    theta = linspace(0, 2*pi, 100);
    plot(cos(theta), sin(theta), '--', 'LineWidth', 2, ...
        'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');

    ylim([-1, 1]);
    xlim([-1.5, 1.5]);
    yticks(-1:0.5:1);
    xticks(-1.5:0.5:1.5);
    axis equal;
    grid off;
    legend('show', 'Location', 'northwest', 'FontSize', 24, ...
        'FontName', 'Times New Roman', 'Box', 'off', 'Interpreter', 'latex');
    xlabel('Real Part', 'FontSize', 24, 'Interpreter', 'latex');
    ylabel('Imaginary Part', 'FontSize', 24, 'Interpreter', 'latex');
    set(gca, 'FontSize', 24, 'LineWidth', 2, ...
        'FontName', 'Times New Roman', 'Box', 'on');

    exportgraphics(fig, fullfile(cfg.figureDir, ...
        sprintf('spectral_analysis_unstable_PROM_%d.pdf', globalId)), ...
        'ContentType', 'vector', 'BackgroundColor', 'white');
    close(fig);
end
end
