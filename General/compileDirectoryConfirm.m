function [err, errMsg] = compileDirectoryConfirm;
%confirm in correct directory.... by making sure 
%we are in the same directory as the initial calling routine (using dbstack which means we can't compile this module)  OLD: "makeExe_general.m" and
%not in or below "Release" or "Debug" (in case operator
%mistakenly copied files)
%VSS revision   $Revision: 4 $
%Last checkin   $Date: 8/28/09 2:55p $
%Last modify    $Modtime: 8/28/09 2:55p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

[err, errMsg, modName] = initErrModName(mfilename);
a = dbstack;
expectedDir= a(length(a)).name;
% OLD expectedDir = which('makeExe_general.m');
[expectedDir, name, ext,versn] = fileparts(expectedDir);
itemp = 0;
while 1
  a = lower(pwd);
  b = findstrchr('\debug', a);
  b = b(1);
  c = findstrchr('\release', a);
  c = c(1);
  %if neither \debug nor \release are in the pwd....
  if (b+c) < 1
    %...if we're in the expected directory, return
    if strcmp(lower(expectedDir), a)
      break
    end
    %\debug nor \release is in the pwd so we are off somewhere else
    d = expectedDir;
  else
    d = a(1:b+c-1);
  end
  itemp = 1;
  button = questdlg(sprintf('Not in expected directory.  In "%s". What is yout desired action?', pwd),...
    'Confirm Directory ', sprintf('Switch to "%s"', d),'Ignore/Continue','Cancel', a);
  if strcmp(button,'Cancel')
    errMsg = 'User cancel';
    %if "progress" figure is not open, message will still be printed to command window
    progress('listboxMsg_Callback',errMsg);
    progress('updateStatusCurrent', 'Fail');
    err = 1;
    return
  end
  if strcmp(button,'Ignore/Continue')
    progress('listboxMsg_Callback',sprintf('Staying in directory "%s"...', a) );
    itemp = 0;
    break
  end
  cd(d)
end  
if itemp
  progress('listboxMsg_Callback',sprintf('Directory successfully switched to "%s"', a) );
end
