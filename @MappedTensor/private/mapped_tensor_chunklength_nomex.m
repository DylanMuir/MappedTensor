function [nChunkLength] = mapped_tensor_chunklength_nomex(vfDiffs, nIndex)
	nChunkLength = find(vfDiffs(nIndex+1:end) ~= vfDiffs(nIndex), 1, 'first');
end
