function [err, errMsg, printedNamePath, printedName] = printSimple(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, form, outpost);

modName = sprintf('>%s', mfilename);
printedNamePath = '' ;
printedName = '';
try %overall safety value
  [err, errMsg, printEnable, copyList, numCopies, formField, h_field]...
    = readPrintCnfg(receivedFlag, pathDirs, printMsg);
  % fname, originator, addressee, textToPrint)
  
  if printEnable
    if printEnable < 2
      %this hasn't been updated.....
      %printed will be done by copying the message file to a new file
      % that a) may start with a printer initialization string
      %      b) has the print date & time on the first line
      %      c) ends with a FormFedd
      %      d) has the same name as the message file with the prefix "printed_"
      %After this file has been created, it will be copied to the specified printer port.
      [err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
      %pull seconds.  ex: 15:01:59.7810 -> 15:01
      a = findstrchr(':', prettyDateTime);
      prettyDateTime = prettyDateTime(1:a(2)-1);
      [initString, EjectPageTxt] = initPrintStrings(printer.qualLetter, 0);
      [pathstr,name,ext,versn] = fileparts(fpathName);
      %create the output file: prefix of "printed_" added to original name
      printedNamePath = sprintf('%sprinted_%s.txt', endWithBackSlash(pathstr), name);
      fidOut = fopen(printedNamePath, 'w') ;
      if printer.HPL3
        fprintf(fidOut, '%s', initString); 
      end
      fprintf(fidOut, '****** printed %s ******/r/n', prettyDateTime);
      while 1
        textLine = fgetl(fid);
        if feof(fid)
          fprintf(fidOut, '%s%s', textLine, EjectPageTxt);
          break
        else
          fprintf(fidOut, '%s/r/n', textLine);
        end
      end %while 1
      fcloseIfOpen(fidOut);
      try
        err = dos (sprintf('copy "%s" %s', printedNamePath, printer.printerPort));
      catch
        err = 2;
      end
      if err
        errMsg = sprintf('%s: error printing "%s" on "%s".', modName, printedNamePath, printer.printerPort);
        fprintf('\n***Err %i, %s', err, errMsg);
      end
    else %if printEnable < 2
      set(h_field(length(h_field)), 'Name', fpathName);
      
      len = 0;
      for itemp = 1:length(formField)
        if ~findstrchr('footer',formField(itemp).digitizedName)...
            & ~findstrchr('message',formField(itemp).digitizedName)...
            & findstrchr('Hleft',formField(itemp).HorizonJust)
          len = max(length(formField(itemp).digitizedName), len);
        end
      end %for itemp = 1:length(formField)
      %
      spaces(1:len) = ' ' ;
      outpostHeading('BBS', outpost.bbs, formField, h_field, spaces);
      outpostHeading('FROM', outpost.from, formField, h_field, spaces);
      outpostHeading('TO', outpost.to, formField, h_field, spaces);
      outpostHeading('Subject', outpost.subject, formField, h_field, spaces);
      if receivedFlag
        a = 'Received: ';
      else
        a = 'Sent: ';
      end
      outpostHeading('dateTime', strcat(a, outpost.dateTime), formField, h_field, spaces);
      if length(outpost.logMsgNum)
        outpostHeading('Local MsgNum', outpost.logMsgNum, formField, h_field, spaces);
      end
      %and now the message itself
      Ndx = 0;
      str = {''};
      while ~feof(fid)
        Ndx = Ndx + 1;
        textLine = fgetl(fid);
        str(Ndx) = {textLine};
      end %while ~feof(fid)
      [err, errMsg, textToPrint] = fillFormField('message', char(str), formField, h_field, '', '');
      
      [err, errMsg, printedNamePath, printedName] = ...
        formFooterPrint(printer, printEnable, copyList, numCopies, h_field, formField, fpathName, outpost.from, outpost.to, '', outpost, receivedFlag);
    end %if printEnable < 2 else
  end %if printEnable
catch % try %overall safety value
  err = 100;
  errMsg = sprintf('%s>: %s', mfilename, lasterr);
  try
    % printing failure: try using notepad
    err_1 = dos (sprintf('notepad /a /p "%s"', fpathName));
    % we could pass this in but that affects ALL calls.  This is easier...
    %  besides, we'll never need the try/catch........
    [err_1, errMsg_1, outpostNmNValues] = OutpostINItoScript;
    fid = fopen(sprintf('%s%s.log', outpostValByName('DirAddOnsPrgms', outpostNmNValues), mfilename),'a');
    if fid > 0
      [err_1, errMsg_1, date_time] = datevec2timeStamp(now);
      fprintf(fid, '\r\n%s error: %s ', date_time, errMsg);
      fprintf(fid, '\r\n    file: %s', fpathName);
      fprintf('\n%s error: %s', date_time, errMsg);
      fprintf('\n    file: %s', fpathName);
      fclose(fid);
    end
  catch
  end
end % try/catch %overall safety value


%------------------------
function outpostHeading(fieldID, fieldText, formField, h_field, spaces);
if (findstrchr('datetime', lower(fieldID)) < 1) & (nargin > 3)
  fieldText = sprintf('%s%s: %s', spaces(1:(length(spaces)-length(fieldID))), fieldID, fieldText);
end
[err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '');
