function mtVar = reshape(mtVar, varargin)
% RESHAPE Reshape array.
%   RESHAPE(X,M,N, ...) returns an N-D array with the same
%   elements as X but reshaped to have the size M-by-N-by-P-by-...
%   M*N*P*... must be the same as PROD(SIZE(X)).
%
% Example: m=MappedTensor(rand(5,10)); ~isempty(reshape(m,[10,5]))

  if nargin < 2, return; end
  % handle array of objects
  if numel(mtVar) > 1
    for index=1:numel(mtVar)
      reshape(mtVar(index),varargin{:});
    end
    return
  end

  vnNewSize = [ varargin{:} ];
  vnOldSize = size(mtVar);
  if prod(vnNewSize) ~= prod(size(mtVar))
    error([ mfilename ': reshape: number of elements [ M,N,...] must not change.' ]);
  end
  mtVar.vnOriginalSize = vnNewSize;
  
  if numel(vnNewSize) > numel(vnOldSize)
    % fill new dimensions, if any, with new DimensionOrder
    for index=(numel(vnOldSize)+1):numel(vnNewSize)
      mtVar.vnDimensionOrder(index) = index;
    end
  elseif numel(vnNewSize) < numel(vnOldSize)
    % remove some dimensions
    for index=(numel(vnNewSize)+1):numel(vnOldSize)
      mtVar.vnDimensionOrder(mtVar.vnDimensionOrder==index) = 0;
    end
    mtVar.vnDimensionOrder = nonzeros(mtVar.vnDimensionOrder);
  end
end
