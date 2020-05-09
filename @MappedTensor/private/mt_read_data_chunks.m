function [tData] = mt_read_data_chunks(hDataFile, mnFileChunkIndices, vnUniqueIndices, vnReverseSort, vnDataSize, Format, Offset)
% mt_read_data_chunks - FUNCTION Read data without sorting or checking indices
% 'vnUniqueIndices' MUST be sorted and unique; 'vnReverseSort' must be the
% inverting indices from calling UNIQUE

	nNumChunks = size(mnFileChunkIndices, 1);

	% - Allocate data
	[nClassSize, strStorageClass] = ClassSize(Format);
	vUniqueData = zeros(numel(vnUniqueIndices), 1, strStorageClass);

	% - Read data in chunks
	nDataPointer = 1;
	for (nChunkIndex = 1:nNumChunks)
		% - Get chunk info
		nChunkSkip = mnFileChunkIndices(nChunkIndex, 2);
		nChunkSize = mnFileChunkIndices(nChunkIndex, 3);
		
		% - Seek file to beginning of chunk
		fseek(hDataFile, (mnFileChunkIndices(nChunkIndex, 1)-1) * nClassSize + Offset, 'bof');
		
		% - Normal forward read
		vUniqueData(nDataPointer:nDataPointer+nChunkSize-1) = fread(hDataFile, nChunkSize, [strStorageClass '=>' Format], (nChunkSkip-1) * nClassSize);
		
		% - Shift to next data chunk
		nDataPointer = nDataPointer + nChunkSize;
	end

	% - Assign data back to original indexing order
	tData = reshape(vUniqueData(vnReverseSort), vnDataSize);
end
