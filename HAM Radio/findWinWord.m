function pathNameOfWord = findWinWord(pathNameOfWord);
% function pathNameOfWord = findWinWord(pathNameOfWord);

[pathstr,name,ext,versn] = fileparts(pathNameOfWord);
pathstr = endWithBackSlash(pathstr);
if ~length(name) | ~length(ext)
  pathNameOfWord = sprintf('%swinword.exe', pathstr);
end
a = dir(pathNameOfWord) ;
if length(a)
  return
end

currentDir = pwd;
a = dir(strcat(pathstr,'*.'));
if length(a)
  cd (handles.logPath);
end
[fname, pname] = uigetfile('WinWord*.exe');
cd (currentDir);
% if cancel:
if isequal(fname,0) | isequal(pname,0)
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
  return
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
end
pathNameOfWord = strcat(fname, pname);
