function [err, errMsg] = writePrintICS_213INI(PathConfig, printEnableRec, printEnableSent, copies4recv, copies4sent, copies4sentFromPaper, HPL3, copies4DelvrRecp, printEnableDelvrRecp);
%create the file

[err, errMsg, fidINI]  = fOpenToWrite(sprintf('%sprint_ICS_213.ini', PathConfig),'w');
if err
  errMsg = sprintf('>%s%s', mfilename, errMsg);
  return
end

fprintf(fidINI, '%% flag to enable/disable printing.  default is enable\r\n');
fprintf(fidINI, '%% 0: printer disabled\r\n');
fprintf(fidINI, '%% 1: pre-printed form in printer, printer enable for # of copies specified below\r\n');
fprintf(fidINI, '%% 2: blank paper in printer, printer enable for # of copies specified below\r\n');
fprintf(fidINI, '%% 3: printer disabled, enable on screen display\r\n');
fprintf(fidINI, 'printEnableRec = %i\r\n', printEnableRec);
fprintf(fidINI, 'printEnableSent = %i\r\n', printEnableSent);
fprintf(fidINI, 'printEnableDelvrRecp = %i\r\n', printEnableDelvrRecp);

fprintf(fidINI, '%% number of copies to print.  If <0, all defined copies will be printed\r\n');
fprintf(fidINI, '%%  as listed in outTray_copies.txt or inTray_copies.txt;\r\n');
fprintf(fidINI, '%%  If 1 or more, those many will be printed up to the maximum listed.\r\n');
fprintf(fidINI, '%%  For received messages:\r\n');
fprintf(fidINI, 'copies4recv = %i\r\n', copies4recv) ;
fprintf(fidINI, '%%  For sent messages electronically originated\r\n');
fprintf(fidINI, 'copies4sent = %i\r\n', copies4sent) ;
fprintf(fidINI, '%%  For sent messages transcribed from paper\r\n');
fprintf(fidINI, 'copies4sentFromPaper = %i\r\n', copies4sentFromPaper) ;
fprintf(fidINI, '%%  For delivery receipts:\r\n');
fprintf(fidINI, 'copies4DelvrRecp = %i\r\n', copies4DelvrRecp) ;
fprintf(fidINI, '%% enable 1 or disable 0 using the HPL 3 codes for draft, bidirection, fixed spacing\r\n');
fprintf(fidINI, '%%  only applies to pre-printed forms, indicted when printEnable* == 1\r\n');
fprintf(fidINI, 'HPL3 = %i\r\n', HPL3);
fclose(fidINI);
