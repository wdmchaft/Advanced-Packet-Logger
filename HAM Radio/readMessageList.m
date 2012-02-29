function messageList = readMessageList(PathToList) ;
%reads the list created by the Script of new messages.
%  There are actually two list = sent & received.  This routine
%  handles either since they differ only in their location.
%OUTPUT
% messageList.name: name(s) read from the file
% messageList.date: date of each file determinedby performing a "dir" listing for that file
% messageList.postDateTime: date message was posted onto the BBS. Requires
%      Outpost version 2.5.0 c21 or newer or will be empty.
%      for sent messages, this is the date & time the message was sent by
%         outpost. (i.e.: the time per the Outpost computer)
%      for received message, this is the time message was posted
%         to the BBS which is the time per the BBS' clock.

messageList = {} ;
fid = fopen(strcat(PathToList, 'newMessageList.txt'), 'r') ;
if (fid > 0)
  itemp = 0;
  while ~feof(fid)
    itemp = itemp + 1 ;
    textLine = fgetl(fid);
    if length(textLine)
      commaAt = findstrchr(',', textLine);
      if commaAt
        messageList(itemp).name = {textLine(1:commaAt(1)-1)} ;
      else
        messageList(itemp).name = {textLine} ;
      end
      %pull the date from the file's name
      % starts with R or S followed by _YrMoDa_HrMnSec_Subject....  
      % vvvvvvvv  same code in writeProcLogIfIncomplete vvvvvvv
      b = findstrchr('_', textLine);
      if (length(b) > 2)
        messageList(itemp).date = {textLine(b(1)+1:b(3)-1)};
      else
        messageList(itemp).date = {};
      end % if (length(b) > 2)
      % ^^^^^^^^  same code in writeProcLogIfIncomplete ^^^^^^^^
      [err, errMsg, messageList(itemp).postDateTime] = extractTextFromCSVText(textLine, commaAt, 2) ;
    end % if length(textLine)
  end % while ~feof(fid)
  fclose(fid);
end %if (fid > 0)
