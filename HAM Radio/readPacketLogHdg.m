function [column, version] = readPacketLogHdg(columnHeader);

column.xfrMsgNo	= -1;
column.lclMsgNo = -1;
column.outpostPostDTime = -1;
column.bbs = -1;
column.outpostLclTime = -1;
column.formTime = -1;
column.from = -1;
column.to = -1;
column.formType = -1;
column.subject = -1;
column.comment = -1;
column.replyRqd = -1;
column.fileName = -1;
column.whenLogged = -1;

%version 0:
%   'SENDER,   ,OUTPOST,FORM,    ,  ,         ,       ,       ,REPLY\r\n');
%   'MSG NO,BBS, TIME  ,TIME,FROM,TO,FORM TYPE,SUBJECT,COMMENT, RQD.,FileName';

%version 1 has additional leading column but all else is the same
%   'LOCAL  ,SENDER,   ,OUTPOST,FORM,    ,  ,         ,       ,       ,REPLY\r\n');
%   'MSG #,MSG NO,BBS, TIME  ,TIME,FROM,TO,FORM TYPE,SUBJECT,COMMENT, RQD.,FileName';

commasAt = findstrchr(',', columnHeader);
[err, errMsg, column.xfrMsgNo] = findColumnOfData(columnHeader, 'XFR MSG NO', commasAt);
if err
  version = 0;
  column.lclMsgNo = -1;
  [err, errMsg, column.xfrMsgNo] = findColumnOfData(columnHeader, 'SENDER MSG NO', commasAt);
else
  version = 1;
  [err, errMsg, column.lclMsgNo] = findColumnOfData(columnHeader, 'LOCAL MSG #', commasAt);
end
[err, errMsg, column.outpostPostDTime] = findColumnOfData(columnHeader, 'OUTPOST POST TIME', commasAt);
if ~err
  version = 2;
end
[err, errMsg, column.bbs] = findColumnOfData(columnHeader, 'BBS', commasAt);
[err, errMsg, column.outpostLclTime] = findColumnOfData(columnHeader, 'OUTPOST TIME', commasAt);
[err, errMsg, column.formTime] = findColumnOfData(columnHeader, 'FORM TIME', commasAt);
[err, errMsg, column.from] = findColumnOfData(columnHeader, 'FROM', commasAt);
[err, errMsg, column.to] = findColumnOfData(columnHeader, 'TO', commasAt);
[err, errMsg, column.formType] = findColumnOfData(columnHeader, 'FORM TYPE', commasAt);
[err, errMsg, column.subject] = findColumnOfData(columnHeader, 'SUBJECT', commasAt);
[err, errMsg, column.comment] = findColumnOfData(columnHeader, 'COMMENT', commasAt);
[err, errMsg, column.replyRqd] = findColumnOfData(columnHeader, 'REPLY RQD.', commasAt);
[err, errMsg, column.fileName] = findColumnOfData(columnHeader, 'FileName', commasAt);
[err, errMsg, column.whenLogged] = findColumnOfData(columnHeader, 'When Logged', commasAt);
