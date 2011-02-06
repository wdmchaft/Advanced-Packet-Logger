function [err, errMsg] = saveBreakpoints;
%Saves all active breakpoints in modules and "stop on error, ..warning, etc"
% Restore by calling "db_startup"


% Need upgrade to deal with requirement " mfile must be in a directory that is on
% the search path or in the current directory."
% Specifically: 
% 1. sort the breakpoints by path
% 2. place a "cd <path>" before the breakpoint(s) in a given path
% 3. remove the path from the dbstop declaration & record in file
% 4. repeat for all path(s) found
% 5. add a "cd" at the end of the file for the desired final directory...
%   which I think is "currentDir"

[err, errMsg, modName] = initErrModName(mfilename);
s = dbstatus;
fid = fopen('db_startup.m','w');
if fid > 0 
  fprintf('Saving existing breakpoints in "%s\\db_startup.m".  Run "db_startup" to re-activate these.', pwd);
  fprintf(fid, 'cd(currentDir)\r\n');
else
  err = 1;
  errMsg = sprintf('%s: Unable to open file "db_startup.m" to save breakpoints.', modName);
  if nargout < 1
    fprintf(' Error: %s', errMsg);
  end
  return
end
dbstatus %display on console
for itemp = 1:length(s)
  thisFile = char(s(itemp).name);
  if length(thisFile)
    theseLines = s(itemp).line;
    %command: "dbstop in debugBreakpoint at debugBreak"
    %recorded as: 
    %  name: 'd:\edc\debugBreakpoint (debugBreak)'
    %  line: 34
    %  cond: ''
    %action required: pull the parenthetical portion
    a = findstrchr('(', thisFile);
    if a
      b = findstrchr(')', thisFile);
      c = thisFile(a+1:b-1);
      thisFile = strtrim(thisFile(1:a-1));
      fprintf(fid,'dbstop in ''%s'' at ''%s''\r\n', thisFile, c);
      doLines = (length(theseLines) > 1);
    else
      doLines = 1;
    end
    if doLines
      for jtemp = 1:length(theseLines)
        fprintf(fid,'dbstop in ''%s'' at %i\r\n', strtrim(thisFile), theseLines(jtemp));
      end
    end
  else
    fprintf(fid,'dbstop if %s\r\n', char(s(itemp).cond));
  end
end
fprintf(fid, 'progress(''listboxMsg_Callback'', sprintf(''****** Breakpoints re-established: ****** ''));\r\n');
fprintf(fid, 'dbstatus\r\n');
fcloseIfOpen(fid);
fprintf('Breakpoints saved.');
if nargout < 1
  clear err
end