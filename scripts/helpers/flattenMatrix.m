function flatMat = flattenMatrix(mat)
%FLATTENMATRIX Flatten a time-by-z-by-x salinity array into time-by-space.

dims = size(mat);
if numel(dims) ~= 3
    error('Input must be a 3D matrix.');
end

flatMat = reshape(mat, dims(1), dims(2) * dims(3));
end
