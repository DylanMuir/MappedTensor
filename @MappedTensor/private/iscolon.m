% iscolon - FUNCTION Test whether a reference is equal to ':'
function bIsColon = iscolon(ref)
	bIsColon = ischar(ref) && isequal(ref, ':');
end
