function c = binary(a, b, op, varargin)
% UNARY handles unary operations
%   UNARY(M, op, ...) applies unary operator OP onto array M. OP must be given
%   as a string.
%
% binary operator may be:
%   eq ge gt ldivide le lt and or xor
%   minus mldivide mpower mrdivide mtimes ne plus power rdivide times
%   isequal
%   conv convn deconv xcorr

% This file is used by: all binary operators above

c = []; varg = {}; flag_newarray = false;
dim = []; % will use max dim

switch char(op)
case {'eq','ge','gt','ldivide','le','lt','and','or','xor',...
  'minus','mldivide','mpower','mrdivide','mtimes','ne','plus','power',...
  'rdivide','times'}
  % pure binary operators without argument, and not changing slice shape.
  
case 'isequal'
  varg = { 'SliceSize', ones(1,ndims(a)) }; % each isequal(slice) is a scalar
  op = @(s1,s2,n)feval(op, s1, s2, varargin{:}); % ignore slice index, use vector
  flag_newarray = true;

otherwise
  error([ mfilename ': ' op ' is an unsupported operator.' ]);
end

if nargout == 0 && ~flag_newarray
  arrayfun2(a,b, op, varg{:});
  c = a;
else
  c = arrayfun2(a,b, op, varg{:});
end

% ------------------------------------------------------------------------------
% copy/paste this code inside the @MappedTensor directory to generate all unary
% methods
% ------------------------------------------------------------------------------

function binary_generate()
% generate binary methods code, calling unary with arguments

ops = {'eq','ge','gt','ldivide','le','lt','and','or','xor',...
  'minus','mldivide','mpower','mrdivide','mtimes','ne','plus','power',...
  'rdivide','times','isequal'};
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
  fprintf(fid, 'function s = %s(m1, m2, varargin)\n', op);
  fprintf(fid, '%% %s\n', h); % first line of help
  fprintf(fid, '%%\n');
  fprintf(fid, '%% Example: m=%s(rand(100)); n=%s(rand(100)); ~isempty(%s(m,n))\n', ...
    'MappedTensor', 'MappedTensor', op);
  fprintf(fid, '%% See also: %s\n', op);
  fprintf(fid, '\n');
  fprintf(fid, 'if nargout\n');
  fprintf(fid, '  s = binary(m1,m2, ''%s'', ''InPLace'', false, varargin{:});\n', op);
  fprintf(fid, 'else\n');
  fprintf(fid, '  binary(m1,m2, ''%s'', varargin{:}); %% in-place operation\n', op);
  fprintf(fid, '  s = m1;\n');
  fprintf(fid, 'end\n');
  fclose(fid);
end
