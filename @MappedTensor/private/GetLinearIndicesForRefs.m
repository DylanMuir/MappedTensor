% GetLinearIndicesForRefs - FUNCTION Convert a set of multi-dimensional indices directly into linear indices
function [vnLinearIndices, vnDimRefSizes] = GetLinearIndicesForRefs(cRefs, vnLims, hRepSumFunc)

    % - Find colon references
    vbIsColon = cellfun(@iscolon, cRefs);

    % - Fill trailing referenced dimension limits
    vnLims(end+1:numel(cRefs)) = 1;

    % - Catch "reference whole stack" condition
    if (all(vbIsColon))
        vnLinearIndices = 1:prod(vnLims);
        if (numel(cRefs) == 1)
           vnDimRefSizes = [vnLims 1];
        else
           vnDimRefSizes = vnLims;
        end
        return;
    end

    nFirstNonColon = find(~vbIsColon, 1, 'first');
    vbTrailingRefs = true(size(vbIsColon));
    vbTrailingRefs(1:nFirstNonColon-1) = false;
    vnDimRefSizes = cellfun(@numel, cRefs);
    vnDimRefSizes(vbIsColon) = vnLims(vbIsColon);

    % - Calculate dimension offsets
    vnDimOffsets = [1 cumprod(vnLims)];
    vnDimOffsets = vnDimOffsets(1:end-1);

    % - Remove trailing "1"s
    vbOnes = cellfun(@(c)isequal(c, 1), cRefs);
    nLastNonOne = find(~vbOnes, 1, 'last');
    vbTrailingRefs((nLastNonOne+1):end) = false;

    % - Work out how many linear indices there will be in total
    nNumIndices = prod(vnDimRefSizes);
    vnLinearIndices = zeros(nNumIndices, 1);

    % - Build a referencing window encompassing the leading colon refs (or
    % first ref)
    if (nFirstNonColon > 1)
        vnLinearIndices(1:prod(vnLims(1:(nFirstNonColon-1)))) = 1:prod(vnLims(1:(nFirstNonColon-1)));
    else
        vnLinearIndices(1:vnDimRefSizes(1)) = cRefs{1};
        vbTrailingRefs(1) = false;
    end

    % - Replicate windows to make up linear indices
    for (nDimension = find(vbTrailingRefs & ~vbOnes))
        % - How long is the current window?
        nCurrWindowLength = prod(vnDimRefSizes(1:(nDimension-1)));
        nThisWindowLength = nCurrWindowLength * vnDimRefSizes(nDimension);
        
        % - Is this dimension a colon reference?
        if (vbIsColon(nDimension))
           vnLinearIndices(1:nThisWindowLength) = hRepSumFunc(vnLinearIndices(1:nCurrWindowLength), ((1:vnLims(nDimension))-1) * vnDimOffsets(nDimension));

        else
           vnLinearIndices(1:nThisWindowLength) = hRepSumFunc(vnLinearIndices(1:nCurrWindowLength), (cRefs{nDimension}-1) * vnDimOffsets(nDimension));
        end
    end

    if (numel(vnDimRefSizes) == 1) % && ~any(vbIsColon)
        vnDimRefSizes = size(cRefs{1});
    end

end
