function [err, errMsg, printEnableRec, printEnableSent, printEnableDelvrRecp, ...
    copies4recv, copies4sent, copies4sentFromPaper, copies4DelvrRecp, HPL3] = readPrintICS_213INI(PathConfig, printEnable);
%INPUT
% printEnable: >1: values in file are ignored & both returned values set to passed in value
% OUTPUT
% printEnableRec:
% printEnableSent:
%    0: printer disabled
%    1: pre-printed form in printer & printer enabled. may be reset by the INI files - cannot be set by the INI file.
%       i.e.: to print this passed in variable must be set AND if the INI file is found and has a value for print 
%       enable, it must to set.  No printing will occur if the file doesn't exist, doesn't contain printEnable, 
%       or if its value for printEnable is cleared.
%    2: blank paper in printer, printer enable -> data will be loaded into form, printer 
%       activated for <# of copies> (loaded from 'print_ICS_213.ini'), and the form will be closed.
%    3: printer disabled, enable data displayed on screen
%
%For all "copies" variables, 
%   -1: print all in list (outTray_copies.txt or intray_copies.txt) [default]
%    0: print none regardless of printEnable
%   >0: print that many copies up but no more than in the list
% copies4recv: number of copies printed for received messages
% copies4sent: number of copies printed for sent messages electronically originated
% copies4sentFromPaper: number of copies printed for sent messages transcribed from paper

err = 0;
errMsg = '';

%defaults for the read operation:
printEnableRec = printEnable;
printEnableSent = printEnable;
printEnableDelvrRecp = printEnable;
% < 1 prints all if printing enabled
copies4recv = -1;
copies4sent = -1;
copies4sentFromPaper = -1;
copies4DelvrRecp = -1;
HPL3 = 1;

printEnableRecFlg = 0;
printEnableSentFlg = 0;
printEnableDelvrRecpFlag = 0;

fidINI = fopen(sprintf('%sprint_ICS_213.ini', PathConfig),'r');
if (fidINI > 0)
  if (printEnable < 2)
    %for backward compatibility, read 'printEnable'
    [printEnable, found] = readVal(fidINI, 'printEnable', printEnable);
    if found
      if ~printEnableRecFlg
        printEnableRec = printEnable;
      end
      if ~printEnableSentFlg
        printEnableSent = printEnable;
      end
      if ~printEnableDelvrRecpFlag
        printEnableDelvrRecpFlag = printEnable;
      end
    end %if found
    [printEnableRec, printEnableRecFlg] = readVal(fidINI, 'printEnableRec', printEnableRec);
    [printEnableSent, printEnableSentFlg] = readVal(fidINI, 'printEnableSent', printEnableSent);
    [printEnableDelvrRecp, printEnableDelvrRecpFlag] = readVal(fidINI, 'printEnableDelvrRecp', printEnableDelvrRecp);
  end % if (printEnable < 2)
  [copies4recv, found] = readVal(fidINI, 'copies4recv', copies4recv);
  [copies4sent, found] = readVal(fidINI, 'copies4sent', copies4sent);
  [copies4sentFromPaper, found] = readVal(fidINI, 'copies4sentFromPaper', copies4sentFromPaper);
  [copies4DelvrRecp, found] = readVal(fidINI, 'copies4DelvrRecp', copies4DelvrRecp);
  
  [HPL3, found] = readVal(fidINI, 'HPL3', HPL3);
else %if (fidINI > 0)
  [err, errMsg] = writePrintICS_213INI(PathConfig, printEnableRec, printEnableSent, ...
      copies4recv, copies4sent, copies4sentFromPaper, HPL3, copies4DelvrRecp, printEnableDelvrRecp);
end %if (fidINI > 0) else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [val, found] = readVal(fidINI, key, valIn);
found = 0;
val = valIn;
% remember where we are within the file
fpPosition = ftell(fidINI);
while ~found & ~feof(fidINI)
  textLine = fgetl(fidINI) ;
  equalAt = findstrchr('=', textLine);
  if equalAt
    if (1 == findstrchr(strcat(key, ' ='), textLine))
      found = 1;
      val = str2num(textLine(equalAt+1:length(textLine)));
    end
  end
end %while ~found & ~feof(fid)
if ~found
  fseek(fidINI, fpPosition, 'bof');
end
