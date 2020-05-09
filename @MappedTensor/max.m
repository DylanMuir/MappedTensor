% max - METHOD Overloaded max function for usage "max(mtVar, ...)"
function [tfMax, tnMaxIndices] = max(mtVar, varargin)
% MAX    Largest component.

   % - Check arguments
   if (nargin > 3)
      error('MappedTensor:max:InvalidArguments', ...
            '*** MappedTensor/max: Too many arguments were provided.');
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
   
   % - What sort of "max" are we performing?
   if ((nargin == 1) || isempty(varargin{1}))
      [tfMax, tnMaxIndices] = compare_single_tensor(mtVar, nDim, @max);
      
   else
      % - One tensor and another scalar or tensor
      [tfMax, tnMaxIndices] = compare_dual_tensor(mtVar, varargin{1}, nDim, @max);
   end
end
