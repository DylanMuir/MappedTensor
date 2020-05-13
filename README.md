# Transparent lazy data access for matlab

By default, [Matlab][1] matrices must be fully loaded into memory. This can make allocating and working with
huge matrices a pain, especially if you only _really_ need access to a small portion of the matrix at a time.
[`memmapfile`][2] allows the data for a matrix to be stored on disk, but you can't access the matrix transparently
in functions that don't expect a [`memmapfile`][2] object without reading in the whole matrix. `MappedTensor` is
a matlab class that looks like a simple matlab tensor, with all the data stored on disk.

A few extra niceties over [`memmapfile`][2] are included, such as built-in per-slice access; fast addition,
subtraction, multiplication and division by scalars; fast negation; permutation; complex support.

Tensor data is automatically allocated on disk in a temporary file, which is removed when all referencing
objects are cleared. Existing binary files can also be accessed. `MappedTensor` is a handle class, which means
that assigning an existing mapped tensor to another variable _will not_ make a copy, but both variables will point
to the same data. Changing the data in one variable will change both variables.

MappedTensor internally uses `mex` functions, which need to be compiled the first time MappedTensor is used. If
compilation fails then slower, non-mex versions will be used.

## Download and install

Download [MappedTensor][3]  
Unzip the `@MappedTensor` directory to somewhere on the [Matlab][1] path. The *@* ampersand symbol is important,
as it signals to [Matlab][2] that this is a class directory. Then type:
```matlab
addpath /path/to/Mappedtensor
```

**Note**: MappedTensor provides an accelerated MEX function for performing
file reads and writes.  MappedTensor will attempt to compile this
function when a MappedTensor variable is first created.  This requires
mex to be configured correctly for your system.  If compilation fails,
then a slower pure Matlab version will be used.

## Creating a MappedTensor object

```M = MappedTensor([dim1 dim2...], ...)```
```M = MappedTensor(dim1, dim2, ...)```
```M = MappedTensor(dim, ...)```
allocates a MappedTensor object to store an array
with specified size [d1 d2...]. When only one dimension value is specified, 
the actual dimension is for a square array [d d].

```M = MappedTensor(FILENAME, [d1 d2...], 'FORMAT', class, ...)``` 
constructs a 
MappedTensor object that re-uses an existing map file FILENAME for an array
with dimensions [d1 d2...]. The full size, class, and offset of the file must  
be known and specified in advance.  This file will not be removed when all 
handle references are destroyed.

```M = MappedTensor(ARRAY)``` 
constructs a MappedTensor object that maps a 
numeric array ARRAY into a temporary file. The array *must be 2D or 
more* (not scalar, nor vector that would conflict with a dimension setting).
This syntax implies to already allocate the initial array, which limits the 
size of the MappedTensor. For large arrays, it is more efficient to 
pre-allocate the object with specified dimensions or the 'Size' property
and then set the content, per chunks.

```M = MappedTensor(..., PROP1, VALUE1, PROP2, VALUE2, ...)``` 
constructs a
MappedTensor object, and sets the properties of that object that are named in
the argument list (PROP1, PROP2, etc.) to the given values (VALUE1, VALUE2,
etc.). All property name arguments must be quoted strings (e.g.,
'writable'). Any properties that are not specified are given their default
values.

**Note**: When a variable containing a MappedTensor object goes out of scope
or is otherwise cleared, the memory map is automatically closed.
You may also call the DELETE method to force clear the object.

## Tensor properties

All properties can be accessed with syntax e.g. `M.property`. All these properties can also be set when building the tensor.

| Property | Description |
|----------|-------------|
| Data  |  The actual Data |
| Filename  |  Binary data file name on disk (real part of tensor) |
| FilenameCmplx  |  Binary data file name on disk (complex part of tensor) |
| Format  |  The class of this mapped tensor |
| MachineFormat  |  The desired machine format of the mapped file |
| Offset  |  The number of bytes to skip at the beginning of the file |
| Temporary  |  A flag which records whether a temporary file was created |
| Writable  |  Should the data be protected from writing? |

We detail below the use of these properties, especially to set an initial tensor.

`Format`: Char string (defaults to 'double').
Format of the contents of the mapped region. 
Format specifies that the mapped data is to be accessed as a single
vector of type specified by Format's value. 
Supported char arrays are 'int8', 'int16', 'int32', 'int64', 
'uint8', 'uint16', 'uint32', 'uint64', 'single', and 'double'.
Complex arrays are supported. Sparse arrays are not supported.
You can change later the storage class of the object with the CAST 
method, however this is usually not recommended.

`Offset`: Non-negative integer (defaults to 0).
Number of bytes from the start of the file to the start of the
mapped region. Offset 0 represents the start of the file. This 
allows to skip over the beginning of an (existing) binary file, by
throwing away the specified number of header bytes. You can use 
methdos FREAD and FWRITE to read this header region.

`Writable`: True or false (defaults to false).
Access level which determines whether or not Data property (see
below) may be assigned to.
This property can be changed after object creation.

`Temporary`: True or false (default to true when created from array).
When false, the associated file is kept when the object is cleared.
Such files can be further reused. When the object is created from
an array, Temporary is true. When creating from an existing map file
Temporary is false. You can change this property after creation.
When saving an object, the Temporary state is set to false.
This property can be changed after object creation.

`MachineFormat`: big-endian ('ieee-be') or little-endian ('ieee-le')
If not specified, the machine-native format will be used.

`Data`: array
Array to assign to the mapped object.
This property can be changed after object creation.
You can also set the Data with syntax: 
```matlab
set(M, 'Data', array)
M(:)            = whole_array;
M([ 1 3 5... ]) = slice; 
```

`Filename`: Char array.
Contains the name of the file being mapped. You can also get the
mapped file with FILEPARTS.

`FilenameCmplx`: Char array.
Contains the name of the file being mapped (complex part). You can also get the
mapped file with FILEPARTS.

##Additional Name/Value pair options at build only

`TempDir`: Directory path
Directory where the mapped file(s) should stored. The default path
is e.g. TMPDIR or /tmp. You may also use /dev/shm on Linux systems
to map the file into memory.

`Like`: array
Specified array dimension and class is used to preallocate a new
object. Note that sparse arrays are not supported.

`Size`: [d1 d2 ...] array
Vector which specifies the size of the mapped array. This is the same as specifying dimensions as first arguments (see above).

All the properties above may also be accessed after the MappedTensor object
has been created with the GET method. For example,
```matlab
set(M, 'Writable', true); % or M.Writable = true;
```
changes the Writable property of M to true.

## Using the array

The MappedTensor array can be used in most cases just as a normal Matlab
array, as many class methods have been defined to match the usual behaviour.

Most standard Matlab operators just work transparently with MAPPEDTENSOR.
You may use single objects, and even array of tensors for a vectorized
processing, such as in:

`
m=MappedTensor(rand(100)); n=copyobj(m); p=2*[m n];
`

These objects contain a reference to the actual data. Defining n=m actually
access the same data. To make a copy, use the COPYOBJ method.

Transparent casting to other classes is supported in O(1) time. Note that
due to transparent casting and tranparent O(1) scaling, rounding may
occur in a different class to the returned data, and therefore may not
match Matlab rounding precisely. If this is an issue, index the tensor
and then scale the returned values rather than rely on O(1) scaling of
the entire tensor.

To work efficiently on very large arrays, it is recommended to employ the
ARRAYFUN method, which applies a function FUN along a given dimension. This
is done transparently for many unary and binary operators.

The NUMEL method returns 1 on a single object, and the number of elements
in vectors of objects. To get the number of elements in a single object, 
use PROD(SIZE(M)). This behaviour allows most methods to be vectorized on
sequences on tensors.

A list of available methods is shown below.

| Method | Description |
|--------|-------------|
| abs  |   Absolute value. (unary op) |
| acos  |   Inverse cosine, result in radians. (unary op) |
| acosh |   Inverse hyperbolic cosine. (unary op) |
| addlistener |   Add listener for event. |
| all  |  True if all elements of a tensor are nonzero. (unary op) |
| and  |  & Logical AND. (binary op) |
| any  |  True if any element of a tensor is a nonzero number or is (unary op) |
| arrayfun  |  Apply a function on the entire array, in slices. |
| arrayfun2  |  Apply a function on two similar arrays, in slices. |
| asin  |  Inverse sine, result in radians. (unary op) |
| asinh  |  Inverse hyperbolic sine. (unary op) |
| atan  |  Inverse tangent, result in radians. (unary op) |
| atanh  |  Inverse hyperbolic tangent. (unary op) |
| cast  |  Cast a variable to a different data type or class. |
| ceil  |  Round towards plus infinity. (unary op) |
| char  |  Convert tensor representation to character array (string). |
| conj  |  Complex conjugate. (unary op) |
| copyobj  |  Make deep copy of array. |
| cos  |  Cosine of argument in radians. (unary op) |
| cosh  |  Hyperbolic cosine. (unary op) |
| ctranspose  |  ' Complex conjugate transpose. |
| cumprod  |  Cumulative product of elements. (unary op) |
| cumsum  |  Cumulative sum of elements. (unary op) |
| del2  |  Discrete Laplacian. (unary op) |
| delete  |  Delete the file, if a temporary file was created for this variable |
| disp  |  LAY Display array (long). |
| display  |  Display array (short). |
| double  |  SINGLE Convert tensor representation to double precision (float64). |
| end  |  Last index in an indexing expression |
| eq  |  == Equal. (binary op) |
| exp  |  Exponential. (unary op) |
| fileparts  |  Return the files associated with the data |
| find  |  Find indices of nonzero elements. (unary op) |
| findobj  |  Find objects matching specified conditions. |
| findprop  |  Find property of MATLAB handle object. |
| floor  |  Round towards minus infinity. (unary op) |
| fread  |  Read binary data from file. |
| fwrite  |  Write binary data from file. |
| ge  |  >= Greater than or equal. (binary op) |
| get  |  Get MATLAB object properties. |
| getdisp  |  Specialized MATLAB object property display. |
| gt  |  > Greater than. (binary op) |
| imag  |  Complex imaginary part. (unary op) |
| int16  |  Convert tensor representation to signed 16-bit integer. |
| int32  |  Convert tensor representation to signed 32-bit integer. |
| int64  |  Convert tensor representation to signed 64-bit integer. |
| int8  |  Convert tensor representation to signed 8-bit integer. |
| ipermute  |  Inverse permute array dimensions. |
| ischar  |  True for character array (string). |
| isempty  |  True for empty array. |
| isequal  |  True if arrays are numerically equal. (binary op) |
| isfinite  |  True for finite elements. (unary op) |
| isfloat  |  True for floating point arrays, both single and double. |
| isinf  |  True for infinite elements. (unary op)  |
| isinteger  |  True for arrays of integer data type. |
| islogical  |  True for logical array. |
| ismatrix  |  True if array is a matrix (not a scalar). |
| isnan  |  True for Not-a-Number. (unary op) |
| isnumeric  |  True for numeric arrays. |
| isreal  |  True for real array. |
| isscalar  |  True if array is a scalar. |
Sealed    |  isvalid  |  Test handle validity. |
| ldivide  |  .\ Left array divide. (binary op) |
| le  |  <= Less than or equal. (binary op) |
| length  |  Length of vector. |
Static    |  loadobj  |  Load filter for objects. |
| log  |  Natural logarithm. (unary op) |
| log10  |  Common (base 10) logarithm. (unary op) |
| logical  |  UINT8 Convert tensor representation to logical (true/false). |
| lt  |  < Less than. (binary op) |
| max  |  Largest component. |
| mean  |  Average or mean value. (unary op) |
| median  |  Median value. (unary op) |
| min  |  Smallest component. |
| minus  |  - Minus. (binary op) |
| mldivide  |  \ Backslash or left matrix divide. (binary op) |
| mpower  |  ^ Matrix power. (binary op) |
| mrdivide  |  / Slash or right matrix divide. (binary op) |
| mtimes  |  * Matrix multiply. (binary op) |
| ndims  |  Number of dimensions. |
| ne  |  ~= Not equal. (binary op) |
| nonzeros  |  Nonzero matrix elements. (unary op) |
| norm  |  Matrix or tensor norm. (unary op) |
| not  |  ~ Logical NOT. (unary op) |
| notify  |  Notify listeners of event. |
| numel  |  Number of object in a vector. The number of elements in a single tensor is obtailed with `prod(size(M))` |
| numel2  |  NUMEL2 Number of elements in an array, same as `prod(size(M))` |
| or  |  | Logical OR. (binary op) |
| permute  |  Permute array dimensions |
| plot  |  Plot an array. |
| plus  |  + Plus. (binary op) |
| power  |  .^ Array power. (binary op) |
| prod  |  Product of elements. (unary op) |
| rdivide  |  ./ Right array divide. (binary op) |
| real  |  Real part. (unary op) |
| reducevolume  |  reduce an array size |
| reshape  |  Reshape array. |
| round  |  Round towards nearest integer. (unary op) |
| runtest  |  runs a set of tests on object methods |
| saveobj  |  Save filter for objects. |
| set  |  Set MATLAB object property values. |
| setdisp  |  Specialized MATLAB object property display. |
| sign  |  Signum function. (unary op) |
| sin  |  Sine of argument in radians. (unary op) |
| single  |  Convert tensor representation to single precision (float32). |
| sinh  |  Hyperbolic sine. (unary op) |
| size  |  Get original tensor size, and extend dimensions if necessary |
| sqrt  |  Square root. (unary op) |
| subsasgn  |  Subscripted assignment |
| subsref  |  Subscripted reference. |
| sum  |  Sum of elements. |
| tan  |  Tangent of argument in radians. (unary op) |
| tanh  |  Hyperbolic tangent. (unary op) |
| times  |  .* Array multiply. (binary op) |
| transpose  |  .' Transpose. |
| uint16  |  Convert tensor representation to unsigned 16-bit integer. |
| uint32  |  Convert tensor representation to unsigned 32-bit integer. |
| uint64  |  Convert tensor representation to unsigned 64-bit integer. |
| uint8  |  Convert tensor representation to unsigned 8-bit integer. |
| uminus  |  - Unary minus. (unary op) |
| uplus  |  + Unary plus. |
| var  |  Variance. (unary op) |
| version  |  Return class version |
| xor  |  Logical EXCLUSIVE OR. (binary op) |


## Examples

```matlab
   % To create a mapped file for a given input array:
   % A temporary file is created to hold the data.
   m = MappedTensor(rand(100,100,100));

   % To reuse a previously existing mapped file:
   m = MappedTensor('records.dat', [100 100 100], ...
         'format','double', 'writable', true);
   m(:) = rand(100, 100, 100);  % assign new data
   m(1:2:end) = 0;
```

## Publications

This work was published in [Frontiers in Neuroinformatics][4]: DR Muir and BM Kampa. 2015. [_FocusStack and StimServer:
A new open source MATLAB toolchain for visual stimulation and analysis of two-photon calcium neuronal imaging data_][5],
**Frontiers in Neuroinformatics** 8 _85_. DOI: [10.3389/fninf.2014.00085](http://dx.doi.org/10.3389/fninf.2014.00085).
Please cite our publication in lieu of thanks, if you use this code.

[1]: http://www.mathworks.com
[2]: http://www.mathworks.com/help/techdoc/ref/memmapfile.html
[3]: https://github.com/DylanMuir/MappedTensor/releases/latest
[4]: http://www.frontiersin.org/neuroinformatics
[5]: http://dx.doi.org/10.3389/fninf.2014.00085
