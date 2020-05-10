function s = find(self, varargin)
% FIND   Find indices of nonzero elements.
%   FIND(M) finds elements in the first chunk with non-zero elements.
%   It is not a full equivalent to Matlab FIND, but allows to search for a
%   partial result.
%
% Example: m=MappedTensor(rand(100)); ~isempty(find(m))
% See also: find

if nargout
  s = unary(self, 'find', 'InPLace', false, varargin{:});
else
  unary(self, 'find', varargin{:}); % in-place operation
  s = self;
end
