function [varargout] = mapped_tensor_shim_nomex(strCommand, varargin)
    switch (strCommand)
        case 'open'
           if (nargin == 2)
              [varargout{1}] = fopen(varargin{1}, 'r+');
              [nul, nul, varargout{2}, nul] = fopen(varargout{1}); %#ok<ASGLU,NASGU>
           else
              varargout{1} = fopen(varargin{1}, 'r+', varargin{2});
           end
           
        case 'close'
           fclose(varargin{1});
           
        case 'read_chunks'
           varargout{1} = mt_read_data_chunks(varargin{1:7});
           
        case 'write_chunks'
           mt_write_data_chunks(varargin{1:7});
           
        case 'read_all'
           varargout{1} = mt_read_all(varargin{1:5});
           
        case 'write_all'
           varargout{1} = mt_write_all(varargin{1:6});
    end
end
