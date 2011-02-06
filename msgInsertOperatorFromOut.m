function [err, errMsg] = msgInsertOperatorFromOut(msgHTMLpathName)
% line by line copy of a PacFORM message.html with
%the insertion of the Operator information (name & call sign)
%as has been set up in Outpost. 

fidIn = fopen(msgHTMLpathName, 'r');
fidOut = fopen('c:\pacforms\exec\textmsg.html','w');


[err, errMsg, outpostNmNValues] = OutpostINItoScript;

% 'StationID'    'KI6SEP'    'NameID'    'Andy Rose'


% function datetime()
% { var hr, ampm;
%   var Today = new Date();
%   var month = zerofill(Today.getMonth()+1);
%   var year = Today.getFullYear();
%   var day  = zerofill(Today.getDate());
%   var hr1 = Today.getHours();
%   var min = zerofill(Today.getMinutes());
%   /*
%   if (hr1 >12)
%     { hr = hr1 - 12;
%       ampm = " PM";
%     } else
%     { hr = hr1;
%       ampm = " AM";
%     }
%     */
%     hr = zerofill(hr);
%     var dat = month+"/"+day+"/"+year;
%     var tim = hr1+min;
%     document.forms[0].date.value=dat;
%     document.forms[0].time.value=tim;
%     document.forms[0].odate.value=dat;
%     document.forms[0].otime.value=tim;
%     
%   }
textLine = fgetl(fidIn);

while ~feof(fidIn) & ~findstrchr('function datetime()', textLine)
  fprintf(fidOut,'%s\r\n', textLine);
  textLine = fgetl(fidIn);
end
while ~feof(fidIn) & ~findstrchr('document.forms[0].otime.value=tim', textLine)
  fprintf(fidOut,'%s\r\n', textLine);
  textLine = fgetl(fidIn);
end
%
fprintf(fidOut,'%s\r\n', textLine);
a = findstrchr('doc', textLine);
spc(1:a-1) = ' ';
fprintf(fidOut,'%sdocument.forms[0].ocall.value="%s";     //operator: call sign\r\n', spc, outpostValByName('StationID', outpostNmNValues));
fprintf(fidOut,'%sdocument.forms[0].oname.value="%s";  //operator: name\r\n', spc, outpostValByName('NameID', outpostNmNValues));
while ~feof(fidIn)
  fprintf(fidOut,'%s\r\n', textLine);
  textLine = fgetl(fidIn);
end
fcloseIfOpen(fidIn);
fcloseIfOpen(fidOut);
;

