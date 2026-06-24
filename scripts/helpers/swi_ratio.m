function ratio = swi_ratio(salinity, threshold, cellVolume)
%SWI_RATIO Fraction of cells whose salinity exceeds the threshold.

if isscalar(cellVolume)
    totalVolume = numel(salinity) * cellVolume;
    seawaterVolume = sum(salinity(:) > threshold) * cellVolume;
else
    if ~isequal(size(cellVolume), size(salinity))
        error('cellVolume must be scalar or the same size as salinity.');
    end
    seawaterVolume = sum(cellVolume(salinity > threshold), 'all');
    totalVolume = sum(cellVolume, 'all');
end

ratio = seawaterVolume / totalVolume;
end
