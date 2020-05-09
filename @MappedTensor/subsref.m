function v = subsref(mtVar, subs)
% SUBSREF Subscripted reference.
  
  % - Check reference type
  switch (subs.type)
  case {'()'}
     % - Call the internal subsref function to access data
     v = my_subsref(mtVar, subs);
  otherwise
     v = builtin('subsref', mtVar, subs);
  end
end
