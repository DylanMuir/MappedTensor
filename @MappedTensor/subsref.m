function v = subsref(mtVar, subs)
% SUBSREF Subscripted reference.
%   The subscript reference can be applied with syntax:
%   M(I) which referes to element I in array M. For multi-dimensional arrays,
%   the syntax is M(I,J,...). The use of ':' in place an index indicates the
%   whole dimension.
%
%   The special syntax A(:) extract all values of the tensor.
%
%   M.field accesses the property 'field' in object M.
%
% Example: % Example: m=MappedTensor(eye(5)); subsref(m,1) == 1 % same as m(1)

  if ischar(subs) 
    subs = substruct('.',subs);
  elseif isnumeric(subs)
    subs = substruct('()',{ subs });
  end

  % handle array of objects
  if numel(mtVar) > 1
    v = [];
    if strcmp(subs.type,'()')
      v = builtin('subsref', mtVar, subs);
      return
    else
      v = {};
      for index=1:numel(mtVar)
        v{end+1} = subsref(mtVar(index), subs);
      end
      return
    end
  end
  
  % - Check reference type
  switch (subs.type)
  case {'()'}
     % - Call the internal subsref function to access data
     v = my_subsref(mtVar, subs);
  otherwise
     v = builtin('subsref', mtVar, subs);
  end
end
