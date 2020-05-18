function [mtNewVar] = arrayfun(mtVar, fhFunction, varargin) 
  % ARRAYFUN Apply a function on the entire array, in slices.
  %   ARRAYFUN(M, FUN, ...) applies the function specified by FUN.
  %   Each slice in M is passed individually to FUN, along with the slice index
  %   and any trailing arguments (...).
  %   The major advantage of ARRAYFUN is a reduced memory usage.
  %   Without output argument, the initial array is updated with the new value.
  %   ARRAYFUN works both with M being a single array, but also with M given as
  %   a vector of arrays [ M1 M2...].
  %
  %   The function FUN syntax is:
  %
  %     FUN(slice, N, ....) where slice is the current slice cut along
  %     dimension DIM, N is the slice index, and additional arguments
  %     can be given. It is recommended to use function handles for FUN.
  %
  %   Raw "Slice assign" operations can be performed by specifying FUN
  %   as a function that takes no input argument, or using the
  %   'WriteOnly' parameter (see below).
  %
  %   ARRAYFUN(M, FUN, DIM) applies the function specified by FUN along 
  %   the specified dimension DIM. An empty DIM will guess the optimal
  %   for performance.
  %
  %   P = ARRAYFUN(...) returns the result in a new object P (instead of
  %   updating the original array).
  %
  %   ARRAYFUN(M, FUN, ..., 'Param1', val1, ...) enables you to
  %   specify optional parameter name/value pairs.  Parameters are:
  %
  %     'SliceSize' -- a size vector [d1 d2 ...] indicating the new size
  %     of the slice after applying FUN. In that case, a new array
  %     P will be generated, with the same length as M along DIM, but a
  %     new size [d1 d2 ...] along the other dimensions.
  %
  %     'WriteOnly' -- a logical, being True when FUN only sets the new
  %     slice without needing to read the initial slice content. This
  %     option enhances performance to initialize an array content.
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
  %     arrayfun(M, @(x)(abs(fft2(x)), 3);
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
  %
  % Example: m=MappedTensor(rand(100)); arrayfun(m, 'abs')

  % handle array of objects
  if numel(mtVar) > 1
    mtNewVar = [];
    for index=1:numel(mtVar)
      this = arrayfun(mtVar(index), fhFunction, varargin{:});
      if isa(this, 'MappedTensor')
        if isempty(mtNewVar), mtNewVar = this;
        else mtNewVar = [ mtNewVar this ]; end
      else
        if isempty(mtNewVar)
          mtNewVar = { this };
        else
          mtNewVar{end+1} = this;
        end
      end
    end
    return
  end

  % defaults
  nSliceDim = []; vnSliceSize = []; bWriteOnly = false; bVerbose = false;
  bEarlyReturn = false; bInPlace = (nargout == 0);

  % - Shall we generate a new tensor?
  bNewTensor = false;

  % parse input arguments (nSliceDim, vnSliceSize, bWriteOnly, ...)
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
      case 'writeonly'
        bWriteOnly = varargin{index+1};
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
        bWriteOnly   = false;
        bNewTensor   = true;
      end
    end
  end
  varargin(toremove) = [];

  % - Get tensor size
  vnTensorSize = size(mtVar);

  if isempty(nSliceDim)
    % we search for the last dimension, for which the lower chunk dimensions fit
    % in 1/4-th of free memory
    [~,~,sys] = version(mtVar);
    max_sz = sys.free/4*1024; % in Bytes
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
      fprintf(1, 'MappedTensor/arrayfun: Using Dimension=%i\n', nSliceDim);
    end
  end

  % - Check slice dimension
  if ((nSliceDim < 1) || (nSliceDim > numel(vnTensorSize)))
    error('MappedTensor:badsubscript', ...
          '*** MappedTensor: arrayfun: Index exceeds matrix dimensions.');
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
          'MappedTensor: arrayfun: The output of a arrayfun command is likely to be thrown away...');
    end
  end

  % - Do we need to read from the source tensor, or does the slice
  % function only writes ?
  if nargin(fhFunction) == 0 || bWriteOnly == true
    bWriteOnly = true;
  else
    bWriteOnly = false;
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
    vnNewTensorSize = size(mtVar);
    
    % - Are we attempting to re-size the tensor?
    if (~isequal(vnSliceSize([1:nSliceDim-1 nSliceDim+1:end]), vnTensorSize([1:nSliceDim-1 nSliceDim+1:end])))
       error('MappedTensor:IncorrectSliceDimensions', ...
          '*** MappedTensor: arrayfun: A tensor cannot be resized during a slice operation.\n       Assign the output to a new tensor.');
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
   fprintf(1, 'MappedTensor/arrayfun: [%6.2f%%]', 0);
  end
  
  for (nIndex = 1:vnTensorSize(nSliceDim))
    % - Get chunks for this indexing window
    mnTheseSourceChunks = bsxfun(@plus, mnSourceChunkIndices, [(nIndex-1) * nSourceWindowStep 0 0]);
    if ~bEarlyReturn
      mnTheseDestChunks = bsxfun(@plus, mnDestChunkIndices, [(nIndex-1) * nDestWindowStep 0 0]);
    end

    % - Handle a "slice assign" function with no input arguments efficiently
    if (bWriteOnly && ~bEarlyReturn)
      % - Call function
      if (nargin(fhFunction) == 0)
        tData = feval(fhFunction);
      else
        tData = feval(fhFunction, [], nIndex, varargin{:});
      end

      mtVar.hShimFunc('write_chunks', mtNewVar.hRealContent, mnTheseDestChunks, ...
        1:numel(tData), size(tData), mtNewVar.Format, mtNewVar.Offset, tData ./ mtVar.fRealFactor, mtVar.bBigEndian);
       
    else
      % - Read source data, multiply by real factor
      tData = mtVar.hShimFunc('read_chunks', mtVar.hRealContent, mnTheseSourceChunks, 1:prod(vnSourceDataSize), 1:prod(vnSourceDataSize), vnSourceDataSize, mtVar.Format, mtVar.Offset, mtVar.bBigEndian);
      tData = tData .* mtVar.fRealFactor;

      % - Read complex part, if it exists
      if (mtVar.bIsComplex)
        tDataCmplx = mtVar.hShimFunc('read_chunks', mtVar.hCmplxContent, mnTheseSourceChunks, 1:prod(vnSourceDataSize), 1:prod(vnSourceDataSize), vnSourceDataSize, mtVar.Format, mtVar.Offset, mtVar.bBigEndian);
        tData = complex(tData, tDataCmplx .* mtVar.fComplexFactor);
      end

      % - Reshape source data
      tData = reshape(tData, vnSourceDataSize);
       
      % - Call function
      if (nargin(fhFunction) > 1)
        tData = feval(fhFunction,tData, nIndex, varargin{:});
      else
        tData = feval(fhFunction,tData, varargin{:});
      end

      % handle early return with single chunk
      if bEarlyReturn && ~isempty(tData) && any(tData)
        mtNewVar = tData;
        return;
      end

      % - Write results
      if (~isreal(tData))
        if (~mtNewVar.bIsComplex)
           make_complex(mtNewVar);
        end
           
        % - Write real and complex parts
        mtVar.hShimFunc('write_chunks', mtNewVar.hRealContent, mnTheseDestChunks, 1:numel(tData), vnDestDataSize, mtNewVar.Format, mtNewVar.Offset, real(tData) ./ mtVar.fRealFactor, mtVar.bBigEndian);
        mtVar.hShimFunc('write_chunks', mtNewVar.hCmplxContent, mnTheseDestChunks, 1:numel(tData), vnDestDataSize, mtNewVar.Format, mtNewVar.Offset, imag(tData) ./ mtVar.fComplexFactor, mtVar.bBigEndian);
      else
        % - Write real part
        mtVar.hShimFunc('write_chunks', mtNewVar.hRealContent, mnTheseDestChunks, 1:numel(tData), vnDestDataSize, mtNewVar.Format, mtNewVar.Offset, tData ./ mtVar.fRealFactor, mtVar.bBigEndian);
      end
    end
    if bVerbose
      fprintf(1, '\b\b\b\b\b\b\b\b%6.2f%%]', nIndex / vnTensorSize(nSliceDim) * 100);
    end
  end
  if bVerbose
   fprintf(1, '\b\b\b\b\b\b\b\b%6.2f%%]\n', 100);
  end
end
