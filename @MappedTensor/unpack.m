function mtVar = unpack(mtVar)
% UNPACK  Decompress the mapped file.
%   Decompress tensor storage with ZIP, TAR, GZIP, LZ4, ZSTD, BZIP2, XZ, LZO, ...
%   M = UNPACK(M) decompresses the mapped data files for given tensor.
%   However, unpacking is usually done transparently when data is accessed.
%
%   TF = PACK(M, 'check') returns true when the tensor M is compressed.
%
%   You should install the extractors individually.
%   Recommended:
%   * LZ4 <https://lz4.github.io/lz4/> (2011). Extremely fast.
%   * ZSTD <https://github.com/facebook/zstd> (2015). Very fast.
%   * BROTLI <https://github.com/google/brotli> (2013). Very fast.
%   * LZO <https://www.lzop.org/> (1996-2017). Very fast.
%   * PBZIP2 <https://github.com/ruanhuabin/pbzip2>. Parallelized BZIP2.
%   * PIGZ <https://zlib.net/pigz/> (2007). Parallelized GZIP.
%   * PIXZ <https://github.com/vasi/pixz> (2010). Parallelized XZ.
%
%   Other:
%   * ZIP <https://support.pkware.com/home> (1989). Standard.
%   * TAR <https://www.gnu.org/software/tar/>. Standard.
%   * GZIP <https://www.gnu.org/software/gzip/> (1992). Standard.
%   * BZIP2 <https://www.sourceware.org/bzip2/> (1996). Very compact.
%   * LZMA <https://tukaani.org/lzma/> (1998). Slow, efficient.
%   * XZ <https://tukaani.org/xz/>. Rather slow, very compact.
%   * PXZ <https://jnovy.fedorapeople.org/pxz/>. Parallelized XZ.
%   * 7Z <https://www.7-zip.org/> (1998).
%   * RAR <https://www.rarlab.com/> (1993).
%   * COMPRESS (Z) <https://ncompress.sourceforge.io/> (1985).
%
%   Recommended compressors are LZ4, ZSTD, PIGZ and PBZIP2.
%   ZIP, GZIP and TAR are supported without further installation.
%
% Example: m=MappedTensor(eye(1000)); pack(m); unpack(m); 

  mtVar = pack(mtVar, 'decompress');
