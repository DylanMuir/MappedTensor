function strFilename = create_temp_file(nNumEntries, d)
    % - Get the name of a temporary file
    if nargin < 2 || isempty(d)
     strFilename = tempname;
    else
     strFilename = tempname(d);
    end

    % - Attempt fast allocation on some platforms
    if (ispc)
         [bFailed, ~] = system(sprintf('fsutil file createnew %s %i', strFilename, nNumEntries));
    elseif (ismac || isunix)
         [bFailed, ~] = system(sprintf('fallocate -l %i %s', nNumEntries, strFilename));
    else
         bFailed = true;
    end

    % - Slow fallback -- use Matlab to write zero data directly
    if (bFailed)
         hFile = fopen(strFilename, 'w+');
         fwrite(hFile, 0, 'uint8', nNumEntries-1);
         fclose(hFile);
    end
    end
