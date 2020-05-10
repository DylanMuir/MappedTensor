function s = atan(self, varargin)
% ATAN   Inverse tangent, result in radians.
%
% Example: m=MappedTensor(rand(100)); ~isempty(atan(m))
% See also: atan

if nargout
  s = unary(self, 'atan', 'InPLace', false, varargin{:});
else
  unary(self, 'atan', varargin{:}); % in-place operation
  s = self;
end
