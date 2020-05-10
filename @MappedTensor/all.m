function s = all(self, varargin)
% ALL    True if all elements of a tensor are nonzero.
%
% Example: m=MappedTensor(rand(100)); ~isempty(all(m))
% See also: all

if nargout
  s = unary(self, 'all', 'InPLace', false, varargin{:});
else
  unary(self, 'all', varargin{:}); % in-place operation
  s = self;
end
