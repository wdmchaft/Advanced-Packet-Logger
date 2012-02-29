function [var, foundFlg] = findNextract(key, verbose, writeFile, fid, DirWrite);
%function [var, foundFlg] = findNextract(key, verbose, writeFile, fid);
%Reads the "fid" file looking for a line starting with the key word - no
%leading spaces.   "findSpaceNextract" is similar but allows leading spaces.
%If found, will return the text string after the "=".  The
%returned variable will have leading & trailing spaces removed.
%If the key word starts with Dir, returned variable will be terminated with "\"
%  line:<key> = <var> will return strtrim(var) & foundFlg will be set.
%To allow the reading of variables from the file in any order, if the <key>
%is not found, will attempt again from the begining of "fid"
%
%INPUT:
% key: the text that starts the line of interest.  Everything to the left
%  of "=" (the space(s) after the text & before the "=" aren't requried)
% verbose: when non-zero, status will be printed to the console
% writeFile: when set, will call "writeTxt" to write a text file named
%  ini_<key>.txt in DirWrite
% fid: pointer to the file of interest.  File must be open.  This module
%   will not close the file but might change where we are in the file
%   (see the explanation of how this module retries.)
%OUTPUT:
% var: the text after the "=" on the lines that starts with <key>
%    <key> = <var>    <var> has leading and trailing spaces removed.
%   If no line is found starting with <key>, the returned value will be
%   an empty string.
% foundFlg: set when a line starting with <key> is found.  Cleared if not.
%       = 1: key found & text found other than spaces after =
%       = 2: key found, = found but not text after =
%ALSO SEE
% "findNextractNum": calls this module and then converts <var> to a number

if nargin < 3
  writeFile = 0;
end
if nargin < 5
  DirWrite = '';
end

var = '';
foundFlg = 0;
%if we don't find it the first time, perhaps the call for this "key"
% was done out of sequentional order per the INI file.  We'll try a second time from the beginning
for retry = 0:1
  textLine = '';
  while ~any(1==findstrchr(textLine, key)) & ~feof(fid)
    textLine = fgetl(fid);
  end
  if feof(fid) & ~findstrchr(textLine, key)
    %EOF & blank textLine: go to the beginning of the file & try again
    fseek(fid, 0, 'bof');
  else % if feof(fid) & ~length(textLine)
    %the key must start the line
    if any(1 == findstrchr(textLine, key))
      [var, foundFlg] = afterEqual(textLine);
      %if this is a directory declaration, make sure it is \ terminated
      if (findstrchr('Dir', key) == 1) & foundFlg
        var = endWithBackSlash(var);
      end 
    else % if any(1 == findstrchr(textLine, key))
      var = '';
      foundFlg = 0;
    end % if any(1 == findstrchr(textLine, key)) else
    %when found, break out of the retry loop
    break;
  end %  if feof(fid) & ~length(textLine) else
end %for retry = 0:1
if foundFlg & writeFile
  writeTxt(var, key, verbose, DirWrite);
end
if verbose
  if length(var)
    logSession(sprintf('\r\n%s = %s', key, var), verbose);
  else
    logSession(sprintf('\r\nNo value found for "%s"', key), verbose);
  end
end
%----------------------
function [var, foundFlg] = afterEqual(textLine)

equalAt = findstrchr(textLine,'=');
if equalAt
  if length(textLine) > equalAt(1)
    var = strtrim(textLine(equalAt(1)+1:length(textLine)));
    foundFlg = 1;
  else
    var = '';
    % key found & "=" found but nothing after the =
    foundFlg = 2;
  end
else
  var = '';
  foundFlg = 0;
end
%----------------------
