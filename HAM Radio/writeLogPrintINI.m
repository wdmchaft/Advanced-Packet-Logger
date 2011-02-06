function [err, errMsg] = writeLogPrintINI(PathToFile, logPrtEnable, logPrt_minuteInterval, logPrt_mnmToPrt, logPrt_msgNums);
%create the file

[err, errMsg, fidINI]  = fOpenToWrite(sprintf('%slogPrint.ini', PathToFile),'w');
if err
  errMsg = sprintf('>%s%s', mfilename, errMsg);
  return
end

fprintf(fidINI, '%% Control of Automatic log printing.\r\n');
fprintf(fidINI, '%% Automatic printing enabled (1)/ disabled (0)\r\n');
fprintf(fidINI, 'logPrtEnable = %i\r\n', logPrtEnable);
fprintf(fidINI, '%% Update printing interval in minutes\r\n');
fprintf(fidINI, 'logPrt_minuteInterval = %i\r\n', logPrt_minuteInterval);
fprintf(fidINI, '%% Minimum number of logged messages for update printing\r\n');
fprintf(fidINI, '%% If fewer logged, printing at interval will not occur.\r\n');
fprintf(fidINI, 'logPrt_mnmToPrt = %i\r\n', logPrt_mnmToPrt);
fprintf(fidINI, '%% Over ride interval/print immediately when this many received\r\n');
fprintf(fidINI, 'logPrt_msgNums = %i\r\n', logPrt_msgNums);
fcloseIfOpen(fidINI);