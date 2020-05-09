% isvalidsubscript - FUNCTION Test whether a vector contains valid entries
% for subscript referencing
function isvalidsubscript(oRefs)
	try
		% - Test for colon
		if (iscolon(oRefs))
		   return;
		end
		
		if (islogical(oRefs))
		   % - Test for logical indexing
		   validateattributes(oRefs, {'logical'}, {'binary'});
		   
		else
		   % - Test for normal indexing
		   validateattributes(oRefs, {'numeric'}, {'integer', 'real', 'positive'});
		end
		
	catch
		error('MappedTensor:badsubscript', ...
		      '*** MappedTensor: Subscript indices must either be real positive integers or logicals.');
	end
	end
