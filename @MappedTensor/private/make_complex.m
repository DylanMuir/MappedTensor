%% make_complex - PROTECTED METHOD Convert tensor to complex storage
function make_complex(mtVar)
	% - test to see if we can store complex values in the desired
	% representation
	switch (mtVar.Format)
		case {'char', 'logical'}
		   error('MappedTensor:NoConversionComplexToClass', ...
		      '*** MappedTensor: Cannot assign complex values to a tensor of class %s.', mtVar.Format);
	end

	% - create temporary storage for the complex part of the tensor
	if (~mtVar.Temporary)
		warning('MappedTensor:NoPermanentComplexStorage', ...
		   '--- MappedTensor: Warning: The complex part of a tensor is always stored temporarily.');
	end

	% - make enough space for a tensor
	mtVar.strCmplxFilename = create_temp_file(mtVar.nNumElements * mtVar.nClassSize + mtVar.Offset, mtVar.strTempDir);

	% - open the file
	mtVar.hCmplxContent = mtVar.hShimFunc('open', ~mtVar.Writable, mtVar.strCmplxFilename, mtVar.strMachineFormat);

	% - record that the tensor has a complex part
	mtVar.bIsComplex = true;
end
