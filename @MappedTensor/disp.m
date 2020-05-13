function disp(mtVar)
% DISPLAY Display array (long).
%
% Example: m=MappedTensor(rand(10)); disp(m); 1

  if numel(mtVar) > 1
    display(mtVar);
    return;
  end
  
  strSize = strtrim(sprintf(' %d', size(mtVar)));

  if (mtVar.bIsComplex)
    strComplex = 'complex ';
  else
    strComplex = '';
  end

  if ~isempty(inputname(1))
   iname = inputname(1);
  else
   iname = 'ans';
  end

  display(mtVar, iname);

  disp([ '  Filename:   ' mtVar.Filename ' ' mtVar.FilenameCmplx ]);
  disp([ '  Writable:   ' mat2str(mtVar.Writable) ])
  disp([ '  Offset:     ' num2str(mtVar.Offset) ])
  disp([ '  Format:     ' mtVar.Format ])
  disp([ '  Data:       [' strtrim(sprintf(' %d', size(mtVar))) '] ' mtVar.Format ' array' ])
  disp([ '  Temporary:  ' mat2str(mtVar.Temporary) ])

  n = mtVar.nNumElements * mtVar.nClassSize + mtVar.Offset;
  if mtVar.bIsComplex, n=n*2; end
  disp([ '  Bytes:      ' num2str(n) ]);
  disp(' ');
end
