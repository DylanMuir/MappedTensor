function s = set(s, varargin)
% SET    Set structure properties.
%    V = SET(S,'PropertyName','Value') set the value of the specified
%    property/field in the structure.  
% 
%    SET(S) displays all structure field names.
%
% Example: a=MappedTensor(peaks); set(a,'Format','uint8'); isinteger(a)

  field='';
  value=[];
  if nargin && nargin<3, return; end
  if nargin >=2,  field=varargin{1}; end
  if nargin >=3,  value=varargin{2}; end
  if isempty(field), s = fieldnames(s); return; end
  
  s = subsasgn(s, field, value);
