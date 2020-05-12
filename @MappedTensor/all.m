function s = all(self, varargin)
% ALL    True if all elements of a tensor are nonzero. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(all(m))
% See also: all

s = unary(self, mfilename, varargin{:}, 'InPlace', false);
