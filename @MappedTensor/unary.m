function b = unary(a, op, varargin)
% UNARY handles unary operations
%   UNARY(M, op, ...) applies unary operator OP onto array M. OP must be given
%   as a string.
%
% Operations that keep data order:
%   abs acosh acos asinh asin atanh atan ceil conj cosh cos del2 exp
%   floor imag isfinite isinf isnan log10 log not 
%   real round sign sinh sin sqrt tanh tan all any nonzeros conj
%
% Operations that return a different data:
%   norm sum mean var median prod all min max
%   find any nonzeros (partial result)

b = []; varg = {}; flag_newarray = false;
dim = []; % will use max dim

switch op
case {'abs','acosh','acos','asinh','asin','atanh','atan','ceil','conj','cosh','cos','del2','exp',...
  'floor','imag','isfinite','isinf','isnan','log10','log','not',...
  'real','round','sign','sinh','sin','sqrt','tanh','tan','conj'}
  % pure unary operators without argument, and not changing slice shape.
case 'del2'
  % DEL2 Discrete Laplacian, with prefactor
  op = @(s)del2(s)*2*ndims(a);
case {'min','max'}
  if ~isempty(varargin)
    dim2 = varargin{1}; % must not be same as the arrayfun dim
  else
    dim2 = 1;
  end
  % get arrayfun dim (largest) and slice dimension
  sz  = size(a);
  sz0 = sz; sz0(dim2) = 0; [~,dim] = max(sz0); sz0(dim2) = 1;
  varg = { 'SliceSize', sz0 };
  op = @(s,n)feval(op, s, [], dim2); % ignore slice index
  flag_newarray = true;
case {'sum','var','median','mean','prod','cumsum','cumprod'}
  if ~isempty(varargin)
    dim2 = varargin{1}; % must not be same as the arrayfun dim
  else
    dim2 = 1;
  end
  % get arrayfun dim (largest) and slice dimension
  sz  = size(a);
  sz0 = sz; sz0(dim2) = 0; [~,dim] = max(sz0); sz0(dim2) = 1;
  varg = { 'SliceSize', sz0 };
  op = @(s,n)feval(op, s, dim2); % ignore slice index
  flag_newarray = true;
case 'norm'
  varg = { 'SliceSize', ones(1,ndims(a)) }; % each norm(slice) is a scalar
  op = @(s,n)feval(op, s(:), varargin{:}); % ignore slice index, use vector
  flag_newarray = true;
  % TODO: merge all norms ??
case 'all'
  % all requires to test the whole tensor.
  % any could be restricted to test until true and then break.
  varg = { 'SliceSize', ones(1,ndims(a)) }; % each all(slice) is a single scalar
  op = @(s,n)feval(op, s(:));
  flag_newarray = true;
case {'find','any','nonzeros'}
  varg = { 'EarlyReturn',true };
  flag_newarray = true;
otherwise
  error([ mfilename ': unary: ' op ' is an unsupported operator.' ]);
end

if nargout == 0 && ~flag_newarray
  arrayfun(a, op, dim, varg{:});
  b = a;
else
  b = arrayfun(a, op, dim, varg{:});
end

