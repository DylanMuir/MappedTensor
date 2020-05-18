function [tData] = mt_read_data(hShimFunc, hDataFile, sSubs, vnTensorSize, Format, Offset, bBigEndian, hRepSumFunc, hChunkLengthFunc)
    % mt_read_data - FUNCTION Read a set of indices from the file, in an optimsed fashion

    % - Catch "read whole tensor" condition
    if (all(cellfun(@iscolon, sSubs.subs)))
        % - Read data
        tData = hShimFunc('read_all', hDataFile, vnTensorSize, ...
           Format, Offset, double(bBigEndian));
              
        % - Reshape stack and return
        tData = reshape(tData, vnTensorSize);
        return;
    end

    % - Check referencing and convert to linear indices
    [vnLinearIndices, vnDataSize] = ConvertColonsCheckLims(sSubs.subs, vnTensorSize, hRepSumFunc);

    % - Maximise chunk probability and minimise number of reads by reading
    % only sorted unique entries
    [vnLinearIndices, nul, vnReverseSort] = unique_accel(vnLinearIndices); %#ok<ASGLU>

    % - Split into readable chunks
    mnFileChunkIndices = SplitFileChunks(vnLinearIndices, hChunkLengthFunc);

    % - Call shim read function
    tData = hShimFunc('read_chunks', hDataFile, mnFileChunkIndices, vnLinearIndices, vnReverseSort, vnDataSize, Format, Offset, double(bBigEndian));
    end
