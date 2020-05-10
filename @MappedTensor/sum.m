function [tFinalSum] = sum(mtVar, varargin)
% SUM Sum of elements.
%   S = SUM(M) sums M along first dimension. 
%
%   S = SUM(M, DIM) sums M along the dimension DIM. 
%
%   S = SUM(..., 'double) accumulate S in double and S has class double, 
%   even if X is single. This is the default.
%
%   S = SUM(..., 'native) accumulate S natively and S has the same class
%   as M.

   % - Get tensor size
   vnTensorSize = size(mtVar);
   
   % - By default, sum along first non-singleton dimension
   DEF_nDim = find(vnTensorSize > 1, 1, 'first');
   
   % - By default, accumulate in a double tensor
   DEF_strReturnClass = 'double';
   
   % - Check arguments and apply defaults
   if (nargin > 3)
      error('MappedTensor:sum:InvalidArguments', ...
         '*** MappedTensor/sum: Too many arguments were supplied.');
   
   elseif (nargin == 3)

   elseif (nargin == 2)
      if (ischar(varargin{1}))
         varargin{2} = varargin{1};
         varargin{1} = DEF_nDim;
                     
      else
         varargin{2} = DEF_strReturnClass;
      end
   
   elseif (nargin == 1)
      varargin{1} = DEF_nDim;
      varargin{2} = DEF_strReturnClass;
   end
   
   % - Was a valid dimension specified?
   try
      validateattributes(varargin{1}, {'numeric'}, {'positive', 'integer', 'scalar'});
   catch
      error('MappedTensor:sum:InvalidArguments', ...
         '*** MappedTensor/sum: ''dim'' must be supplied as a positive scalar number.');
   end
   nDim = varargin{1};
   
   % - Was a valid output argument type specified?
   try
      strReturnClass = validatestring(lower(varargin{2}), {'native', 'double', 'default'});
   catch
      error('MappedTensor:sum:InvalidArguments', ...
         '*** MappedTensor/sum: ''outtype'' must be one of {''double'', ''native'', ''default''}.');
   end

   % - Get the class for the summation matrix
   if (strcmp(strReturnClass, 'native'))
      % - Logicals are always summed in a double tensor
      if (islogical(mtVar))
         strOutputClass = 'double';
      else
         strOutputClass = mtVar.Format;
      end
   
   elseif (strcmp(strReturnClass, 'default'))
      strOutputClass = DEF_strReturnClass;
      
   else %if (strcmp(strReturnClass, 'double'))
      strOutputClass = strReturnClass;
   end
   
   % -- Sum in chunks to avoid allocating full tensor
   nElementsInChunk = 100000;
   vnSumSize = vnTensorSize;
   vnSumSize(nDim) = 1;
   vnSliceDimensions = cumprod(vnTensorSize);
   
   % - Compute the size of a single split
   vnSingleSplitSize = ceil(vnTensorSize ./ ceil(vnSliceDimensions ./ nElementsInChunk));
   
   % - Make vectors of split indices
   cellSplitIndices = cell(1, numel(vnTensorSize));
   for (nDimIndex = 1:numel(vnTensorSize)); %#ok<FORPF>
      vnStarts = 1:vnSingleSplitSize(nDimIndex):vnTensorSize(nDimIndex);
      vnEnds = [vnStarts(2:end)-1 vnTensorSize(nDimIndex)];
      vnNumDivisions(nDimIndex) = numel(vnStarts); %#ok<AGROW>
      
      for (nDivIndex = 1:vnNumDivisions(nDimIndex))
         cellSplitIndices{nDimIndex}{nDivIndex} = vnStarts(nDivIndex):vnEnds(nDivIndex);
      end
   end
   
   % -- Perform sum by taking dimensions in turn
   tFinalSum = zeros(vnSumSize, strOutputClass);
   
   % - Construct referencing structures
   sSourceRef = substruct('()', ':');
   sDestRef = substruct('()', ':');
   
   vnSplitIndices = ones(1, numel(vnTensorSize));
   cellTheseSourceIndices = cell(1, numel(vnTensorSize));
   bContinue = true;
   while (bContinue)
      % - Find what the indices for the current chunk should be
      for (nDimIndex = 1:numel(vnTensorSize)) %#ok<FORPF>
         cellTheseSourceIndices{nDimIndex} = cellSplitIndices{nDimIndex}{vnSplitIndices(nDimIndex)};
      end
      cellTheseDestIndices = cellTheseSourceIndices;
      cellTheseDestIndices{nDim} = 1;
      
      % - Call subsasgn, subsref and sum to process data
      sSourceRef.subs = cellTheseSourceIndices;
      sDestRef.subs = cellTheseDestIndices;
      tFinalSum = subsasgn(tFinalSum, sDestRef, subsref(tFinalSum, sDestRef) + sum(subsref(mtVar, sSourceRef), nDim, strReturnClass));
      
      % - Increment first non-max index
      nIncrementDim = find(vnSplitIndices <= vnNumDivisions, 1, 'first');
      
      % - Increment and roll-over indices, if required
      while (bContinue)
         % - Increment the index
         vnSplitIndices(nIncrementDim) = vnSplitIndices(nIncrementDim) + 1;
         
         if (vnSplitIndices(nIncrementDim) > vnNumDivisions(nIncrementDim))
            % - We need to roll-over this index, and increment the next
            vnSplitIndices(nIncrementDim) = 1;
            nIncrementDim = nIncrementDim + 1;
            
            % - Did we roll-over the last index?
            if (nIncrementDim > numel(vnNumDivisions))
               bContinue = false;
            end
            
         else
            % - We didn't need to roll over the index, so continue with
            % the new indices
            break;
         end
      end
      
   end
end
