% min - METHOD Overloaded max function for usage "min(mtVar, ...)"
function [tfMax, tnMaxIndices] = min(mtVar, varargin)
% MIN    Smallest component.

   % - Check arguments
   if (nargin > 3)
      error('MappedTensor:min:InvalidArguments', ...
            '*** MappedTensor/min: Too many arguments were provided.');
   end
   
   % - Record stack size
   vnSize = size(mtVar);
   
   % - Which dimension should we go along?
   if (nargin < 3)
      % - Find the first non-singleton dimension
      [nul, nDim] = find(vnSize > 1, 1, 'first'); %#ok<ASGLU>
   else
      nDim = varargin{2};
   end
   
   % - What sort of "min" are we performing?
   if ((nargin == 1) || isempty(varargin{1}))
      [tfMax, tnMaxIndices] = compare_single_tensor(mtVar, nDim, @min);
      
   else
      % - One tensor and another scalar or tensor
      [tfMax, tnMaxIndices] = compare_dual_tensor(mtVar, varargin{1}, nDim, @min);
   end
end
