function r = runtest(s, m, option)
% RUNTEST runs a set of tests on object methods
%   RUNTEST(s) checks all object methods. In deployed versions, only the 'test'
%   functions can be used, whereas from Matlab, the header Example: lines can be
%   used for testing. The test functions must be named 'test_<class>_<method>'.
%   Each test result must return e.g. a non-zero value, or 'OK'.
%
%   RUNTEST(s, 'method') and RUNTEST(s, {'method1',..}) checks only the given 
%   methods. When not given or empty, all methods are checked.
%
%   RUNTEST(..., 'testsuite') generates a test suite (list of functions)
%
%   R = RUNTEST(...) perform the test and returns a structure array with test results.
%
%   RUNTEST(s, R) where R is a RUNTEST structure array, displays the test results.

if nargin <2
  m = [];
end
if isstruct(m)
  runtest_report(m)
  return
end
if nargin < 3 
  if ischar(m) && strcmp(m, 'testsuite')
    m = '';
    option='testsuite';
  else option = ''; end
end

if isempty(m)
  m = methods(s);
  % we should remove superclass methods, to only test what is from that class
  for super=superclasses(s)'
    ms = methods(super{1});
    for sindex=1:numel(ms)
      mindex=find(strcmp(ms{sindex}, m));
      if ~isempty(mindex)
        m{mindex}='';
      end
    end
  end
end
m=cellstr(m);

% perform all tests
r = runtest_dotest(s, m);

% display results
fprintf(1, '%s: %s %i tests from %s\n', mfilename, class(s), numel(r), pwd);
disp('--------------------------------------------------------------------------------')
runtest_report(r);

if ~isdeployed && ischar(option) && strcmp(option, 'testsuite')
  runtest_testsuite(s, r);
end

% ------------------------------------------------------------------------------
function r = runtest_dotest(s, m)
% RUNTEST_DOTEST performs a test for given method 'm'
  r = [];
  fprintf(1,'Running %s (%s) for %i methods (from %s)\n',...
    mfilename, class(s), numel(m), pwd);

  for mindex=1:numel(m)
    % test if the method is functional
    if isempty(m{mindex}) || ~ischar(m{mindex}), continue; end
    if strcmp(mfilename, m{mindex}), continue; end % not myself
    res = [];
    
    % check if code is valid (not in deployed). 
    % Must be convertible to pcode (in temporary dir)
    if ~isdeployed
      if isempty(which([ class(s) '/' m{mindex} ])), continue; end
      pw = pwd;
      p = tempname; mkdir(p); cd(p)
      failed = [];
      try
        pcode(which([ class(s) '/' m{mindex} ]));
      catch ME
        failed= ME;
      end
      rmdir(p, 's'); cd(pw); % clean temporary directory used for the p-code
      if ~isempty(failed)
        h   = []; % invalid method (can not get help)
        res = runtest_init(m{mindex});
        res.Details.Status = 'ERROR';
        res.Details.Output = failed;
        res.Incomplete     = true;
        res.Failed         = true;
        r = [ r res ];
        continue
      end
    end
    
    % get the HELP text (not in deployed)
    if ~isdeployed
      failed = [];
      try
        if strcmp(class(s),m{mindex})
          h   = help([ class(s) ]);
        else
          h   = help([ class(s) '.' m{mindex} ]);
        end
      catch ME
        failed = ME;
      end
      if ~isempty(failed) % invalid method (can not get help)
        res = runtest_init(m{index});
        res.Details.Status = 'ERROR';
        res.Details.Output = failed;
        res.Incomplete     = true;
        res.Failed         = true;
        r = [ r res ];
        continue
      end

      % get the Example lines in Help
      if ~isempty(h)
        h = textscan(h, '%s','Delimiter','\n'); h=strtrim(h{1});
        % get the Examples: lines
        ex= strfind(h, 'Example:');
        ex= find(~cellfun(@isempty, ex));
      else ex=[];
      end

      % perform test for each Example line in Help. Ex is an index.
      for this_example_index=1:numel(ex)
        index = ex(this_example_index); % index of line starting with Example.
        if isempty(index) || isempty(h{index}), continue; end
        h{index} = strrep(h{index}, 'Example:','');
        % we add lines. First must start with Example, and may go on with '...'
        code = ''; iscontinuation = false;
        for lindex=index:numel(h)
          rline = h{lindex};
          if (lindex == index) || iscontinuation
            code = [ code strrep(rline, '...','') ];
          end
          if numel(rline) > 3 && strcmp(rline(end:-1:(end-2)),'...'), iscontinuation = true;
          else break; end
        end
        res = runtest_dotest_single(s, m{mindex}, code);
        r = [ r res ];
      end
    end % if not deployed
    
    % now test if we have a 'test' function as well
    if exist([ 'test_' class(s) '_' m{mindex} ],'file')
      code = [ 'test_' class(s) '_' m{mindex} ];
      res = runtest_dotest_single(s, m{mindex}, code);
      r = [ r res ];
    end
    
    % check if there is no test for a given method
    if isempty(res)
      res = runtest_init(m{mindex});
      res.Details.Status = 'notest';
      res.Passed         = true;
      r = [ r res ];
    end

  end % mindex
  fprintf(1, '\n');
  disp([ 'Done ' mfilename ' (' class(s) ')' ])
  
% ------------------------------------------------------------------------------
function res = runtest_init(m)
  res.Name      =char(m);
  res.Passed    =false;
  res.Failed    =false;
  res.Incomplete=false;
  res.Duration  =0;
  res.Details.Name   = m;
  res.Details.Code   =''; 
  res.Details.Status ='';
  res.Details.Output ='';
  res.Details.Code   ='';
  
% ------------------------------------------------------------------------------
function res = runtest_dotest_single(s, m, code)
% RUNTEST_DOTEST_SINGLE text a single 'Example:' line or 'test_' function

  % test if the method is functional
  res = [];
  if nargin < 2, m = []; end
  if isempty(m) || (~ischar(m) && ~isa(m, 'function_handle')), return; end
  if strcmp(mfilename, m), return; end % not myself
  if nargin < 3, code = m; end
  if isempty(code), return; end
  
  % init result to 'empty'
  res = runtest_init(m);
  res.Details.Code = strtrim(code);
  
  % perform test <<< HERE
  t0 = clock;
  T = runtest_sandbox(res.Details.Code);
  res.Passed   = T.passed;
  res.Failed   = T.failed;
  res.Duration = etime(clock, t0);
  res.Details.Output = T.output;
  if T.passed,     res.Details.Status = 'passed';
  elseif T.failed, 
    if isempty(T.output) || ischar(T.output) res.Details.Status = 'FAILED';
    else res.Details.Status = 'ERROR'; res.Incomplete=true; end
  end
  

% ------------------------------------------------------------------------------
function runtest_report(r)

  % we display details for Incomplete and Failed tests
  for index=1:numel(r)
    res = r(index);
    if res.Failed || res.Incomplete
      % get the error message
      if isa(res.Details.Output,'MException')
        ME = res.Details.Output;
        if ~isempty(ME.stack) && ~strcmp(ME.stack(1).name, 'runtest_sandbox')
          msg = sprintf('%s in %s:%i', ...
            ME.message, ME.stack(1).file, ME.stack(1).line);
        else
          msg = ME.message;
        end
      else msg = res.Details.Output; end
      fprintf(1, '%10s %7s %s %s\n', ...
        res.Name, res.Details.Status, char(res.Details.Code), cleanupcomment(msg));
    elseif res.Passed && strcmp(res.Details.Status, 'notest')
      fprintf(1, '%10s %7s %s %s\n', ...
        res.Name, res.Details.Status, char(res.Details.Code), '');
    end
  end
  disp('Totals:')
  fprintf(1, '  %i Passed, %i Failed, %i Incomplete.\n', ...
    sum([ r.Passed ]), sum([ r.Failed ]), sum([ r.Incomplete ]));
  fprintf(1, '  %.2f seconds testing time.\n', sum([ r.Duration ]));

% ------------------------------------------------------------------------------ 
function runtest_testsuite(s, r)
% RUNTEST_TESTSUITE generate a set of functions from the Example lines
  p = tempname; mkdir(p); 
  disp([ mfilename ': generating test suite...' ]);
  for index=1:numel(r)
    res = r(index);
    filename = [ 'test_' class(s) '_' res.Name ];
    if strcmp(res.Details.Code, filename), continue; end
    if isempty(res.Details.Code), continue; end
    
    % create the file when it does not exist
    if isempty(dir(fullfile(p,[ filename '.m' ])))
      fid = fopen(fullfile(p,[ filename '.m' ]),'w');
      if fid == -1, continue; end
      fprintf(fid, 'function ret=%s\n', filename);
      fprintf(fid, '%% %s checks for class %s, method ''%s''\n', ...
        upper(filename), class(s), res.Name);
      fprintf(fid, '%%   %s returns ERROR when the test could not run\n%%   OK when test is passed, FAILED otherwise.\n',...
        upper(filename));
    else
      % the test already exists. We have multiple tests for same method. catenate.
      fid = fopen(fullfile(p,[ filename '.m' ]),'a');
      if fid == -1, continue; end
      fprintf(fid, '%% -------------------------------------------------\n');
    end
    fprintf(fid, 'clear ans\n');
    fprintf(fid, 'try\n');
    fprintf(fid, '  %s\n', res.Details.Code);
    fprintf(fid, 'catch ME\n');
    fprintf(fid, '  ret=[ ''ERROR '' mfilename ]; return\n');
    fprintf(fid, 'end\n');
    fprintf(fid, 'result = ans;\n');
    fprintf(fid, 'if (isnumeric(result) || islogical(result)) && all(result(:))\n');
    fprintf(fid, '  ret=[ ''OK '' mfilename ];\n');
    fprintf(fid, 'elseif ischar(result) && any(strcmpi(strtok(result),{''OK'',''passed''}))\n');
    fprintf(fid, '  ret=[ ''OK '' mfilename ];\n');
    fprintf(fid, 'else\n');
    fprintf(fid, '  ret=[ ''FAILED '' mfilename ]; return\n');
    fprintf(fid, 'end\n');
    fclose(fid);
  end
  disp([ mfilename ': test suite generated in <a href="' p '">' p '</a>' ]);
% ------------------------------------------------------------------------------

function T = runtest_sandbox(ln)
% EVALS Evaluate expression similarly as EVALC but in a sandbox.
%   T = EVALS(expr) evaluates expression, and returns a structure holding the
%   evaluation
%     T.passed is true when the result is true/non-zero, or the output contains
%             'OK' or 'passed' as first word.
%     T.failed is true when the result was null/not OK, or failed execution.
%     T.output holds anything that would normally be written to the
%              command window, or a MException object (when failed execution).

  passed=false; failed=false; output='';
  
  if iscellstr(ln)
    ln = sprintf('%s; ', ln{:});
  end
  if ~ischar(ln)
    error([ mfilename ': expect a char/cellstr as expression to evaluate' ]);
  end

  try
    clear ans
    output = evalc(ln);

    if exist('ans','var')
      result = ans;
    else
      result = 1;
    end
    if (isnumeric(result) || islogical(result)) && all(result(:))
      passed=true;
    elseif ischar(result) && any(strcmpi(strtok(result),{'OK','passed','ans','done','success'}))
      passed=true;
    else
      failed=true;
    end
  catch ME
    output = ME;
    failed = true;
  end

  T.passed = passed;
  T.failed = failed;
  T.output = output;
  
