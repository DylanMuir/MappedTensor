function [nBytes, strStorageClass] = ClassSize(Format)
    % - By default, the data storage class is identical to the definition class
    strStorageClass = Format;

    % - Parse class argument
    switch(lower(Format))
        case {'char'}
           nBytes = 2;
           strStorageClass = 'uint16';
           
        case {'int8', 'uint8'}
           nBytes = 1;
           
        case {'logical'}
           nBytes = 1;
           strStorageClass = 'uint8';
           
        case {'int16', 'uint16'}
           nBytes = 2;
           
        case {'int32', 'uint32', 'single'}
           nBytes = 4;
           
        case {'int64', 'uint64', 'double'}
           nBytes = 8;
           
        otherwise
           error('MappedTensor:InvalidClass', '*** MappedTensor/ClassSize: Invalid class specifier.');
    end
    end
