function v = get(s, varargin)
% GET    Get structure properties.
%    V = GET(S,'PropertyName') returns the value of the specified
%    property/field in the structure.  If S is an array, then get will 
%    return a cell array of values.  
% 
%    GET(S) displays all object field names.
%
% Example: a=MappedTensor(peaks); ischar(get(a,'Format'))

  if nargin == 1, field=''; else field = varargin; end
  if isempty(field), v = fieldnames(s); return; end
  v = [];

  v = subsref(s, char(field));
  
