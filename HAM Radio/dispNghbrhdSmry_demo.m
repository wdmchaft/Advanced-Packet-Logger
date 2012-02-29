function dispNghbrhdSmry_demo(pathToDemoLog, coreNameOfList, monitoredName)
%function dispNghbrhdSmry_demo('C:\PacketDemoLogs\', 'packetCommLog_111022_Recvd')
%
% This program sequentially updates the log monitored by "dispNghbrhdSmry".
% The monitored log is re-written with data from sequentially numbered
%  files.  The monitored log is named <pathToDemoLog><monitoredName.csv> and the
%  sequentionally numberd files are <pathToDemoLog><coreNameOfList_nn.csv>
% The program pauses after each update, popping up a window for the user to
%  release the pause or abort.
%
%  Uses the sequence of log files created by "dispNghbrhdSmry_makeLogs"
%
% INPUT:
%   pathToDemoLog: path to both the source series of files, numbered with 01 through nn.
%   coreNameOfList: the common name portion of the list <name>_nn
%   monitoredName: the name of the file which will be monitored by
%     "dispNghbrhdSmry" during the demo.  
%

if (nargin < 1)
  pathToDemoLog = ''; 
  coreNameOfList = '';
  monitoredName = '';
  fid = fopen(sprintf('%s_prevRun.txt', mfilename),'r');
  if (fid > 0)
    pathToDemoLog = fgetl(fid); 
    coreNameOfList = fgetl(fid); 
    monitoredName = fgetl(fid); 
    fclose(fid);
  end
end
tic
if ~length(coreNameOfList)
  currentDir = pwd;
  if length(pathToDemoLog)
    a = dir(strcat(pathToDemoLog,'*.'));
    if length(a)
      cd (pathToDemoLog);
    end
  end 
  %if accessing network, bring up message
  if (1 == findstrchr('\\', pathToDemoLog))
    b = sprintf('Accessing network which may take a moment or two.');
    b = sprintf('%s (this message will automatically close or you may close it)', b);
    h_help = helpdlg(b, 'Accessing network');
    set(h_help, 'tag', mfilename); %for general closing...
  end
  [fname, pathToDemoLog] = uigetfile('packetCommLog_*_recvd*.csv');
  cd (currentDir);
  % if cancel:
  if isequal(fname,0) | isequal(pathToDemoLog,0)
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
    return
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
  end
  a = 'recvd';
  b = findstrchr(a, lower(fname));
  coreNameOfList = fname(1:(b+length(a)-1));
end


fPath = endWithBackSlash(pathToDemoLog) ;

fileList = dir(sprintf('%s%s_*.csv', fPath, coreNameOfList));

if length(fileList) < 1
  errordlg(sprintf('No files "%s_nn.csv" in \n in "%s%"', coreNameOfList, pathToDemoLog),'File Error');
  return
end
if nargin < 3
  monitoredName = coreNameOfList ;
end
fid = fopen(sprintf('%s_prevRun.txt', mfilename),'w');
if (fid > 0)
  fprintf(fid, '%s\r\n', pathToDemoLog); 
  fprintf(fid, '%s\r\n', coreNameOfList); 
  fprintf(fid, '%s\r\n', monitoredName); 
  fclose(fid);
end

a = 'Program to assist in demonstrating the EOC DA Summary';
a = sprintf('%s\n\nThis program is set to access the log "%s" at "%s".', a, monitoredName, pathToDemoLog);
a = sprintf('%s\nNormally you should start this program first and then "dispNghbrhdSmry"', a);
a = sprintf('%s\n\nIf "dispNghbrhdSmry" is now running, you can either: ', a);
a = sprintf('%s\n     1.) In "dispNghbrhdSmry", select a log other than "%s" to monitor until instructed.', a, monitoredName);
a = sprintf('%s\nor  2.) Exit "dispNghbrhdSmry", re-start it when instructed.', a);
% a = sprintf('%s', a);
% a = sprintf('%s', a);
str1 = 'Continue';
str2 = 'Cancel';
button = questdlg(a,'Start Demo', str1, str2, str1);
if strcmp(button, str2) % Cancel
  fprintf('\nUser abort/cancel');
  return
end


totDly = 0;
str1 = 'Continue';
str2 = 'Cancel';
if findstrchr('packetdemologs', lower(pathToDemoLog))
  str3 = 'No Delay';
end

for Ndx = 1:length(fileList)
  thisFile = fileList(Ndx).name;
  fprintf('\nworking #%i %s', Ndx, thisFile);
  %
  % write flag file
  %
  fidIn = fopen(strcat(fPath, thisFile),'r');
  fidOut = fopen(sprintf('%s%s.csv', fPath, monitoredName),'w');
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
    cnt = totDly;
  end
  % if cnt, wait for dispNghbrhdSmry to finish parsing.
  while (cnt & ~length(a))
    a = dir(strcat(fPath, 'flag.txt'));
    pause(0.2)
    cnt = cnt - 1;
%     checkCancel
%     if userCancel
%       break
%     end
  end % while (cnt & ~length(a))
  % erase the flag file
  if totDly
    delete(strcat(fPath, 'flag.txt'));
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
  %   if userCancel
  %     break
  %   end
  % %   if ~totDly
  % %     [nextWaitScanUpdate, h_waitBar] = ...
  % %       initWaitBar(sprintf('%f',msgDly(min(Ndx,length(msgDly)))),0.1,'northwest');
  % %   end
  if (Ndx < 2)
    a = sprintf('You may now start "dispNghbrhdSmry" if it isn''t running & set');
    a = sprintf('%s\nit to monitor the log "%s" at "%s".', a, monitoredName, pathToDemoLog);
    a = sprintf('%s\n\nLog #%i (of %i) %s has been used - summary should be updating', a, Ndx, length(fileList), thisFile);
  else
    a = sprintf('Log #%i (of %i) %s has been used - summary should be updating', Ndx, length(fileList), thisFile);
  end
  if ~totDly
    a = sprintf('%s\n\nHit OK when you are ready for next log', a);
    if findstrchr('packetdemologs', lower(pathToDemoLog))
      button = questdlg(a,'Continue', str1, str2, str3, str1);
    else
      button = questdlg(a,'Continue', str1, str2, str1);
    end
    if strcmp(button, str2) % Cancel
      fprintf('\nUser abort/cancel');
      % %     dbclear in 'dispNghbrhdSmry_demo'
      return
    end
    if findstrchr('packetdemologs', lower(pathToDemoLog))
      if strcmp(button, str3) % Cancel
        totDly = 1;
        cnt = totDly;
      end
    end
  end %if ~totDly
end
