%goo

switch a
case 0
  fprintf('0');
case 1
  fprintf('1');
case 2
  fprintf('2');
case 3
  fprintf('3');
  fprintf('yo')
otherwise
  fprintf('other');
end

return

actionText = {'created message; result of New or Forward or Reply',...
'created message, after Send (before Send/Receive)',...
'created message, after Send/Receive',...
'Received message, not opened',...
'Received message, and opened',...
'created message, Saved to draft folder',...
'created message, but canceled before saved or sent',...
'any message, deleted'};


for itemp = 1:length(NewNdx)
  Ndx = NewNdx(itemp);
  fprintf('\n%i: %s %s', msgList(Ndx).msgId, char(actionText(msgList(Ndx).action)), datestr(msgList(Ndx).dateTime));
end
fprintf('\n');
validNdx([1:length(NewNdx)]) = 1;
for itemp = length(NewNdx):-1:12
   Ndx = NewNdx(itemp);
   if (msgList(Ndx).msgId == msgList(Ndx-1).msgId)
     switch msgList(Ndx).action
       % deleted 
     case 8
       validNdx(itemp-1) = 0;
       fprintf('\n%i msg %i: %s', itemp, msgList(Ndx).msgId, char(actionText(msgList(Ndx).action)));
       fprintf('\n%i msg %i: %s', itemp-1, msgList(Ndx-1).msgId, char(actionText(msgList(Ndx-1).action)));
       fprintf('...pulling %i.', itemp-1);
     otherwise
     end
   end
 end
 