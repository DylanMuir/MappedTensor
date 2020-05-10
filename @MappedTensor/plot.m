function h = plot(a, varargin)
% PLOT Plot an array.
%   H = PLOT(M) plots the array M as a vector, matrix/surface, or volume.
%   Higher dimension tensors plot a projection.
%
% Example: b=plot(MappedTensor(rand(100));

% test if further arguments are iFuncs
h = [];

% evaluate the model value, and axes
if prod(size(a)) > 1e6
  signal = reducevolume(a);
else
  signal = subsref(a, substruct('()', repmat({':'}, 1, ndims(a))));
end
signal = squeeze(signal);

if ~isempty(inputname(1))
  iname = inputname(1);
else
  iname = 'ans';
end
if (a.bIsComplex)
  strComplex = 'complex ';
else
  strComplex = '';
end
strSize = strtrim(sprintf(' %d', size(a)));
     
name = strtrim(sprintf('%s %s%s [%s] MappedTensor', ...
       iname, strComplex, a.Format, strSize));

% call the single plot method
try
  h = iFunc_plot(name, signal);
  if ~isempty(h)
    h = iFunc_plot_menu(h, a, name);
  end
catch ME
  warning(getReport(ME))
  warning([ mfilename ': WARNING: could not plot array ' name '. Skipping.' ])
end
  

% ------------------------------------------------------------------------------
% simple plot of the array
function h=iFunc_plot(name, signal)
% this internal function plots a single model, 1D, 2D or 3D.
h=[];
if isempty(signal) || isscalar(signal)
  h = [];
  return
elseif isvector(signal)
  if all(~isfinite(signal)) signal = zeros(size(signal)); end
  h = plot(signal);
elseif ndims(signal) == 2
  h = surf(signal);
  view(3)
  set(h,'EdgeColor','None');
elseif ndims(signal) == 3
  h =patch(isosurface(signal, mean(signal(:))));
  set(h,'EdgeColor','None','FaceColor','green'); alpha(0.7);
  light
  view(3)
else
  % reduce dimensionality to 3
  for n=4:ndims(a)
    signal = sum(signal, n);
  end
  h=iFunc_plot(name, signal); % call now with 3d...
end

set(h, 'DisplayName', name);

%-------------------------------------------------------------------------------
function h=iFunc_plot_menu(h, a, name)
% contextual menu for the single object being displayed
% internal functions must be avoided as it uses LOTS of memory

  % return when a Contextual Menu already exists
  % if ~isempty(get(h,   'UIContextMenu')), return; end
  
  uicm = uicontextmenu; 
  % menu About
  uimenu(uicm, 'Label', [ name ': ' num2str(ndims(a)) 'D array ...' ]);

  set(h,   'UIContextMenu', uicm); 
  
  % add contextual menu to the axis ============================================
  % contextual menu for the axis frame

  uicm = uicontextmenu;
  % menu Duplicate (axis frame/window)
  uimenu(uicm, 'Label', 'Duplicate View...', 'Callback', ...
     [ 'tmp_cb.g=gca;' ...
       'tmp_cb.f=figure; tmp_cb.c=copyobj(tmp_cb.g,gcf); ' ...
       'set(tmp_cb.c,''position'',[ 0.1 0.1 0.85 0.8]);' ...
       'set(gcf,''Name'',''Copy of ' name '''); ' ...
       'set(gca,''XTickLabelMode'',''auto'',''XTickMode'',''auto'');' ...
       'set(gca,''YTickLabelMode'',''auto'',''YTickMode'',''auto'');' ...
       'set(gca,''ZTickLabelMode'',''auto'',''ZTickMode'',''auto'');']);
       
  if ndims(a) == 1 && ~isfield(ud,'contextual_1d')
    ud.contextual_1d = 1;
  end
  uimenu(uicm, 'Label','Toggle grid', 'Callback','grid');
  if ndims(a) >= 2 
    uimenu(uicm, 'Label','Reset Flat/3D View', 'Callback', [ ...
      '[tmp_a,tmp_e]=view; if (tmp_a==0 & tmp_e==90) view(3); else view(2); end;' ...
      'clear tmp_a tmp_e; lighting none;alpha(1);shading flat;rotate3d off;axis tight;' ]);
    uimenu(uicm, 'Label','Smooth View','Callback', 'shading interp;');
    uimenu(uicm, 'Label','Add Light','Callback', 'light;lighting phong;');
    uimenu(uicm, 'Label','Add Transparency','Callback', 'alphamap(''decrease''); for tmp_h=get(gca, ''children'')''; try; alpha(tmp_h,0.7*get(tmp_h, ''facealpha'')); end; end; clear tmp_h');
    uimenu(uicm, 'Label','Edit Colormap...','Callback', 'colormapeditor;')
    uimenu(uicm, 'Label',[ 'Linear/Log signal' ],...
      'Callback', [ 'tmp_h = findobj(gca,''type'',''surface''); ' ...
      'if strcmp(get(gca,''zscale''),''linear'') ' ...
        'set(gca,''zscale'',''log''); ' ...
        'for tmp_h2=tmp_h(:)''; try; set(tmp_h2, ''cdata'', log(get(tmp_h2, ''zdata''))); end; end;' ...
      'else;' ...
        'set(gca,''zscale'',''linear''); ' ...
        'for tmp_h2=tmp_h(:)''; try; set(tmp_h2, ''cdata'', get(tmp_h2, ''zdata'')); end; end;' ...
       'end; clear tmp_h tmp_h2' ]);
    uimenu(uicm, 'Label','Linear/Log X axis', ...
    'Callback', 'if strcmp(get(gca,''xscale''),''linear'')  set(gca,''xscale'',''log''); else set(gca,''xscale'',''linear''); end');
    uimenu(uicm, 'Label','Linear/Log Y axis', ...
    'Callback', 'if strcmp(get(gca,''yscale''),''linear'')  set(gca,''yscale'',''log''); else set(gca,''yscale'',''linear''); end');
    uimenu(uicm, 'Label','Toggle Perspective','Callback', 'if strcmp(get(gca,''Projection''),''orthographic'')  set(gca,''Projection'',''perspective''); else set(gca,''Projection'',''orthographic''); end');
  else
    uimenu(uicm, 'Label','Reset View', 'Callback','view(2);lighting none;alpha(1);shading flat;axis tight;rotate3d off;');
    uimenu(uicm, 'Label',[ 'Linear/Log ' strtok(a.Name) ],'Callback', 'if strcmp(get(gca,''yscale''),''linear'')  set(gca,''yscale'',''log''); else set(gca,''yscale'',''linear''); end');
    uimenu(uicm, 'Label', 'Linear/Log axis','Callback', 'if strcmp(get(gca,''xscale''),''linear'')  set(gca,''xscale'',''log''); else set(gca,''xscale'',''linear''); end');
  end

  uimenu(uicm, 'Separator','on','Label', 'About MappedTensor', ...
    'Callback',[ 'msgbox(''' sprintf('. Visit <https://github.com/farhi/MappedTensor>') ''',''About Mappedtensor'',''help'')' ]);
  set(gca, 'UIContextMenu', uicm);
  
  if ndims(a) == 1
    ylabel(name)
  else
    zlabel(name)
  end

  title(name);

