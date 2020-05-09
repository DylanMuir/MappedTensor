% mt_read_all - FUNCTION Read the entire stack
function [tData] = mt_read_all(hDataFile, vnTensorSize, Format, Offset, ~)
    % - Allocate data
    [~, strStorageClass] = ClassSize(Format);
    %    tData = zeros(vnTensorSize, strStorageClass);

    % - Seek file to beginning of data
    fseek(hDataFile, Offset, 'bof');

    % - Normal forward read
    tData = fread(hDataFile, prod(vnTensorSize), [strStorageClass '=>' Format], 0);
end
