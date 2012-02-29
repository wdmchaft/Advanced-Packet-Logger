%makeCopyCode

%expects user in the compile popups to chose debug
%if compile successful, copies the created .exe to '....\Outpost\archive\'

makeDiagnostics

if err
  fprintf('Error: %i %s', err, errMsg);
else % if err
  if iscellstr(coreModules(1))
    thisCore = char(coreModules(1));
  else
    thisCore = coreModules;
  end
  [pathstr,name,ext,versn] = fileparts(thisCore);
  fromPathName = sprintf('%s%s.exe', endWithBackSlash(targetDir), name) ;
  [err, errMsg, outpostNmNValues] = OutpostINItoScript; 
  if findstrlen('OutpostINItoScript', thisCore)
    toPath = outpostValByName('DirOutpost', outpostNmNValues);
  else
    toPath = outpostValByName('DirAddOnsPrgms', outpostNmNValues);
  end
  [status,msg] = copyfile(fromPathName, toPath);
  if status 
    fprintf('\r\nCopied "%s" to "%s".', fromPathName, toPath);
    sourceFileDir = '\mFiles\Ham Radio\';
    if ((findstrchr('displayCounts', thisCore )) & (length('displayCounts.m') >= length(thisCore)))
      err = bac_it(sourceFileDir, toPath, 'display*.fig');
      err = bac_it(sourceFileDir, toPath, 'logPrint.fig');
      %     elseif ((findstrchr('packetLogSettings', thisCore )) & (length('packetLogSettings.m') >= length(thisCore)))
      %       err = bac_it('\mFiles\Ham Radio\', toPath, strcat(thisCore,'packetLogSettings.fig');
    else % if status
      err = bac_it(sourceFileDir, toPath, strcat(name,'.fig'));
    end % if status
    % Look for an associated .inc file & be sure to include the files it specifies    
    [pathstr,name,ext,versn] = fileparts(thisCore);
    a = dir(sprintf('%s%s.inc', sourceFileDir, name));
    if length(a)
      [err, errMsg, fileList] = incFileToList(strcat(sourceFileDir, a(1).name));
      for itemp = 1:length(fileList)
        [pathstr,name,ext,versn] = fileparts(fileList{itemp});
        err = 0
        if length(pathstr)
          % assuming the file's path is a subset of the "toPath"
          a = findstr(toPath, pathstr);
          b = strcat(toPath(1:(a-1)), pathstr)
          err = bac_it(sourceFileDir, b, fileList{itemp});
        else          
          err = bac_it(sourceFileDir, toPath, fileList{itemp});
        end
      end % for itemp = 1:length(fileList)
    end  % if length(a)
  else % if status 
    fprintf('\r\nError copying "%s" to "%s".', fromPathName, toPath);
    fprintf('\r\nError message: %s.', msg);
  end % if status else
end % if err else (first err)