function [mtNewVar] = arrayfun2(mtVar1, mtVar2, fhFunction, varargin) 
  % ARRAYFUN2 Apply a function on two similar arrays, in slices.
  %   ARRAYFUN2(M1, M2, FUN, ...) applies the function specified by FUN.
  %   Each slice is passed individually to FUN, along with the slice index and
  %   any trailing arguments (...).
  %   The major advantage of ARRAYFUN2 is a reduced memory usage.
  %   Without output argument, the initial array is updated with the new value.
  %   ARRAYFUN2 works both with M being a single array, but also with M given as
  %   a vector of arrays [ M1 M2...].
  %
  %   The function FUN syntax is:
  %
  %     FUN(slice1, slice2, N, ....) where slice is the current slice cut along
  %     dimension DIM, N is the slice index, and additional arguments
  %     can be given. It is recommended to use function handles for FUN.
  %
  %   ARRAYFUN2(M1, M2, FUN, DIM) applies the function specified by FUN along 
  %   the specified dimension DIM.  An empty DIM will guess the optimal
  %   for performance.
  %
  %   P = ARRAYFUN2(...) returns the result in a new object P (instead of
  %   updating the original array M1).
  %
  %   ARRAYFUN2(M1, M2, FUN, ..., 'Param1', val1, ...) enables you to
  %   specify optional parameter name/value pairs.  Parameters are:
  %
  %     'SliceSize' -- a size vector [d1 d2 ...] indicating the new size
  %     of the slice after applying FUN. In that case, a new array
  %     P will be generated, with the same length as M along DIM, but a
  %     new size [d1 d2 ...] along the other dimensions.
  %
  %     'Dimension' -- an integer scalar equivalent to specifying DIM.
  %
  %     'Verbose' -- a logical, being True to display operation progress.
  %
  %     'EarlyReturn' -- a logical, being True returns prematurely with first
  %     non empty chunk result. The result is a normal Matlab array.
  %
  %     'InPlace' -- a logical, being True when operation is carried-out in
  %     place. The result is stored in the initial array (when possible).
  %     Default is true.
  %
  %   Examples:
  %   =========
  %
  %     arrayfun2(M1, M2, @plus);
  %       each slice of the third dimension of M1 ans M2, taken in turn, are 
  %       passed to @plus and the result is stored back into initial array.
  %       If no output argument is specified, the initial array is updated.
  %
  %     P = arrayfun2(M1, M2, @plus);
  %       same as above, but generates a new array.
  %
  % Example: m=MappedTensor(rand(100)); arrayfun2(m,m,'times')

  % handle array of objects
  mt = 0;
  if     isa(mtVar1, 'MappedTensor') && numel(mtVar1) > 1, mt=1;
  elseif isa(mtVar2, 'MappedTensor') && numel(mtVar2) > 1, mt=2; end
  
  if mt

    if mt==1; n=numel(mtVar1);
    else      n=numel(mtVar2); end
    mtNewVar = [];
    for index=1:n
      if mt==1, this = arrayfun2(mtVar1(index), mtVar2,        fhFunction, varargin{:});
      else      this = arrayfun2(mtVar1,        mtVar2(index), fhFunction, varargin{:});
      end
      if isa(this, 'MappedTensor')
        if isempty(mtNewVar), mtNewVar = this;
        else mtNewVar = [ mtNewVar this ]; end
      else
        if isempty(mtNewVar), mtNewVar = { this };
        else                  mtNewVar{end+1} = this;
        end
      end
    end
    return
  end

  % - Get tensor size
  if isa(mtVar1, 'MappedTensor') mtVar = mtVar1;
  else                           mtVar = mtVar2; end

  % defaults
  nSliceDim = []; vnSliceSize = []; bVerbose = false;
  bEarlyReturn = false; bInPlace = (nargout == 0);

  % - Shall we generate a new tensor?
  bNewTensor = false;

  % parse input arguments (nSliceDim, vnSliceSize, ...)
  toremove = []; firstnumeric = false;
  for index=1:numel(varargin)
    if ~firstnumeric && isnumeric(varargin{index}) && numel(varargin{index}) <= 1
     nSliceDim = varargin{index}; firstnumeric = true;
     toremove(end+1) = index; 
    elseif ischar(varargin{index}) && index < numel(varargin)
      switch(lower(varargin{index}))
      case 'dimension'
        nSliceDim = varargin{index+1};
        toremove = [ toremove index index+1 ];
      case 'slicesize'
        vnSliceSize = varargin{index+1};
        toremove = [ toremove index index+1 ];
      case 'verbose'
        bVerbose = varargin{index+1};
        toremove = [ toremove index index+1 ];
      case 'inplace'
        bInPlace = varargin{index+1};
        toremove = [ toremove index index+1 ];
      case 'earlyreturn'
        bEarlyReturn = varargin{index+1};
        toremove     = [ toremove index index+1 ];
        bNewTensor   = true;
      end
    end
  end
  varargin(toremove) = [];
  
  vnTensorSize = size(mtVar);
  % OK when: sizes do match, or one is scalar
  if ~isscalar(mtVar1) && ~isscalar(mtVar2) ...
    && (length(size(mtVar1)) ~= length(size(mtVar2)) || ~all(vnTensorSize == size(mtVar2)))
    error('MappedTensor:sizemismatch', ...
          '*** MappedTensor: arrayfun2: size of the two arrays do not match (or one must be scalar).');
  end

  if isempty(nSliceDim)
    % we search for the last dimension, for which the lower chunk dimensions fit
    % in 1/4-th of free memory
    [~,~,sys] = version(mtVar);
    max_sz = sys.free/4*1024; % in B
    for d=ndims(mtVar):-1:1
      sz = size(mtVar);
      sz(d) = [];
      if prod(sz)*(mtVar.nNumElements * mtVar.nClassSize + mtVar.Offset) <= max_sz
        nSliceDim = d; break;
      end
    end
    if isempty(nSliceDim)
      nSliceDim = length(vnTensorSize); % use last dimension
    end
    if bVerbose
      fprintf(1, 'MappedTensor/arrayfun2: Using Dimension=%i\n', nSliceDim);
    end
  end

  % - Check slice dimension
  if ((nSliceDim < 1) || (nSliceDim > numel(vnTensorSize)))
    error('MappedTensor:badsubscript', ...
          '*** MappedTensor: arrayfun2: Index exceeds matrix dimensions.');
  end

  % - Was the slice size explicitly provided?
  if isempty(vnSliceSize)
    vnSliceSize = vnTensorSize;
    vnSliceSize(nSliceDim) = 1;

  elseif (~isequal(vnSliceSize([1:nSliceDim-1 nSliceDim+1:end]), vnTensorSize([1:nSliceDim-1 nSliceDim+1:end])))
    % - The slice size is different than the tensor size, so we have to
    % generate a new tensor
    bNewTensor = true;
    
    % - Display a warning if the output of this command is likely to be
    % lost
    if bInPlace
       warning('MappedTensor:LostSliceOutput', ...
          'MappedTensor: arrayfun2: The output of a arrayfun2 command is likely to be thrown away...');
    end
  end

  % - If an explicit return argument is requested, construct a new tensor
  if ~bInPlace
    bNewTensor = true;
  end

  % - Shall we create a new return variable?
  if (~bEarlyReturn && bNewTensor)
    vnNewTensorSize = vnSliceSize;
    vnNewTensorSize(nSliceDim) = vnTensorSize(nSliceDim);

    mtNewVar = MappedTensor(vnNewTensorSize, 'Class', mtVar.Format);
    
  elseif bEarlyReturn
    mtNewVar = [];
  else
    % - Store the result back in the original tensor, taking advantage
    % of the handle property of a MappedTensor
    mtNewVar = mtVar;
    
    vnNewTensorSize = size(mtVar1);
    
    % - Are we attempting to re-size the tensor?
    if (~isequal(vnSliceSize([1:nSliceDim-1 nSliceDim+1:end]), vnTensorSize([1:nSliceDim-1 nSliceDim+1:end])))
       error('MappedTensor:IncorrectSliceDimensions', ...
          '*** MappedTensor/arrayfun2: A tensor cannot be resized during a slice operation.\n       Assign the output to a new tensor.');
    end
  end

  % - Create a referencing window
  cvColons = repmat({':'}, 1, numel(vnTensorSize));
  cvColons{nSliceDim} = 1;
  [vnLinearSourceWindow, vnSourceDataSize] = ConvertColonsCheckLims(cvColons, vnTensorSize, mtVar.hRepSumFunc);

  cvTest = repmat({1}, 1, numel(vnTensorSize));
  cvTest{nSliceDim} = 2;
  nTestIndex = ConvertColonsCheckLims(cvTest, vnTensorSize, mtVar.hRepSumFunc);
  nSourceWindowStep = nTestIndex - vnLinearSourceWindow(1);

  % - Split source window into readable chunks
  mnSourceChunkIndices = SplitFileChunks(vnLinearSourceWindow, mtVar.hChunkLengthFunc);

  if ~bEarlyReturn
    if (bNewTensor)
      cvColons = repmat({':'}, 1, numel(vnNewTensorSize));
      cvColons{nSliceDim} = 1;
      [vnLinearDestWindow, vnDestDataSize] = ConvertColonsCheckLims(cvColons, vnNewTensorSize, mtVar.hRepSumFunc);
      
      cvTest = repmat({1}, 1, numel(vnTensorSize));
      cvTest{nSliceDim} = 2;
      nTestIndex = ConvertColonsCheckLims(cvTest, vnNewTensorSize, mtVar.hRepSumFunc);
      nDestWindowStep = nTestIndex - vnLinearDestWindow(1);
      
      % - Split into readable chunks
      mnDestChunkIndices = SplitFileChunks(vnLinearDestWindow, mtVar.hChunkLengthFunc);
    else
      mnDestChunkIndices = mnSourceChunkIndices;
      nDestWindowStep = nSourceWindowStep;
      vnDestDataSize = vnSourceDataSize;
    end
  end

  % - Slice up along specified dimension
  if bVerbose
    fprintf(1, 'MappedTensor/arrayfun2: [%6.2f%%]', 0);
  end
  
  for (nIndex = 1:vnTensorSize(nSliceDim))
    % - Get chunks for this indexing window
    mnTheseSourceChunks = bsxfun(@plus, mnSourceChunkIndices, [(nIndex-1) * nSourceWindowStep 0 0]);
    if ~bEarlyReturn
      mnTheseDestChunks = bsxfun(@plus, mnDestChunkIndices, [(nIndex-1) * nDestWindowStep 0 0]);
    end
    
    % read mtVar1 data
    tData1 = arrayfun2_read_data(mtVar1, mnTheseSourceChunks, vnSourceDataSize);
    tData2 = arrayfun2_read_data(mtVar2, mnTheseSourceChunks, vnSourceDataSize);
     
    % - Call function
    if (nargin(fhFunction) > 2)
      tData1 = feval(fhFunction,tData1, tData2, nIndex, varargin{:});
    else
      tData1 = feval(fhFunction,tData1, tData2, varargin{:});
    end

    % handle early return with single chunk
    if bEarlyReturn
      if ~isempty(tData1) && any(tData1)
        mtNewVar = tData1;
        return;
      else
        continue;
      end
    end

    % - Write results
    if (~isreal(tData1))
      if (~mtNewVar.bIsComplex)
         make_complex(mtNewVar);
      end
         
      % - Write real and complex parts
      mtVar.hShimFunc('write_chunks', mtNewVar.hRealContent, mnTheseDestChunks, ...
        1:numel(tData1), vnDestDataSize, mtNewVar.Format, mtNewVar.Offset, ...
        real(tData1) ./ mtVar.fRealFactor, mtVar.bBigEndian);
      mtVar.hShimFunc('write_chunks', mtNewVar.hCmplxContent, mnTheseDestChunks, ...
        1:numel(tData1), vnDestDataSize, mtNewVar.Format, mtNewVar.Offset, ...
        imag(tData1) ./ mtVar.fComplexFactor, mtVar.bBigEndian);
    else
      % - Write real part
      mtVar.hShimFunc('write_chunks', mtNewVar.hRealContent, mnTheseDestChunks, 1:numel(tData1), vnDestDataSize, mtNewVar.Format, mtNewVar.Offset, tData1 ./ mtVar.fRealFactor, mtVar.bBigEndian);
    end

    if bVerbose
      fprintf(1, '\b\b\b\b\b\b\b\b%6.2f%%]', nIndex / vnTensorSize(nSliceDim) * 100);
    end
  end
  if bVerbose
   fprintf(1, '\b\b\b\b\b\b\b\b%6.2f%%]\n', 100);
  end
end

% ------------------------------------------------------------------------------
function tData = arrayfun2_read_data(mtVar, mnTheseSourceChunks, vnSourceDataSize)
  % read a chunk of data in mtVar

  if ~isa(mtVar, 'MappedTensor'), tData = mtVar; return; end

  % - Read source data, multiply by real factor
  tData = mtVar.hShimFunc('read_chunks', mtVar.hRealContent, mnTheseSourceChunks, ...
    1:prod(vnSourceDataSize), 1:prod(vnSourceDataSize), vnSourceDataSize, ...
    mtVar.Format, mtVar.Offset, mtVar.bBigEndian);
  tData = tData .* mtVar.fRealFactor;

  % - Read complex part, if it exists
  if (mtVar.bIsComplex)
    tDataCmplx = mtVar.hShimFunc('read_chunks', mtVar.hCmplxContent, ...
      mnTheseSourceChunks, 1:prod(vnSourceDataSize), 1:prod(vnSourceDataSize), ...
      vnSourceDataSize, mtVar.Format, mtVar.Offset, mtVar.bBigEndian);
    tData = complex(tData, tDataCmplx .* mtVar.fComplexFactor);
  end

  % - Reshape source data
  tData = reshape(tData, vnSourceDataSize);
end
