function h = fwrite(m, buf)
% FWRITE  Write binary data from file.
%   H = FWRITE(M, BUF) writes N bytes from MappedTensor header. The Offset must be
%   positive. The returned data H is of type 'uint8', and can be converted to
%   a string with 'char(H)'.

  h = [];
  buf = uint8(buf(:));
  n = numel(buf);
  n = min(m.Offset, n); % only in header
  if n <=0, return; end
  buf = buf(1:n);

  [fid,message] = fopen(m.Filename, 'r');
  if fid < 0
    disp(message);
    error([ mfilename ': invalid file ' m.Filename ])
  end
  h = fwrite(fid, buf);
  fclose(fid);
