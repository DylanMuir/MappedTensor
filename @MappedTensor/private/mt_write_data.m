function mt_write_data(hShimFunc, hDataFile, sSubs, vnTensorSize, Format, Offset, tData, bBigEndian, hRepSumFunc, hChunkLengthFunc)
	% mt_write_data - FUNCTION Read a set of indices from the file, in an optimsed fashion

	% - Catch "read whole tensor" condition
	if (all(cellfun(@iscolon, sSubs.subs)))
		% - Write data and return
		hShimFunc('write_all', hDataFile, vnTensorSize, ...
		   Format, Offset, cast(tData, Format), double(bBigEndian));
		return;
	end

	% - Check referencing and convert to linear indices
	[vnLinearIndices, vnDataSize] = ConvertColonsCheckLims(sSubs.subs, vnTensorSize, hRepSumFunc);

	% - Maximise chunk probability and minimise number of writes by writing
	% only sorted unique entries
	[vnLinearIndices, vnUniqueDataIndices] = unique_accel(vnLinearIndices);

	% - Split into readable chunks
	mnFileChunkIndices = SplitFileChunks(vnLinearIndices, hChunkLengthFunc);

	% - Call shim writing function
	hShimFunc('write_chunks', hDataFile, mnFileChunkIndices, vnUniqueDataIndices, vnDataSize, Format, Offset, cast(tData, Format), double(bBigEndian));
	end
