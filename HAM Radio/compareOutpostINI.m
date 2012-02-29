function compareOutpostINI

[err, errMsg, outpostNmNValues] = OutpostINItoScript; 
dirOutpost = endWithBackSlash(outpostValByName('DirOutpost', outpostNmNValues));

fidOrig = fopen(strcat(dirOutpost,'outpost_preChange.ini'),'r');
fidCurrent = fopen(strcat(dirOutpost,'outpost.ini'),'r');
while ~feof(fidOrig) & ~feof(fidCurrent)
  textLineOrig = fgetl(fidOrig);
  textLineCurr = fgetl(fidCurrent);
  if ~strcmp(textLineOrig, textLineCurr)
    fprintf('\n***** Changed from\n%s\nto\n%s', textLineOrig, textLineCurr)
  end
end
fclose(fidOrig);
fclose(fidCurrent);
dos(sprintf('copy "%soutpost.ini" "%soutpost_preChange.ini"', dirOutpost, dirOutpost));

% GetPrivate=1 -> retrieve private messages (0/1)
% GetNts=1 retreive NTS messages (0/1)
% GetBC=1 -> Retrieve New Bulletins (0/1)
% GetFiltered=1 -> Retrieve Selected Bulletins or xNOS Areas (0/1)
%    I think Filters aren't used if GetFiltered=0
% % Filters=
% % to
% % Filters=QTS:KEPS:ARES
% SkipMyNts=1

% Tools->Report Settings - Variables
% City
% County
% State=
% TacLoc - tactical location
% Org - organization


%automation off to on
% SrAutoOption=0 -> 1
% SC=142->143 
%automation interval from 10 -> 20 minutes
%SrIntTime=10 -> 20

%Tools/Message Settings:
%automatic message numbering (for outgoing messages)
% AutoMsgNum=1
% AutoMsgNum=0 
%
% SLS=0 without hypenation 
% SLS=1 with hypenation
% SLS=2 date time format

%Tools/Report
%TacID=SEP

%Outbound message number: AutoMsgNum
%Incoming message number: LMIflag

%New message set up
% NewMsgDefault=0   default to PRIVATE
% to
% NewMsgDefault=1   default to BULLETIN 
