function [err, errMsg, text] = findKey(keyText, fid, fileName);
%function [err, errMsg, text] = findKey(keyText, fid, fileName);
% *** intended to be called from 'findKeyText' ***
%  Searches in fileName for a line *beginning* with the contents of
% 'keyText'.  When found, returns the text following '=' and pulls all
% non-printable characters from the text as well as all leading blanks
% which are the blanks immediately after the '='.
%Search starts at current line w/in file and continues to end of file but
% does NOT wrap to beginning of file
%err: 1 = key text not found.  Perhaps try from the beginning of the file.
%     2 = key text found but deliminter not found.  Whoops: not correct format.
%  'fid' must refer to an open file.
%VSS revision   $Revision: 9 $
%Last checkin   $Date: 5/26/06 4:21p $
%Last modify    $Modtime: 5/26/06 8:00a $
%Last changed by$Author: Arose $
%  $NoKeywords: $
global testDEBUGrelease %place nothing else on this line: only for use on desktop (automatically removed by compile procedure) 

err = 0;
errMsg = '';
text = '';
while ( ~feof(fid) )
  line = fgets(fid);
  if (line < 0)
    err = 1;
    if testDEBUGrelease %this line removed by "modifyCode4Compile"
      %code for use in debug compile mode is here
      errMsg = sprintf('%s: Unable to find "%s"', mfilename, keyText);
    else % if testDEBUGrelease (this line removed by "modifyCode4Compile")
      %code for use in release compile mode is here
      errMsg = sprintf('%s: 1 "%s"', mfilename, keyText);
    end % if testDEBUGrelease else  (this line removed by "modifyCode4Compile")
    return
  end
  a = findstr(upper(keyText), upper(line) ); 
  if (size(a, 1))
    if (a == 1)
      break;
    end
    a = '' ;
  end
end

if ( ~(size(a, 1)) )
  err = 1;
  if testDEBUGrelease %this line removed by "modifyCode4Compile"
    %code for use in debug compile mode is here
    errMsg = sprintf('%s: Unable to find "%s"', mfilename, keyText);
  else % if testDEBUGrelease (this line removed by "modifyCode4Compile")
    %code for use in release compile mode is here
    errMsg = sprintf('%s: 2 "%s"', mfilename, keyText);
  end % if testDEBUGrelease else  (this line removed by "modifyCode4Compile")
  return
end

%extract what follows the key text
a = findstr('=', line);
if length(a) > 0
  text = line([a(1) + 1:length(line)] );
  %pull leading blanks 
  while (length(text) > 0)
    if (32 == double(text(1)))
      tempText = text([2:length(text)]);
      text = tempText;
    else
      break
    end
  end
  
  %pull control & non-printable characters anywhere 
  itemp = 1;
  while (itemp <= length(text))
    a = double(text(itemp)) ;
    %if non-printable...
    if (a < 32)
      %if first character...
      if (itemp == 1)
        tempText = text([2:length(text)]);
      else
        tempText = text([1:(itemp-1)]);
        tempText = strcat(tempText, text([(itemp+1):length(text)]));
      end
      %move the adjust text back into the real variable
      text = tempText;
    else
      %else... this is a printable character: look at the next
      itemp = itemp + 1;
    end
  end %while (itemp <= length(text))
else
  err = 2;
  if testDEBUGrelease %this line removed by "modifyCode4Compile"
    %code for use in debug compile mode is here
    errMsg = sprintf('%s: Unable to find the delimiter ("=" ).', mfilename);
  else % if testDEBUGrelease (this line removed by "modifyCode4Compile")
    %code for use in release compile mode is here
    errMsg = sprintf('%s: =', mfilename, keyText);
  end % if testDEBUGrelease else  (this line removed by "modifyCode4Compile")
end
