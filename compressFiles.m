function [err, errMsg] = compressFiles(pathNFileSpecificer, filesPerZip)


%might run faster to change to the file directory so the dosCmd doesn't need to include the path for each file:
%  the batch command line can then be shorter & more files can be per line which reduces the manipulation overhead
%  required to add files to a zip.  Should include a test to make sure the line doesn't get too long.

err = 0;
errMsg = '';

dirList = dir(pathNFileSpecificer);
[pathstr,name,ext,versn] = fileparts(pathNFileSpecificer);
pathstr = endWithBackSlash(pathstr);

numZips = ceil(length(dirList)/filesPerZip);
dirNdx = 0;
for thisZip = 1:numZips
  dosCmd = '';
  fid = fopen('compressFiles.bat','w');
  if fid < 1
    err= 1
    errMsg = 'unable to create batch file';
    return
  end
  for itemp = 1:filesPerZip
    if itemp+dirNdx > length(dirList)
      break
    end
    % % dosCmd = sprintf('%s "%s%s"', dosCmd, pathstr, char(dirList(itemp+dirNdx).name) );
    fprintf(fid,'"C:\\Program Files\\7-Zip\\7z.exe" a "%szipfile_%i.zip" %s%s\r\n', pathstr, thisZip, pathstr, char(dirList(itemp+dirNdx).name)) ;
  end
  fclose(fid);
  dirNdx = dirNdx + itemp;
  if itemp
% %     dosCmd = sprintf('"C:\\Program Files\\7-Zip\\7z.exe" a "%szipfile_%i.zip" %s', pathstr, thisZip, dosCmd);
    [err, errMsg] = dosIt('compressFiles.bat');
    if err
      return
    end
  end
end
