% compare_dual_tensor - FUNCTION Comparison function between two tensors, or a tensor and scalar
function [tfResult, tnIndices] = compare_dual_tensor(oVarA, oVarB, nDim, fhCompare)
    % -- Check arguments

    % - Make sure we have a double scalar
    vbScalarArgs = false(1, 2);
    if (isscalar(oVarA))
        oVarA = double(oVarA);
        vbScalarArgs(1) = true;
    end

    if (isscalar(oVarB))
        oVarB = double(oVarB);
        vbScalarArgs(2) = true;
    end

    % - Check sizes
    if (~any(vbScalarArgs) && ~isequal(size(oVarA), size(oVarB)))
        % - Both tensors must be the same size
        error('MappedTensor:InvalidArguments', ...
           '*** MappedTensor: First two arguments must either be scalar, or the same size.');
    end

    % - How big will the result be?
    if (all(vbScalarArgs))
        % - Short-cut comparison
        tfResult = fhCompare(oVarA, oVarB);
        if (isequal(tfResult, oVarA))
           tnIndices = 1;
        else
           tnIndices = 2;
        end
        
        return;
        
    elseif (~vbScalarArgs(1))
        vnResultSize = size(oVarA);
        
    else
        vnResultSize = size(oVarB);
    end

    vnSliceSize = vnResultSize;
    vnSliceSize(nDim) = 1;

    % - Find the tensor and a scalar
    if (nnz(vbScalarArgs) == 1)
        if (~vbScalarArgs(1))
           mtTensorA = oVarA;
           fScalar = oVarB;
           nTensorAInd = 1;
           nTensorBInd = 2;
        else
           mtTensorA = oVarB;
           fScalar = oVarA;
           nTensorAInd = 2;
           nTensorBInd = 1;
        end
        
    else
        % - Both are tensor args
        mtTensorA = oVarA;
        mtTensorB = oVarB;
        nTensorAInd = 1;
        nTensorBInd = 2;
    end

    % - Allocate new tensors for the result and indices
    tfResult = MappedTensor(vnResultSize);
    tnIndices = MappedTensor(vnResultSize);
    tnTheseIndices = nan(vnSliceSize);

    % - Make a referencing structure
    sSubs = substruct('()', repmat({':'}, 1, numel(vnResultSize)));

    % -- Find result by iterating over tensor (A) slices
    for (nSlice = 1:size(mtTensorA, nDim))
        % - Get this slice
        sSubs.subs{nDim} = nSlice;
        tfThisSlice = subsref(mtTensorA, sSubs);
        
        % - Get the value(s) to compare
        if (any(vbScalarArgs))
           oCompare = fScalar;
        else
           oCompare = subsref(mtTensorB, sSubs);
        end
        
        % - Perform the comparison and record the result
        tfThisResult = fhCompare(tfThisSlice, oCompare);
        tfResult = subsasgn(tfResult, sSubs, tfThisResult);
        
        % - Record indices for this slice
        tbAResult = tfThisSlice == tfThisResult;
        tnTheseIndices(tbAResult) = nTensorAInd;
        tnTheseIndices(~tbAResult) = nTensorBInd;
        tnIndices = subsasgn(tnIndices, sSubs, tnTheseIndices);
    end
    end
