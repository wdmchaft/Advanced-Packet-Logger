function [cnt] = readRecvMsgNum(outpostNmNValues);
%read the number from the file '_log_recvMsg_count.ini' in DirAddOns.  
%This is next number to be used
% If the file doesn't exit, the number is set to 1 (one).
% See also "writeRecvMsgNum"

DirAddOns = outpostValByName('DirAddOns', outpostNmNValues);
fNameCnt = sprintf('%s_log_recvMsg_count.ini', DirAddOns);
fidCnt = fopen(fNameCnt, 'r');
if (fidCnt > 0)
  cnt = str2num(fgetl(fidCnt)) ;
  fclose(fidCnt) ;
else
  cnt = 1;
end
