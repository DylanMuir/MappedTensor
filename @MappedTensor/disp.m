function disp(mtVar)
% DISPLAY Display array (long).
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

   disp([ '  Filename:   ' mtVar.Filename ' ' mtVar.strCmplxFilename ]);
   disp([ '  Writable:   ' mat2str(mtVar.Writable) ])
   disp([ '  Offset:     ' num2str(mtVar.Offset) ])
   disp([ '  Format:     ' mtVar.Format ])
   disp([ '  Data:       [' strtrim(sprintf(' %d', size(mtVar))) '] ' mtVar.Format ' array' ])
   disp([ '  Persistent: ' mat2str(~mtVar.Temporary) ])

   n = mtVar.nNumElements * mtVar.nClassSize + mtVar.Offset;
   if mtVar.bIsComplex, n=n*2; end
   disp([ '  Size:       ' num2str(n) ]);
   disp(' ');
end
