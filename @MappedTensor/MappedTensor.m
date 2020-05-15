% MAPPEDTENSOR Construct memory-mapped file object.
%    The MAPPEDTENSOR object allows to handle data sets larger than the available 
%    memory. The variable can be passed around BY REFERENCE, indexed and
%    written to without allocating space for the entire variable in Matlab. Note
%    that this is a handle class, meaning that if you copy the variable you only
%    copy the handle and not the data.  Modifying one array will modify all the
%    copies.
%
%    The ARRAYFUN and ARRAFUN2 methods can then be used to treat data per chunks
%    that fit in memory.
%
%    M = MAPPEDTENSOR([dim1 dim2...], ...)
%    M = MAPPEDTENSOR(dim1, dim2, ...)
%    M = MAPPEDTENSOR(dim, ...) allocates a MAPPEDTENSOR object to store an array
%    with specified size [d1 d2...]. When only one dimension value is specified, 
%    the actual dimension is for a square array [d d].
%
%    M = MAPPEDTENSOR(FILENAME, [d1 d2...], 'FORMAT', class, ...) constructs a 
%    MAPPEDTENSOR object that re-uses an existing map file FILENAME for an array
%    with dimensions [d1 d2...]. The full size, class, and offset of the file must  
%    be known and specified in advance.  This file will not be removed when all 
%    handle references are destroyed.
%
%    M = MAPPEDTENSOR(ARRAY) constructs a MAPPEDTENSOR object that maps a 
%    numeric array ARRAY into a temporary file. The array must be 2D or 
%    more (not scalar, nor vector that would conflict with a dimension setting).
%    This syntax implies to already allocate the initial array, which limits the 
%    size of the MappedTensor. For large arrays, it is more efficient to 
%    pre-allocate the object with specified dimensions or the 'Size' property
%    and then set the content, per chunks.
%     
%    M = MAPPEDTENSOR(..., PROP1, VALUE1, PROP2, VALUE2, ...) constructs a
%    MAPPEDTENSOR object, and sets the properties of that object that are named in
%    the argument list (PROP1, PROP2, etc.) to the given values (VALUE1, VALUE2,
%    etc.). All property name arguments must be quoted strings (e.g.,
%    'writable'). Any properties that are not specified are given their default
%    values.
%
%    Note: When a variable containing a MAPPEDTENSOR object goes out of scope
%    or is otherwise cleared, the memory map is automatically closed.
%    You may also call the DELETE method to force clear the object.
%    To keep the mapped data files, use MappedTensor(...,'Temporary',false)
% 
%    Tensor properties
%    =================
%
%    These properties can be set at build stage.
% 
%        Format: Char string (defaults to 'double').
%            Format of the contents of the mapped region. 
%            Format specifies that the mapped data is to be accessed as a single
%            vector of type specified by Format's value. 
%            Supported char arrays are 'int8', 'int16', 'int32', 'int64', 
%            'uint8', 'uint16', 'uint32', 'uint64', 'single', and 'double'.
%            Complex arrays are supported. Sparse arrays are not supported.
%            You can change later the storage class of the object with the CAST 
%            method, however this is usually not recommended.
% 
%        Offset: Nonnegative integer (defaults to 0).
%            Number of bytes from the start of the file to the start of the
%            mapped region. Offset 0 represents the start of the file. This 
%            allows to skip over the beginning of an (existing) binary file, by
%            throwing away the specified number of header bytes. You can use 
%            methdos FREAD and FWRITE to read this header region.
% 
%        Writable: True or false (defaults to false).
%            Access level which determines whether or not Data property (see
%            below) may be assigned to.
%            This property can be changed after object creation.
%
%        Temporary: True or false (default to true when created from array).
%            When false, the associated file is kept when the object is cleared.
%            Such files can be further reused. When the object is created from
%            an array, Temporary is true. When creating from an existing map file
%            Temporary is false. You can change this property after creation.
%            When saving an object, the Temporary state is set to false.
%            This property can be changed after object creation.
%
%        Data: array
%            Array to assign to the mapped object.
%            This property can be changed after object creation.
%            You can also set the Data with syntax: 
%              set(M, 'Data', array)
%              M(:)            = whole_array;
%              M([ 1 3 5... ]) = slice; 
%
%        Filename: Char array.
%            Contains the name of the file being mapped. You can also get the
%            mapped file with FILEPARTS.
%
%        MachineFormat: big-endian ('ieee-be') or little-endian ('ieee-le')
%            If not specified, the machine-native format will be used.
%
%    For instance you may use:
%
%      M = MappedTensor('Filename','data.bin','Data',rand(100));
%
%    All the properties above may also be accessed after the MAPPEDTENSOR object
%    has been created with the GET method. The Writable, Temporary, Data properties 
%    can be changed with the SET method. For example,
% 
%        set(M, 'Writable', true); % or M.Writable = true;
%  
%    changes the Writable property of M to true.
%
%    Additional properties at build stage only
%    =========================================
%
%        TempDir: Directory path
%            Directory where the mapped file(s) should stored. The default path
%            is e.g. TMPDIR or /tmp. You may also use /dev/shm on Linux systems
%            to map the file into memory.
%
%        Like: array
%            Specified array dimension and class is used to preallocate a new
%            object. Note that sparse arrays are not supported.
%
%        Size: [d1 d2 ...] array
%            Vector which specifies the size of the mapped array.
%
%    Note: MappedTensor provides an accelerated MEX function for performing
%    file reads and writes.  MappedTensor will attempt to compile this
%    function when a MappedTensor variable is first created.  This requires
%    mex to be configured correctly for your system.  If compilation fails,
%    then a slower pure Matlab version will be used.
%
%    Loading from data files
%    =======================
%
%    The LOAD method allows to lazy import binary data sets with syntax
%
%    m = load(MappedTensor, 'filename');
%
%    with the following data formats.
%
%     | Extension         | Description               |
%     |-------------------|---------------------------|
%     | EDF               | ESRF Data Format          |
%     | POS               | Atom Probe Tomography     |
%     | NPY               | Python NumPy array        |
%     | MRC MAP CCP4 RES  | MRC MRC/CCP4/MAP electronic density map |
%     | MAR               | MAR CCD image             |
%     | IMG MCCD          | ADSC X-ray detector image |
%
%    Using the array:
%    ================
%
%    The MAPPEDTENSOR array can be used in most cases just as a normal Matlab
%    array, as many class methods have been defined to match the usual behaviour.
%
%    Most standard Matlab operators just work transparently with MAPPEDTENSOR.
%    You may use single objects, and even array of tensors for a vectorized
%    processing, such as in:
%
%      m=MappedTensor(rand(100)); n=copyobj(m); p=2*[m n];
%
%    These objects contain a reference to the actual data. Defining n=m actually
%    access the same data. To make a copy, use the COPYOBJ method.
%
%    Transparent casting to other classes is supported in O(1) time. Note that
%    due to transparent casting and tranparent O(1) scaling, rounding may
%    occur in a different class to the returned data, and therefore may not
%    match Matlab rounding precisely. If this is an issue, index the tensor
%    and then scale the returned values rather than rely on O(1) scaling of
%    the entire tensor.
%
%    To work efficiently on very large arrays, it is recommended to employ the
%    ARRAYFUN method, which applies a function FUN along a given dimension. This
%    is done transparently for many unary and binary operators.
%
%    The NUMEL method returns 1 on a single object, and the number of elements
%    in vectors of objects. To get the number of elements in a single object, 
%    use PROD(SIZE(M)). This behaviour allows most methods to be vectorized on
%    sequences on tensors.
% 
%    Examples:
%    =========
%        % To create a mapped file for a given input array:
%        % A temporary file is created to hold the data.
%        m = MAPPEDTENSOR(rand(100,100,100));
%
%        % To reuse a previously existing mapped file:
%        m = MAPPEDTENSOR('records.dat', [100 100 100], ...
%              'format','double', 'writable', true);
%        m(:) = rand(100, 100, 100);  % assign new data
%        m(1:2:end) = 0;
%
%    Example: m = MappedTensor(rand(100,100))
%
%    Note: m = rand(100, 100, 100); would over-write the mapped tensor with a 
%    standard matlab tensor.  To assign to the entire tensor you must use
%    colon referencing: m(:) = ... or set(m, 'Data', ...). For very large arrays
%    it is safer to assign data slice-per-slice.
%
%    Credits:
%    ========
%
%    If this software is useful to your academic work, please cite our
%    publication in lieu of thanks:
%
%    D R Muir and B M Kampa, 2015. "FocusStack and StimServer: a new open
%      source MATLAB toolchain for visual stimulation and analysis of two-photon
%      calcium neuronal imaging data". Frontiers in Neuroinformatics 8 (85).
%      DOI: 10.3389/fninf.2014.00085
%
%    This version of the code has been heavily revamped by
%    <emmanuel.farhi@synchrotron-soleil.fr>. Please cite the following
%    publication E. Farhi et al., J. Neut. Res., 17 (2013) 5. DOI: 10.3233/JNR-130001
% 
%    See also MEMMAPFILE, MAPPEDTENSOR/arrayfun, MAPPEDTENSOR/get, 
%    MAPPEDTENSOR/subsasgn, MAPPEDTENSOR/subsref.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 19th November, 2010
%
% Thanks to @marcsous (https://github.com/marcsous) for bug reports and
% fixes.
%
% revamped by E. Farhi <emmanuel.farhi@synchrotron-soleil.fr>, May 2020.

classdef MappedTensor < handle
  properties % public, in sync with memmapfile
    Filename ='';;        % Binary data file on disk (real part of tensor)
    FilenameCmplx='';     % Binary data file on disk (complex part of tensor)
    Format   = 'double';  % The class of this mapped tensor
    Writable = true;      % Should the data be protected from writing?
    Offset   = 0;         % The number of bytes to skip at the beginning of the file
    Data;                 % The actual Data (alias)
    Temporary=true;       % A flag which records whether a temporary file was created
    MachineFormat;        % The desired machine format of the mapped file
    UserData;             % where to store more stuff
  end
  
  properties (Access = private)
    strTempDir;             % Temporary directory used for data files on disk
    hRealContent;           % File handle for data (real part)
    hCmplxContent;          % File handle for data (complex part)
    strStorageClass;        % The storage class of this tensor on disk
    nClassSize;             % The size of a single scalar element of the storage class, in bytes
    vnDimensionOrder;       % A vector containing the virtual dimension order used for referencing the tensor
    nNumElements;           % The number of total elements in the tensor, for convenience
    vnOriginalSize;         % A vector recording the original size of the tensor
    bMustCast;              % A boolean indicating that the data should be cast on reading and writing
    bIsComplex = false;     % A boolean indicating the the data has a complex part
    fComplexFactor = 1;     % A factor multiplied by the complex part of the tensor (used for scalar multiplication and negation)
    fRealFactor = 1;        % A factor multiplied by the real part of the tensor (used for scalar multiplication and negation)
    bBigEndian;             % Should the data be stored in big-endian format?
    hShimFunc;              % Handle to the (hopefully compiled) shim function
    hRepSumFunc;            % Handle to the (hopefully compiled) repsum function
    hChunkLengthFunc;       % Handle to the (hopefully compiled) chunk length function
    bCompressed=0;          % 0: uncompressed; 1: compressed; 2:operation in progress       
  end % properties
   
  methods
    %% MappedTensor - CONSTRUCTOR
    function [mtVar] = MappedTensor(varargin)
    % MAPPEDTENSOR Build an array mapped onto a file.
    %
    % Example: m = MappedTensor(rand(100,100))

      persistent hShimFunc hRepSumFunc hChunkLengthFunc

      % MAPPEDTENSOR Get a handle to the appropriate shim function (should be done
      %     before any errors are thrown)
      if isempty(hShimFunc)
        [hShimFunc, hRepSumFunc, hChunkLengthFunc] = GetMexFunctionHandles;
      end

      mtVar.hShimFunc        = hShimFunc;
      mtVar.hRepSumFunc      = hRepSumFunc;
      mtVar.hChunkLengthFunc = hChunkLengthFunc;

      % - Filter arguments for properties
      vbKeepArg = true(numel(varargin), 1);
      nArg = 1;
      vnTensorSize = [];
      while (nArg <= numel(varargin))
        if (ischar(varargin{nArg}))

          switch(lower(varargin{nArg}))
          case {'class','format'}
            % - A non-default class was specified
            mtVar.Format = varargin{nArg+1};
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;

          case {'tempdir'}
            % - a temporary directory path
            mtVar.strTempDir = varargin{nArg+1};
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;
             
          case {'headerbytes','offset'}
            % - A number of header bytes was specified
            mtVar.Offset = varargin{nArg+1};
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;
             
          case {'machineformat'}
            % - The machine format was specifed
            mtVar.MachineFormat = varargin{nArg+1};
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;
             
          case {'readonly'}
            % - Read-only or read/write status was specified
            mtVar.Writable = ~logical(varargin{nArg+1});
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;
            
          case {'writable'}
            % - Read-only or read/write status was specified
            mtVar.Writable = logical(varargin{nArg+1});
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;   
             
          case {'convert','data'}
            % - Convert an existing tensor into a MappedTensor

            % - Get the Tensor value to convert
            tfSourceTensor = varargin{nArg+1};

            % - Do we already have a MappedTensor?
            if (isa(tfSourceTensor, 'MappedTensor'))
              % - Just return it
              mtVar = tfSourceTensor;
              return;
              
            else

              % - Check the size of the incoming tensor
              if (numel(tfSourceTensor) == 0)
                 error('MappedTensor:Arguments', ...
                       '*** MappedTensor: A zero-sized tensor cannot be converted to a MappedTensor.');
              end
              
              % - Remove 'Data' arguments from varargin
              varargin([nArg nArg+1]) = [];
              
              % - Create a MappedTensor
              mtVar = MappedTensor(size(tfSourceTensor), varargin{:}, 'Like', tfSourceTensor);
              
              % - Copy the data
              mtVar = subsasgn(mtVar, substruct('()', {':'}), tfSourceTensor);
              return;
            end
             
          case {'like'}
            % - Set the class property accordingly
            if isa(varargin{nArg+1}, 'MappedTensor')
              mtVar.Format = get(varargin{nArg+1}, 'Format');
            else
              mtVar.Format = class(varargin{nArg+1});
            end
            % - Set the complexity (real or complex) accordingly
            if (~isreal(varargin{nArg+1}))
              mtVar.bIsComplex = true;
            end

            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;
            
          case 'temporary'
            % - Temporary status was specified
            mtVar.Temporary = logical(varargin{nArg+1});
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;
            
          case 'persistent'
            % - Persistent (not temporary) status was specified
            mtVar.Temporary = ~logical(varargin{nArg+1});
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;
            
          case {'size','dimension'}
            % - Size was specified
            vnTensorSize = varargin{nArg+1};
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;

          case 'filename'
            if ischar(varargin{nArg+1}) && ~isempty(varargin{nArg+1})
              if ~isempty(dir(varargin{nArg+1}))
                mtVar.Filename = varargin{nArg+1};
              else
                disp([ mfilename ': file ' varargin{nArg+1} ' is missing.' ])
              end
            end
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;
            mtVar.Temporary = false;

          case {'filename_complex','strcmplxfilename','filenamecmplx' }
            if ischar(varargin{nArg+1}) && ~isempty(varargin{nArg+1})
              if ~isempty(dir(varargin{nArg+1}))
                mtVar.FilenameCmplx = varargin{nArg+1};
              else
                disp([ mfilename ': file ' varargin{nArg+1} ' is missing.' ])
              end
            end
            vbKeepArg(nArg:nArg+1) = false;
            nArg = nArg + 1;
            mtVar.Temporary = false;
            
          otherwise
            % - No other properties are supported
            if nArg > 1
              error('MappedTensor:InvalidProperty', ...
              '*** MappedTensor: ''%s'' is not a valid property.', varargin{nArg});
            end
           end % switch
        end % if char
        
        % - Check the next argument
        nArg = nArg + 1;
      end % while

      % - Filter out unneeded arguments
      varargin = varargin(vbKeepArg);

      % - Interpret an empty argument list as {1}
      if (isempty(varargin))
        varargin = {1};
      end

      % - Get class information
      [mtVar.nClassSize, mtVar.strStorageClass] = ClassSize(mtVar.Format);

      % - Do we need to cast data between these two classes?
      mtVar.bMustCast = ~isequal(mtVar.strStorageClass, mtVar.Format);

      % - Should we map a file on disk, or create a temporary file?
      if (ischar(varargin{1})) && ~isempty(dir(varargin{1})) && ~isdir(varargin{1})
        % - Open an existing file
        if isempty(vnTensorSize)
          vnTensorSize = double([varargin{2:end}]);
        end
        mtVar.Filename = varargin{1};
        mtVar.Temporary = false;
      elseif numel(varargin) == 1 && (isnumeric(varargin{1})||islogical(varargin{1})) ...
        && all(size(varargin{1})>1)
       mtVar = MappedTensor('Data', varargin{1});
       return
      elseif isempty(mtVar.Filename)
        % - Create a temporary file
        mtVar.Temporary = true;
        if isempty(vnTensorSize)
          vnTensorSize = double([varargin{:}]);
        end
      end
      vnTensorSize = double(vnTensorSize);
      % - If only one dimension was provided, assume the matrix is
      % square (Matlab default semantics)
      if (isscalar(vnTensorSize))
        vnTensorSize = vnTensorSize * [1 1];
      end

      % - Validate tensor size argument
      try
        validateattributes(vnTensorSize, {'numeric'}, {'positive', 'integer', 'nonempty'});
      catch
        error('MappedTensor:Arguments', ...
           '*** MappedTensor: Error: ''vnTensorSize'' must be a positive integer vector.');
      end

      % - Make enough space for a temporary tensor
      if mtVar.Temporary && isempty(mtVar.Filename)
        mtVar.Filename = create_temp_file(prod(vnTensorSize) * mtVar.nClassSize + mtVar.Offset, mtVar.strTempDir);
      end

      % - Open the file
      if (isempty(mtVar.MachineFormat))
        [mtVar.hRealContent, mtVar.MachineFormat] = mtVar.hShimFunc('open', ~mtVar.Writable, mtVar.Filename);
      else
        mtVar.hRealContent = mtVar.hShimFunc('open', ~mtVar.Writable, mtVar.Filename, mtVar.MachineFormat);
      end

      % - Check machine format
      switch (lower(mtVar.MachineFormat))
        case {'ieee-be', 'ieee-be.l64'}
           mtVar.bBigEndian = true;
           
        case {'ieee-le', 'ieee-le.l64'}
           mtVar.bBigEndian = false;
           
        otherwise
           error('MappedTensor:MachineFormat', ...
                 '*** MappedTensor: Error: only ''ieee-be'' and ''ieee-le'' machine formats are supported.');
      end

      % - Record the original tensor size, remove trailing unitary dimensions
      if (vnTensorSize(end) == 1) && (numel(vnTensorSize) > 2)
        nLastNonUnitary = max(2, find(vnTensorSize ~= 1, 1, 'last'));
        vnTensorSize = vnTensorSize(1:nLastNonUnitary);
      end

      mtVar.vnOriginalSize = vnTensorSize;

      % - Initialise dimension order
      mtVar.vnDimensionOrder = 1:numel(vnTensorSize);

      % - Record number of total elements
      mtVar.nNumElements = prod(vnTensorSize);

      % - Set complexity
      if (mtVar.bIsComplex)
        make_complex(mtVar);
      end
    end % constructor ----------------------------------------------------------
    
    function delete(mtVar)
      % DELETE Delete the file, if a temporary file was created for this variable

      % handle array of objects
      if numel(mtVar) > 1
        for index=1:numel(mtVar)
          delete(mtVar(index));
        end
        return
      end

      try
        % - Close the file handles
        mtVar.hShimFunc('close', mtVar.hRealContent);
        
        if mtVar.bIsComplex
           mtVar.hShimFunc('close', mtVar.hCmplxContent);
        end

        for f={ mtVar.Filename mtVar.FilenameCmplx }
          if ~isempty(f{1}) && ischar(f{1}) && ~isempty(dir(f{1}))
            if mtVar.Temporary
               % - Really delete the temporary file, don't just put it in the trash
               strState = recycle('off');
               delete(f{1});
               recycle(strState);
            else
              disp(sprintf('MappedTensor: keeping file %s containing %s %s with Offset %i', ...
                f{1}, mtVar.Format, mat2str(size(mtVar)), mtVar.Offset));
            end
          end
        end
        
      catch mtErr
        % - Die gracefully if we couldn't delete the temporary file
        warning('MappedTensor:Destructor', ...
           'MappedTensor/delete: Could not delete temporary file.\n       Error: %s', mtErr.message);
           getReport(mtErr)
      end
    end % delete

    function v = get.Data(mtVar)
      v = subsref(mtVar, substruct('()', repmat({':'}, 1, ndims(mtVar))));
    end
      
    function mtVar = set.Data(mtVar, v)
      subsasgn(mtVar, substruct('()', {':'}), v);
    end

    % end - METHOD Overloaded end
    function ind = end(obj,k,n)
    % END Last index in an indexing expression
    %
    % Example: m=MappedTensor(eye(10)); m(end) == 1
       szd = size(obj);
       if k < n
          ind = szd(k);
       else
          ind = prod(szd(k:end));
       end
    end
      
    % ndims - METHOD Overloaded ndims function
    function [nDim] = ndims(mtVar, varargin)
    % NDIMS   Number of dimensions.
    %
    % Example: m=MappedTensor(eye(10)); ndims(m) == 2

      % handle array of objects
      if numel(mtVar) > 1
        nDim = ones(size(mtVar));
        for index=1:numel(mtVar)
          nDim(index) = ndims(mtVar(index));
        end
        return
      end
    
      % - If varargin contains anything, a cell reference "{}" was attempted
      if (~isempty(varargin))
          error('MappedTensor:cellRefFromNonCell', ...
              '*** MappedTensor: Cell contents reference from non-cell obejct.');
      end
      
      % - Return the total number of dimensions in the tensor
      nDim = length(size(mtVar));
    end % ndims

    function tf = isempty(mtVar)
    % ISEMPTY True for empty array.
    %
    % Example: m=MappedTensor; isempty(m)

      % handle array of objects
      if numel(mtVar) > 1
        tf = ones(size(mtVar));
        for index=1:numel(mtVar)
          tf(index) = isempty(mtVar(index));
        end
        return
      end
      
      tf = (mtVar.nNumElements == 1 && subsref(mtVar, substruct('()', {1})) == 0);
    end
      
    % numel - METHOD Overloaded numel function
    function [nNumElem] = numel2(mtVar, varargin)
    % NUMEL2 Number of elements in an array, same as prod(size)
    %
    % Example: m=MappedTensor(rand(10)); numel2(m) == prod(size(m))

      if numel(mtVar) > 1
        nNumElem = zeros(size(mtVar));
        for index=1:numel(mtVar)
          nNumElem(index) = numel2(mtVar(index));
        end
        return
      end
       
       % - Return the total number of elements in the tensor
       nNumElem = mtVar.nNumElements;
    end
      
    % length - METHOD Overloaded length function
    function [nLength] = length(mtVar)
    % LENGTH   Length of vector.
    %
    % Example: m=MappedTensor(rand(10,20)); length(m) == 20

      % handle array of objects
      if numel(mtVar) > 1
        nLength = ones(size(mtVar));
        for index=1:numel(mtVar)
          nLength(index) = length(mtVar(index));
        end
        return
      end
      
      nLength = max(size(mtVar));
    end
      
    % permute - METHOD Overloaded permute function
    function [mtVar] = permute(mtVar, vnNewOrder)
    % PERMUTE Permute array dimensions
    %
    % Example: m=MappedTensor(rand(10,20)); all(size(permute(m,[2 1])) == [20 10])

      if nargin < 2, return; end
      % handle array of objects
      if numel(mtVar) > 1
        for index=1:numel(mtVar)
          permute(mtVar(index), vnNewOrder);
        end
        return
      end
      
      vnCurrentOrder = mtVar.vnDimensionOrder;

      if (numel(vnNewOrder) > numel(vnCurrentOrder))
        vnCurrentOrder(end+1:numel(vnNewOrder)) = numel(vnCurrentOrder)+1:numel(vnNewOrder);
      end

      mtVar.vnDimensionOrder(1:numel(vnNewOrder)) = vnCurrentOrder(vnNewOrder);
    end
      
    % ipermute - METHOD Overloaded ipermute function
    function [mtVar] = ipermute(mtVar, vnOldOrder)
    % IPERMUTE Inverse permute array dimensions.
    %
    % Example: m=MappedTensor(rand(20,10)); all(size(ipermute(m,[2 1])) == [10 20])

      if nargin < 2, return; end
      % handle array of objects
      if numel(mtVar) > 1
        for index=1:numel(mtVar)
          ipermute(mtVar(index),vnOldOrder);
        end
        return
      end
      
      vnNewOrder(vnOldOrder) = 1:numel(vnOldOrder);
      mtVar = permute(mtVar, vnNewOrder);
    end
      
    % ctranspose - METHOD Overloaded ctranspose function
    function [mtVar] = ctranspose(mtVar)
    % '   Complex conjugate transpose.
    % Transposition just swaps the first two dimensions, leaving the trailing
    % dimensions unpermuted.
    %
    % Example: m=MappedTensor(rand(10,20)); all(size(m') == [20 10])
    
      % handle array of objects
      if numel(mtVar) > 1
        for index=1:numel(mtVar)
          ctranspose(mtVar(index));
        end
        return
      end

      % - Array-transpose real and complex parts
      mtVar = transpose(mtVar);

      % - Negate complex part
      if (mtVar.bIsComplex)
        mtVar.fComplexFactor = -mtVar.fComplexFactor;
      end
    end
      
    % transpose - METHOD Overloaded transpose function
    function [mtVar] = transpose(mtVar)
    % .' Transpose.
    % % Transposition just swaps the first two dimensions, leaving the trailing
    % dimensions unpermuted.
    %
    % Example: m=MappedTensor(rand(10,20)); all(size(m.') == [20 10])
      if numel(mtVar) > 1
        for index=1:numel(mtVar)
          transpose(mtVar(index));
        end
        return
      end
      mtVar = permute(mtVar, [2 1]);
    end
      
    % isreal - METHOD Overloaded isreal function
    function [bIsReal] = isreal(mtVar)
    % ISREAL True for real array.
    %
    % Example: m=MappedTensor(rand(10,20)); isreal(m)

    % handle array of objects
      if numel(mtVar) > 1
        bIsReal = ones(size(mtVar));
        for index=1:numel(mtVar)
          bIsReal(index) = isreal(mtVar(index));
        end
        return
      end
      
      bIsReal = ~mtVar.bIsComplex;
    end
      
    % islogical - METHOD Overloaded islogical function
    function [bIsLogical] = islogical(mtVar)
    % ISLOGICAL True for logical array.
    %
    % Example: m=MappedTensor('Data',logical(eye(5))); islogical(m)

    % handle array of objects
      if numel(mtVar) > 1
        bIsLogical = ones(size(mtVar));
        for index=1:numel(mtVar)
          bIsLogical(index) = islogical(mtVar(index));
        end
        return
      end
      
      bIsLogical = isequal(mtVar.Format, 'logical');
    end
      
    % isnumeric - METHOD Overloaded isnumeric function
    function [bIsNumeric] = isnumeric(mtVar)
    % ISNUMERIC True for numeric arrays.
    %
    % Example: m=MappedTensor(rand(10,20)); isnumeric(m)

    % handle array of objects
      if numel(mtVar) > 1
        bIsNumeric = ones(size(mtVar));
        for index=1:numel(mtVar)
          bIsNumeric(index) = isnumeric(mtVar(index));
        end
        return
      end

      bIsNumeric = ~islogical(mtVar) && ~ischar(mtVar);
    end
      
    % isscalar - METHOD Overloaded isscalar function
    function [bIsScalar] = isscalar(mtVar)
    % ISSCALAR True if array is a scalar.
    %
    % Example: m=MappedTensor(1); isscalar(m)

    % handle array of objects
      if numel(mtVar) > 1
        bIsScalar = ones(size(mtVar));
        for index=1:numel(mtVar)
          bIsScalar(index) = isscalar(mtVar(index));
        end
        return
      end
      
      bIsScalar = numel2(mtVar) == 1;
    end
      
    % ismatrix - METHOD Overloaded ismatrix function
    function [bIsMatrix] = ismatrix(mtVar)
    % ISMATRIX True if array is a matrix (not a scalar).
    %
    % Example: m=MappedTensor(rand(10)); ismatrix(m)

    % handle array of objects
      if numel(mtVar) > 1
        bIsMatrix = ones(size(mtVar));
        for index=1:numel(mtVar)
          bIsMatrix(index) = ismatrix(mtVar(index));
        end
        return
      end
      
      bIsMatrix = ~isscalar(mtVar);
    end
      
    % ischar - METHOD Overloaded ischar function
    function [bIsChar] = ischar(mtVar)
    % ISCHAR  True for character array (string).
    %
    % Example: m=MappedTensor('Data','this is Mapped'); ischar(m)

    % handle array of objects
      if numel(mtVar) > 1
        bIsChar = ones(size(mtVar));
        for index=1:numel(mtVar)
          bIsChar(index) = ischar(mtVar(index));
        end
        return
      end
      
      bIsChar = isequal(mtVar.Format, 'char');
    end
      
    % isfloat - METHOD Overloaded isfloat function
    function [bIsFloat] = isfloat(mtVar)
    % ISFLOAT True for floating point arrays, both single and double.
    %
    % Example: m=MappedTensor(single(rand(10))); isfloat(m)

    % handle array of objects
      if numel(mtVar) > 1
        bIsFloat = ones(size(mtVar));
        for index=1:numel(mtVar)
          bIsFloat(index) = isfloat(mtVar(index));
        end
        return
      end
      
      bIsFloat = isequal(mtVar.Format, 'single') || isequal(mtVar.Format, 'double');
    end
      
    % isinteger - METHOD Overloaded isinteger function
    function [bIsInteger] = isinteger(mtVar)
    % ISINTEGER True for arrays of integer data type.
    %
    % Example: m=MappedTensor(uint8(eye(5))); isinteger(m)

    % handle array of objects
      if numel(mtVar) > 1
        bIsInteger = ones(size(mtVar));
        for index=1:numel(mtVar)
          bIsInteger(index) = isinteger(mtVar(index));
        end
        return
      end
      
      bIsInteger = ~isfloat(mtVar) & ~islogical(mtVar) & ~ischar(mtVar);
    end
      
    % uplus - METHOD Overloaded uplus operator (+mtVar)
    function [mtVar] = uplus(mtVar)
      %  +  Unary plus.
      %    +A for objects is a copy of A. 
      %    A new object is created, with same content (same as COPYOBJ).
      %
      %    B = UPLUS(A) is called for the syntax '+A'.
      %
      % Example: a=MappedTensor(peaks); ~isempty(+a)
    end

    %% fileparts - METHOD Return the files that underlie this MappedTensor
    function [Filename, FilenameCmplx] = fileparts(mtVar)
      % FILEPARTS Return the files associated with the data
      %
      % Example: m=MappedTensor(eye(5)); ~isempty(dir(fileparts(m)))

      % handle array of objects
      if numel(mtVar) > 1
        Filename=cell(1,numel2(mtVar)); FilenameCmplx = Filename;
        for index=1:numel(mtVar)
          [Filename{index}, FilenameCmplx{index}] = fileparts(mtVar(index));
        end
        return
      end
      
      Filename = mtVar.Filename;
      FilenameCmplx = mtVar.FilenameCmplx;
    end

    function tfData = char(mtVar)
      % CHAR Convert tensor representation to character array (string).
      %
      % Example: m=MappedTensor('Data',[72 101 108 108 111]); ischar(char(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData char(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'char');
    end

    function tfData = int8(mtVar)
      % INT8 Convert tensor representation to signed 8-bit integer.
      %
      % Example: m=MappedTensor('Data','Hello'); isinteger(int8(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData int8(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'int8');
    end

    function tfData = uint8(mtVar)
      % UINT8 Convert tensor representation to unsigned 8-bit integer.
      %
      % Example: m=MappedTensor('Data','Hello'); isinteger(uint8(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData uint8(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'uint8');
    end

    function tfData = logical(mtVar)
      % UINT8 Convert tensor representation to logical (true/false).
      %
      % Example: m=MappedTensor(eye(5)); islogical(logical(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData logical(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'logical');
    end

    function tfData = int16(mtVar)
      % INT16 Convert tensor representation to signed 16-bit integer.
      %
      % Example: m=MappedTensor(100*rand(10)); isinteger(int16(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData int16(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'int16');
    end

    function tfData = uint16(mtVar)
      % UINT16 Convert tensor representation to unsigned 16-bit integer.
      %
      % Example: m=MappedTensor(100*rand(10)); isinteger(uint16(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData uint16(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'uint16');
    end

    function tfData = int32(mtVar)
      % INT32 Convert tensor representation to signed 32-bit integer.
      %
      % Example: m=MappedTensor(100*rand(10)); isinteger(int32(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData int32(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'int32');
    end

    function tfData = uint32(mtVar)
      % UINT32 Convert tensor representation to unsigned 32-bit integer.
      %
      % Example: m=MappedTensor(100*rand(10)); isinteger(uint32(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData uint32(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'uint32');
    end

    function tfData = single(mtVar)
      % SINGLE Convert tensor representation to single precision (float32).
      %
      % Example: m=MappedTensor(100*rand(10)); isnumeric(single(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData single(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'single');
    end

    function tfData = int64(mtVar)
      % INT64 Convert tensor representation to signed 64-bit integer.
      %
      % Example: m=MappedTensor(100*rand(10)); isinteger(int64(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData int64(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'int64');
    end

    function tfData = uint64(mtVar)
      % UINT64 Convert tensor representation to unsigned 64-bit integer.
      %
      % Example: m=MappedTensor(100*rand(10)); isinteger(uint64(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData uint64(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'uint64');
    end

    function tfData = double(mtVar)
      % SINGLE Convert tensor representation to double precision (float64).
      %
      % Example: m=MappedTensor(100*rand(10)); isnumeric(double(m))

      % handle array of objects
      if numel(mtVar) > 1
        tfData = [];
        for index=1:numel(mtVar)
          tfData = [ tfData double(mtVar(index)) ];
        end
        return
      end
      
      tfData = cast(mtVar, 'double');
    end
      
    %% saveobj - METHOD Overloaded save mechanism
    function [sVar] = saveobj(mtVar)
    % SAVEOBJ Save filter for objects.

      % - Generate a structure containing only the pertinent properties
      sVar.Filename         = mtVar.Filename;
      sVar.FilenameCmplx    = mtVar.FilenameCmplx;
      sVar.Temporary        = false;
      sVar.Format           = mtVar.Format;
      sVar.vnDimensionOrder = mtVar.vnDimensionOrder;
      sVar.vnOriginalSize   = mtVar.vnOriginalSize;
      sVar.Writable         = mtVar.Writable;
      sVar.Offset           = mtVar.Offset;
      sVar.MachineFormat    = mtVar.MachineFormat;
      sVar.Size             = size(mtVar);
      sVar.bCompressed      = mtVar.bCompressed;

      mtVar.Temporary = false; % must keep data
      
      disp([ mfilename ': saveobj: please keep file (real)    ' sVar.Filename])
      if mtVar.bIsComplex && ~isempty(sVar.FilenameCmplx)
        disp([ mfilename ': saveobj: please keep file (complex) ' sVar.FilenameCmplx])
      end

    end % saveobj
      
  end % methods
      
  methods (Static)
    %% loadobj - METHOD Overloaded load mechanism
    function [mtVar] = loadobj(sSavedVar)
    % LOADOBJ Load filter for objects.

      if isempty(sSavedVar), mtVar = []; return; end
      
      % compute the initial size of object
      vnOriginalSize = sSavedVar.vnOriginalSize; %#ok<PROP>
      vnOriginalSize(end+1:numel(sSavedVar.vnDimensionOrder)) = 1; %#ok<PROP>
     
      % - Return the size of the tensor data element, permuted
      vnSize = vnOriginalSize(sSavedVar.vnDimensionOrder); %#ok<PROP>

      % check files. Are they available ?
      Filename = private_search_file(sSavedVar.Filename);
      if isempty(Filename)
        warning([ mfilename ': loadobj: can not find mapped data file ' sSavedVar.Filename ]);
      end
      FilenameCmplx = private_search_file(sSavedVar.FilenameCmplx);

      args = { ...
        'Filename',         Filename, ...
        'Filename_Complex', FilenameCmplx, ...
        'Format',           sSavedVar.Format, ...
        'MachineFormat',    sSavedVar.MachineFormat, ...
        'Temporary',        false, ...
        'Writable',         sSavedVar.Writable, ...
        'Offset',           sSavedVar.Offset, ...
        'Size',             vnSize };
        
      mtVar = MappedTensor(args{:}); % build new object

      mtVar.vnOriginalSize   = sSavedVar.vnOriginalSize;
      mtVar.vnDimensionOrder = sSavedVar.vnDimensionOrder;
      mtVar.bCompressed      = sSavedVar.bCompressed;

    end
  end % methods (static)
      
end % end classdef MappedTensor

