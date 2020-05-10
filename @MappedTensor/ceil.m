function s = ceil(self, varargin)
% CEIL   Round towards plus infinity.
%
% Example: m=MappedTensor(rand(100)); ~isempty(ceil(m))
% See also: ceil

if nargout
  s = unary(self, 'ceil', 'InPLace', false, varargin{:});
else
  unary(self, 'ceil', varargin{:}); % in-place operation
  s = self;
end
