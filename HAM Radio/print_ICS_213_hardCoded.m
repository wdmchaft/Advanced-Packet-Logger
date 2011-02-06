function [err, errMsg, printedName, printedNamePath] = print_ICS_213(fid, fname, receivedFlag, PathToArchive);

[err, errMsg, modName] = initErrModName(mfilename)

inTraycopiesTo = {'ADDRESSEE','PLANNING','RADIO'};
outTraycopiesTo = {'RADIO','PLANNING','ORIGINATOR'};
%These lines will have been read before this module is called:
% !PACF!
% # EOC MESSAGE FORM 
% # JS-ver. 2.1.3, 11-11-07
% # FORMFILENAME: Message.html

footerFirstLine = 58;
footerLastLine = 60;

fidINI = fopen(sprintf('%sprint_ICS_213.ini', PathToArchive),'r');
printEnable = 1 ;
copies = 0;  %a silly number (< 1) prints all
HPL3 = 0;
if fidINI
  print_ICS_213_ini_key = {'printEnable'};
  textLine = '';
  while 1
    textLine = fgetl(fidINI);
    equalAt = findstrchr('=', textLine);
    if equalAt
      if (1 == findstrchr('printEnable', textLine))
        printEnable = str2num(textLine(equalAt+1:length(textLine)));
      end
      if (1 == findstrchr('copies', textLine))
        copies = str2num(textLine(equalAt+1:length(textLine)));
      end
      if (1 == findstrchr('HPL3', textLine))
        HPL3 = str2num(textLine(equalAt+1:length(textLine)));
      end
      % % 
      % %       a = textLine(1:equalAt-1);
      % %       while findstrchr(a(length(a)),' ')
      % %         a = a(1:length(a)-1);
      % %       end
    end
    if feof(fidINI)
      break
    end
  end
  fcloseIfOpen(fidINI);
end

spaces = '';
for itemp = 1:80
  spaces = sprintf('%s ', spaces);
end

%skip ahead through the file until we get the line before the information of interest
textLine = '' ;
while ~findstrchr('# Answers are enclosed in brackets', textLine) & ~feof(fid)
  textLine = fgetl(fid);
end

% initialoze the text output array
for itemp = 1:footerLastLine
  textToPrint(itemp) = {''};
end
%read & detect the field for each line of the entire message
while 1
  % clear the print line so the line will not be altered unless the field
  %   has an entry. >0 will center justify & <0 will left justify
  printLine = 0;
  textLine = fgetl(fid);
  if (1 == findstrchr(textLine, '#EOF'))
    break
  end
  if feof(fid)
    err = 1 ;
    errMsg = sprintf('%s: incomplete message: End-of-message but no "#EOF"', modName);
    break
  end
  [fieldText, fieldID] = extractPACFormField(textLine);
  switch fieldID
  case '2.'
    printLine = 2;
    printCol = 45;
  case 'MsgNo' %: [MLN-074]
    printLine = 2;
    printCol = 58;
  case '3.' %: []
    printLine = 2;
    printCol = 72;
  case '1a.' % : [06/20/2009]
    printLine = 5;
    printCol = 10;
  case '1b.' % : [1018]  Time
    printLine = 9;
    printCol = 10;
  case '4.' % : Situation Severity
    printCol = [17];
    switch fieldText
    case 'EMERGENCY'
      printLine = 5;
    case 'URGENT'
      printLine = 8;
    case 'OTHER'
      printLine = 10;
    otherwise
    end
    fieldText = 'XX';
  case '5.' % : Message Handling Order
    printCol = 36;
    switch fieldText
    case 'IMMEDIATE'
      printLine = 5;
    case 'PRIORITY'
      printLine = 8;
    case 'ROUTINE'
      printLine = 10;
    otherwise
    end
    fieldText = 'XX';
  case '6a.' % Take Action Yes No
    if length(fieldText)
      printLine = 6;
      if findstrchr(fieldText,'No')
        printCol = 74;
        fieldText = 'XX';
      end
      if findstrchr(fieldText,'Yes')
        printCol = 60;
        fieldText = 'XX';
      end
    end % if length(fieldText)
  case '6b.' % : Reply Yes   No
    if length(fieldText)
      if findstrchr(fieldText,'No')
        printLine = 9;
        printCol = 74;
        fieldText = 'XX';
      end
      if findstrchr(fieldText,'Yes')
        printLine = 9;
        printCol = 60;
        fieldText = 'XX';
      end
    end % if length(fieldText)
  case '6c.' % For your info.
    if findstrchr(fieldText,'checked')
      printLine = 10;
      printCol = 60;
      fieldText = 'XX';
    end
  case '6d.' % : for "Reply Yes, " this is the "by:"
    % ================ this may come after 6b & if No was selected, 
    %        we need to insert, not append 
    % we want this left justified, not centered
    printLine = -9 ;
    printCol = 68 ;
  case '7.' % : TO   ICS Position
    printLine = 13;
    printCol = 25;
  case '9a.' % : TO  Location
    printLine = 15;
    printCol = 25;
  case 'ToName' % : []
    printLine = 18;
    printCol = 25;
  case 'ToTel' % : []
    printLine = 20;
    printCol = 33;
  case '8.' % : From ICS Position
    printLine = 13;
    printCol = 63;
  case '9b.' % : From Location
    printLine = 15;
    printCol = 63;
  case 'FmName' % : []
    printLine = 18;
    printCol = 63;
  case 'FmTel' % : []
    printLine = 20;
    printCol = 63;
  case '10.' % : Subject
    printLine = -22 ;
    printCol = 15 ;
  case '11.' % : Reference (eg number of earlier message)
    printLine = -24 ;
    printCol = 35 ;
  case '12.' % : Message  
    textToPrint = formatMessageBox(fieldText, textToPrint, 1+[26, 28, 30, 32, 34, 35], 5, 77, spaces);
  case '13.' % Action Taken 
    textToPrint = formatMessageBox(fieldText, textToPrint, 1+[39, 40,43], 5, 77, spaces);
  case 'CCMgt' % : []
    if findstrchr(fieldText,'checked')
      printLine = -44;
      printCol = 10;
      fieldText = 'XX';
    end
  case 'CCOps' % : []
    if findstrchr(fieldText,'checked')
      printLine = -44;
      printCol = 20;
      fieldText = 'XX';
    end
  case 'CCPlan' % : []
    if findstrchr(fieldText,'checked')
      printLine = -44;
      printCol = 39;
      fieldText = 'XX';
    end
  case 'CCLog' % : []
    if findstrchr(fieldText,'checked')
      printLine = -44;
      printCol = 51;
      fieldText = 'XX';
    end
  case 'CCFin' % : []
    if findstrchr(fieldText,'checked')
      printLine = -44;
      printCol = 64;
      fieldText = 'XX';
    end
  case 'Rec-Sent' % : []
    if findstrchr(fieldText,'Sent')
      printLine = -47;
      printCol = 24;
      fieldText = 'XX';
    end
    if findstrchr(fieldText,'Received')
      printLine = -47;
      printCol = 15;
      fieldText = 'XX';
    end
  case 'Method' % : []
    if length(fieldText)
      switch fieldText
      case 'Telephone'
        printLine = -48;
        printCol = 5;
      case 'EOC Radio'
        printLine = -50;
        printCol = 5;
      case 'Amateur Radio'
        printLine = -51;
        printCol = 5;
      case 'Dispatch Center'
        printLine = -48;
        printCol = 19;
      case 'FAX'
        printLine = -50;
        printCol = 19;
      case 'Courier'
        printLine = -50;
        printCol = 28;
      case 'Other'
        printLine = -51;
        printCol = 19;
      otherwise
      end
      if printLine
        fieldText = 'XX';
      end
    end
  case 'Other' % : []
    printLine = 51;
    printCol = 31;
  case 'OpCall' % : []
    printLine = -47 ;
    printCol = 57 ;
  case 'OpName' % : []
    printLine = -48 ;
    printCol = 55 ;
  case 'OpDate' % : [06/20/2009]
    printLine = -51 ;
    printCol = 47;
  case 'OpTime' % : [941]
    printLine = -51
    printCol = 69;
  otherwise
    % #EOF
  end
  %if something was found, printLine will have a value
  if printLine
    % the polarity of printLine is a flag: >0 means center justify, < 0 means left justify
    if printLine > 0
      textToPrint(printLine) = {centerJustifyText(fieldText, char(textToPrint(printLine)), printCol, spaces)};
    else
      printLine = -printLine;
      textToPrint(printLine) = {leftJustifyText(fieldText, textToPrint(printLine), printCol, spaces)};
    end
  end
end

fcloseIfOpen(fid);

if receivedFlag
  copiesTo = inTraycopiesTo;
else
  copiesTo = outTraycopiesTo;
end

if ~err
  [err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
  [initString, EjectPageTxt] = initPrintStrings;
  [pathstr,name,ext,versn] = fileparts(fname);
  %create the output file
  printedNamePath = sprintf('%sprinted_213_%s.txt', endWithBackSlash(pathstr), name);
  if (copies < 1) | (copies > length(copiesTo))
    copies = length(copiesTo);
  end
  %send all the text to a file & then use the copy command to sent to the printer
  % normal operation is to loop once for each copy with the footer being different 
  %  each to, specifying who should have the copy.  One last copy is made without
  %  any footer.
  for copyNdx = 1:copies+1
    fid = fopen(printedNamePath, 'w');
    if (copyNdx <= copies)
      %if the desired number of copies is >1 we'll include who this copy is for in the footer.
      %  If it is 1 we'll only include the date & time we printed it.
      if (copies > 1)
        % at bottom of the page, print the recipient of this copy
        for ltemp = footerFirstLine:(footerLastLine-1)
          textToPrint(ltemp) = {centerJustifyText(char(copiesTo(copyNdx)), char(textToPrint(ltemp)), 40, spaces)};
        end
        textToPrint(footerLastLine) = {centerJustifyText(sprintf('%s printed %s', char(copiesTo(copyNdx)), prettyDateTime), ...
            char(textToPrint(footerLastLine)), 40, spaces)};
      else %if (copies > 1)
        textToPrint(footerLastLine) = {centerJustifyText(sprintf('printed %s', prettyDateTime), ...
            char(textToPrint(footerLastLine)), 40, spaces)};
      end %if (copies > 1) else
      %initialize/configure the printer
      if HPL3
        fprintf(fid, '%s', initString); 
      end
    end % %    if (copyNdx <= copies))
    for itemp = 1:length(textToPrint)-1
      fprintf(fid,'%s\r\n', char(textToPrint(itemp)));
    end
    fprintf(fid,'%s', char(textToPrint(itemp+1)));
    if (copyNdx <= copies)
      fprintf(fid,'%s', char(12));  %form feed
    end %    if (copyNdx <= copies))

    fcloseIfOpen(fid);
    textToPrint(footerFirstLine:footerLastLine) = {''};
    % print the output file
    if printEnable
      %final copy does not contain the printer configuration codes
      if (copyNdx <= copies)
        err = dos (sprintf('copy "%s" lpt1:', printedNamePath));
        if err
          errMsg = sprintf('%s: error printing "%s" on LPT1:."', modName, printedNamePath);
          break
        end
      end
    end % if printEnable
  end % for copyNdx = 1:copiesTo
  [pathstr,name,ext,versn] = fileparts(printedNamePath);
  printedName = sprintf('%s%s', name, ext) ;
end

%-------------------------------
function combinedText = centerJustifyText(newText, textSoFar, centerCol, spaces);
% centers 'newText' at 'centerCol'
%calls "leftJustifyText" which actually performs the append/insert
startCol = centerCol - floor(length(newText)/2) ;
if startCol < 1
  startCol = 1;
end
combinedText = leftJustifyText(newText, textSoFar, startCol, spaces); 
%-------------------------------
function combinedText = leftJustifyText(newText, textSoFar, startCol, spaces); 
% if the existing text is shorted than the startCol, 
%   adds the necessary number of leading spaces & then 'newText'
% if the existing text goes beyond the startCol,
%   inserts 'newText' into the existing text overwriting any existing text in these positions
%   but preserving all existing text before and after newText's location.
existingText = char(textSoFar) ;
%if no new text, don't do anything
if ~length(newText)
  combinedText = existingText;
  return
end
% is this an insert?
if startCol <= length(existingText)
  %we're going to be brutual: overwrite anything in this area in the text
  % is there existing text after the new text?
  if length(existingText) > (startCol + length(newText))
    combinedText = sprintf('%s%s%s', existingText(1:startCol-1), newText, existingText(startCol+length(newText)) );
  else
    %no: we're trimming the exist & adding more than was there
    combinedText = sprintf('%s%s', existingText(1:startCol-1), newText);
  end
else
  %not an insert but an append: we'll add enough spaces and then the text of interest
  a = startCol - length(existingText);
  if a
    combinedText = sprintf('%s%s%s', existingText, spaces(1:a), newText);
  else
    combinedText = sprintf('%s%s', existingText, newText);
  end
end
%-------------------------------
function [textToPrint] = formatMessageBox(message, textToPrint, availableLinesArray, startCol, endCol, spaces);
% wraps message to fit within the columns by breaking message at a whitespace,
%  whitespace defined as a space, comma, semi-colon, period, CR, or LF
%overwrites EVERYTHING on the line - could call 'leftJustifyText' to perform an insert/overlay
%  but this is not needed for a ICS-213
lineLength = endCol - startCol + 1 ;
whiteSpace = [' ', ',', char(10), char(12), ';','.'] ;
remainingMsg = message ;

thisLine = 1;
while (length(remainingMsg) > lineLength) & (thisLine <= length(availableLinesArray))
  a = find(ismember(remainingMsg, whiteSpace));
  b = find(a < lineLength);
  b = a(b(length(b)));
  textToPrint(availableLinesArray(thisLine)) = {sprintf('%s%s', spaces(1:startCol-1), remainingMsg(1:b))};
  remainingMsg = remainingMsg(b+1:length(remainingMsg));
  thisLine = thisLine + 1 ;
end % while length(remainingMsg) > lineLength

textToPrint(availableLinesArray(thisLine)) = {sprintf('%s%s', spaces(1:startCol-1), remainingMsg)};
%-------------------------------
