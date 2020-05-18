% SplitFileChunks - FUNCTION Split a set of indices into contiguous chunks
% (with a consistent skip step within a chunk)
function [mnFileChunkIndices] = SplitFileChunks(vnLinearIndices, hChunkLengthFunc)
    % - Handle degenerate cases
    switch (numel(vnLinearIndices))
        case 1
           % - Single element
           mnFileChunkIndices = [vnLinearIndices, 1, 1];
           
        case 2
           % - Two elements
           mnFileChunkIndices = [vnLinearIndices(1), vnLinearIndices(2) - vnLinearIndices(1), 2];

        otherwise
           % - Get diffs
           vnDiffs = [diff(reshape(vnLinearIndices, 1, [])) nan];
           
           nChunk = 1;
           nIndex = 1;
           % - Preallocate by estimating
           nChunkAlloc = ceil(numel(vnLinearIndices)/2);
           mnFileChunkIndices = nan(nChunkAlloc, 3);
           while (nIndex <= numel(vnLinearIndices))
              nChunkLength = hChunkLengthFunc(vnDiffs, nIndex) + 1;
              
              % - Fix up NaN skip
              if (isnan(vnDiffs(nIndex)))
                 vnDiffs(nIndex) = 1;
              end
              
              % - Define this chunk
              mnFileChunkIndices(nChunk, :) = [vnLinearIndices(nIndex), vnDiffs(nIndex), nChunkLength];
              
              % - Move to the next chunk; reallocate if necessary
              nChunk = nChunk + 1;
              if (nChunk > nChunkAlloc)
                 nChunkAlloc = nChunkAlloc*2;
                 mnFileChunkIndices(nChunkAlloc, :) = nan;
              end
              
              % - Shift diffs array
              nIndex = nIndex + nChunkLength;
           end
           
           % - Trim chunks
           mnFileChunkIndices = mnFileChunkIndices(1:nChunk-1, :);
    end
end
