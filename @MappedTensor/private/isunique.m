% isunique - FUNCTION Determine whether the elements of a vector are unique
function [bIsUnique, aSorted, vnASortedIndices] = isunique(a)

    % - Check for a sorted vector, or sort it
    if issorted(a)
        aSorted = a;
        vnASortedIndices = 1:numel(a);
    else
        [aSorted, vnASortedIndices] = sort(a);
    end

    % - Vector is unique if there is never a duplicate
    bIsUnique = all(diff(aSorted) ~= 0);

    end
