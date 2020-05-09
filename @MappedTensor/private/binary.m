function c = binary(a, b, op, varargin)
% BINARY handles binary operations
%
% Operator may apply on an estruct array and:
%   a scalar
%   a vector/matrix: if its dimensionality is lower than the object,
%     it is replicated on the missing dimensions
%   a single estruct object, which is then used for each estruct array element
%     operator(a(index), b)
%   an estruct array, which should then have the same dimension as the other
%     estruct argument, in which case operator applies on pairs of both arguments.
%     operator(a(index), b(index))
%   an iFunc object (2nd arg), which is then evaluated on the estruct axes for operator
%
% binary operator may be:
%   combine conv convn deconv eq ge gt isequal ldivide le lt
%   minus mldivide mpower mrdivide mtimes ne plus power rdivide sqr times xcorr
%   and or xor
%
% Contributed code (Matlab Central):
%   genop: Douglas M. Schwarz, 13 March 2006
%
% Version: $Date$ $Version$ $Author$

% This file is used by: all binary operators above

% for the estimate of errors, we use the Gaussian error propagation (quadrature rule),
% or the simpler average error estimate (derivative).

% handle input estruct arrays

if (isa(a, 'estruct') & numel(a) > 1)
  c = [];
  if isa(b, 'estruct') & numel(b) == numel(a)
    % add element to element
    c = zeros(estruct, numel(a), 1);
    for index=1:numel(a)
      c(index) = binary(a(index), b(index), op);
    end
  elseif isempty(b)
    % process all elements from vector
    c = a(1);
    for index=2:numel(a)
      c = binary(c, a(index), op);
    end
    return
  elseif isa(b, 'estruct') & numel(b) ~= numel(a) & numel(b) ~= 1
    if a(1).verbose
      disp(...
      [ mfilename ': If you wish to force this operation, use ' op ...
        '(a,b{0}) to operate with the object Signal, not the object itself (which has axes).' ]);
      end
    error(...
    [ mfilename ': Dimension of object arrays do not match for operator ' op ...
      ': 1st is ' num2str(numel(a)) ' and 2nd is ' num2str(numel(b)) ]);
  else
    % add single element to vector
    c = zeros(estruct, numel(a), 1);
    for index=1:numel(a(:))
      c(index) = binary(a(index), b, op);
    end
  end
  if ~isempty(b)
    c = reshape(c, size(a));
  end
  return
elseif isa(b, 'estruct') & numel(b) > 1
  c = zeros(estruct, numel(b), 1);
  for index=1:numel(b)
    c(index) = binary(a, b(index), op);
  end
  return
end

if ischar(a) && (exist(a, 'file') || any(strncmp(a, {'file:/','http:/','ftp://','https:'},6)))
  a = estruct(a); % import file
end
if ischar(b) && (exist(b, 'file') || any(strncmp(b, {'file:/','http:/','ftp://','https:'},6)))
  b = estruct(b); % import file
end

% when given an iFunc, we evaluate it on the estruct axes
if isa(a,'iFunc')
  s.type = '()';
  s.subs = { a };
  a = subsref(b, s);
elseif isa(b, 'iFunc')
  s.type = '()';
  s.subs = { b };
  b = subsref(a, s);
end

if (isempty(a) || isempty(b))
  if any(strcmp(op, {'plus','minus','combine'}))
    if     isempty(a), c=b; return;
    elseif isempty(b), c=a; return; end
  else c = []; return;
  end
end

if isa(a, 'estruct')
  cmd=a.Command;
elseif isa(b, 'estruct')
  cmd=b.Command;
end

% make sure the object axes/Signal are set.
if isa(a, 'estruct') && isfield(a.Private,'cache') 
  if (isfield(a.Private.cache,'check_requested') && a.Private.cache.check_requested) ...
  || (~isfield(a.Private.cache,'size') || isempty(a.Private.cache.size))
    axescheck(a);
  end
end
if isa(b, 'estruct') && isfield(b.Private,'cache') 
  if (isfield(b.Private.cache,'check_requested') && b.Private.cache.check_requested) ...
  || (~isfield(b.Private.cache,'size') || isempty(b.Private.cache.size))
    axescheck(b);
  end
end

% handle special case of operation with transposed 1D data set and an other one
if (~isscalar(a) && isvector(a) && size(a,1)==1 && ~isscalar(b) && ~isvector(b)) || ...
   (~isscalar(b) && isvector(b) && size(b,1)==1 && ~isscalar(a) && ~isvector(a))
  transpose_ab = 1;
  a = permute(a,[ 2 1 3:length(size(a)) ]);
  b = permute(b,[ 2 1 3:length(size(b)) ]);
else
  transpose_ab = 0;
end

% detect when objects are orthogonal
sa = size(a); sb = size(b);
if     numel(sa) > numel(sb), sb=sb(1:numel(sa));
elseif numel(sb) > numel(sa), sa=sa(1:numel(sb));
end
index=find((sa == 1 & sb > 1) | (sb ==1 & sa > 1));
orthogonal_ab = (numel(index) == numel(sa));  % all orthogonal

% get Signal, Error and Monitor for 'a' and 'b'
if isa(a, 'estruct') && isa(b, 'estruct') && ~orthogonal_ab
  if strcmp(op, 'combine')
    [a,b] = union(a,b);     % perform combine on union
  else
    % compute intersection when objects are not orthogonal
    [a,b] = intersect(a,b); % perform operation on intersection
  end
end

% the p1 flag is true when a monitor normalization is required (not for combine)
if strcmp(op, 'combine'), p1 = 0; else p1 = 1; end
if ~isa(a, 'estruct')   % constant/scalar
  s1= a; e1=0; m1=0;
  c = copyobj(b);
else
  s1 = subsref(a,struct('type','.','subs','Signal'));
  e1 = subsref(a,struct('type','.','subs','Error'));
  m1 = subsref(a,struct('type','.','subs','Monitor'));
  c  = copyobj(a);
end
if ~isa(b, 'estruct') % constant/scalar
  s2= b; e2=0; m2=0;
else
  s2 = subsref(b,struct('type','.','subs','Signal'));
  e2 = subsref(b,struct('type','.','subs','Error'));
  m2 = subsref(b,struct('type','.','subs','Monitor'));
end

if numel(e1) > 1 && all(e1(:) == e1(1)), e1=e1(1); end
if numel(m1) > 1 && all(m1(:) == m1(1)), m1=m1(1); end
if numel(e2) > 1 && all(e2(:) == e2(1)), e2=e2(1); end
if numel(m2) > 1 && all(m2(:) == m2(1)), m2=m2(1); end
if all(m1(:)==0) && all(m2(:)==0), m1=0; m2=0; end

% do test on dimensionality for a vector/matrix input
% use vector duplication to fill estruct dimensionality (repmat/kron)

% the 'real' signal is 'Signal'/'Monitor', so we must perform operation on this.
% then we compute the associated error, and the final monitor
% finally we multiply the result by the monitor.

% 'y'=normalized signal, 'd'=normalized error, 'p1' set to true when normalization
% to the Monitor is required (i.e. all operations except combine).
if not(all(m1(:) == 0)) && not(all(m1(:) == 1)) && p1,
  y1 = genop(@rdivide, s1, m1); d1 = genop(@rdivide,e1,m1);
else y1=s1; d1=e1; end
if not(all(m2(:) == 0)) && not(all(m2(:) == 1)) && p1,
  y2 = genop(@rdivide,s2,m2); d2 = genop(@rdivide,e2,m2);
else y2=s2; d2=e2; end

% operation ============================================================
switch op
case {'plus','minus','combine'}
  if strcmp(op, 'combine'),
       s3 = genop( @plus,  y1, y2); % @plus without Monitor nomalization (y=s)
       if isscalar(m1), m1=m1*ones(size(s1)); end
       if isscalar(m2), m2=m2*ones(size(s2)); end
  else s3 = genop( op,     y1, y2); end
  i1 = isnan(y1(:)); i2=isnan(y2(:));
  % if NaN's are found (from interp), use non NaN values in the other data set
  if any(i1) && ~isscalar(y2), s3(i1) = y2(i1); end
  if any(i2) && ~isscalar(y1), s3(i2) = y1(i2); end

  try
    e3 = sqrt(genop(@plus, d1.^2,d2.^2));
    if any(i1) && numel(i1) <= numel(e2), e3(i1) = e2(i1); end
    if any(i2) && numel(i2) <= numel(e1), e3(i2) = e1(i2); end
  catch
    e3 = [];  % set to sqrt(Signal) (default)
  end

  if     all(m1==0), m3 = m2;
  elseif all(m2==0), m3 = m1;
  else
    try
      m3 = genop(@plus, m1, m2);
      if any(i1) && numel(i1) <= numel(m2), m3(i1) = m2(i1); end
      if any(i2) && numel(i2) <= numel(m1), m3(i2) = m1(i2); end
    catch
      m3 = [];  % set to 1 (default)
    end
  end
  clear i1 i2

case {'times','rdivide', 'ldivide','mtimes','mrdivide','mldivide','conv','convn','xcorr','deconv'}
  % Signal
  if strcmp(op, 'conv') || strcmp(op, 'deconv') || strcmp(op, 'xcorr')
    s3 = fconv(y1, y2, varargin{:});  % pass additional arguments to fconv
    if nargin >= 4
      if strfind(varargin{1}, 'norm')
        m2 = 0;
      end
    end
  else
    s3 = genop(op, y1, y2);
  end

  % Error = s3*sqrt(e1/s1^2+e2/s2^2)
  % when e.g. s1 is scalar, e1 is 0 then s3=s1*s2, and the e3 error should just be s1*e2
  try
    if all(s1(:)==0) e1s1=0; else e1s1 = genop(@rdivide,e1,s1).^2; e1s1(find(s1 == 0)) = 0; end
    if all(s2(:)==0) e2s2=0; else e2s2 = genop(@rdivide,e2,s2).^2; e2s2(find(s2 == 0)) = 0; end
    e3 = genop(@times, sqrt(genop(@plus, e1s1, e2s2)), s3);
  catch
    e3=[];  % set to sqrt(Signal) (default)
  end

  % Monitor
  if     all(m1==0), m3 = m2;
  elseif all(m2==0), m3 = m1;
  elseif p1
    try
      m3 = genop(@times, m1, m2);
    catch
      m3 = [];  % set to 1 (default)
    end
  else m3=get(c,'Monitor'); end

case {'power','mpower'}
  s3 = genop(op, y1, y2);

  try
    e2logs1 = genop(@times, e2, log(s1)); e2logs1(find(s1<=0))   = 0;
    s2e1_s1 = genop(@times, s2, genop(@rdivide,e1,s1));  s2e1_s1(find(s1 == 0)) = 0;
    e3 = s3.*genop(@plus, s2e1_s1, e2logs1);
  catch
    e3 = [];  % set to sqrt(Signal) (default)
  end

  if     all(m1==0), m3 = m2;
  elseif all(m2==0), m3 = m1;
  elseif p1
    try
      m3 = genop(@times, m1, m2);
    catch
      m3 = [];  % set to 1 (default)
    end
  else m3=get(c,'Monitor'); end

case {'lt', 'gt', 'le', 'ge', 'ne', 'eq', 'and', 'or', 'xor' }
  s3 = logical(genop(op, y1, y2));
  try
    e3 = sqrt(genop( op, d1.^2, d2.^2));
    e3 = 2*genop(@divide, e3, genop(@plus, y1, y2)); % normalize error to mean signal
  catch
    e3=0; % no error
  end
  m3 = ones(size(get(c, 'Monitor'))); % set to 1 (default)
  if numel(m3) > 1 && all(m3(:) == m3(1)), m3=1; end
case {'isequal','isequaln','isequalwithequalnans'}
  c = logical(feval(op, y1, y2));
  return
otherwise
  if isa(a,'estruct'), al=a.Tag; else al=num2str(a); end
  if isa(b,'estruct'), bl=b.Tag; else bl=num2str(b); end
  error([ mfilenale ': Can not apply operation ' op ' on objects ' al ' and ' bl '.' ]);
end

clear e1 e2 m1 m2 y1 y2

% set Signal label
s1=s1(1:min(10, numel(s1)));
if isa(a, 'estruct'), al = label(a,'0');
else
  al=num2str(s1(:)'); if length(al) > 10, al=[ al(1:10) '...' ]; end
end
s2=s2(1:min(10, numel(s2)));
if isa(b, 'estruct'), bl = label(b,'0');
else
  bl=num2str(s2(:)');
  if length(bl) > 10, bl=[ bl(1:10) '...' ]; end
end
clear s1 s2

% ensure that Monitor and Error have the right dimensions
if numel(e3) > 1 && numel(e3) ~= numel(s3)
  e3 = genop(@times, e3, ones(size(s3)));
end
if numel(m3) > 1 && numel(m3) ~= numel(s3)
  m3 = genop(@times, m3, ones(size(s3)));
end

% handle special case of operation with transposed 1D data set and an other one
if transpose_ab==1
  s3 = permute(s3,[ 2 1 3:length(size(s3)) ]);
  e3 = permute(e3,[ 2 1 3:length(size(e3)) ]);
  m3 = permute(m3,[ 2 1 3:length(size(m3)) ]);
end

% operate with Signal/Monitor and Error/Monitor (back to Monitor data)
if not(all(m3(:) == 0 | m3(:) == 1)) & p1,
  s3 = genop(@times, s3, m3); e3 = genop(@times,e3,m3);
end

% update object (store result)
c  = set(c, 'Signal', s3);
label(c, 'Signal', [  op '(' al ',' bl ')' ]);
clear s3
e3=abs(e3);
c  = set(c, 'Error', abs(e3));
clear e3
c  = set(c, 'Monitor', m3);
clear m3

% fill missing axes when objects are orthogonal
if isa(a, 'estruct') && isa(b, 'estruct') && orthogonal_ab
  index_b=1;
  ax = getaxis(c);
  for index=1:ndims(c)
    if isempty(getaxis(c, num2str(index)))
      x       = getaxis(b, index_b);           % axis value
      xd      = getaxis(b, num2str(index_b));  % get the axis definition
      % must make sure we do not overwrite an existing axis name
      if any(strcmp(xd, ax)), xd = sprintf('Axis_%i', index); end
      if any(strcmp(xd, ax)), xd = sprintf('axis_%i', index); end
      if any(strcmp(xd, ax)), xd = sprintf('%s_%i', op, index); end
      index_b = index_b+1;
      if ~isempty(xd) && ischar(xd)
        c=setalias(c, xd, x);
        c=setaxis(c, index, xd);
      else
        c=setaxis(c, index, x);
      end
    end
  end
end

c.Command=cmd;
history(c, op, a,b);
