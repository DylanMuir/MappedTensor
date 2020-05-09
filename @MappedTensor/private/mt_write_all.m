% mt_write_all - FUNCTION Write the entire stack
function mt_write_all(hDataFile, vnTensorSize, Format, Offset, tData, ~)

   % - Do we need to replicate the data?
   if (isscalar(tData) && prod(vnTensorSize) > 1)
      tData = repmat(tData, prod(vnTensorSize), 1);

   elseif (numel(tData) ~= prod(vnTensorSize))
      % - The was a mismatch in the sizes of the left and right sides
      error('MappedTensor:index_assign_element_count_mismatch', ...
            '*** MappedTensor: In an assignment A(I) = B, the number of elements in B and I must be the same.');
   end
   
   % - Get storage class
   [~, strStorageClass] = ClassSize(Format);

   % - Seek file to beginning of data
   fseek(hDataFile,  Offset, 'bof');
      
   % - Normal forward write of data
   fwrite(hDataFile, tData, strStorageClass, 0);
end
