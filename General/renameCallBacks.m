function renameCallBacks
validNameChar = [char(double('A'):double('Z')) char(double('a'):double('z')) '0123456789_'];

key = 'print'
keyLen = length(key);
newKeyUpr = 'Prt';

key = 'LogPrt'
keyLen = length(key);
newKeyUpr = 'LogPrint';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
newKeyLwr = strcat(lower(newKeyUpr(1)), newKeyUpr(2:length(newKeyUpr)));
key = lower(key);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = 'packetLogSettings.m';
fileNameOut = 'packetLogSettings_1.m';
fid = fopen(fileName,'r');
fidOut = fopen(fileNameOut,'w');
fidNew = fopen('newVars.txt', 'w');
oldNameList = {};
while ~feof(fid)
  textLine = fgetl(fid);
  newTextLine = textLine;
  a = findstrchr(key, lower(textLine));
  if a
    prcntAt = findstrchr('%',  strtrim(textLine));
    if prcntAt == 1
      a = 0 ;
    end
  end
%     apostAt = findstrchr('''', lower(textLine));
%     prcntAt = findstrchr('%',  lower(textLine));
%     b = find(a < prcntAt);
%     if b
%       a = a(b):
%     else
%       a = 0;
%     end
%     %anything after a "%" is a comment unless that is within a quoted string
%     if apostAt
%       
%     end % if apostAt
%   end % if a
  if a
    Ndx = [];
    b = findstrchr('printf', textLine);
    if b
      % build a list of "print" that are NOT "printf"
      found = 0 ;
      jtemp = 0;
      for itemp = 1:length(a)
        if ~any(a(itemp) == b)
          jtemp = jtemp + 1;
          Ndx(jtemp) = a(itemp);
        end % if ~any(a(itemp) == b)
      end %for itemp = 1:length(a)
    else % if b
      Ndx = a;
    end %if b else
    for thisNdx = length(Ndx):-1:1
      %check for capitalization!
      if double(newTextLine(Ndx(thisNdx))) < 91
        new = newKeyUpr;
      else
        new = newKeyLwr;
      end
      newTextLine = sprintf('%s%s%s', newTextLine(1:Ndx(thisNdx)-1), new, newTextLine(Ndx(thisNdx)+keyLen:length(newTextLine)));
    end %  for thisNdx = 1:length(Ndx)
    if length(Ndx)
      fprintf('\n%s\n%s\n', textLine, newTextLine);
      fprintf(fidNew,'\n%s\n%s\n', textLine, newTextLine);
    end
  end % if a
  fprintf(fidOut, '%s\r\n', newTextLine);
end % while ~feof
fcloseIfOpen(fid);
fcloseIfOpen(fidNew);
fcloseIfOpen(fidOut);

edit ('newVars.txt')
  
return
