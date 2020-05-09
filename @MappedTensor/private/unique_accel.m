% unique_accel - FUNCTION Accelerated version of 'unique', for the
% particular usage required here
function [c,indA,indC] = unique_accel(a)

    numelA = numel(a);

    % - Short-cut for vectors that are already unique
    [bIsUnique, sortA, indSortA] = isunique(a);

    if (bIsUnique)
        c = sortA;
        indA = 1:numelA;
        indC = indA;
        return;
    end

    % Determine if A is a row vector.
    rowvec = isrow(a);

    % Convert to column
    sortA = sortA(:);
    indSortA = indSortA(:);

    % groupsSortA indicates the location of non-matching entries.
    if isnumeric(sortA) && (numelA > 1)
        dSortA = diff(sortA);
        if (isnan(dSortA(1)) || isnan(dSortA(numelA-1)))
           groupsSortA = sortA(1:numelA-1) ~= sortA(2:numelA);
        else
           groupsSortA = dSortA ~= 0;
        end
        
    else
        groupsSortA = sortA(1:numelA-1) ~= sortA(2:numelA);
    end

    if (numelA ~= 0)
        groupsSortA = [true; groupsSortA];          % First element is always a member of unique list.
    else
        groupsSortA = zeros(0,1);
    end

    % Extract unique elements.
    c = sortA(groupsSortA);         % Create unique list by indexing into sorted list.

    % Find indA.
    if nargout > 1
        indA = indSortA(groupsSortA);   % Find the indices of the sorted logical.
    end

    % Find indC.
    if nargout == 3
        groupsSortA = full(groupsSortA);
        if numelA == 0
           indC = zeros(0,1);
        else
           indC = cumsum(groupsSortA);                         % Lists position, starting at 1.
           indC(indSortA) = indC;                              % Re-reference indC to indexing of sortA.
        end
    end

    % If A is row vector, return C as row vector.
    if rowvec
        c = c.';
    end

    end
