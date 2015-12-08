function OpenScanimageTifStack(oStack, strFullPath, strFilenameOnly, nFile)
% Basic TifStack Constructer to open the Scanimage files 
% Includes support for interleaved frames of different channels, as
% specified by Scanimage tif format. 
% Uses Scanimage internal functions to parse tif header information. 
%
% Ingie Hong <ingiehong@jhmi.edu>, 2015


   % Open Scanimage file header first 
   sHeader = ConvertScanimageHeader(strFullPath);  % Read header information first for dimension information (interleaved frames)
   
   % Open Scanimage file 
   oStack.vhMemMapFileHandles{nFile} = TIFFStack(strFullPath, [], [sHeader.uNumChannels]);
   sHeader.nNumFrames = size(oStack.vhMemMapFileHandles{nFile}, 4);
   
   % - Permute TIFFStack so that dimensions are in the appropriate order
   oStack.vhMemMapFileHandles{nFile} = permute(oStack.vhMemMapFileHandles{nFile}, [2 1 4 3]);
   
   if (nFile == 1)
      oStack.vsHeaders = sHeader;
   else
      oStack.vsHeaders(nFile) = sHeader;
   end

   % - Check that this stack is compatible with previous stack sizes (frame
   % sizes)
   if (isempty(oStack.vnFrameSize))
      oStack.vnFrameSize = sHeader.vnFrameSizePixels;

   elseif (~isequal(sHeader.vnFrameSizePixels, oStack.vnFrameSize))
      error('FocusStack:DifferentFrameSizes', ...
         '*** FocusStack/OpenFiles/OpenTifStack: Raw file [%s] has a different frame size than the stack.', ...
         ['.../' strFilenameOnly]);
   end

   % - Check frame duration
   tThisFrameDuration = sHeader.tLineScanTime_ms*1e-3 * sHeader.vnFrameSizePixels(2);

   if (isempty(oStack.tFrameDuration))
      oStack.tFrameDuration = tThisFrameDuration;

   elseif (~isequal(round(oStack.tFrameDuration * 1000), round(tThisFrameDuration * 1000)))
      warning('FocusStack:DifferentFrameDuration', ...
         '--- FocusStack/OpenFiles/OpenTifStack: Raw file [%s] has a different frame duration than the stack (%dms vs %dms).', ...
         ['.../' strFilenameOnly], round(oStack.tFrameDuration * 1000), round(tThisFrameDuration * 1000));
   end

   % - Check Z step
   if (isempty(oStack.fZStep))
      oStack.fZStep = sHeader.vfXYZStep_nm(3) / 1e9;

   elseif (~isequal(oStack.fZStep, sHeader.vfXYZStep_nm(3) / 1e9))
      warning('FocusStack:DifferentZStep', ...
         '--- FocusStack/OpenFiles/OpenTifStack: Raw file [%s] has a different frame Z step than the stack.', ...
         ['.../' strFilenameOnly]);
   end

   % - Check zoom
   if (isempty(oStack.fPixelsPerUM))
      oStack.fPixelsPerUM = sHeader.vnFrameSizePixels(1) ./ (117 ./ sHeader.fZoomFactor);

   elseif (~isequal(oStack.fPixelsPerUM, sHeader.vnFrameSizePixels(1) ./ (117 ./ sHeader.fZoomFactor)))
      warning('FocusStack:DifferentZoom', ...
         '--- FocusStack/OpenFiles/OpenTifStack: Raw file [%s] has a different zoom level than the stack (%dum vs %dum).', ...
         ['.../' strFilenameOnly], round(oStack.vnFrameSize(1) ./ oStack.fPixelsPerUM), ...
         round(oStack.vnFrameSize(1) ./ (sHeader.vnFrameSizePixels(1) ./ (117 ./ sHeader.fZoomFactor))));
   end
   
   % - Check number of channels
   if (isempty(oStack.nNumChannels))
      oStack.nNumChannels = sHeader.uNumChannels ; % OLD:: size(oStack.vhMemMapFileHandles{nFile}, 4);
      
   elseif (~isequal(oStack.nNumChannels, size(oStack.vhMemMapFileHandles{nFile}, 4)))
      error('FocusStack:DifferentFrameSizes', ...
            '*** FocusStack/OpenFiles/OpenTifStack: Raw file [%s] has a different number of channels than the stack.', ...
            ['.../' strFilenameOnly]);
   end

   % - Check data class
   if (isempty(oStack.strDataClass))
      oStack.strDataClass = getDataClass(oStack.vhMemMapFileHandles{nFile});
      
   elseif (~isequal(oStack.strDataClass, getDataClass(oStack.vhMemMapFileHandles{nFile})))
      error('FocusStack:DifferentDataClass', ...
            '*** FocusStack/OpenFiles/OpenTifStack: Raw file [%s] has a different data class than the stack.', ...
            ['.../' strFilenameOnly]);
   end
   
   % - Set number of frames for this file
   oStack.vnNumFrames(nFile) = sHeader.nNumFrames;
end

