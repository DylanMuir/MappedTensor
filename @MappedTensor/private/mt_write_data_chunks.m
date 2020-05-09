function mt_write_data_chunks(hDataFile, mnFileChunkIndices, vnUniqueDataIndices, vnDataSize, Format, Offset, tData)
% mt_write_data_chunks - FUNCTION Write data without sorting or checking indices
% 'vnUniqueIndices' MUST be sorted and unique; 'vnUniqueDataIndices' must
% be the corresponding indices into the data from calling UNIQUE

    nNumChunks = size(mnFileChunkIndices, 1);

    % - Do we need to replicate the data?
    if (isscalar(tData) && prod(vnDataSize) > 1)
        tData = repmat(tData, prod(vnDataSize), 1);

    elseif (numel(tData) ~= prod(vnDataSize))
        % - The was a mismatch in the sizes of the left and right sides
        error('MappedTensor:index_assign_element_count_mismatch', ...
              '*** MappedTensor: In an assignment A(I) = B, the number of elements in B and I must be the same.');
    end

    % - Take only unique data indices
    vUniqueData = tData(vnUniqueDataIndices);

    % - Write data in chunks
    nDataPointer = 1;
    [nClassSize, strStorageClass] = ClassSize(Format);
    for (nChunkIndex = 1:nNumChunks)
        % - Get chunk info
        nChunkSkip = mnFileChunkIndices(nChunkIndex, 2);
        nChunkSize = mnFileChunkIndices(nChunkIndex, 3);

        % - Seek file to beginning of chunk
        fseek(hDataFile, (mnFileChunkIndices(nChunkIndex, 1)-1) * nClassSize + Offset, 'bof');
        
        % - Normal forward write of chunk data
        fwrite(hDataFile, vUniqueData(nDataPointer:nDataPointer+nChunkSize-1), strStorageClass, (nChunkSkip-1) * nClassSize);
        
        % - Shift to next data chunk
        nDataPointer = nDataPointer + nChunkSize;
    end
end
