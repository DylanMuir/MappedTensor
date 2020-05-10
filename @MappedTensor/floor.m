function s = floor(self, varargin)
% FLOOR  Round towards minus infinity.
%
% Example: m=MappedTensor(rand(100)); ~isempty(floor(m))
% See also: floor

if nargout
  s = unary(self, 'floor', 'InPLace', false, varargin{:});
else
  unary(self, 'floor', varargin{:}); % in-place operation
  s = self;
end
