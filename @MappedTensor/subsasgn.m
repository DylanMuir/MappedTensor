function [mtVar] = subsasgn(mtVar, S, tfData)
% SUBSASGN Subscripted assignment
%   A(I) = B assigns the values of B into the elements of A specified by
%   the subscript vector I.  B must have the same number of elements as I
%   or be a scalar. For multi-dimensional arrays, syntax is M(I,J,..) = B.
%
%   The special syntax A(:) = B assigns all values of the tensor as B.
%
%   A.field = B assigns value B to the object property 'field'.
%
%   
  if ischar(S) 
    S = substruct('.',S)
  elseif isnumeric(S)
    S = substruct('()',{ S });
  end

  % handle array of objects
  if numel(mtVar) > 1
    if strcmp(S.type,'()')
      builtin('subasgn', mtVar, S, tfData);
      return
    else
      for index=1:numel(mtVar)
        subasgn(mtVar(index), S, tfData);
      end
      return
    end
  end

  if strcmp(S.type,'.')
    mtVar = builtin('subsasgn', mtVar, S, tfData);
    return
  end
  
  % Test for valid subscripts
  cellfun(@isvalidsubscript, S.subs);

  % - Test read-only status if tensor
  if (~mtVar.Writable)
    error('MappedTensor:ReadProtect', '*** MappedTensor: Attempted write to a read-only tensor.');
  end

  if pack(mtVar,'check')
    unpack(mtVar);
  end

  % - Test real/complex nature of input and current tensor
  if (~isreal(tfData))
    % - The input data is complex
    if (~mtVar.bIsComplex)
       make_complex(mtVar);
    end
  end

  % - Cast data, if required
  if (mtVar.bMustCast)
    if (mtVar.bIsComplex)
       tfData = complex(cast(real(tfData) ./ mtVar.fRealFactor, mtVar.strStorageClass), ...
                        cast(imag(tfData) ./ mtVar.fComplexFactor, mtVar.strStorageClass));
                     
    else
       tfData = cast(tfData ./ mtVar.fRealFactor, mtVar.strStorageClass);
    end
  end

  % - Permute input data
  tfData = ipermute(tfData, mtVar.vnDimensionOrder);

  if (~isreal(tfData)) || (~isreal(mtVar))
    % - Assign to both real and complex parts
    mt_write_data(mtVar.hShimFunc, mtVar.hRealContent, S, mtVar.vnOriginalSize, mtVar.strStorageClass, mtVar.Offset, real(tfData), mtVar.bBigEndian, mtVar.hRepSumFunc, mtVar.hChunkLengthFunc);
    mt_write_data(mtVar.hShimFunc, mtVar.hCmplxContent, S, mtVar.vnOriginalSize, mtVar.strStorageClass, mtVar.Offset, imag(tfData), mtVar.bBigEndian, mtVar.hRepSumFunc, mtVar.hChunkLengthFunc);

  else
    % - Assign only real part
    mt_write_data(mtVar.hShimFunc, mtVar.hRealContent, S, mtVar.vnOriginalSize, mtVar.strStorageClass, mtVar.Offset, tfData, mtVar.bBigEndian, mtVar.hRepSumFunc, mtVar.hChunkLengthFunc);
  end
end
