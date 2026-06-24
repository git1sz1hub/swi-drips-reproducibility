function [w, usedIdx] = baryWeightsIDW(pStar, pTrain, varargin)
%BARYWEIGHTSIDW Inverse-distance barycentric weights.

opt.Power = 2;
opt.Epsilon = 0;
opt.K = inf;
opt.Scale = 1;
opt.ReturnIdx = false;
opt = parse_options(opt, varargin{:});

if iscolumn(pStar)
    pStar = pStar(:).';
end
if size(pTrain, 1) == numel(pStar)
    pTrain = pTrain.';
end

[nTrain, nDim] = size(pTrain);
if numel(pStar) ~= nDim
    error('Dimension mismatch between query point and training points.');
end

if isscalar(opt.Scale)
    opt.Scale = repmat(opt.Scale, 1, nDim);
end
scale = opt.Scale(:).';

delta = pTrain - pStar;
scaled = delta .* scale;
d2 = sum(scaled.^2, 2);

tol = 1e-12;
match = d2 < tol^2;
if any(match)
    w = zeros(nTrain, 1);
    w(match) = 1 / nnz(match);
    if opt.ReturnIdx
        usedIdx = find(match);
    end
    return;
end

if opt.K < nTrain
    [~, idx] = mink(d2, opt.K);
    mask = false(nTrain, 1);
    mask(idx) = true;
else
    mask = true(nTrain, 1);
end

dEff = sqrt(d2(mask)) + opt.Epsilon;
wPart = dEff.^(-opt.Power);
wPart = wPart / sum(wPart);

w = zeros(nTrain, 1);
w(mask) = wPart;
if opt.ReturnIdx
    usedIdx = find(mask);
end
end

function opt = parse_options(opt, varargin)
if mod(numel(varargin), 2) ~= 0
    error('Options must be name/value pairs.');
end

for k = 1:2:numel(varargin)
    name = validatestring(varargin{k}, fieldnames(opt));
    opt.(name) = varargin{k + 1};
end
end
