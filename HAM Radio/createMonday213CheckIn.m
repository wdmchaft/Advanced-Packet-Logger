function createMonday213CheckIn(pathName, operator, callSign);

%Message number will be last 3 of call-YrMoDa_HrMnSc

todayDate = datestr(now,23); %Mo/Da/Yr
todayTime = datestr(now,15); %hr:mn   24 hour format
a = findstrchr(':', todayTime);
%eliminate the ":"
todayTime = todayTime([1:a-1 a+1:length(todayTime)]);

[err, errMsg, date_time] = datevec2timeStamp(now);
date_time = date_time(1:13);

fid = fopen(pathName, 'w');
if (fid < 1)
  fprintf('\r\nError: unable to open to write "%s".', pathName);
  return
end

fprintf(fid, '!PACF!\r\n');
fprintf(fid, '# EOC MESSAGE FORM \r\n');
fprintf(fid, '# JS-ver. 2.1.3, 11-11-07\r\n');
fprintf(fid, '# FORMFILENAME: Message.html\r\n');
fprintf(fid, '# Form Item numbers are followed by a colon (:)\r\n');
fprintf(fid, '# Answers are enclosed in brackets ( [ ] )\r\n');
fprintf(fid, '2.: []\r\n');
fprintf(fid, 'MsgNo: [%s-%s]\r\n', callSign([4:6]), date_time);
fprintf(fid, '3.: []\r\n');
fprintf(fid, '1a.: [%s]\r\n', todayDate);
fprintf(fid, '1b.: [%s]\r\n', todayTime);
fprintf(fid, '4.: [OTHER]\r\n');
fprintf(fid, '5.: [PRIORITY]\r\n');
fprintf(fid, '6a.: [No]\r\n');
fprintf(fid, '6b.: [No]\r\n');
fprintf(fid, '6c.: [checked]\r\n');
fprintf(fid, '6d.: []\r\n');
fprintf(fid, '7.: [Planning]\r\n');
fprintf(fid, '9a.: [SNYEOC]\r\n');
fprintf(fid, 'ToName: []\r\n');
fprintf(fid, 'ToTel: []\r\n');
fprintf(fid, '8.: [N/A]\r\n');
fprintf(fid, '9b.: [N/A]\r\n');
fprintf(fid, 'FmName: []\r\n');
fprintf(fid, 'FmTel: []\r\n');
fprintf(fid, '10.: [Monday Night Check In]\r\n');
fprintf(fid, '11.: []\r\n');
fprintf(fid, '12.: [%s %s  Mountain View  direct.  Also checking\r\n', operator, callSign);
 fprintf(fid, 'in with K6MTV]\r\n');
fprintf(fid, '13.: []\r\n');
fprintf(fid, 'CCMgt: []\r\n');
fprintf(fid, 'CCOps: []\r\n');
fprintf(fid, 'CCPlan: []\r\n');
fprintf(fid, 'CCLog: []\r\n');
fprintf(fid, 'CCFin: []\r\n');
fprintf(fid, 'Rec-Sent: [Sent]\r\n');
fprintf(fid, 'Method: [Other]\r\n');
fprintf(fid, 'Other: [PACKET]\r\n');
fprintf(fid, 'OpCall: [%s]\r\n', callSign);
fprintf(fid, 'OpName: [%s]\r\n', operator);
fprintf(fid, 'OpDate: [%s]\r\n', todayDate);
fprintf(fid, 'OpTime: [%s]\r\n', todayTime);
fprintf(fid, '#EOF\r\n');
fcloseIfOpen(fid);
