function [tfMax, tnMaxIndices] = min(mtVar, varargin)
% MIN    Smallest component.
%   MIN(X) is a row vector containing the minimum element along the first
%   non-singleton dimension.
%
%   [Y,I] = MIN(X) returns the indices of the minimum values in vector I.
%
%   MIN(X,Y) returns an array the same size as X and Y with the
%   smallest elements taken from X or Y. Either one can be a scalar.
%
%   [Y,I] = MIN(X,[],DIM) operates along the dimension DIM.
%
% Example: m=MappedTensor(eye(5)); all(min(m) == 0)

  % - Check arguments
  if (nargin > 3)
    error('MappedTensor:min:InvalidArguments', ...
          '*** MappedTensor/min: Too many arguments were provided.');
  end

  % - Record stack size
  vnSize = size(mtVar);

  % - Which dimension should we go along?
  if (nargin < 3)
    % - Find the first non-singleton dimension
    [nul, nDim] = find(vnSize > 1, 1, 'first'); %#ok<ASGLU>
  else
    nDim = varargin{2};
  end

  % - What sort of "min" are we performing?
  if ((nargin == 1) || isempty(varargin{1}))
    [tfMax, tnMaxIndices] = compare_single_tensor(mtVar, nDim, @min);
    
  else
    % - One tensor and another scalar or tensor
    [tfMax, tnMaxIndices] = compare_dual_tensor(mtVar, varargin{1}, nDim, @min);
  end
end
