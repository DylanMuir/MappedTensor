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

switch char(op)
case {'abs','acosh','acos','asinh','asin','atanh','atan','ceil','conj','cosh','cos','del2','exp',...
  'floor','imag','isfinite','isinf','isnan','log10','log','not',...
  'real','round','sign','sinh','sin','sqrt','tanh','tan','conj','uplus','uminus'}
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
  error([ mfilename ': ' op ' is an unsupported operator.' ]);
end

if nargout == 0 && ~flag_newarray
  arrayfun(a, op, dim, varg{:});
  b = a;
else
  b = arrayfun(a, op, dim, varg{:});
end

% ------------------------------------------------------------------------------
% copy/paste this code inside the @MappedTensor directory to generate all unary
% methods
% ------------------------------------------------------------------------------

function unary_generate()
% generate unary methods code, calling unary with arguments

ops = {'abs','acosh','acos','asinh','asin','atanh','atan','ceil','conj', ...
  'cosh','cos','del2','exp',...
  'floor','imag','isfinite','isinf','isnan','log10','log','not',...
  'real','round','sign','sinh','sin','sqrt','tanh','tan','conj', ...
  'del2','var','median','mean','prod','cumsum','cumprod','norm','all','any', ...
  'uminus','find','any','nonzeros'};
for index=1:numel(ops)
  op = ops{index};
  
  % if ~isempty(dir([ op '.m' ])), continue; end

  % get header
  h = help(op);
  h = textscan(h, '%s', 'Delimiter','\n\r');
  h = h{1}; % get lines;
  h = strrep(h{1}, 'vector','tensor'); % first line.

  % write m-code
  fid = fopen([ op '.m' ], 'w');
  fprintf(fid, 'function s = %s(self, varargin)\n', op);
  fprintf(fid, '%% %s\n', h); % first line of help
  fprintf(fid, '%%\n');
  fprintf(fid, '%% Example: m=%s(rand(100)); ~isempty(%s(m))\n', 'MappedTensor', op);
  fprintf(fid, '%% See also: %s\n', op);
  fprintf(fid, '\n');
  fprintf(fid, 'if nargout\n');
  fprintf(fid, '  s = unary(self, ''%s'', ''InPLace'', false, varargin{:});\n', op);
  fprintf(fid, 'else\n');
  fprintf(fid, '  unary(self, ''%s'', varargin{:}); %% in-place operation\n', op);
  fprintf(fid, '  s = self;\n');
  fprintf(fid, 'end\n');
  fclose(fid);
end
