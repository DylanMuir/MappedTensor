function newVar = copyobj(mtVar)
  % COPYOBJ Make deep copy of array.
  %
  % Example: m=MappedTensor(100*rand(10)); n=copyobj(m); isequal(m,n)

  newVar = [];

  % handle array of objects
  if numel(mtVar) > 1
    for index=1:numel(mtVar)
      newVar = [ newVar copyobj(mtVar(index)) ];
    end
    return
  end

  % first we copy the files to new ones.
  if ~isempty(mtVar.Filename) && ischar(mtVar.Filename) ...
    && ~isempty(dir(mtVar.Filename))
    [p,f] = fileparts(mtVar.Filename);
    newRealFilename = tempname(p);
    [ex,mess] = copyfile(mtVar.Filename, newRealFilename);
    if ~ex
      error([ mfilename ': copyobj: ERROR copying file ' mtVar.Filename ': ' message ])
    end
  else return;
  end
  if ~isempty(mtVar.FilenameCmplx) && ischar(mtVar.FilenameCmplx) ...
    && ~isempty(dir(mtVar.FilenameCmplx))
    [p,f] = fileparts(mtVar.FilenameCmplx);
    newCmplxFilename = tempname(p);
    [ex,mess] = copyfile(mtVar.FilenameCmplx, newCmplxFilename);
    if ~ex
      error([ mfilename ': copyobj: ERROR copying file ' mtVar.FilenameCmplx ': ' message ])
    end
  else newCmplxFilename = [];
  end

  % then we recreate the object.
  vnOriginalSize = mtVar.vnOriginalSize; %#ok<PROP>
  vnOriginalSize(end+1:numel(mtVar.vnDimensionOrder)) = 1; %#ok<PROP>
 
  % - Return the size of the tensor data element, permuted
  vnSize = vnOriginalSize(mtVar.vnDimensionOrder); %#ok<PROP>
  
  args = { ...
    'Filename',         newRealFilename, ...
    'Filename_Complex', newCmplxFilename, ...
    'Format',           mtVar.Format, ...
    'MachineFormat',    mtVar.MachineFormat, ...
    'Temporary',        mtVar.Temporary, ...
    'Writable',         mtVar.Writable, ...
    'Offset',           mtVar.Offset, ...
    'Size',             vnSize };
    
  newVar = MappedTensor(args{:}); % build new object

  newVar.vnOriginalSize   = mtVar.vnOriginalSize;
  newVar.vnDimensionOrder = mtVar.vnDimensionOrder;
  
end % copyobj
