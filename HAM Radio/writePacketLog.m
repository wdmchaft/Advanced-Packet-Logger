function [err, errMsg, msg] = writePacketLog(pathName, outpost, form, incidentName, outpostNmNValues, clearMemOfChgs, msg) ;
% function [err, errMsg, msg] = writePacketLog(pathName, outpost, form, incidentName, outpostNmNValues, clearMemOfChgs, msg)
%
% Creates or appends to a CSV log of packet messages sent & received by this station.
%  If the log file doesn't exist, creates it with title lines and heading, followed
%    by the data.
%  If the log file does exist, merely appends the data.
%  When the operator of this station changes, an additional line is inserted in the log before the message
%    to mark the change.  Triggered by change operator's name (NameID), call sign (StationID)
%    tactical call, enable/disable of tactical call, enable/disable of TCwPEnabled, or in the Incident Name
%REQUIREMENTS
% Needs to be able to access Outpost.INI to determine the operator name and call sign
%INPUTS:
% pathName: path & full name including extension
% outpost: structure containing the following character fields of information
%          developed by Outpost.  Definitions are self-explantory.
%          Fields must be present - null strings are acceptable.
%   outpost.bbs
%   outpost.from
%   outpost.to
%   outpost.subject 
%   outpost.dateTime
%   outpost.postDTime
%   outpost.time
% form: structure containing the following character fields of information
%       extracted from the received message form. Fields must be present - null strings are acceptable.
%   form.type:'Simple' if not a PACF, otherwise the name of the form.  This module merely
%       writes the name to the log & doesn't care what the name is.  Current typical PACF names include 
%       'CITY-SCAN UPDATE FLASH REPORT', 'SC COUNTY LOGISTICS', 'EOC MESSAGE FORM', 'CITY MUTUAL AID REQUEST',
%       'SHORT FORM HOSPITAL STATUS', 'HOSPITAL STATUS', 'HOSPITAL-BEDS', 'OES MISSION REQUEST', and 'SEMS SITUATION'
%   form.time: time recorded on the form.  This is the originator's time
%   form.senderMsgNum: for forms received that contain a number of their
%   form.receiverMsgNum = '';  %don't know how packet will use this but it is on the forms
%   form.MsgNum
%     form.xfrNum: one of the above based on sent vs received - will be in log & is established outside this module
%   form.comment: general information extract from the form by the software; varies by form
%   form.replyReq: flag used by ICS213 form to indicate if a reply is requested.
%   form.replyWhen: used with form.replyReq to indictae when the reply is desired.


%outpostVarNameList = 
%    'StationID'    'NameID'    'TacticalCall'    'TCwPEnabled'    'TCnPEnabled'    'BbsName'    
%    'TncName'    'DirFiles'    'DirArchive'    'DirReports'    'DirLogs'    'DirPF'    'DirScripts'


%Each message has a line in the log containing the following.  I believe have two message numbers for packet isn't useful and is too unwieldly
% LOCAL    | XFR      | OUTPOST | FORM | FROM | FORM | SUBJECT | COMMENT | REPLY
% MSG. NO  | MSG. NO. | TIME    | TIME |      | TYPE |         |         | RQD.

%each form page contains:
%Incident name, operator name, operator call sign

%additional items that might be good to have on each line:
%BBS, 
%sender call sign if tactical calls are being used.  Might be able to get this from ICS213 PACForm
%ICS position at "this" end - who is getting the message for incoming or who created the message for outgoing

%additional items that might be a good idea to have on each page
%operator location (this is the "to" for incoming and "from" for outgoing messages


%Outpost: Report Settings: TacID is prefix to message number on outgoing subject line

%Read only invoked automatically when Windows Explorer is opened
% Explorer
% Tools/Options
% File Types
% "csv"
% Advanced
% edit the Open action
% clear "DDE Message" line
% on "Application used to perform....", replace the ending of  /e with /r "%1"

%The use of persistent variables is inappropriate for this application because
%  the program will not keep running but be started and exited repeatidly.
% % persistent opCall opName tacCall TCwPEnabled TCnPEnabled

%However using a persistent variable here makes sense as it will serve as a flag
% among the three logs we write: composite, sent & received.

[err, errMsg, modName] = initErrModName(mfilename);

%presuming landscape on 11x8.5 giving 10" printable @ 12 characters per inch
charactersPerLine = 120 ;
spaces([1:charactersPerLine]) = ' ';
%current settings
opCall = outpostValByName('StationID', outpostNmNValues);
opName = outpostValByName('NameID', outpostNmNValues);
tacCall = outpostValByName('TacticalCall', outpostNmNValues);
TCwPEnabled = outpostValByName('TCwPEnabled', outpostNmNValues);
% tactical enable (1) / disabled (0)
TCnPEnabled = outpostValByName('TCnPEnabled', outpostNmNValues);

City = outpostValByName('City', outpostNmNValues);
County = outpostValByName('County', outpostNmNValues);
State = outpostValByName('State', outpostNmNValues);
TacLoc = outpostValByName('TacLoc', outpostNmNValues);
Org = outpostValByName('Org', outpostNmNValues);
BBS = outpost.bbs;

readOnly = 0;
readOnlySuprt = 0;
%only if the log is the composite file (not Recvd & not Sent) will we write the support file
if ~findstrchr('_Recvd', pathName) & ~findstrchr('_Sent', pathName)
  supportFilePathName = strcat(pathName, '_sprt.csv') ;
  readOnlySuprt = 0;
else % if ~findstrchr('_Recvd', pathName) & ~findstrchr('_Sent', pathName)
  supportFilePathName = '' ;
end % if ~findstrchr('_Recvd', pathName) & ~findstrchr('_Sent', pathName) else
% ***** note: the extension is assumed to be ".csv" in several places in this module
%  here, defining "supportFilePathName", and when we turn on read-only.
pathNameExt = strcat(pathName, '.csv');
%test for log existence
fid = fopen(pathNameExt, 'r');
if (fid < 1)
  %doesn't exist - create and write heading lines
  fid = fopen(pathNameExt, 'w');
  if length(supportFilePathName)
    %local function:
    fidSprt = fopen(supportFilePathName, 'w');
    if (fidSprt > 0)
      %only record these at the beginning of the file
      fprintf(fidSprt,'fileVersion = 1\r\n' );
      fprintf(fidSprt,'formTitle = PACKET COMMUNICATIONS LOG\r\n' );
      fprintf(fidSprt,'formType = FORM ICS 309A\r\n' );
      fprintf(fidSprt,'formGroup = SANTA CLARA COUNTY ARES/RACES\r\n');
      writeLogSprt(fidSprt, incidentName, opCall, opName, tacCall, TCwPEnabled, TCnPEnabled,...
        City, County, State, TacLoc, Org, BBS, outpost.dateTime);  
    end
  else
    fidSprt = 0;
  end % if length(supportFilePathName)
  % if we can't create the log file or if we are trying to create the support file but cannot, post error(s)
  if (fid < 1) | ((fidSprt < 1) & length(supportFilePathName))
    err = 1;
    if (fid < 1)
      errMsg = sprintf('%s: unable to open "%s" to write the log.', modName, pathNameExt);
    else
      errMsg = sprintf('%s: unable to open "%s" to write the log support.', modName, supportFilePathName);
    end
    return
  end
  
  %PACKET COMMUNICATIONS LOG      Incident Name: <Incident Name>       <[Org,][City,][County,][State]>
  %FORM ICS 309A -                           <TacLoc>                          <Tac Call - if enabled>
  %SANTA CLARA COUNTY ARES/RACES                         Operator Name & Call Sign: <name> <call sign>

  % 1st title line  
  %words at Left & center:    
  thisLine = centerJustify('PACKET COMMUNICATIONS LOG', strcat('Incident Name: ', incidentName), round(charactersPerLine/2), spaces);
  a = buildElement('', Org);
  a = buildElement(a, City);
  % make sure the word "County" is included if there is a county
  if length(County)
    if ~findstrchr('county', lower(County))
      County = strcat(County, ' County');
    end
  end % if length(County)
  a = buildElement(a, County);
  a = buildElement(a, State);
  %1st title: words at right
  thisLine = leftJustify(thisLine, a, charactersPerLine, spaces);
  % thisLine = leftJustify(thisLine, 'Operator Name & Call Sign', charactersPerLine, spaces);
  %first line completed - Send the line to the file
  fprintf(fid, '"%s"\r\n', thisLine);
  % 2nd title line
  thisLine = centerJustify('FORM ICS 309A -', TacLoc, round(charactersPerLine/2), spaces);
  %2nd title: words at right
  % if tactical call is enabled
  if strcmp(TCnPEnabled,'1')
    thisLine = leftJustify(thisLine, sprintf('Tactical call: %s', tacCall), charactersPerLine, spaces);
  end
  fprintf(fid, '"%s"\r\n', thisLine);
  % 3rd title line
  thisLine = centerJustify('SANTA CLARA COUNTY ARES/RACES', '', round(charactersPerLine/2), spaces);
  %3rd title: words at right
  thisLine = leftJustify(thisLine, sprintf('Operator Name & Call Sign: %s %s', opName, opCall), charactersPerLine, spaces);
  
  %print last line of title & an extra CR/LF  *** DO NOT REMOVE THE EXTRA CR/LF (aka blank line) OR readPacketLog 
  %                                               WILL HAVE ISSUES FINDING THE COLUMN HEADERS***
  fprintf(fid, '"%s"\r\n\r\n', thisLine);
  % 1st heading line (note that when opened in Excel, the number if spaces before/after a comma is irrelevant so
  %                    keep it aligned here for clarity with the headings that are on two lines.)
  fprintf(fid, 'LOCAL,XFR   ,   , OUTPOST ,OUTPOST,FORM,    ,  ,         ,       ,       ,REPLY\r\n');
  a =          'MSG #,MSG NO,BBS,POST TIME, TIME  ,TIME,FROM,TO,FORM TYPE,SUBJECT,COMMENT, RQD.,FileName,When Logged';
  fprintf(fid, '%s\r\n', a);
  %placing a divider line of '=' both for clarity and the aid in reading the file by marking
  %  when the header end.  Make sure it has a minimum length even if the header gets modified
  % *** ===s ARE NEEDED FOR readPacketLog
  c = max(50, length(a) );
  divider([1:c]) = '=' ;
  fprintf(fid, '%s\r\n', divider);
else % if (fid < 1) %test if log exists
  %log exists: we'll just append
  fclose(fid);
  % % now being performed in "processOutpostPacketMessages": faster to
  % % do once for all messages: 
  fid = fOpen(pathNameExt, 'a');
  %perhaps in read-only?
  if fid < 1
    %release the read-only
    dos(sprintf('attrib "%s" -r', pathNameExt));
    [err, errMsg, fid] = fOpenToWrite(pathNameExt, 'a', mfilename);
    if err
      errMsg = strcat(modName, errMsg);
      dos(sprintf('attrib "%s" +r', pathNameExt));
      return
    end
    %remember we released it so we can redo
    readOnly = 1;
  end
  %only if the log is the composite file (not Recvd & not Sent) will we check for changes. This is
  % based on the usage from "processOutpostPacketMessages" which writes the composite log first and
  % then the selected subsets.  We do want the subset logs to report the same status as the composite "master" log
  if length(supportFilePathName) & clearMemOfChgs
    % do not want any message developed to be cleared later in this call:
    clearMemOfChgs = 0;
    %check for changes among these settings. If change, add a line to the log stating what all has changed
    %   We'll load the change message to the persistent variable "msg"
    msg = '' ;
    %  new info to highlight change
    % reload the values from the support file
    [err, errMsg, iN, oC, oN, tC, tcwP, tcnE,...
        cty, cnty, st, tl, or, bbsCN] = readLogSprt(supportFilePathName) ;    % test the current settings against each:
    msg = testForChange(opName, oN, 'operator name', '');
    msg = testForChange(opCall, oC, 'operator call sign', msg);
    [msg, change] = testForEnable(TCnPEnabled, tcnE, 'tactical call', msg);
    %if taccall has been just enabled...
    if (change > 0)
      % msg will include it's enabled so lets append the taccall
      msg = sprintf('%s: %s;', msg(1:(length(msg)-1)), tacCall);
    else %if (change > 0)
      %taccall wasn't JUST enabled
      %only care about change in taccall if it is enabled
      if strcmp(TCnPEnabled,'1')
        msg = testForChange(tacCall, tC, 'tactical call', msg);
      end
    end %if (change > 0) else
    msg = testForEnable(TCwPEnabled, tcwP, 'TCwPEnabled', msg);
    msg = testForChange(incidentName, iN, 'Incident Name', msg);

    msg = testForChange(City, cty, 'City', msg);
    msg = testForChange(County, cnty, 'County', msg);
    msg = testForChange(State, st, 'State', msg);
    msg = testForChange(TacLoc, tl, 'Tactical Location', msg);
    msg = testForChange(Org, or, 'Organization', msg);
    msg = testForChange(BBS, bbsCN, 'BBS', msg);
    
    %msg = testForChange(newVal, oldVal, varDescrpt, msg);
    %if anything has changed, update the record of the current settings in the support file ....
    if length(msg)
      fidSprt = fopen(supportFilePathName, 'a');
      if fidSprt < 1
        readOnlySuprt = 1;
        % now being performed in "processOutpostPacketMessages": faster to
        % do once for all messages: 
        %release the read-only (re-asserted later for all log-related files)
        dos(sprintf('attrib "%s" -r', supportFilePathName));
        fidSprt = fopen(supportFilePathName, 'a');
      end
      if (fidSprt > 0)
        %local function:
        writeLogSprt(fidSprt, incidentName, opCall, opName, tacCall, TCwPEnabled, TCnPEnabled,...
          City, County, State, TacLoc, Org, BBS, outpost.dateTime);  
      end
    end %if length(msg)
  end % if length(supportFilePathName) & clearMemOfChgs
end % % if (fid < 1) else %test if log exists 

%if there has been a changed detected when we are/were writing the composite log,
% also write it to this log
%   "msg" is persistent so it will survive until we are told to clear it.
if length(msg)
  fprintf(fid, '**** For following lines: %s\r\n', msg);
end % if length(msg)

%write the line of information for the current message
thisLine = sprintf('"%s","%s"', outpost.logMsgNum, form.xfrNum);
thisLine = sprintf('%s,"%s"', thisLine, outpost.bbs);
thisLine = sprintf('%s,"%s"', thisLine, outpost.postDTime);
thisLine = sprintf('%s,"%s"', thisLine, outpost.dateTime);
thisLine = sprintf('%s,"%s %s"', thisLine, form.date, form.time);
thisLine = sprintf('%s,"%s"', thisLine, outpost.from);
thisLine = sprintf('%s,"%s"', thisLine, outpost.to);
thisLine = sprintf('%s,"%s"', thisLine, form.type);
thisLine = sprintf('%s,"%s %s"', thisLine, outpost.subject, form.subject);
thisLine = sprintf('%s,"%s"', thisLine, form.comment);
%vvvv opening quote "  . . .
thisLine = sprintf('%s,"%s', thisLine, form.replyReq);
if length(form.replyWhen)
  thisLine = sprintf('%s[%s]', thisLine, form.replyWhen);
end
%^^^^. . . closing quote " 
thisLine = sprintf('%s"', thisLine);
%needed so "displayCounts can explicitly know the file to open:
thisLine = sprintf('%s,"%s"', thisLine, outpost.fpathName);
%exactly when this entry was added to the log
thisLine = sprintf('%s,"%s"', thisLine, datestr(now));
% thisLine = sprintf('%s,%s', thisLine, );
fprintf(fid, '%s\r\n', thisLine);

fclose(fid);
% now being performed in "processOutpostPacketMessages": faster to
% do once for all messages: 
%make the files read-only so user doesn't accidently lock us out by
%  opening it in Excel and forgetting to close Excel
%if we had to release read-only within this module, we'll set it again
if readOnly
  dos(sprintf('attrib "%s*.csv" +r', pathName));
elseif readOnlySuprt 
  dos(sprintf('attrib "%s" +r', supportFilePathName));
end % if readOnly  elseif readOnlySuprt 

%-------------------------------
%-------------------------------
function [thisLine] = centerJustify(existingLine, newText, centerCol, spaces);
startCol = centerCol - floor(length(newText)/2);
endCol = startCol + length(newText) - 1;
if (startCol > length(existingLine))
  % we want new text to start after existing text ends: add spaces to center new text
  spacesNeeded = startCol - length(existingLine);
  thisLine = sprintf('%s%s%s', existingLine, spaces(1:spacesNeeded), newText);
else
  % we want new text to start before existing text ends
  % Give up on centering: append newText to end separated by a space
  thisLine = sprintf('%s %s', existingLine, newText) ;
  %   if endCol < length(existingLine)
  %     % trim end of existing text so next text starts where we want & if new text's end is before end
  %     %  of existing, continue existing.
  %     thisLine = sprintf('%s%s%s', existingLine([1:(startCol-1)]), newText, existingLine([(endCol+1),length(existingLine)])) ;
  %   else
  %     thisLine = sprintf('%s%s', existingLine([1:(startCol-1)]), newText) ;
  %   end
end
%-------------------------------
%-------------------------------
function [thisLine] = leftJustify(existingLine, newText, rightCol, spaces);
startCol = rightCol - length(newText);
if (startCol > length(existingLine))
  % we want new text to start after existing text ends: add spaces to position new text
  spacesNeeded = startCol - length(existingLine);
  thisLine = sprintf('%s%s%s', existingLine, spaces(1:spacesNeeded), newText);
else
  % we want new text to start before existing text ends
  % Give up on right justification: extend line length & append newText to end separated by a space
  thisLine = sprintf('%s %s', existingLine, newText) ;
  %   if rightCol < length(existingLine)
  %     thisLine = sprintf('%s%s%s', existingLine([1:(startCol-1)]), newText, existingLine([(rightCol+1),length(existingLine)])) ;
  %   else
  %     thisLine = sprintf('%s%s', existingLine([1:(startCol-1)]), newText) ;
  %   end
end
%-------------------------------
%-------------------------------
function writeLogSprt(fidSprt, incidentName, opCall, opName, tacCall, TCwPEnabled, TCnPEnabled,...
  City, County, State, TacLoc, Org, BBS, outpostDateTime);
% names within ' ' here must be identical to those in readLogSprt
fprintf(fidSprt,'outpostDateTime = %s\r\n', outpostDateTime);
fprintf(fidSprt,'Incident Name = %s\r\n', incidentName);
fprintf(fidSprt,'opCall = %s\r\n', opCall);
fprintf(fidSprt,'opName = %s\r\n', opName);
fprintf(fidSprt,'tacCall = %s\r\n', tacCall);
fprintf(fidSprt,'TCwPEnabled = %s\r\n', TCwPEnabled);
fprintf(fidSprt,'TCnPEnabled = %s\r\n', TCnPEnabled);
fprintf(fidSprt,'City = %s\r\n', City);
fprintf(fidSprt,'County = %s\r\n', County);
fprintf(fidSprt,'State = %s\r\n', State);
fprintf(fidSprt,'TacLoc = %s\r\n', TacLoc);
fprintf(fidSprt,'Org = %s\r\n', Org);
fprintf(fidSprt,'BBS = %s\r\n', BBS);
fprintf(fidSprt,'============================\r\n');
fcloseIfOpen(fidSprt);
%-------------------------------
%-------------------------------
function [msg, change] = testForChange(newVal, oldVal, varDescrpt, msg);
%Use for text variables
%ex: msg = testForChange(opCall, oC, 'operator call sign', msg);
change = 0;
% need to strcmp & to check for string length: if both null, strcmp shows change
if ~strcmp(newVal, oldVal) & (length(newVal) | length(oldVal))
  if ~length(msg)
    msg = 'Change';
  end
  %<msg> 'operator call sign' to <newVal>;
  %Change in operator call sign to KI6SEP;
  %Change in operator call sign to KI6SEP; Tactical Location to Senior Center;
  msg = sprintf('%s %s to %s;', msg, varDescrpt, newVal );
  change = 1;
end % if ~strcmp(newVal, oldVal) & (length(newVal) | length(oldVal))
%-------------------------------
%-------------------------------
function [msg, change] = testForEnable(newVal, oldVal, varDescrpt, msg);
%Use for variables that enable/disable
%change: 0=no change, 1=just enabled; -1=just disabled
change = 0;
% need to strcmp & to check for string length: if both null, strcmp shows change
if ~strcmp(newVal, oldVal) & (length(newVal) | length(oldVal))
  if str2num(newVal)
    msg = sprintf('%s %s enabled;', msg, varDescrpt );
    change = 1;
  else
    msg = sprintf('%s %s disabled;', msg, varDescrpt );
    change = -1;
  end
end % if ~strcmp(newVal, oldVal) & (length(newVal) | length(oldVal))
%-------------------------------
%-------------------------------
function [element] = buildElement(existing, toAdd);
element = existing;
if length(toAdd)
  if length(existing)
    %append ", "  & then contents of toAdd
    element = sprintf('%s, %s', existing, toAdd);
  else
    element = toAdd;
  end
end
%-------------------------------
%-------------------------------
