function [err, errMsg] = writeProcessOPM_INI(pathToINI, printEnable, HPL3, printerPort, qualLetter);

[err, errMsg, fidINI] = fOpenToWrite(sprintf('%sProcessOPM.ini', pathToINI),'w');
if err
  errMsg = sprintf('>%s%s', mfilename, errMsg);
  return
end
fprintf(fidINI, '%% This file establishes certain conditions for "processOutpostPacketMessages".\r\n');
fprintf(fidINI, '%% Comment lines are any line that start with a space or % \r\n');
fprintf(fidINI, '%% If this file did not exist when the program was run, it was written with\r\n');
fprintf(fidINI, '%%  the program''s default values.  You may alter them as desired.\r\n');
fprintf(fidINI, '%% Any lines converted to a Comment or removed will result in the default being used.\r\n');
fprintf(fidINI, '%%Disable(0) printing of messages - this is a number value (only enables printing for known forms) \r\n');
fprintf(fidINI, '%%  1: enable printing only for ICS-213 PACForms on pre-printed forms. \r\n');
fprintf(fidINI, '%%  2: enable printing for ICS-213 PACForm fields and simple Outpost messages on blank paper. \r\n');
fprintf(fidINI, '%%  Individual form types may also have control files to disable printing of that form.\r\n');
fprintf(fidINI, 'printEnable = %i \r\n', printEnable);
fprintf(fidINI, '%%Enable(1)/disable(0) HPL3 printer control codes - this is a numeric value.\r\n');
fprintf(fidINI, 'HPL3 = %i \r\n', HPL3);
fprintf(fidINI, '%%location of the printer \r\n');
fprintf(fidINI, 'printerPort = %s \r\n', printerPort);
fprintf(fidINI, '%%Letter(1)/draft(0) print quality - this is a numeric value.\r\n');
fprintf(fidINI, 'qualLetter = %i\r\n', qualLetter);
% fprintf(fidINI, '%% \r\n');
fclose(fidINI);

