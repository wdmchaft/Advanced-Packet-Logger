function [err, errMsg, logged, header, columnHeader] = readPacketLog(pathName) ;
% function [err, errMsg, logged, header, columnHeader] = readPacketLog(pathName)
%OUTPUTS:
% logged: structure list of each item on each line of logged information
%   the names of the structure items is automatically picked up by displayCounts
%   so care should be taken if the names are changed: the displayed headings there
%   are linked to the columns by these names (displayCounts_OpeningFcn, handles.dispFieldNms = ...)
%    (see a list below)
% header:
%   header.logFDate, the system date & time the file was written. ex: "30-Nov-2009 13:22:50"
%   header.logFDate, the system date & time the file was written. ex: "30-Nov-2009 13:22:50"
%   header.line(n) list of all header lines except for the column headers
% columnHeader: list of the column headers
% logged(count):
%   logged.conditionChange: what all the conditions that
%      have changed listed as text. Detected if log line starts with "*", 
%      WHEN the line is listing the change conditions, all the following
%      terms will be null, empty, or zero.
%   logged.logMsgNo: local message number
%   logged.xfrMsgNo: message number tranferred over packet radio.  
%      For outgoing messages, this is same as local message number.
%      For incoming messages, this is the sender's message number
%   logged.bbs: BBS/node we connected to to transfer this message
%   logged.outpostDTime: date & time that outpost retrieved or sent the message
%   logged(count).outpostPostTime: date & time the BBS received the message
%   logged.formDTime: date & time recorded on the form (if any)
%   logged.from: Outpost's sender info converted to uppercase
%   logged.to: Outpost's recipient(s) in terms of call sign(s) - not the form's "to" converted to uppercase
%   logged.formType: type of message: simple for Outpost, PACF: as decribed in the form's heading
%   logged.subject: Outpost's subject for message
%   logged.isDelcrRecv: flag: 0=not delivery receipt; 1= delivery reciept.
%       note: future may acknowledge read receipt using yet another value. 
%       likely this would be but-mapped so either can be sensed.
%   logged.comment: extracted from PACF fields.
%   logged.replyReqd: details regarding "Reply Request" fields status
%   logged.fpathName: message file path & name (where this message was stored by script)
%   logged.whenLogged: date & time logging operation occured

[err, errMsg, modName] = initErrModName(mfilename);
logged = {};
header.logFDate = '';
header.bytes = '';
header.line = {};
columnHeader = {};

a = dir(pathName);
if length(a) < 1
  err = 1;
  errMsg = sprintf('%s: unable to find "%s".', modName, pathName) ;
  return
end
%temp store this information.  Use it iff full load works.
logFDate = a(1).date; 
bytes = a(1).bytes;
fid = fopen(pathName, 'r') ;
if (fid < 0)
  err = 1;
  errMsg = sprintf('%s: unable to read "%s".', pathName) ;
  return
end

%version 0:
%   'SENDER,   ,OUTPOST,FORM,    ,  ,         ,       ,       ,REPLY\r\n');
%   'MSG NO,BBS, TIME  ,TIME,FROM,TO,FORM TYPE,SUBJECT,COMMENT, RQD.,FileName';

%version 1 has additional leading column but all else is the same
%   'LOCAL  ,SENDER,   ,OUTPOST,FORM,    ,  ,         ,       ,       ,REPLY\r\n');
%   'MSG #,MSG NO,BBS, TIME  ,TIME,FROM,TO,FORM TYPE,SUBJECT,COMMENT, RQD.,FileName';

%version 2 adds the column "OUTPOST POST TIME"


%find the line after the header, header ending with a line of at leats 50 "="
textLine = fgetl(fid) ;
headerNdx = 0;
while (length(findstrchr('=', textLine)) < 50) & ~feof(fid)
  headerNdx = headerNdx + 1;
  if length(textLine)
    %header format is "<header>",,,,,,,,,,,
    a = findstrchr('"', textLine);
    b = findstrchr('",', textLine);
    if ~b
      b = findstrchr(',,,', textLine);
      if ~b
        b = length(textLine) + 1;
      end
    end
    header.line(headerNdx) = {textLine(a(1)+1:b(1)-1)};
  else
    header.line(headerNdx) = {textLine};
  end
  [textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fid) ;
end
if feof(fid)
  err = 1 ;
  errMsg = sprintf('%s: unable to find end of the heading of "%s".', modName, pathName);
  fclose(fid) ;
  return;
end
%column header lines precede the line with the =s and are all the lines after the last blank line
for itemp = headerNdx:-1:1
  if ~length(char(header.line(itemp)))
    break
  end
end
%created the column header list
for jtemp = (itemp+1):headerNdx
  Ndx = jtemp - itemp;
  columnHeader(Ndx) = header.line(jtemp);
end 
%remove the column headers from the header list
header.line = header.line(1:itemp);

% crunch the header into one line.
%   1) find the commas in each line
for colNdx = 1:length(columnHeader)
  a = findstrchr(',', char(columnHeader(colNdx)));
  commasAt(colNdx, 1:length(a)) = a;
end %for colNdx = 1:length(columnHeader)
%  2) build the line from the columns
colHeading = '' ;
% all columns....
for commaNdx = 0:size(commasAt, 2)
  aa = '';
  % all colHeading lines
  for colNdx = 1:length(columnHeader)
    %lines may not have same length, so we need to drop the empty locations
    b = commasAt(colNdx, :);
    [err, errMsg, text] = extractTextFromCSVText(columnHeader{colNdx}, b(find(b)), commaNdx) ;
    % pull anything that makes the alignment "pretty" for Excel
    aa = sprintf('%s%s ', aa, strtrim(text) );
  end % for colNdx = 1:length(columnHeader)
  colHeading = sprintf('%s%s,', colHeading, strtrim(aa) );
end %for Ndx = 1:size(commasAt, 1)
columnHeader = colHeading ;

[column, version] = readPacketLogHdg(columnHeader);
% read the data
count = 1 ;
while ~feof(fid)  
  [textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fid) ;
  % ******  hard coded column order ******
  if length(textLine)
    a = findstrchr('*', textLine);
    % needs more work to protect that the message # may start with "*"
    %  ******** New operator
    %if textLine is not indicating change in global conditions (operator, tacCall, etc.)
    if ~a | (a(1) ~= 1)
      [err, errMsg, logged(count).logMsgNo] = extractStripQuotes(textLine, commasAt, column.lclMsgNo) ;
      [err, errMsg, logged(count).xfrMsgNo] = extractStripQuotes(textLine, commasAt, column.xfrMsgNo) ;
      [err, errMsg, logged(count).bbs] = extractStripQuotes(upper(textLine), commasAt, column.bbs) ;
      [err, errMsg, logged(count).outpostDTime] = extractStripQuotes(textLine, commasAt, column.outpostLclTime) ;
      [err, errMsg, logged(count).outpostPostDTime] = extractStripQuotes(textLine, commasAt, column.outpostPostDTime) ;
      [err, errMsg, logged(count).formDTime] = extractStripQuotes(textLine, commasAt, column.formTime) ;
      [err, errMsg, a] = extractStripQuotes(upper(textLine), commasAt, column.from) ;
      logged(count).from = upper(a);
      [err, errMsg, a] = extractStripQuotes(upper(textLine), commasAt, column.to) ;
      logged(count).to = upper(a);
      [err, errMsg, logged(count).formType] = extractStripQuotes(textLine, commasAt, column.formType) ;
      [err, errMsg, logged(count).subject] = extractStripQuotes(textLine, commasAt, column.subject) ;
      logged(count).isDelcrRecv = findstrlen('DELIVERED:', logged(count).subject);
      [err, errMsg, logged(count).comment] = extractStripQuotes(textLine, commasAt, column.comment) ;
      [err, errMsg, logged(count).replyReqd] = extractStripQuotes(textLine, commasAt, column.replyRqd) ;
      [err, errMsg, logged(count).fpathName] = extractStripQuotes(textLine, commasAt, column.fileName) ;
      [err, errMsg, logged(count).whenLogged] = extractStripQuotes(textLine, commasAt, column.whenLogged) ;
      logged(count).conditionChange = '';
    else % if ~a | (a(1) ~= 1)
      logged(count).conditionChange = {textLine} ;
      logged(count).logMsgNo = '' ;
      logged(count).xfrMsgNo = '';
      logged(count).bbs = '';
      logged(count).outpostDTime = '';
      logged(count).outpostPostDTime = '';
      logged(count).formDTime = '';
      logged(count).from = '';
      logged(count).to = '';
      logged(count).formType = '';
      logged(count).subject = '';
      logged(count).isDelcrRecv = 0;
      logged(count).comment = '';
      logged(count).replyReqd = '';
      logged(count).fpathName = '';
      logged(count).whenLogged = '';
    end % if ~a | (a(1) ~= 1) else
    count = count + 1 ;
  end %if length(textLine)
end
if err
  if findstrchr('extractTextFromCSVText: invalid specified comma (-1)', errMsg)
    err = 0;
    errMsg = '';
  else
    errMsg = strcat(modName, errMsg);
  end
end
fcloseIfOpen(fid);
header.logFDate = logFDate; 
header.bytes = bytes;
