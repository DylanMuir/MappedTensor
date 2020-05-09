function display(mtVar, iname)
% DISPLAY Display array (short).
   strSize = strtrim(sprintf(' %d', size(mtVar)));


   if nargin < 2,
     if ~isempty(inputname(1))
       iname = inputname(1);
     else
       iname = 'ans';
     end
   end
   
   if (mtVar.bIsComplex)
      strComplex = 'complex ';
   else
      strComplex = '';
   end

   if ~isdeployed
     disp(sprintf([ '%s = ' ...
       '<a href="matlab:help MappedTensor">MappedTensor</a> ' ...
       'object, containing %s%s [%s] (' ...
       '<a href="matlab:methods ' class(mtVar) '">methods</a>,' ...
       '<a href="matlab:doc(''' class(mtVar) ''')">doc</a>,' ...
       '<a href="matlab:subsref(' iname ', substruct(''()'', repmat({'':''}, 1, ndims(' iname '))))">values</a>,' ...
       '<a href="matlab:disp(' iname ');">more...</a>):' ], ...
       iname, strComplex, mtVar.Format, strSize)); %#ok<DSPS>
   else
     disp(sprintf('  %s = MappedTensor object, containing %s%s [%s]:', ...
       iname, strComplex, mtVar.Format, strSize));
   end

   disp(' ')
   % now display few elements from the array
   nb = 4;  % number of elements to display at begining and end.
   index1 = 1:nb;
   index2 = mtVar.nNumElements + (-nb:-1);
   index1 = index1(index1 <= mtVar.nNumElements);
   index2 = index2(1 <= index2 & index2 > max(index1));
   if isempty(index2)
     disp(subsref(mtVar, substruct('()', {index1})));
   else
     disp([  '  ' num2str(subsref(mtVar, substruct('()', {index1}))) ...
     ' ... ' num2str(subsref(mtVar, substruct('()', {index2}))) ]);
   end
   disp(' ');
end
