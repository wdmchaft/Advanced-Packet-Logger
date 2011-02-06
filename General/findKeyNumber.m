function [err, errMsg, number, fid, text] = findKeyNumber(keyText, fid, fileName, errIn, errMsgIn, defaultNumber);
%function [err, errMsg, number, fid] = findKeyNumber(keyText, fid, fileName[, errIn, errMsgIn[, defaultNumber]]);
%  Searches in fileName for a line *beginning* with the contents of
% 'keyText'.  When found, returns the number following '='.  
%Search starts at current line w/in file and continues to end of file but
%if not found, will wrap to the beginning of the file. If not found, an error
% will be reported and the returned value will be set to 0.
%  if 'fid' is <0, will open file.  Note that after all findKey... calls
%neded by calling program, the calling program will need to perform a
% fclose(fid)
%Optional inputs err & errMsg and as an additional option 'defaultNumber'.  If included and if err has a non-zero value,
% this function will immediately return passing back the err & errMsg values.  If 'defaultNumber' is included, 'number' will 
% be then be set to 'defaultNumber'.  If not included, number will be set to 0.
% This is merely to simplify the calling structure and avoid checking structure in the calling:
%   [err, errMsg, response, fid] = findKeyText(...);
%   if (~err)
%       myData = response;
%       [err, errMsg, response, fid] = findKeyText(...);
%   end
%can be done with
%   [err, errMsg, myData, fid] = findKeyText(..., 0, '', defaultMyData);
%   [err, errMsg, myData2, fid] = findKeyText(..., err, errMsg, defaultMyData2);
%VSS revision   $Revision: 10 $
%Last checkin   $Date: 6/06/06 2:26p $
%Last modify    $Modtime: 6/02/06 4:26p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

global testDEBUGrelease %place nothing else on this line: only for use on desktop (automatically removed by compile procedure) 
[err, errMsg, modName] = initErrModName(mfilename);

if nargin < 4
  errIn = 0;
  errMsgIn = '';
end
if nargin < 6
  defaultNumber = 0;
end
[err, errMsg, text, fid] = findKeyText(keyText, fid, fileName, errIn, errMsgIn);
if (err)
  number = defaultNumber;
  %%%%%%%%%%%%%%%
  return
  %%%%%%%%%%%%%%%
end
if (length(findstr('.', text)) > 1)
  err = 1;
  if testDEBUGrelease %this line removed by "modifyCode4Compile"
    %code for use in debug compile mode is here
    errMsg = sprintf('%s: multiple decimal points detected.', modName);
  else % if testDEBUGrelease (this line removed by "modifyCode4Compile")
    %code for use in release compile mode is here
    errMsg = sprintf('%s: points', modName);
  end % if testDEBUGrelease else  (this line removed by "modifyCode4Compile")
  number = defaultNumber;
  %%%%%%%%%%%%%%%
  return;
  %%%%%%%%%%%%%%%
end
if length(text) < 1
  number = defaultNumber;
  %%%%%%%%%%%%%%%
  return
  %%%%%%%%%%%%%%%
end
number = str2num(text);
if length(number) > 1
  err = 1;
  if testDEBUGrelease %this line removed by "modifyCode4Compile"
    %code for use in debug compile mode is here
    errMsg = sprintf('%s: array detected when single variable expected.', modName);
  else % if testDEBUGrelease (this line removed by "modifyCode4Compile")
    %code for use in release compile mode is here
    errMsg = sprintf('%s: array', modName);
  end % if testDEBUGrelease else  (this line removed by "modifyCode4Compile")
  number = defaultNumber;
  %%%%%%%%%%%%%%%
  return;
  %%%%%%%%%%%%%%%
end
