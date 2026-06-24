function [ROB, Kr, Br] = xDMD_affine(X, Y, r)
%XDMD_AFFINE Build the affine extended DMD reduced operator.

Xtilde = [X; ones(1, size(X, 2))];
[V, Sigma, Z] = svd(Xtilde, 'econ');
V = V(:, 1:r);
Sigma = Sigma(1:r, 1:r);
Z = Z(:, 1:r);

[ROB, ~, ~] = svd(X, 'econ');
ROB = ROB(:, 1:r);

Atilde = ROB' * Y * Z / Sigma * V';
K = Atilde(:, 1:end-1);
B = Atilde(:, end);
Kr = K * ROB;
Br = B;
end
