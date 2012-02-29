function [err, errMsg, printed] = printSimple(fid, fpathName, receivedFlag, pathDirs, printer, form, outpostHdg);

modName = sprintf('>%s', mfilename);
printed.NamePath = ''; 
printed.Name = '' ;
printed.Date = '';
try %overall safety value
  [err, errMsg, formField, h_field] = readPrintCnfg(receivedFlag, pathDirs, printer, outpostHdg);
  % fname, originator, addressee, textToPrint)
  
  if printer.printEnable
    if printer.printEnable < 2
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
      printed.NamePath = sprintf('%sprinted_%s.txt', endWithBackSlash(pathstr), name);
      printed.Name = strcat(name, ext) ;
      fidOut = fopen(printed.NamePath, 'w') ;
      if printer.HPL3
        fprintf(fidOut, '%s', initString); 
      end
      printed.Date = prettyDateTime;
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
        err = dos (sprintf('copy "%s" %s', printed.NamePath, printer.printerPort));
      catch
        err = 2;
      end
      if err
        errMsg = sprintf('%s: error printing "%s" on "%s".', modName, printed.NamePath, printer.printerPort);
        fprintf('\n***Err %i, %s', err, errMsg);
      end
    else %if printer.printEnable < 2
      % build the message portion
      Ndx = 0;
      str = {''};
      while ~feof(fid)
        Ndx = Ndx + 1;
        textLine = fgetl(fid);
        str(Ndx) = {textLine};
      end %while ~feof(fid)
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
      % loop until message has been placed completely on a form - we'll
      %   add pages as required placing just the part of the message that fits
      %   on each page
      thisPage = 0 ;
      while length(str)
        %increment page number
        thisPage = thisPage + 1;
        set(h_field(thisPage, length(h_field)), 'Name', fpathName);
        outpostHeading('BBS', outpostHdg.bbs, formField(thisPage, :), h_field(thisPage, :), spaces);
        outpostHeading('FROM', outpostHdg.from, formField(thisPage, :), h_field(thisPage, :), spaces);
        outpostHeading('TO', outpostHdg.to, formField(thisPage, :), h_field(thisPage, :), spaces);
        outpostHeading('Subject', outpostHdg.subject, formField(thisPage, :), h_field(thisPage, :), spaces);
        if receivedFlag
          a = 'Received: ';
        else
          a = 'Sent: ';
        end
        outpostHeading('dateTime', strcat(a, outpostHdg.dateTime), formField(thisPage, :), h_field(thisPage, :), spaces);
        if length(outpostHdg.logMsgNum)
          outpostHeading('Local MsgNum', outpostHdg.logMsgNum, formField(thisPage, :), h_field(thisPage, :), spaces);
        end
        primaryNdx = find( ismember({formField(thisPage,:).PACFormTagPrimary}, lower('message')) ) ;
        primaryNdx = primaryNdx(1) ;
        hj = formField(thisPage, primaryNdx(1)).HorizonJust ;
        hj = hj(2:length(hj)) ;
        [outstring,newpos] = textwrap(h_field(thisPage, primaryNdx), str);
        positPrim = get(h_field(thisPage, primaryNdx),'Position');
        if (newpos(4) > positPrim(4))
          willFit = floor(length(str) * positPrim(4) / newpos(4) - 1) ;
          [outstring,newpos] = textwrap(h_field(thisPage, primaryNdx), str(1:willFit) );
          % shorten str to what hasn't been placed on a form
          str = str(willFit+1:length(str));
          %open another form
          [err, errMsg, h_f, ff] = showForm('', '', '');
          % merge arrays
          last_h_f = length(h_f);
          h_field((thisPage+1), 1:last_h_f) = h_f(1:last_h_f);
          formField((thisPage+1), 1:length(ff)) = ff;
        else % if (newpos(4) > positPrim(4))
          % this will break us out of the loop after the "set" is performed.
          str = {};
        end % if (newpos(4) > positPrim(4)) else
        %output the message to the form
        set(h_field(thisPage, primaryNdx),'String', outstring, ...
          'HorizontalAlignment', hj)
      end % while length(str)
      % %      [err, errMsg, textToPrint] = fillFormField('message', char(str), formField, h_field, '', '');
      if ~err
        [err, errMsg, printed] = ...
          formFooterPrint(printer, h_field, formField, fpathName, outpostHdg.from, outpostHdg.to, '', outpostHdg, receivedFlag);
      else
        if err == 100
          delete(h_field(:, length(h_field)) )
        end
      end
    end %if printer.printEnable < 2 else
  end %if printer.printEnable
catch % try %overall safety value
  err = 100;
  errMsg = sprintf('%s>: %s', mfilename, lasterr);
  try
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
if err == 100
  try
    % printing failure: try using notepad
    if printer.printEnable == 3
      err_1 = dos (sprintf('notepad /a "%s" &', fpathName));
    else % if printer.printEnable == 3
      if (printer.numCopies < 1) | (printer.numCopies > length(printer.copyList))
        printer.numCopies = length(printer.copyList);
      end
      copiesWanted = printer.numCopies+(length(h_field) < 2);
      for copyNdx = 1:copiesWanted
        err_1 = dos (sprintf('notepad /a /p "%s"', fpathName));
      end % for copyNdx = 1:copiesWanted
      [err, errMsg, h_field, formField] = routingSlip(outpostHdg);
      if (~err & printer.printEnable )
        % addressee, originator, textToPrint, & receivedFlag have no meaning in this context
        [err, errMsg, printed] = ...
          formFooterPrint(printer, h_field, formField, fpathName, '', '', '', outpostHdg, 0);
      end % if (~err & printer.printEnable)
      printed.Name = 'notepad print';  
    end  % if printer.printEnable == 3 else  
  catch
  end
end 


%------------------------------------------------------------------
%------------------------------------------------------------------
function outpostHeading(fieldID, fieldText, formField, h_field, spaces);
if (findstrchr('datetime', lower(fieldID)) < 1) & (nargin > 3)
  fieldText = sprintf('%s%s: %s', spaces(1:(length(spaces)-length(fieldID))), fieldID, fieldText);
end
[err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '');
%------------------------------------------------------------------
