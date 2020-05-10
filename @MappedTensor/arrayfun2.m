function [mtNewVar] = arrayfun2(mtVar1, mtVar2, fhFunction, varargin) 
  % ARRAYFUN2 Apply a function on two similar arrays, in slices.
  %   ARRAYFUN2(M1, M2, FUN, ...) applies the function specified by FUN along the
  %   array M1 largest dimension. Each slice is passed individually to
  %   FUN, along with the slice index and any trailing arguments (...).
  %   The major advantage of ARRAYFUN2 is a reduced memory usage.
  %   Without output argument, the initial array is updated with the new value.
  %
  %   The function FUN syntax is:
  %
  %     FUN(slice1, slice2, N, ....) where slice is the current slice cut along
  %     dimension DIM, N is the slice index, and additional arguments
  %     can be given. It is recommended to use function handles for FUN.
  %
  %   ARRAYFUN2(M1, M2, FUN, DIM) applies the function specified by FUN along 
  %   the specified dimension DIM. An empty DIM will use the largest
  %   dimension.
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
  %   Examples:
  %   =========
  %
  %     arrayfun(M1, M2, @plus);
  %       each slice of the third dimension of M, taken in turn, is 
  %       passed to fft2 and the result stored back into initial array.
  %       It is equivalent in result to M(:) = abs(fft2(M(:, :, :))) but
  %       operates by slice, with reduced memory requirements. If no
  %       output argument is specified, the initial array is updated.
  %
  %     P = arrayfun(M, @(x)(sum(x)), 3, 'SliceSize', [1 10 1]);
  %       creates a new MappedTensor with size [1 10 size(M,3) ].
  %
  %     arrayfun(M, @()(randn(10, 10)), 3);
  %       assigns random numbers to each slice of M
  %
  %     arrayfun(M, @(x, n)(x .* rand*n), 3);
  %       scales each slice along 3rd dimension with a single random
  %       number times the slice index.

  % defaults
  nSliceDim = []; vnSliceSize = []; bVerbose = false;
  bEarlyReturn = false;

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
      case 'earlyreturn'
        bEarlyReturn = varargin{index+1};
        toremove     = [ toremove index index+1 ];
        bNewTensor   = true;
      end
    end
  end
  varargin(toremove) = [];

  % - Get tensor size
  vnTensorSize = size(mtVar1);
  if ~all(vnTensorSize == size(mtVar2))
    error('MappedTensor:sizemismatch', ...
          '*** MappedTensor: arrayfun2: size of the two arrays do not match.');
  end

  if isempty(nSliceDim)
   [~,nSliceDim] = max(vnTensorSize);
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
    if (nargout == 0)
       warning('MappedTensor:LostSliceOutput', ...
          '--- MappedTensor: arrayfun2: The output of a arrayfun2 command is likely to be thrown away...');
    end
  end

  % - If an explicit return argument is requested, construct a new tensor
  if (nargout == 1)
    bNewTensor = true;
  end

  % - Shall we create a new return variable?
  if (~bEarlyReturn && bNewTensor)
    vnNewTensorSize = vnSliceSize;
    vnNewTensorSize(nSliceDim) = vnTensorSize(nSliceDim);
    
    mtNewVar = MappedTensor(vnNewTensorSize, 'Class', mtVar1.Format);
    
  elseif bEarlyReturn
    mtNewVar = [];
  else
    % - Store the result back in the original tensor, taking advantage
    % of the handle property of a MappedTensor
    mtNewVar = mtVar1;
    vnNewTensorSize = size(mtVar1);
    
    % - Are we attempting to re-size the tensor?
    if (~isequal(vnSliceSize([1:nSliceDim-1 nSliceDim+1:end]), vnTensorSize([1:nSliceDim-1 nSliceDim+1:end])))
       error('MappedTensor:IncorrectSliceDimensions', ...
          '*** MappedTensor/arrayfun: A tensor cannot be resized during a slice operation.\n       Assign the output to a new tensor.');
    end
  end

  % - Create a referencing window
  cvColons = repmat({':'}, 1, numel(vnTensorSize));
  cvColons{nSliceDim} = 1;
  [vnLinearSourceWindow, vnSourceDataSize] = ConvertColonsCheckLims(cvColons, vnTensorSize, mtVar1.hRepSumFunc);

  cvTest = repmat({1}, 1, numel(vnTensorSize));
  cvTest{nSliceDim} = 2;
  nTestIndex = ConvertColonsCheckLims(cvTest, vnTensorSize, mtVar1.hRepSumFunc);
  nSourceWindowStep = nTestIndex - vnLinearSourceWindow(1);

  % - Split source window into readable chunks
  mnSourceChunkIndices = SplitFileChunks(vnLinearSourceWindow, mtVar1.hChunkLengthFunc);

  if ~bEarlyReturn
    if (bNewTensor)
      cvColons = repmat({':'}, 1, numel(vnNewTensorSize));
      cvColons{nSliceDim} = 1;
      [vnLinearDestWindow, vnDestDataSize] = ConvertColonsCheckLims(cvColons, vnNewTensorSize, mtVar1.hRepSumFunc);
      
      cvTest = repmat({1}, 1, numel(vnTensorSize));
      cvTest{nSliceDim} = 2;
      nTestIndex = ConvertColonsCheckLims(cvTest, vnNewTensorSize, mtVar1.hRepSumFunc);
      nDestWindowStep = nTestIndex - vnLinearDestWindow(1);
      
      % - Split into readable chunks
      mnDestChunkIndices = SplitFileChunks(vnLinearDestWindow, mtVar1.hChunkLengthFunc);
    else
      mnDestChunkIndices = mnSourceChunkIndices;
      nDestWindowStep = nSourceWindowStep;
      vnDestDataSize = vnSourceDataSize;
    end
  end

  % - Slice up along specified dimension
  if bVerbose
   fprintf(1, '--- MappedTensor/arrayfun: [%6.2f%%]', 0);
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
    if bEarlyReturn && ~isempty(tData1) && any(tData1)
      mtNewVar = tData1;
      return;
    end

    % - Write results
    if (~isreal(tData1))
      if (~mtNewVar.bIsComplex)
         make_complex(mtNewVar);
      end
         
      % - Write real and complex parts
      mtVar1.hShimFunc('write_chunks', mtNewVar.hRealContent, mnTheseDestChunks, ...
        1:numel(tData1), vnDestDataSize, mtNewVar.Format, mtNewVar.Offset, ...
        real(tData1) ./ mtVar1.fRealFactor, mtVar1.bBigEndian);
      mtVar1.hShimFunc('write_chunks', mtNewVar.hCmplxContent, mnTheseDestChunks, ...
        1:numel(tData1), vnDestDataSize, mtNewVar.Format, mtNewVar.Offset, ...
        imag(tData1) ./ mtVar1.fComplexFactor, mtVar1.bBigEndian);
    else
      % - Write real part
      mtVar1.hShimFunc('write_chunks', mtNewVar.hRealContent, mnTheseDestChunks, 1:numel(tData1), vnDestDataSize, mtNewVar.Format, mtNewVar.Offset, tData1 ./ mtVar1.fRealFactor, mtVar1.bBigEndian);
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
