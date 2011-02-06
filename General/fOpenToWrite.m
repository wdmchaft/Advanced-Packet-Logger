function [err, errMsg, fidOut] = fOpenToWrite(filePathName, writeMode, callerName);
%function [err, errMsg, fidOut] = fOpenToWrite(filePathName[, writeMode[, callerName]]);
%If unable to open the file for write or append (as specified),
% will give user choice of Retry or Cancel.  The choice window
% includes the suggestion "It might be open in Excel or another program."
%INPUT
% filePathName: full path, name, & extension for file.
% writeMode[optional]: desired mode to open file, w - write, a - append
%       default is 'w'... since that is name name of this module
% callerName[optional]: when there is a problem, used as part of title for the pop up window
%OUTPUT
% err: 0 if fopen successful, even if Retry was needed; 1 if user cancelled
% errMsg: null if successful, message including full name & path and operation attempted (write or append) 

[err, errMsg, modName] = initErrModName(mfilename);

if nargin < 2
  writeMode = '';
end
if nargin < 3
  callerName = '';
end
if ~length(writeMode) 
  writeMode = 'w';
end
fidOut = fopen(filePathName, writeMode);
if fidOut < 1
  %have observed that a console "copy" has interferred momentarily
  %so we'll build in an automatic retry which includes a slight delay
  pause(0.01);
  lasterr(''); 
  [fidOut, str] = fopen(filePathName, writeMode);
  %retry didn't work so must be a substantial issue
  while fidOut < 1
    a = '?' ;
    if (findstrchr('w', writeMode) == 1)
      a = 'write';
    elseif (findstrchr('a', writeMode) == 1)
      a = 'append';
    end
    if length(callerName)
      titl = sprintf('Write Blocked in "%s"', callerName);
    else
      titl = 'Write Blocked';
    end
    button = questdlg(sprintf('Unable to open to %s to "%s".  It might be open in Excel or another program.  If you want this file to be update now, please close that application and press Retry (%s %i)', a, filePathName, str, fidOut),...
      titl, 'Retry','Cancel','Retry');
    if strcmp(button,'Retry')
      [fidOut, str] = fopen(filePathName,writeMode);
    elseif strcmp(button,'Cancel')
      err = 1;
      errMsg = sprintf('%s: user abort - failed open to %s to "%s"', modName, a, filePathName);
      return
    end  
  end %while fidOut < 1
end