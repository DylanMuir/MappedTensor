% ConvertColonCheckLims - FUNCTION Convert colon referencing to subscript indices; check index limits
function [vnLinearIndices, vnDataSize] = ConvertColonsCheckLims(cRefs, vnLims, hRepSumFunc)
	% - Fill trailing referenced dimension limits
	vnLims(end+1:numel(cRefs)) = 1;

	% - Handle linear indexing
	if (numel(cRefs) == 1)
		vnLims = prod(vnLims);
	end

	% - Check each dimension in turn
	for (nRefDim = numel(cRefs):-1:1) %#ok<FORPF>
		% - Convert colon references
		if (iscolon(cRefs{nRefDim}))
		   cCheckedRefs{nRefDim} = ':';
		   
		elseif (islogical(cRefs{nRefDim}))
		   % - Logical referencing -- convert to indexed referencing
		   vnIndices = find(cRefs{nRefDim}(:));
		   if (any(vnIndices > vnLims(nRefDim)))
		      error('FocusStack:InvalidRef', ...
		         '*** FocusStack/GetFullFileRefs: Logical referencing for dimension [%d] was out of bounds [1..%d].', ...
		         nRefDim, vnLims(nRefDim));
		   end
		   cCheckedRefs{nRefDim} = vnIndices;
		   
		elseif (any(cRefs{nRefDim}(:) < 1) || any(cRefs{nRefDim}(:) > vnLims(nRefDim)))
		   % - Check limits
		   error('MappedTensor:InvalidRef', ...
		      '*** MappedTensor: Index exceeds matrix dimensions.');
		   
		else
		   % - This dimension was ok, convert to double
		   cCheckedRefs{nRefDim} = double(cRefs{nRefDim});
		end
	end

	% - Convert to linear indexing; work out data size
	[vnLinearIndices, vnDataSize] = GetLinearIndicesForRefs(cCheckedRefs, vnLims, hRepSumFunc);

	if (numel(vnDataSize) == 1)
		vnDataSize(2) = 1;
	end
end
