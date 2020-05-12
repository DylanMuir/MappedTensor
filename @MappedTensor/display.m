function display(mtVar, iname)
% DISPLAY Display array (short).
%
% Example: m=MappedTensor(rand(10)); disp(m); 1

  if nargin < 2,
    if ~isempty(inputname(1))
      iname = inputname(1);
    else
      iname = 'ans';
    end
  end

  if numel(mtVar) > 1
    for index=1:numel(mtVar)
      display(mtVar(index), [ iname '(' num2str(index) ')' ]);
    end
    return
  end
   
  strSize = strtrim(sprintf(' %d', size(mtVar)));
  
  if (mtVar.bIsComplex)
    strComplex = 'complex ';
  else
    strComplex = '';
  end

  if ~isdeployed
   disp(sprintf([ '%s = ' ...
     '<a href="matlab:help MappedTensor">MappedTensor</a>' ...
     ' %s%s [%s] (' ...
     '<a href="matlab:methods ' class(mtVar) '">methods</a>,' ...
     '<a href="matlab:doc(''' class(mtVar) ''')">doc</a>,' ...
     '<a href="matlab:subsref(' iname ', substruct(''()'', repmat({'':''}, 1, ndims(' iname '))))">values</a>,' ...
     '<a href="matlab:plot(' iname ')">plot</a>,' ... 
     '<a href="matlab:disp(' iname ');">more...</a>):' ], ...
     iname, strComplex, mtVar.Format, strSize)); %#ok<DSPS>
  else
   disp(sprintf('  %s = MappedTensor %s%s [%s]:', ...
     iname, strComplex, mtVar.Format, strSize));
  end

  disp(' ')
  % now display few elements from the array
  nb = 4;  % number of elements to display at beginning and end.
  if mtVar.nNumElements < 8, nb=mtVar.nNumElements; end
  index1 = 1:nb;
  index2 = mtVar.nNumElements + (-nb:0);
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
