% my_subsref - Standard array referencing
function [tfData] = my_subsref(mtVar, S)
    % - Test for valid subscripts
    cellfun(@isvalidsubscript, S.subs);

    % - Re-order reference indices
    nNumDims = numel(S.subs);
    nNumTotalDims = numel(mtVar.vnDimensionOrder);
    vnReferencedTensorSize = size(mtVar);

    % - Catch "read entire stack" condition
    if (~all(cellfun(@iscolon, S.subs)))
        % - Handle different numbers of referencing dimensions
        if (nNumDims == 1)
           % - Translate from linear refs to indices
           nNumDims = nNumTotalDims;
           
           % - Translate colon indexing
           if (iscolon(S.subs{1}))
              S.subs{1} = (1:numel(mtVar))';
           end
           
           % - Get equivalent subscripted indexes
           [cIndices{1:nNumDims}] = ind2sub(vnReferencedTensorSize, S.subs{1});
           
           % - Permute indices and convert back to linear indexing
           vnInvOrder(mtVar.vnDimensionOrder(1:nNumTotalDims)) = 1:nNumTotalDims;
           vnReferencedTensorSize = vnReferencedTensorSize(vnInvOrder);
           
           try
              S.subs{1} = sub2ind(mtVar.vnOriginalSize, cIndices{vnInvOrder});
           catch
              error('MappedTensor:badsubscript', ...
                 '*** MappedTensor: Subscript out of range.');
           end
           
        elseif (nNumDims < nNumTotalDims)
           % - Wrap up trailing dimensions, matlab style, using linear indexing
           vnReferencedTensorSize(nNumDims) = prod(vnReferencedTensorSize(nNumDims:end));
           vnReferencedTensorSize = vnReferencedTensorSize(1:nNumDims);
           
           % - Inverse permute index order
           vnInvOrder(mtVar.vnDimensionOrder(1:nNumDims)) = 1:nNumDims;
           vnReferencedTensorSize = vnReferencedTensorSize(vnInvOrder(vnInvOrder ~= 0));
           S.subs = S.subs(vnInvOrder(vnInvOrder ~= 0));
           
        elseif (nNumDims == nNumTotalDims)
           % - Simply permute and access tensor
           
           % - Permute index order
           vnInvOrder(mtVar.vnDimensionOrder(1:nNumTotalDims)) = 1:nNumTotalDims;
           vnReferencedTensorSize = vnReferencedTensorSize(vnInvOrder);
           S.subs = S.subs(vnInvOrder);
           
        else % (nNumDims > nNumTotalDims)
           % - Check for non-colon references
           vbNonColon = ~cellfun(@iscolon, S.subs);
           
           % - Check only trailing dimensions
           vbNonColon(1:nNumTotalDims) = false;
           
           % - Check trailing dimensions for non-'1' indices
           if (any(cellfun(@(c)(~isequal(c, 1)), S.subs(vbNonColon))))
              % - This is an error
              error('MappedTensor:badsubscript', ...
                 '*** MappedTensor: Subscript out of range.');
           end
           
           % - Permute index order
           vnInvOrder(mtVar.vnDimensionOrder(1:nNumTotalDims)) = 1:nNumTotalDims;
           vnReferencedTensorSize = vnReferencedTensorSize(vnInvOrder);
           S.subs = S.subs(vnInvOrder);
        end
    end

    % - Reference the tensor data element
    if pack(mtVar,'check')
      unpack(mtVar);
    end
    tfData = mt_read_data(mtVar.hShimFunc, mtVar.hRealContent, S, vnReferencedTensorSize, mtVar.strStorageClass, mtVar.Offset, mtVar.bBigEndian, mtVar.hRepSumFunc, mtVar.hChunkLengthFunc);

    if (mtVar.bIsComplex)
        tfImagData = mt_read_data(mtVar.hShimFunc, mtVar.hCmplxContent, S, vnReferencedTensorSize, mtVar.strStorageClass, mtVar.Offset, mtVar.bBigEndian, mtVar.hRepSumFunc, mtVar.hChunkLengthFunc);
    end
        
    % - Cast data, if required
    if (mtVar.bMustCast)
        tfData = cast(tfData, mtVar.Format);
        
        if (mtVar.bIsComplex)
           tfImagData = cast(tfImagData, mtVar.Format);
        end
    end

    % - Apply scaling factors
    if (mtVar.bIsComplex)
        tfData = complex(mtVar.fRealFactor .* tfData, ...
                         mtVar.fComplexFactor .* tfImagData);
    else
        tfData = mtVar.fRealFactor .* tfData;
    end

    % - Recast data, if required, to take into account scaling which
    % can occur in another class
    if (mtVar.bMustCast)
        tfData = cast(tfData, mtVar.Format);
    end

    % - Permute dimensions
    tfData = permute(tfData, mtVar.vnDimensionOrder);

    % - Reshape return data to concatenate trailing dimensions (just as
    % matlab does)
    if (nNumDims == 1)
        tfData = reshape(tfData, [], 1);
        
    elseif (nNumDims < nNumTotalDims)
        cnSize = num2cell(size(tfData));
        tfData = reshape(tfData, cnSize{1:nNumDims-1}, []);
    end
end
