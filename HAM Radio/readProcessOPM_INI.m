function [err, errMsg, printer] = readProcessOPM_INI(pathToINI);
% function [err, errMsg, printer] = readProcessOPM_INI(pathToINI);
%  called by processOutpostPacketMessages
%Reads <pathToINI>ProcessOPM.ini to permit operator to alter
% various parameters including enabling/disabling the printer,
% whether the printer supports HPL3 commands, and the printer port.
%If the file is not located, writes the file using the default values.
%INPUT:
% pathToINI: typical the archive directory of Outpost
%OUTPUT:
% printer: a structure as follows
%   printer.printEnable: numeric
%   printer.HPL3: numeric
%   printer.printerPort: string (eg LPT1:)

[err, errMsg, modName] = initErrModName(mfilename) ;

pathToINI = endWithBackSlash(pathToINI);
fidINI = fopen(sprintf('%sProcessOPM.ini', pathToINI),'r');
%default conditions.  Will be recorded in file during file creation
printEnable = 0;
HPL3 = 0;
printerPort = 'LPT1:';
qualLetter = 0;

if fidINI > 0
  [a, foundFlg] = findNextractNum('printEnable', 0, 0, fidINI);
  if foundFlg
    printEnable = a;
  end
  [a, foundFlg] = findNextractNum('HPL3', 0, 0, fidINI);
  if foundFlg
    HPL3 = a;
  end
  [a, foundFlg] = findNextract('printerPort', 0, 0, fidINI);
  if foundFlg
    printerPort = a;
  end
  [a, foundFlg] = findNextractNum('qualLetter', 0, 0, fidINI);
  if foundFlg
    qualLetter = a;
  end
else %if fidINI > 0
  [err, errMsg] = writeProcessOPM_INI(pathToINI, printEnable, HPL3, printerPort, qualLetter);
end %if fidINI > 0 else
fcloseIfOpen(fidINI);
printer.printEnable = printEnable;
printer.HPL3 = HPL3;
printer.printerPort = printerPort;
printer.qualLetter = qualLetter;