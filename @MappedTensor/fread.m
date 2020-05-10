function h = fread(m, n)
% FREAD  Read binary data from file.
%   H = FREAD(M, N) reads N bytes from MappedTensor header. The Offset must be
%   positive. The returned data H is of type 'uint8', and can be converted to
%   a string with 'char(H)'.

  h = [];
  n = min(m.Offset, n); % only in header
  if n <=0, return; end

  [fid,message] = fopen(m.Filename, 'r');
  if fid < 0
    disp(message);
    error([ mfilename ': invalid file ' m.Filename ])
  end
  h = fread(fid, n);
  fclose(fid);
