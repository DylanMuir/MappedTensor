function s = not(self, varargin)
% ~   Logical NOT.
%
% Example: m=MappedTensor(rand(100)); ~isempty(not(m))
% See also: not

if nargout
  s = unary(self, 'not', 'InPLace', false, varargin{:});
else
  unary(self, 'not', varargin{:}); % in-place operation
  s = self;
end
