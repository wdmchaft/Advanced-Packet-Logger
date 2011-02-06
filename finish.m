%finish
%Matlab automatically calls this script, "finish", when the user shuts it down/exits.

% We want to start next time in the same working directory
%  which is variable.  We'll store the name of the directory in
%  a file in '\matlab6p1\work' which we first need to locate
%  explicitly because it may not be on the current drive!
a = path;
b = findstrchr('\matlab6p1\work', lower(a));
if b
  c = findstrchr(';', a);
  %find the separator before the text
  d = find(c < b);
  %if found, use the last separator in the set
  if length(d)
    d = c(d(length(d)));
  else
    %not found: point just before the first character
    d = 0;
  end
  e = find(c > b);
  %if found, use the last separator in the set
  if length(e)
    e = c(e(1));
  else
    %not found: start with the first character
    e = length(a)+1;
  end
  %Found!
  matlabWork = a(d+1:e-1);
  %learn the current location...
  currentDir = pwd;
  %doing the 'cd' means the current directory's break points are not saved if
  % the directory is not in the path list!
  %   %switch directory
  %   cd (matlabWork)
  %save the path for the directory we had been using
  fid = fopen(strcat(endWithBackSlash(matlabWork), 'currentDir.txt'),'w');
  if fid > 0
    fprintf(fid,'%s', currentDir);
    fclose(fid);
  end
end %if b

%%%%%% NOTE: the following call cannot be in a function or the breakpoints aren't recorded %%%%%%%%
[fid, pathToINI] = findMatlabINI;
if (fid > 0)
  fclose(fid);
  [pathstr, name, ext, versn] = fileparts(pathToINI) ;
  pathstr = endWithBackSlash(pathstr);
  [Y,M,D,H,MI,S] = datevec(now);
  copyfile(pathToINI, sprintf('%sMATLAB_%i_%i_%i.ini', pathstr, M, D, H));
end %if (fid > 0)
saveBreakpoints;
