function [err1, errMsg, text, fid] = findKeyText(keyText, fid, fileName, errIn, errMsgIn);
%function [err1, errMsg, text, fid] = findKeyText(keyText, fid, fileName[, errIn, errMsgIn]);
%  Searches in fileName for a line *beginning* with the contents of
% 'keyText'.  When found, returns the text following '='
%Search starts at current line w/in file and continues to end of file but
%if not found, will wrap to the beginning of the file.
%  if 'fid' is <0, will open file.  Note that after all findKey... calls
%needed by calling program, the calling program will need to perform a
% fclose(fid)
%Optional inputs err & errMsg.  If included and if err has a non-zero value,
% this function will immediately return passing back the err & errMsg values.
% This is merely to simplify the calling structure and avoid checking structure in the calling:
%   [err, errMsg, response, fid] = findKeyText(...);
%   if (~err)
%       [err, errMsg, response, fid] = findKeyText(...);
%   end
%can be done with
%   [err, errMsg, response, fid] = findKeyText(...);
%   [err, errMsg, response, fid] = findKeyText(..., err, errMsg);
%VSS revision   $Revision: 5 $
%Last checkin   $Date: 6/06/06 2:26p $
%Last modify    $Modtime: 6/02/06 4:47p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

% For some unknown reason, calling the error variable 'err' prevented
%it from actaully returning a non-zero value to findKeyNumber...

global testDEBUGrelease %place nothing else on this line: only for use on desktop (automatically removed by compile procedure) 

[err1, errMsg, modName] = initErrModName(mfilename);

text = '';
if nargin > 3
  if (errIn ~= 0)
    err1 = errIn;
    errMsg = errMsgIn;
    return
  end
end

if (fid > -1)
  if length(fopen(fid)) > 0
    if (~feof(fid))
      [err, errMsg, text] = findKey(keyText, fid, fileName);
      if (err == 0 | err == 2)
        err1 = err;
        if testDEBUGrelease %this line removed by "modifyCode4Compile"
          %code for use in debug compile mode is here
          errMsg = sprintf('%s%s', modName, errMsg);
        end % if testDEBUGrelease else  (this line removed by "modifyCode4Compile")
        return;
      end
    end
    fclose(fid);
  end  %if length(fopen(fid)) > 0
  fid = -1;
end

fid = fopen(fileName, 'r');

if (fid < 0)
  err1 = 301;
  if testDEBUGrelease %this line removed by "modifyCode4Compile"
    %code for use in debug compile mode is here
    errMsg = sprintf('%s: unable to open file [%s]', modName, fileName);
  else % if testDEBUGrelease (this line removed by "modifyCode4Compile")
    %code for use in release compile mode is here
    errMsg = sprintf('%s: [%s]', modName, fileName);
  end % if testDEBUGrelease else  (this line removed by "modifyCode4Compile")
  return
end

[err, errMsg, text] = findKey(keyText, fid, fileName);
if (err)
  if (fid > -1)
    fclose(fid);
    fid = -1;
  end
  err1 = err;
  if testDEBUGrelease %this line removed by "modifyCode4Compile"
    %code for use in debug compile mode is here
    errMsg = sprintf('%s%s', modName, errMsg);
  end % if testDEBUGrelease else  (this line removed by "modifyCode4Compile")
  return
end

