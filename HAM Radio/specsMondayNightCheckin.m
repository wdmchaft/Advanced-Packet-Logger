function specsMondayNightCheckin(callSign)

%creates message body for PacFORM monday night checkin

fidOut = fopen('monChkIn.txt','w');

switch callSign
case 'KI6SEP'
  OpName = 'Andy Rose';
case 'KI6SER'
  OpName = 'Janie Taylor';
case 'KI6TVJ'
  OpName = 'Jacob Detkin';
otherwise
  fcloseIfOpen(fidOut)
  return
end

[err, errMsg, date_time, prettyDateTime, Yr, Mo, Da, Hr, Mn, Sc] = datevec2timeStamp(now);
fprintf(fidOut, '!PACF!\r\n');
fprintf(fidOut, '# EOC MESSAGE FORM \r\n');
fprintf(fidOut, '# JS-ver. 2.1.3, 11-11-07\r\n');
fprintf(fidOut, '# FORMFILENAME: Message.html\r\n');
fprintf(fidOut, '# Form Item numbers are followed by a colon (:)\r\n');
fprintf(fidOut, '# Answers are enclosed in brackets ( [ ] )\r\n');
fprintf(fidOut, '2.: []\r\n');
a = findstrchr('_', date_time);
fprintf(fidOut, 'MsgNo: [%s-%s]\r\n', callSign(4:6), date_time(1:a-1))
fprintf(fidOut, '3.: []\r\n');
a = findstrchr(' ', prettyDateTime);
dateSimple = prettyDateTime(1:a-1);
b = findstrchr(':', prettyDateTime);
timeSimple = prettyDateTime([a+1:b(1)-1 b(1)+1:b(2)-1]);
fprintf(fidOut, '1a.: [%s]\r\n', dateSimple);
fprintf(fidOut, '1b.: [%s1243]\r\n', timeSimple);
fprintf(fidOut, '4.: [OTHER]\r\n');
fprintf(fidOut, '5.: [PRIORITY]\r\n');
fprintf(fidOut, '6a.: [No]\r\n');
fprintf(fidOut, '6b.: [No]\r\n');
fprintf(fidOut, '6c.: [checked]\r\n');
fprintf(fidOut, '6d.: []\r\n');
fprintf(fidOut, '7.: [Planning]\r\n');
fprintf(fidOut, '9a.: [SNYEOC]\r\n');
fprintf(fidOut, 'ToName: []\r\n');
fprintf(fidOut, 'ToTel: []\r\n');
fprintf(fidOut, '8.: [Comm]\r\n');
fprintf(fidOut, '9b.: [Home]\r\n');
fprintf(fidOut, 'FmName: []\r\n');
fprintf(fidOut, 'FmTel: []\r\n');
fprintf(fidOut, '10.: [Monday Night Check In]\r\n');
fprintf(fidOut, '11.: []\r\n');
fprintf(fidOut, '12.: [%s %s \nMountain View;\r\n direct;\r\n Sound card packet using AGWPE & Outpost.  \r\n\nAlso checking in with K6MTV]\r\n', OpName, callSign);
fprintf(fidOut, '13.: []\r\n');
fprintf(fidOut, 'CCMgt: []\r\n');
fprintf(fidOut, 'CCOps: []\r\n');
fprintf(fidOut, 'CCPlan: []\r\n');
fprintf(fidOut, 'CCLog: []\r\n');
fprintf(fidOut, 'CCFin: []\r\n');
fprintf(fidOut, 'Rec-Sent: [Sent]\r\n');
fprintf(fidOut, 'Method: [Other]\r\n');
fprintf(fidOut, 'Other: [PACKET]\r\n');
fprintf(fidOut, 'OpCall: [%s]\r\n', callSign);
fprintf(fidOut, 'OpName: [%s]\r\n', OpName);
fprintf(fidOut, 'OpDatse: [%s]\r\n', dateSimple);
fprintf(fidOut, 'OpTime: [%]\r\n', timeSimple);
fprintf(fidOut, '#EOF\r\n');

fcloseIfOpen(fidOut);