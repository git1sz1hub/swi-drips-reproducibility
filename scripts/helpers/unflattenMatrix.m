function mat = unflattenMatrix(flatMat, nRows, nCols)
%UNFLATTENMATRIX Reshape a flattened field back to nRows-by-nCols.

[~, nFlat] = size(flatMat);
if nFlat ~= nRows * nCols
    error('The second dimension of flatMat must equal nRows * nCols.');
end

mat = reshape(flatMat, [], nRows, nCols);
end
