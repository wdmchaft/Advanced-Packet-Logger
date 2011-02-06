function [err, errMsg, h_] = displayLoadOrder(path, h_)
%INPUT
% h_.dispColFName: if blank or missing, popup will give
%   operator choice of files to load
% h_.dispColHdg: establishes minimum number of entries need to be in
%   h_.dispColFName
%OUTPUT
% h_.dispColOrdr

[err, errMsg, modName] = initErrModName(mfilename) ;
if nargin < 2
  h_.dispColFName = '';
end

if ~length(h_.dispColFName)
  currentDir = pwd;
  cd(path) ;
  coreName = '_monitor.txt';
  [fname, pname] = uigetfile(strcat('*', coreName));
  cd (currentDir);
  % if cancel:
  if isequal(fname,0) | isequal(pname,0)
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
    err = 1; 
    errMsg = sprintf('%s: user cancel.', modName);
    return
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
  end % if isequal(fname,0) | isequal(pname,0)
  path = endWithBackSlash(pname);
  h_.dispColFName = fname;
end % if ~length(h_.dispColFName)

fid = fopen(strcat(path, h_.dispColFName),'r');
if fid < 1
  err = 1; 
  errMsg = sprintf('%s: unable to open "%s" to read.', modName, strcat(path,h_.dispColFName));
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
  return
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
end

textLine = '';
while ~feof(fid) & ~findstrchr(textLine,'Order, Visible, Heading')
  textLine = fgetl(fid);
end
count = 0;
%learn the file format revision.  Intended for internal use should
%  we add items to the file or alter its structure.
[textLine, commasAt] = fgetl_valid(fid) ;
[err, errMsg, fileRev] = extractFromCSVText(textLine, commasAt, 1);

while ~feof(fid) & length(textLine)
  [textLine, commasAt] = fgetl_valid(fid) ;
  count = count + 1 ;
  [err, errMsg, h_.dispColOrdr(count,1)] = extractFromCSVText(textLine, commasAt, 0);
  [err, errMsg, h_.dispColOrdr(count,2)] = extractFromCSVText(textLine, commasAt, 1);
  [err, errMsg, heading] = extractStripQuotes(textLine, commasAt, 2);
end
fclose(fid);
%some validity checks - not checking for duplication of column
% the checks are here in case somebody manually altered the file
% the checks are limited to those that will cause the displayCounts to reject. (won't crash because try/catch)
if size(h_.dispColOrdr, 1) < length(h_.dispColHdg)
  err = 1;
  errMsg = sprintf('%s: two few entries in "%s" (%i < %i)', modName, strcat(path, h_.dispColFName),...
    size(h_.dispColOrdr, 1), length(h_.dispColHdg));
end
if (any(find(h_.dispColOrdr(:,1) < 1)) | any(find(h_.dispColOrdr(:,1) > length(h_.dispColHdg))) )
  if length(errMsg)
    errMsg = sprintf('%s;', errMsg);
  else
    errMsg = sprintf('%s: in "%s"', modName, strcat(path, h_.dispColFName));
  end
  errMsg = sprintf('%s invalid order value detected (<1 or > %i)', errMsg, length(h_.dispColHdg));
end
if (any(find(h_.dispColOrdr(:,2) < 0)) | any(find(h_.dispColOrdr(:,2)>1)) )
  if length(errMsg)
    errMsg = sprintf('%s;', errMsg);
  else
    errMsg = sprintf('%s: in "%s"', modName, strcat(path, h_.dispColFName));
  end
  errMsg = sprintf('%s invalid visbility value detected (<0 or > 1)', errMsg);
end
a = findstrchr(h_.dispColFName, coreName);
h_.dispColFName = h_.dispColFName(1:(a(1)-1));
