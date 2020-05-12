function s = any(self, varargin)
% ANY    True if any element of a tensor is a nonzero number or is (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(any(m))
% See also: any

s = unary(self, mfilename, varargin{:}, 'InPlace', false);
