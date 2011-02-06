function [err, errMsg] = writeRecvMsgNum(cnt, outpostNmNValues);
%Writes "cnt" which needs to be set to the NEXT
% available number to be used.
%Written to the file '_log_recvMsg_count.ini' in DirAddOns.  
%See also "readRecvMsgNum"

DirAddOns = outpostValByName('DirAddOns', outpostNmNValues);
fNameCnt = sprintf('%s_log_recvMsg_count.ini', DirAddOns);
[err, errMsg, fidCnt] = fOpenToWrite(fNameCnt, 'w');
if (fidCnt > 0)
  fprintf(fidCnt, '%i\r\n', cnt);
  fclose(fidCnt) ;
else
  errMsg = sprintf('>%s%s', mfilename, errMsg);
end
