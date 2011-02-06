function dispNghbrhdSmry_demo(pathIt);
%Demo for Neighborhood Summary Chart:
% uses series of logs from actual drill
% updates eLog & separate instance of display neighborhood summary
%   responds to change, perform updated.

global userCancel
userCancel = 0;
cancel
checkCancel

pathIt = endWithBackSlash(pathIt);

a = '';
if nargin < 1
  % hand tuned for the demo system configurations used so far
  %  code works through the list to find a path that works.
  pathList = {'F:','\\Hplapw98\d\','\\AROSE_H\f','C:'};  
  fprintf('\nSearching for Logs:');
  for itemp=1:length(pathList)
    pathIt = endWithBackSlash(pathList{itemp});
    fprintf('\ntrying %s...', pathIt);
    a = dir(pathIt);
    if length(a)
      break
    end
  end
else
  a = dir(endWithBackSlash(pathIt));
end
if ~length(a)
  currentDir = pwd;
  try
    cd (pathIt)
  catch
  end
  [fname, pname] = uigetfile('packetCommLog_101108_Recvd_*.csv');
  cd (currentDir);
  % if cancel:
  if isequal(fname,0) | isequal(pname,0)
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
    fprintf('\n*** User cancel: unable to find the directory containing the logs ***')
    return
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
  end
end
fprintf('found %s!', pathIt);

pathToOutpost = strcat(pathIt, 'MTV_radioRoom_101107\SCCo Packet on cmv13706\');
pathToLogs = strcat(pathToOutpost, 'logs\');

a = 'Program to assist in demonstrating the EOC DA Summary';
a = sprintf('%s\nStart this program first and then "dispNghbrhdSmry"', a);
a = sprintf('%s\n\nIf "dispNghbrhdSmry" is now running, you need to shut it down until instructed.', a);
a = sprintf('%s\n\nThis program is set to access the log at "%s".', a, pathToLogs);
a = sprintf('%s\nYou need to make sure that the computer that will be running "dispNghbrhdSmry" has', a);
a = sprintf('%s\nits "c:\\pathToOutpost.txt" contain the path\n"%s"', a, pathToOutpost);
a = sprintf('%s\n(with the proper drive letter)', a);
% a = sprintf('%s', a);
% a = sprintf('%s', a);
str1 = 'Continue';
str2 = 'Cancel';
button = questdlg(a,'Start Demo', str1, str2, str1);
if strcmp(button, str2) % Cancel
  fprintf('\nUser abort/cancel');
  return
end

%build the series of eLogs
if 0
  fpathName = strcat(pathIt, '\MTV_radioRoom_101107\SCCo Packet on cmv13706\logs\packetCommLog_101108_Recvd');
  list ={};
  %load list of log until outpost time changes:
  %  write list to a file with a unique name 
  %continue extending list until time changes again
  %  write extended list to a file with a unique name
  %repeat until end of log is found -> task complete!
  fidIn = fopen(strcat(fpathName,'.csv'), 'r');
  if (fidIn<1)
    fprintf('oops!');
    return
  end
  lineNdx = 0;
  while 1
    textLine = fgetl(fidIn);
    lineNdx = lineNdx + 1;
    list(lineNdx) = {textLine};
    if length(findstrchr('=', textLine)) > 45
      break
    end
  end
  commaToUse = 3;
  timeStamp = '';
  fileNdx = 1;
  while 1
    textLine = fgetl(fidIn);
    commasAt = findstrchr(textLine,',');
    [err, errMsg, timeNow] = extractTextFromCSVText(textLine, commasAt, commaToUse);
    if ~length(timeStamp)
      timeStamp = timeNow;
    end
    if ~strcmp(timeStamp, timeNow) | feof(fidIn)
      timeStamp = timeNow;
      a = sprintf('%i',fileNdx);
      if length(a) <2
        a = strcat('0',a);
      end
      if feof(fidIn)
        lineNdx = lineNdx + 1;
        list(lineNdx) = {textLine};
      end
      fidOut = fopen(sprintf('%s_%s.csv', fpathName, a),'w');
      for itemp = 1:length(list)
        fprintf(fidOut, '%s\r\n', char(list(itemp)));
      end
      fclose(fidOut);
      fileNdx = fileNdx + 1;
      if feof(fidIn)
        break
      end
    end
    lineNdx = lineNdx + 1;
    list(lineNdx) = {textLine};
  end
  fcloseIfOpen(fidIn)
end

%2nd piece: 
% (0) on 2nd computer or in another instance on this computer,
%     start display & video capture
% (1) read first file & copy/write as <name>: display will update
% (2) wait some amount of time or until key press
% (3) read 2nd file and overwrite <name>: display will update
% (4) repeat 2&3 until all files are processed

fPath = pathToLogs;
a = dir (strcat(fPath, 'packetCommLog_101111_Recvd.csv'));
if length(a)
  delete(strcat(fPath, 'packetCommLog_101111_Recvd.csv'));
end

str1 = 'Continue';
str2 = 'Cancel';
a = 'Ready for you to start "dispNghbrhdSmry.m"';
a = sprintf('%s\n\nStart from command line with "dispNghbrhdSmry(%s)"', a, strcat(fPath, 'packetCommLog_101111_Recvd.csv'));
a = sprintf('%s\nor start "dispNghbrhdSmry" and then after message appears here\n that the first file has been processed appears here File->Open Log to that log.', a);
button = questdlg(a,'Start Demo', str1, str2, str1);
if strcmp(button, str2) % Cancel
  fprintf('\nUser abort/cancel');
  return
end

fileList = dir(strcat(fPath, 'packetCommLog_101108_Recvd_*.*'));
msgDly = [...
6,...
11.1,...
11.2,...
5,...
6,...
6,...
6,...
5,...
6,...
12];
totDly = 0;%5;
firstWait(totDly, pathIt);
% % if ~totDly
% %   [nextWaitScanUpdate, h_waitBar] = ...
% %     initWaitBar('6',0.1,'northwest');
% %   tic
% % end
for Ndx = 1:length(fileList)
  thisFile = fileList(Ndx).name;
  fprintf('\nworking #%i %s', Ndx, thisFile);
  %
  % write flag file
  %
  fidIn = fopen(strcat(fPath, thisFile),'r');
  fidOut = fopen(strcat(fPath, 'packetCommLog_101111_Recvd.csv'),'w');
  while ~feof(fidIn)
    textLine = fgetl(fidIn);
    fprintf(fidOut, '%s\r\n', textLine);
  end
  fcloseIfOpen(fidIn);
  fcloseIfOpen(fidOut);
  fprintf('\n %f', toc);
  a = [];
  if ~totDly
    cnt = 0;
  else
    cnt = 100;
  end
  while (cnt & ~length(a))
    a = dir(strcat(pathIt, '\MTV_radioRoom_101107\SCCo Packet on cmv13706\logs\flag.txt'));
    pause(0.2)
    cnt = cnt - 1;
    checkCancel
    if userCancel
      break
    end
  end % while (cnt & ~length(a))
  % erase the flag file
  if totDly
    delete(strcat(pathIt, '\MTV_radioRoom_101107\SCCo Packet on cmv13706\logs\flag.txt'));
  end
% %   tic;
% %   while (toc < (totDly))
% %     %wait for operator
% %     checkUpdateWaitBar(toc / totDly, h_waitBar);
% %     if userCancel
% %       break
% %     end
% %   end
% %   delete(h_waitBar)
  if userCancel
    break
  end
% %   if ~totDly
% %     [nextWaitScanUpdate, h_waitBar] = ...
% %       initWaitBar(sprintf('%f',msgDly(min(Ndx,length(msgDly)))),0.1,'northwest');
% %   end
  a = sprintf('Log #%i (of %i) %s has been used - summary should be updating', Ndx, length(fileList), thisFile);
  a = sprintf('%s\n\nHit OK when you are ready for next log', a);
  button = questdlg(a,'Continue', str1, str2, str1);
  if strcmp(button, str2) % Cancel
    fprintf('\nUser abort/cancel');
% %     dbclear in 'dispNghbrhdSmry_demo'
    return
  end
end

%----------------------------------------------
function firstWait(totDly, pathIt)
global userCancel
if ~totDly
  cnt = 0;
else
  cnt = 100;
end
a = dir(strcat(pathIt, '\MTV_radioRoom_101107\SCCo Packet on cmv13706\logs\flag.txt'));
if length(a)
  delete(strcat(pathIt, '\MTV_radioRoom_101107\SCCo Packet on cmv13706\logs\flag.txt'));
end
while (cnt & ~length(a))
  a = dir(strcat(pathIt, '\MTV_radioRoom_101107\SCCo Packet on cmv13706\logs\flag.txt'));
  pause(0.2)
  cnt = cnt - 1;
  checkCancel
  if userCancel
    return
  end
end % while (cnt & ~length(a))
% % [nextWaitScanUpdate, h_waitBar] = ...
% %   initWaitBar('6',0.1,'northwest');
% % tic;
% % while (toc < (totDly*3))
% %   %wait for operator
% %   checkUpdateWaitBar(toc / (3*totDly), h_waitBar);
% %   if userCancel
% %     return
% %   end
% % end
% % delete(h_waitBar)
% % if userCancel
% %   return
% % end
%----------------------------------------------
%----------------------------------------------
%----------------------------------------------
