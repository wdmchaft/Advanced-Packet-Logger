%makeCopyCode

%expects user in the compile popups to chose debug
%if compile successful, copies the created .exe to '....\Outpost\archive\'

makeDiagnostics

if err
  fprintf('Error: %i %s', err, errMsg);
else
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
    if ((findstrchr('displayCounts', thisCore )) & (length('displayCounts.m') >= length(thisCore)))
      err = bac_it('\mFiles\Ham Radio\', toPath, 'display*.fig');
      err = bac_it('\mFiles\Ham Radio\', toPath, 'logPrint.fig');
      %     elseif ((findstrchr('packetLogSettings', thisCore )) & (length('packetLogSettings.m') >= length(thisCore)))
      %       err = bac_it('\mFiles\Ham Radio\', toPath, strcat(thisCore,'packetLogSettings.fig');
    else
      err = bac_it('\mFiles\Ham Radio\', toPath, strcat(name,'.fig'));
    end
  else
    fprintf('\r\nError copying "%s" to "%s".', fromPathName, toPath);
    fprintf('\r\nError message: %s.', msg);
  end
end