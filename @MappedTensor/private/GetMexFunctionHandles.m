function [hShimFunc, hRepSumFunc, hChunkLengthFunc] = GetMexFunctionHandles
    % - Does the compiled MEX function exist?
    if (exist('mapped_tensor_shim') ~= 3) %#ok<EXIST>
        try %#ok<TRYNC>
           % - Move to the MappedTensor private directory
           strMTDir = fileparts(which('MappedTensor'));
           strCWD = cd(fullfile(strMTDir, 'private'));
           
           % - Try to compile the MEX functions
           disp([ 'MappedTensor: Compiling MEX functions in ' fullfile(strMTDir, 'private') ]);
           try
             mex('mapped_tensor_shim.c', '-largeArrayDims', '-O');
             mex('mapped_tensor_repsum.c', '-largeArrayDims', '-O');
             mex('mapped_tensor_chunklength.c', '-largeArrayDims', '-O');
           end
           
           % - Move back to previous working directory
           cd(strCWD);
        end
    end

    % - Did we succeed?
    if (exist('mapped_tensor_shim') == 3) %#ok<EXIST>
        hShimFunc = @mapped_tensor_shim;
        hRepSumFunc = @mapped_tensor_repsum;
        hChunkLengthFunc = @mapped_tensor_chunklength;
        
    else
        % - Just use the slow matlab version
        warning('MappedTensor:MEXCompilation', ...
           'MappedTensor: Could not compile MEX functions.  Using slower Matlab versions.');
        
        hShimFunc = @mapped_tensor_shim_nomex;
        hRepSumFunc = @mapped_tensor_repsum_nomex;
        hChunkLengthFunc = @mapped_tensor_chunklength_nomex;
    end
end
