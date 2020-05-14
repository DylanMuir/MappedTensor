function filename = private_search_file(filename)

  if isempty(filename) || ~ischar(filename) || ~isempty(dir(filename)), return; end

  % file is absent. Search for it
  newfile = which(filename); % Matlab path ?
  if ~isempty(newfile), filename = newfile; return; end

  if usejava('jvm')
    home = char(java.lang.System.getProperty('user.home'));
  elseif ~ispc  % does not work under Windows
    home = getenv('HOME');
  end

  [p,f,e] = fileparts(filename);
  for loc = { home pwd }
    newfile = fullfile(loc{1}, [f e]);
    if ~isempty(dir(newfile))
      filename = newfile; return;
    end
  end
  filename = [];
  
