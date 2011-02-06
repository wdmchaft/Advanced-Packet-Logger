function [err, errMsg, logPrtEnable, logPrt_minuteInterval, logPrt_mnmToPrt, logPrt_msgNums]...
  = readLogPrintINI(PathToFile);

err = 0;
errMsg = '';

%defaults for the read operation:
% Automatic printing enabled (1)/ disabled (0)
logPrtEnable = 0;
% Update printing interval in minutes
logPrt_minuteInterval = 15;
% Minimum number of logged messages for update printing.
% If fewer logged, printing at interval will not occur.
logPrt_mnmToPrt = 1;
% Over ride interval/print immediately when this many received.
logPrt_msgNums = 5;

fidINI = fopen(sprintf('%slogPrint.ini', PathToFile),'r');
if (fidINI > 0)
  [logPrtEnable, found] = readVal(fidINI, 'logPrtEnable', logPrtEnable);
  [logPrt_minuteInterval, found] = readVal(fidINI, 'logPrt_minuteInterval', logPrt_minuteInterval);
  [logPrt_mnmToPrt, found] = readVal(fidINI, 'logPrt_mnmToPrt', logPrt_mnmToPrt);
  [logPrt_msgNums, found] = readVal(fidINI, 'logPrt_msgNums', logPrt_msgNums);
else %if (fidINI > 0)
  [err, errMsg] = writeLogPrintINI(PathToFile, logPrtEnable, logPrt_minuteInterval, logPrt_mnmToPrt, logPrt_msgNums);
end %if (fidINI > 0) else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [val, found] = readVal(fidINI, key, valIn);
found = 0;
val = valIn;
% remember where we are within the file
fpPosition = ftell(fidINI);
while ~found & ~feof(fidINI)
  textLine = fgetl(fidINI);
  equalAt = findstrchr('=', textLine);
  if equalAt
    if (1 == findstrchr(key, textLine))
      found = 1;
      val = str2num(textLine(equalAt+1:length(textLine)));
    end
  end
end %while ~found & ~feof(fid)
if ~found
  fseek(fidINI, fpPosition, 'bof');
end
