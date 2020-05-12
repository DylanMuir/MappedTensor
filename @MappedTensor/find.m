function s = find(self, varargin)
% FIND   Find indices of nonzero elements. (unary op)
%   FIND(M) finds elements in the first chunk with non-zero elements.
%   It is not a full equivalent to Matlab FIND, but allows to search for a
%   partial result.
%
% Example: m=MappedTensor(rand(100)); ~isempty(find(m))
% See also: find

s = unary(self, mfilename, varargin{:}, 'InPlace', false);
