function [val, foundFlg] = findNextractNum(key, verbose, writeFile, fid, DirWrite);
%function [var, foundFlg] = findNextractNum(key, verbose, writeFile, fid);
%Reads the "fid" file looking for a line starting with the key word - no
%leading spaces.  If found, will return the numeric value after the "=". 
%  line:<key> = <var> will return str2num(var) & foundFlg will be set.
%To allow the reading of variables from the file in any order, if the <key>
%is not found, will attempt again from the begining of "fid"
%
%INPUT:
% key: the text that starts the line of interest.  Everything to the left
%  of "=" (the space(s) after the text & before the "=" aren't requried)
% verbose: when non-zero, status will be printed to the console
% writeFile: when set, will call "writeTxt" to write a text file named
%  ini_<key>.txt in DirScripts (passed to writeTxt via a global)
% fid: pointer to the file of interest.  File must be open.  This module
%   will not close the file but might change where we are in the file
%   (see the explanation of how this module retries.)
%OUTPUT:
% var: the numeric value of what follows "=" on the lines that starts with <key>
%    <key> = <var>    Calls "findNextract" and then operates on the results.
%   If no line is found starting with <key>, the returned value will be
%   an empty string.
% foundFlg: set when a line starting with <key> is found.  Cleared if not.
%ALSO SEE
% "findNextract": called by this module; returns the text after "="
if nargin < 3
  writeFile = 0;
end
if nargin < 4
  fid = 0;
end
if nargin < 5
  DirWrite = '';
end

[a, foundFlg] = findNextract(key, verbose, writeFile, fid, DirWrite);
if ~foundFlg
  val = 0;
  return
end

commentAt = findstrchr('%', a);
if commentAt(1)
  if commentAt(1) > 1
    a = a(1:commentAt(1)-1) ;
  else
    a = '';
  end
end
if length(a)
  val = str2num(a);
  foundFlg = 1;
else
  val = 0;
  foundFlg = 0;
end
