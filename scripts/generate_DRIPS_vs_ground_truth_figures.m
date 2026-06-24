function generate_DRIPS_vs_ground_truth_figures(cfg, precomp)
%GENERATE_DRIPS_VS_GROUND_TRUTH_FIGURES Regenerate aggregate DRIPS figures.

close all;
errorData = load(fullfile(cfg.resultDir, 'interpolation_errors.mat'), ...
    'Mtest', 'errPDE_abs');
[~, sortedIds] = mink(errorData.errPDE_abs, 20);
selectedCaseIds = sortedIds(cfg.selectedHeldoutRankPositions);

nCases = numel(selectedCaseIds);
caseNames = {'low $k$', 'medium $k$', 'high $k$'};

toeTruthAll = cell(nCases, 1);
toeDripsAll = cell(nCases, 1);
swiTruthAll = cell(nCases, 1);
swiDripsAll = cell(nCases, 1);
salinityLastTruth = cell(nCases, 1);
salinityLastDripsRaw = cell(nCases, 1);

for k = 1:nCases
    heldoutId = selectedCaseIds(k);
    pStar = errorData.Mtest(:, heldoutId);
    salinityFile = fullfile(cfg.heldoutDir, 'salinity_splits', ...
        sprintf('salinity_%02d.mat', heldoutId));
    S = load(salinityFile, 'salinity');
    salinity = S.salinity(1:(cfg.sparseTime / cfg.refineFactor):end, :, :);
    salinityFlat = flattenMatrix(salinity).';

    [XRaw, XClipped] = predict_DRIPS_case(cfg, precomp, pStar, salinityFlat);
    salinityLastDripsRaw{k} = XRaw(:, end);
    salinityLastTruth{k} = salinityFlat(:, end);

    write_case_field_figures(cfg, k, XClipped, salinityFlat);

    timeVector = (0:(size(salinityFlat, 2) - 1)) * cfg.sparseTime / 30;
    toeTruth = zeros(numel(timeVector), 1);
    toeDrips = zeros(numel(timeVector), 1);
    swiTruth = zeros(numel(timeVector), 1);
    swiDrips = zeros(numel(timeVector), 1);

    for t = 1:numel(timeVector)
        truthSnapshot = squeeze(unflattenMatrix(salinityFlat(:, t)', cfg.gridSize(1), cfg.gridSize(2)));
        dripsSnapshot = squeeze(unflattenMatrix(XClipped(:, t)', cfg.gridSize(1), cfg.gridSize(2)));
        if t > 1
            toeTruth(t) = toe_detect(truthSnapshot);
            toeDrips(t) = toe_detect(dripsSnapshot);
        end
        swiTruth(t) = swi_ratio(truthSnapshot, 10, 1);
        swiDrips(t) = swi_ratio(dripsSnapshot, 10, 1);
    end

    toeTruthAll{k} = toeTruth;
    toeDripsAll{k} = toeDrips;
    swiTruthAll{k} = swiTruth;
    swiDripsAll{k} = swiDrips;
end

write_toe_location_all_cases(cfg, caseNames, toeTruthAll, toeDripsAll);
write_swi_ratio_all_cases(cfg, swiTruthAll, swiDripsAll);
write_field_comparison_all_cases(cfg, caseNames, salinityLastTruth, salinityLastDripsRaw);
end

function write_case_field_figures(cfg, caseNumber, XClipped, salinityFlat)
fig = figure('Visible', 'off', 'Position', [100, 100, 600, 600], ...
    'PaperPositionMode', 'auto');
errorField = squeeze(unflattenMatrix(XClipped(:, end)' - salinityFlat(:, end)', ...
    cfg.gridSize(1), cfg.gridSize(2)));
imagesc(abs(errorField));
format_field_axes();
clim([0, 35]);
colormap(parula(256));
cb = colorbar;
cb.Label.String = 'Abs Salinity Error';
cb.Label.FontSize = 24;
cb.Label.FontWeight = 'bold';
cb.Label.FontName = 'Times New Roman';
xlabel('x-coordinate', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('z-coordinate', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 24, 'LineWidth', 2, 'FontName', 'Times New Roman');
axis square;
exportgraphics(fig, fullfile(cfg.figureDir, sprintf('DRIPS_error_case_%d.pdf', caseNumber)), ...
    'ContentType', 'vector', 'Resolution', 300);
close(fig);

fig = figure('Visible', 'off', 'Position', [100, 100, 600, 600], ...
    'PaperPositionMode', 'auto');
dripsField = squeeze(unflattenMatrix(XClipped(:, end)', cfg.gridSize(1), cfg.gridSize(2)));
imagesc(dripsField);
format_field_axes();
clim([0, 35]);
colormap(parula(256));
cb = colorbar;
cb.Label.String = 'Salinity';
cb.Label.FontSize = 24;
cb.Label.FontWeight = 'bold';
cb.Label.FontName = 'Times New Roman';
xlabel('x-coordinate', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('z-coordinate', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 24, 'LineWidth', 2, 'FontName', 'Times New Roman');
axis square;
exportgraphics(fig, fullfile(cfg.figureDir, sprintf('DRIPS_prediction_case_%d.pdf', caseNumber)), ...
    'ContentType', 'vector', 'Resolution', 300);
close(fig);

fig = figure('Visible', 'off', 'Position', [100, 100, 600, 600], ...
    'PaperPositionMode', 'auto');
truthField = squeeze(unflattenMatrix(salinityFlat(:, end)', cfg.gridSize(1), cfg.gridSize(2)));
imagesc(truthField);
format_field_axes();
clim([0, 35]);
colormap(parula(256));
cb = colorbar;
cb.Ticks = 0:5:35;
cb.Label.String = 'Salinity';
cb.Label.FontSize = 24;
cb.Label.FontWeight = 'bold';
cb.Label.FontName = 'Times New Roman';
xlabel('x-coordinate', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('z-coordinate', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 24, 'LineWidth', 2, 'FontName', 'Times New Roman');
axis square;
exportgraphics(fig, fullfile(cfg.figureDir, sprintf('ground_truth_case_%d.pdf', caseNumber)), ...
    'ContentType', 'vector', 'Resolution', 300);
close(fig);
end

function format_field_axes()
xlim([1, 100]);
ylim([1, 200]);
xticks([1, 50, 100]);
xticklabels({'0', '$L_x/2$', '$L_x$'});
yticks([1, 100, 200]);
yticklabels({'$L_z$', '$L_z/2$', '0'});
set(gca, 'TickLabelInterpreter', 'latex');
end

function write_toe_location_all_cases(cfg, caseNames, toeTruthAll, toeDripsAll)
fig = figure('Visible', 'off', 'Position', [100, 100, 800, 600], ...
    'PaperPositionMode', 'auto');
hold on;
nCases = numel(caseNames);
hTruth = gobjects(nCases, 1);
hDrips = gobjects(nCases, 1);
for k = 1:nCases
    tTruth = (0:(numel(toeTruthAll{k}) - 1)) * cfg.sparseTime / 30;
    tDrips = (0:(numel(toeDripsAll{k}) - 1)) * cfg.sparseTime / 30;
    hTruth(k) = plot(tTruth, toeTruthAll{k}, '-', 'LineWidth', 3);
    hDrips(k) = plot(tDrips, toeDripsAll{k}, '--', 'LineWidth', 3);
    xlim([0, 48]);
    xticks(0:12:48);
    ylim([0, 0.8]);
    yticks(0:0.2:0.8);
end
xlabel('Time (months)', 'FontSize', 28, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
ylabel('Toe location (\%)', 'FontSize', 28, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
set(gca, 'FontSize', 24, 'LineWidth', 2, 'FontName', 'Times New Roman', 'Box', 'on');
labelsTruth = cellfun(@(s) ['\ Truth, ' s], caseNames, 'UniformOutput', false);
labelsDrips = cellfun(@(s) ['\ Prediction, ' s], caseNames, 'UniformOutput', false);
lgd = legend([hTruth; hDrips], [labelsTruth(:); labelsDrips(:)], ...
    'Location', 'best', 'FontSize', 28, 'FontName', 'Times New Roman', ...
    'Interpreter', 'latex', 'Box', 'off');
lgd.NumColumns = 2;
exportgraphics(fig, fullfile(cfg.figureDir, 'DRIPS_toe_location_all_cases.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
close(fig);
end

function write_swi_ratio_all_cases(cfg, swiTruthAll, swiDripsAll)
fig = figure('Visible', 'off', 'Position', [100, 100, 800, 600], ...
    'PaperPositionMode', 'auto');
hold on;
for k = 1:numel(swiTruthAll)
    tTruth = (0:(numel(swiTruthAll{k}) - 1)) * cfg.sparseTime / 30;
    tDrips = (0:(numel(swiDripsAll{k}) - 1)) * cfg.sparseTime / 30;
    plot(tTruth, swiTruthAll{k}, '-', 'LineWidth', 3);
    plot(tDrips, swiDripsAll{k}, '--', 'LineWidth', 3);
    xlim([0, 48]);
    xticks(0:12:48);
    ylim([0, 0.3]);
    yticks(0:0.1:0.3);
end
xlabel('Time (months)', 'FontSize', 28, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
ylabel('SWI ratio (\%)', 'FontSize', 28, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
set(gca, 'FontSize', 24, 'LineWidth', 2, 'FontName', 'Times New Roman', 'Box', 'on');
legend off;
exportgraphics(fig, fullfile(cfg.figureDir, 'DRIPS_swi_ratio_all_cases.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
close(fig);
end

function write_field_comparison_all_cases(cfg, caseNames, salinityLastTruth, salinityLastDripsRaw)
nCases = numel(caseNames);
fig = figure('Visible', 'off', 'Position', [100, 100, 800, 800], ...
    'PaperPositionMode', 'auto');
layout = tiledlayout(3, nCases, 'TileSpacing', 'compact', 'Padding', 'compact');

xtk = [1, 50, 100];
xtkl = {'0', '$L_x/2$', '$L_x$'};
ytk = [1, 100, 200];
ytkl = {'$L_z$', '$L_z/2$', '0'};
axLast = gobjects(3, 1);

for k = 1:nCases
    ax = nexttile(layout, k);
    imagesc(ax, reshape(salinityLastTruth{k}, cfg.gridSize(1), cfg.gridSize(2)));
    format_comparison_axis(ax, xtk, xtkl, ytk, ytkl, k == 1, false);
    title(ax, ['Truth, ' caseNames{k}], 'FontSize', 16, 'FontWeight', 'bold', ...
        'Interpreter', 'latex');
    if k == nCases
        axLast(2) = ax;
    end

    ax = nexttile(layout, k + nCases);
    imagesc(ax, reshape(salinityLastDripsRaw{k}, cfg.gridSize(1), cfg.gridSize(2)));
    format_comparison_axis(ax, xtk, xtkl, ytk, ytkl, k == 1, false);
    title(ax, ['DRIPS, ' caseNames{k}], 'FontSize', 16, 'FontWeight', 'bold', ...
        'Interpreter', 'latex');
    if k == nCases
        axLast(1) = ax;
    end

    ax = nexttile(layout, 2*nCases + k);
    err = reshape(salinityLastDripsRaw{k} - salinityLastTruth{k}, ...
        cfg.gridSize(1), cfg.gridSize(2));
    imagesc(ax, abs(err));
    format_comparison_axis(ax, xtk, xtkl, ytk, ytkl, k == 1, true);
    title(ax, ['Abs error, ' caseNames{k}], 'FontSize', 16, 'FontWeight', 'bold', ...
        'Interpreter', 'latex');
    if k == nCases
        axLast(3) = ax;
    end
end

drawnow;
cbWidth = 0.01;
gap = 0.010;
for row = 1:3
    ax = axLast(row);
    pos = ax.Position;
    cb = colorbar(ax);
    cb.Units = 'normalized';
    cb.Position = [pos(1) + pos(3) + gap, pos(2), cbWidth, pos(4)];
    cb.Ticks = 0:5:35;
    cb.Label.FontSize = 16;
    cb.Label.FontWeight = 'bold';
    cb.Label.FontName = 'Times New Roman';
    cb.Label.Interpreter = 'latex';
    cb.LineWidth = 1.5;
    if row <= 2
        cb.Label.String = 'Salinity (ppt)';
    else
        cb.Label.String = 'Abs error (ppt)';
    end
end

exportgraphics(fig, fullfile(cfg.figureDir, 'DRIPS_vs_ground_truth_all_cases.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
close(fig);
end

function format_comparison_axis(ax, xtk, xtkl, ytk, ytkl, showYTicks, showXTicks)
xlim(ax, [1, 100]);
ylim(ax, [1, 200]);
clim(ax, [0, 35]);
colormap(ax, parula(256));
axis(ax, 'square');
set(ax, 'TickLabelInterpreter', 'latex', 'FontSize', 16, 'LineWidth', 2, ...
    'FontName', 'Times New Roman', 'Box', 'on', 'TickDir', 'out');
if showYTicks
    yticks(ax, ytk);
    yticklabels(ax, ytkl);
else
    ax.YTick = [];
end
if showXTicks
    xticks(ax, xtk);
    xticklabels(ax, xtkl);
else
    ax.XTick = [];
end
end
