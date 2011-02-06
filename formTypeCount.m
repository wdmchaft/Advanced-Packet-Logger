function [msgList, msgCnt] = formTypeCount(foundStation, handles);

% pacfList = {...,
%     'CITY-SCAN UPDATE FLASH REPORT', ...
%     'SC COUNTY LOGISTICS', ...
%     'EOC MESSAGE FORM',  ...
%     'CITY MUTUAL AID REQUEST',  ...
%     'SHORT FORM HOSPITAL STATUS',  ...
%     'HOSPITAL STATUS',  ...
%     'HOSPITAL-BEDS',  ...
%     'OES MISSION REQUEST',  ...
%     'SEMS SITUATION', ...
%     'FORM DOC-9 HOSPITAL-STATUS REPORT', ...
%     'RESOURCE REQUEST FORM #9A',...
%     'FORM DOC-9 BEDS HOSPITAL-STATUS REPORT'...
% };

msgList ={};
msgCnt = 0;

formTypeNdx = find(ismember(handles.dispFieldNms,'formType'));
for toFROM = 0:1
  if toFROM
    a = 'from';
  else
    a = 'to';
  end  
  whichFld = find(ismember(handles.dispFieldNms, a));
  
  thisNdx = find(ismember(handles.logged(:, whichFld), foundStation));
  if length(thisNdx)
    msgsCountStation = length(thisNdx);
    for itemp = 1:length(thisNdx)
      Ndx = thisNdx(itemp);
      a = find(ismember(msgList, handles.logged(Ndx, formTypeNdx)));
      if length(a)
        msgCnt(a,(toFROM+1)) = msgCnt(a,(toFROM+1)) + 1;
      else
        a = length(msgList) + 1;
        msgList(a) = handles.logged(Ndx, formTypeNdx);
        msgCnt(a, [1:2]) = 0;
        msgCnt(a,(toFROM+1)) = 1;
      end
    end
    [msgList, Ndx] = sort(msgList);
    msgCnt = msgCnt(Ndx, :);
  end
end
% ---------------------------------------


