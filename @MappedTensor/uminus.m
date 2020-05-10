function s = uminus(self, varargin)
% -  Unary minus.
%
% Example: m=MappedTensor(rand(100)); ~isempty(uminus(m))
% See also: uminus

if nargout
  s = unary(self, 'uminus', 'InPLace', false, varargin{:});
else
  unary(self, 'uminus', varargin{:}); % in-place operation
  s = self;
end
