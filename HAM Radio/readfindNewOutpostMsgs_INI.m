function [err, errMsg, startTimeOption, dateTime] = readfindNewOutpostMsgs_INI(pathNameExt, newestTxtPathNameEx);
% function [err, errMsg, startTimeOption, dateTime] = readfindNewOutpostMsgs_INI(pathNameExt, newestTxtPathNameEx);
%  called by processOutpostPacketMessages
%Reads <pathToINI>ProcessOPM.ini to permit operator to alter
% various parameters including enabling/disabling the printer,
% whether the printer supports HPL3 commands, and the printer port.
%If the file is not located, writes the file using the default values.
%INPUT:
% pathNameExt: typical the archive directory of Outpost & the name.ext of the ini
% newestTxtPathNameEx: path & name.ext of the file used to store the time of the latest processed message
%   only used here as note to operator if we create ths INI file
%OUTPUT:
% printer: a structure as follows
%   printer.printEnable: numeric
%   printer.HPL3: numeric
%   printer.printerPort: string (eg LPT1:)d

[err, errMsg, modName] = initErrModName(mfilename) ;

fidINI = fopen(pathNameExt,'r');
%default conditions.  Will be recorded in file during file creation
startTimeOption = 1;
dateTime = datestr(now);

if fidINI > 0
  [a, foundFlg] = findNextractNum('startTimeOption', 0, 0, fidINI);
  if foundFlg
    startTimeOption = a;
  end
  [a, foundFlg] = findNextract('dateTime', 0, 0, fidINI);
  if foundFlg
    dateTime = a;
  end
else %if fidINI > 0
  [err, errMsg] = writefindNewOutpostMsgs_INI(pathNameExt, newestTxtPathNameEx, startTimeOption, dateTime);
end %if fidINI > 0 else
fcloseIfOpen(fidINI);
