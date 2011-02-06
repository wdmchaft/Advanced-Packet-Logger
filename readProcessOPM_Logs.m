function [err, errMsg, logPaths, logPathsDisabled] = readProcessOPM_Logs(pathTo_logsINI, fileName, addCmt);
% function [err, errMsg, logPaths] = readProcessOPM_Logs(pathTo_logsINI[, fileName[, addCmt]]);
%  called by processOutpostPacketMessages
%Reads <pathTo_logsINI>ProcessOPM_logs.ini to determine operator's preferencs
% for the locations of copies of the log.  This is a simple list
% of paths for the copies.
%If the file is not located, calls "writeProcessOPM_Logs" to create 
%  the file with instructions as a coaching aid but does not actually contain additional paths.
%INPUT:
% pathTo_logsINI: typical the archive directory of Outpost
% fileName[optional]: name for the file.  If not present or null, "ProcessOPM_logs.ini"
% addCmt[optional]: if present & when the file does not exist and is therefore
%   created by this program, "addCmt" is inserted as the second comment line.
%OUTPUT:
% logPaths: a cell array of strings of the paths each terminated with \
% logPathsDisabled: for the edit window, a cell array of strings of disabled/inactive
%           paths.  These lines start with '(disabled)'
%SEE ALSO
%  writeProcessOPM_Logs

[err, errMsg, modName] = initErrModName(mfilename) ;

pathTo_logsINI = endWithBackSlash(pathTo_logsINI);
if (nargin < 2)
  fileName = '';
end
if (nargin < 3)
  addCmt = '';
end

[pathstr,name,ext,versn] = fileparts(pathTo_logsINI);
% if filename is empty & no name included as part of the path...
if ~length(fileName) & ~length(name)
  fileName = 'ProcessOPM_logs.ini';
end

fileName = sprintf('%s%s', pathTo_logsINI, fileName);
fidLOGS = fopen(fileName,'r');
logPaths = {};
logPathsDisabled = {};

if fidLOGS > 0
  %rule: a valid path must be on a line and begin with \\ or a letter with ":"
  % in the second location.  A line that starts with anything else is treated
  % as a comment and ignored.
  while ~feof(fidLOGS)
    textLine = fgetl(fidLOGS) ;
    if (length(textLine) > 1)
      disabled = findstrchr('(disabled)', textLine);
      if (disabled(1) == 1)
        logPathsDisabled(length(logPathsDisabled)+1) = {textLine};
      else %if (disabled(1) == 1)
        colonAt = findstrchr(':', textLine);
        % if network path or if <letter><colon>  (ex: C: )
        if (findstrchr('\\', textLine) == 1) | (ischar(textLine(1)) & (2 == colonAt(1)))
          %a test could go here to make sure the location is valid/available. a=dir(textLine);
          textLine = endWithBackSlash(textLine) ;
          logPaths(length(logPaths)+1) = {textLine};
        end % if (findstrchr('\\', textLine) == 1) | (ischar(textLine(1)) & (2 == colonAt(1)))
      end %if (disabled(1) == 1) else
    end % if (length(textLine) > 1)
  end % while ~feof(fidLOGS)
  fcloseIfOpen(fidLOGS);
else %if fidLOGS > 0
  [err, errMsg] = writeProcessOPM_Logs(logPaths, pathTo_logsINI, '', addCmt);
end %if fidLOGS > 0 else
