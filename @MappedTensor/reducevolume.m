function s = reducevolume(a, R)
% REDUCEVOLUME reduce an array size
%   B = REDUCEVOLUME(A, [Rx Ry Rz ... ]) reduces the number
%     of elements in the object by only keeping every Rx element in the x
%     direction, every Ry element in the y direction, and every Rz element
%     in the z direction and so on.
%     The result is a normal Matlab array.
%
%   B = REDUCEVOLUME(A, R)
%     If a scalar R is used to indicate the amount or
%     reduction instead of a vector, the reduction is assumed to
%     be R on all axes. 
%
%   B = REDUCEVOLUME(A)
%     When omitted, the volume/size reduction is performed on bigger axes until
%     the final array contains less than 1e6 elements.
%
%  Example: m=MappedTensor([500,500,500],'Format','uint8'); prod(size(reducevolume(m))) < 2e6

% rebinning object so that its number of elements is smaller 

if nargin == 1
  R = []; % will guess to reduce down to 1e6
end

% determine best reduction factor
if ischar(R) || isempty(R)
  S  = size(a);
  R  = ones(size(S));
  S0 = S;
  
  % loop until we get les than 1e6 elements
  while prod(S) > 1e6
    % identify the biggest axis, and reduce it by increasing R
    for index=1:length(R)
      [dummy, j] = sort(S);
      % S(j(end)) is the biggest element
      R(j(end)) = R(j(end))+1;
      S = S0 ./ R;
    end
  end
 
end

% scan dimensions and rebin them
S = []; S.type='()';
for index=1:length(R)
  lx=size(a,index);
  if R(index) > 1
    S.subs{index} = ceil(1:R(index):lx);
  else
    S.subs{index} = ':';
  end
end
clear x

% get sub-object
s = subsref(a, S);

