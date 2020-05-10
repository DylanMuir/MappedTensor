function s = nonzeros(self, varargin)
% NONZEROS Nonzero matrix elements.
%   NONZEROS(M) retunrs first found non-zeros elements.
%   It is not a full equivalent to Matlab NONZEROS, but allows to search for a
%   partial result.
%
% Example: m=MappedTensor(rand(100)); ~isempty(nonzeros(m))
% See also: nonzeros

if nargout
  s = unary(self, 'nonzeros', 'InPLace', false, varargin{:});
else
  unary(self, 'nonzeros', varargin{:}); % in-place operation
  s = self;
end
