function s = nonzeros(self, varargin)
% NONZEROS Nonzero matrix elements. (unary op)
%   NONZEROS(M) returns first found non-zeros elements.
%   It is not a full equivalent to Matlab NONZEROS, but allows to search for a
%   partial result.
%
% Example: m=MappedTensor(rand(100)); ~isempty(nonzeros(m))
% See also: nonzeros

s = unary(self, mfilename, varargin{:}, 'InPlace', false);
