% cast - Overloaded "cast" method.
%
% Usage: tfData = cast(mtVar, Format <, bForce>)
%
% See the documentation for the built-in "cast" function.
%
% The optional parameter 'bForce' 

function tfData = cast(mtVar, Format, bForce)
% CAST  Cast a variable to a different data type or class.

   % - Should we really cast the entire tensor?
   if (~exist('bForce', 'var') || isempty(bForce))
      bForce = false;
   end
   
   % - Validate the class
   try
      sSubs = substruct('()', {1});
      cast(subsref(mtVar, sSubs), Format);
   catch
      error('MappedTensor:cast:UnsupportedCLass', ...
            '*** MappedTensor: Error: Unsupported data type for conversion: ''%s''', Format);
   end
   
   % - Cast the object
   if (bForce)
      warning('MappedTensor:WholeTensor', ...
         '--- MappedTensor: Warning: This command will allocate memory for the entire tensor!');
      
      sSubs = substruct('()', repmat({':'}, numel(size(mtVar)), 1));
      tfData = builtin('cast', subsref(mtVar, sSubs), Format);
      
   else
      % - Do a transparent cast
      tfData = mtVar;
      mtVar.bMustCast = true;
      mtVar.Format = Format;
   end
end

