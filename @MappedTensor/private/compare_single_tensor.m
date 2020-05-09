% compare_single_tensor - FUNCTION Comparison function along a single tensor
function [tfResult, tnIndices] = compare_single_tensor(mtVarA, nDim, fhCompare)
	% - Determine size of slice
	vnSliceSize = size(mtVarA);
	vnSliceSize(nDim) = 1;

	% - Make a referencing structure
	sSubs = substruct('()', repmat({':'}, 1, numel(vnSliceSize)));
	sSubs.subs{nDim} = 1;

	% - Allocate initial slice
	tfResult = subsref(mtVarA, sSubs);
	tnIndices = ones(vnSliceSize);

	% - Find result by iterating over tensor
	for (nSlice = 2:size(mtVarA, nDim))
		% - Get this slice
		sSubs.subs{nDim} = nSlice;
		tfThisSlice = subsref(mtVarA, sSubs);
		
		% - Compare with current result
		tfResult = fhCompare(tfThisSlice, tfResult);
		
		% - Which indices do we need to retain?
		tbResetIndex = tfResult == tfThisSlice;
		tnIndices(tbResetIndex) = nSlice;
	end
	end
