function s = round(self, varargin)
% ROUND  Round towards nearest integer.
%
% Example: m=MappedTensor(rand(100)); ~isempty(round(m))
% See also: round

if nargout
  s = unary(self, 'round', 'InPLace', false, varargin{:});
else
  unary(self, 'round', varargin{:}); % in-place operation
  s = self;
end
