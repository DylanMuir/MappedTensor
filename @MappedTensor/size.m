function [varargout] = size(mtVar, vnDimensions)
% SIZE   Get original tensor size, and extend dimensions if necessary
%   D = SIZE(X) gets the tensor dimension. The dimension D is a vector.
%
%   [M,N,..] = SIZE(X) returns the sizes of the first N dimensions of the
%   array X.
%
%   M = SIZE(X,DIM) returns the length of the dimension specified
%   by the scalar DIM.
%
%   Example: m=MappedTensor(eye(5)); size(m,1) == 5

  vnOriginalSize = mtVar.vnOriginalSize; %#ok<PROP>
  vnOriginalSize(end+1:numel(mtVar.vnDimensionOrder)) = 1; %#ok<PROP>

  % - Return the size of the tensor data element, permuted
  vnSize = vnOriginalSize(mtVar.vnDimensionOrder); %#ok<PROP>

  % - Return specific dimension(s)
  if nargin > 1
    if (~isnumeric(vnDimensions) || ~all(isreal(vnDimensions)))
       error('MappedTensor:dimensionMustBePositiveInteger', ...
          '*** MappedTensor: Dimensions argument must be a positive integer within indexing range.');
    end

    % - Return the specified dimension(s)
    vnSize(end+1:max(vnDimensions)) = 1;
    vnSize = vnSize(vnDimensions);
  end

  % - Handle differing number of size dimensions and number of output
  % arguments
  nNumArgout = max(1, nargout);

  if (nNumArgout == 1)
    % - Single return argument -- return entire size vector
    varargout{1} = vnSize;
    
  elseif (nNumArgout <= numel(vnSize))
    % - Several return arguments -- return single size vector elements,
    % with the remaining elements grouped in the last value
    varargout(1:nNumArgout-1) = num2cell(vnSize(1:nNumArgout-1));
    varargout{nNumArgout} = prod(vnSize(nNumArgout:end));
    
  else
    % - Output all size elements
    varargout(1:numel(vnSize)) = num2cell(vnSize);

    % - Deal out trailing dimensions as '1'
    varargout(numel(vnSize)+1:nNumArgout) = {1};
  end
end
