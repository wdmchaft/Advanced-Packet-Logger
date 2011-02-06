function [err, errMsg, printedNamePath, printedName] = ...
  formFooterPrint(printer, printEnable, copyList, numCopies, h_field, formField, fname, originator, addressee, textToPrint, outpost, receivedFlag)

%outpost: structure containing Outpost header information including the date & time
%receivedFlag

%#IFDEF debugOnly
%support for debugging - user cancel for either quit or activating break point in IDE
global userCancel
%#ENDIF

if nargin < 11
  outpost.dateTime = '';
  receivedFlag = 0;
end

%establish return variables: clear tells processLog this message hasn't been printed
printedNamePath = ''; 
printedName = '' ;
spaces(1:100) = ' ';
[err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
%pull seconds.  ex: 15:01:59.7810 -> 15:01
a = findstrchr(':', prettyDateTime);
prettyDateTime = prettyDateTime(1:a(2)-1);
%try/catch safety valve.  This should never trip.  If it
%  does, we want 
%  (1) the program to continue
%  (2) an error to be reported
%  (3) (maybe) the loading of the form to be disabled
%  (4) the reported error to be logged to a file
try %most of module
  if (length(h_field) < 2)
    [initString, EjectPageTxt] = initPrintStrings(printer.qualLetter, 0);
    [pathstr,name,ext,versn] = fileparts(fname);
    %create the output file  **** note if printing is NOT enabled, we'll clear this
    %  so we don't falsely log print.  Creating it here permits creation of the file that
    %  would be printed - facilitiates debugging, etc.
    printedNamePath = sprintf('%sprinted_Form_%s.txt', endWithBackSlash(pathstr), name);
  end % if (length(h_field) < 2)
  if (numCopies < 1) | (numCopies > length(copyList))
    numCopies = length(copyList);
  end
  
  numPages = size(formField, 1);
  
  %send all the text to a file & then use the copy command to sent to the printer
  % normal operation is to loop once for each copy with the footer being different 
  %  each to, specifying who should have the copy.  One last copy is made without
  %  any footer.
  for copyNdx = 1:numCopies+(length(h_field) < 2)
    if (length(h_field) < 2)
      fid = fopen(printedNamePath, 'w');
    end
    %loop for forms that require more than one page
    for thisPage = 1:numPages
      %just want the field handles - we'll create the contents here
      footerNdx = find( ismember({formField(thisPage,:).digitizedName}, 'Footer') );
      if (copyNdx <= numCopies)
        %if the desired number of copies is >1 we'll include who this copy is for in the footer.
        %  If it is 1 we'll only include the date & time we printed it.
        if (numCopies > 1)
          % at bottom of the page, print the recipient of this copy
          %  determine how many lines can be available given the digitized space:
          fieldText = char(copyList(copyNdx));
          if findstrchr('ADDRESSEE', upper(fieldText))
            fieldText = sprintf('%s (%s)', fieldText, addressee);
          elseif findstrchr('ORIGINATOR', upper(fieldText))
            fieldText = sprintf('%s (%s)', fieldText, originator);
          end
          footerNumLines = round(formField(thisPage,footerNdx).lftTopRhtBtm(4) - formField(thisPage,footerNdx).lftTopRhtBtm(2) ) ;
          thisField = formField(thisPage,footerNdx) ;
          thisField.VertJust = 'Vtop';
          [footerFirstLine, col] = justify(thisField, fieldText);
          if (length(h_field) > 1)
            footerNumLines = 2;
            string = {};
          end
          for ltemp = 0:(footerNumLines-1)
            row = footerFirstLine + ltemp;
            % want time stamp on lesser of 2nd line or last line
            if ((ltemp == 1) | ((footerNumLines < 3) & (ltemp == (footerNumLines - 1))))
              % % ft = sprintf('copy %i of %i printed %s', copyNdx, numCopies, prettyDateTime);
              if (numPages > 1)
                ft = sprintf('page %i of %i printed %s', thisPage, numPages, prettyDateTime);
              else
                ft = sprintf('printed %s', prettyDateTime);
              end
              if (length(h_field) < 2)
                [a, c] = justify(thisField, ft);
                textToPrint(row) = {leftJustifyText(ft, char(textToPrint(row)), c, spaces)};
              else
                string(ltemp+1) = {ft};
              end
            else % if ((ltemp == 1) | ((footerNumLines < 3) & (ltemp == (footerNumLines - 1))))
              if (length(h_field) < 2)
                textToPrint(row) = {leftJustifyText(fieldText, char(textToPrint(row)), col, spaces)};
              else
                string(ltemp+1) = {fieldText};
              end
            end % if ((ltemp == 1) | ((footerNumLines < 3) & (ltemp == (footerNumLines - 1)))) else
          end % for ltemp = 0:(footerNumLines-1)
          if length(outpost.dateTime)
            if receivedFlag
              string(footerNumLines+1) = {sprintf('Received %s', outpost.dateTime)};
            else
              string(footerNumLines+1) = {sprintf('Sent %s', outpost.dateTime)};
            end
          end %if length(outpost.dateTime)
        else %if (numCopies > 1)
          fieldText = char(copyList(copyNdx));
          if findstrchr('ADDRESSEE', upper(fieldText))
            fieldText = sprintf('%s (%s)', fieldText, addressee);
          elseif findstrchr('ORIGINATOR', upper(fieldText))
            fieldText = sprintf('%s (%s)', fieldText, originator);
          end
          % % fieldText = sprintf('%s copy %i of %i printed %s', fieldText, copyNdx, numCopies, prettyDateTime);
          if (numPages > 1)
            % % fieldText = sprintf('%s page %i of %i printed %s', fieldText, copyNdx, numCopies, prettyDateTime);
            fieldText = sprintf('%s page %i of %i printed %s', fieldText, thisPage, numPages, prettyDateTime);
          else
            fieldText = sprintf('%s printed %s', fieldText, prettyDateTime);
          end
          if (length(h_field) < 2)
            [footerFirstLine, col] = justify(formField(thisPage, footerNdx), fieldText);
            footerNumLines =  1;
            textToPrint(footerFirstLine) = {leftJustifyText(fieldText, textToPrint(footerFirstLine), col, spaces)};
          else
            string = {fieldText};
            if length(outpost.dateTime)
              if receivedFlag
                string(2) = {sprintf('Received %s', outpost.dateTime)};
              else
                string(2) = {sprintf('Sent %s', outpost.dateTime)};
              end
            end %if length(outpost.dateTime)
          end
        end %if (numCopies > 1) else
        %initialize/configure the printer
        if (length(h_field) < 2)
          if printer.HPL3
            fprintf(fid, '%s', initString); 
          end
        end
      end % %    if (copyNdx <= numCopies))
      if (length(h_field) < 2)
        for itemp = 1:length(textToPrint)-1
          fprintf(fid,'%s\r\n', char(textToPrint(itemp)));
        end
        fprintf(fid,'%s', char(textToPrint(itemp+1)));
        if (copyNdx <= numCopies)
          fprintf(fid,'%s', char(12));  %form feed
        end %    if (copyNdx <= numCopies))
        fcloseIfOpen(fid);
        textToPrint(footerFirstLine+[0:(footerNumLines-1)]) = {''};
      else % if (length(h_field) < 2)
        hj = formField(thisPage,footerNdx).HorizonJust;
        hj = hj(2:length(hj));
        posit = get(h_field(thisPage,footerNdx),'position');
        [outstring,newpos] = textwrap(h_field(thisPage,footerNdx), string);
        %detect if footer is not tall ...
        if newpos(4) > posit(4)
          %not tall... merge lines & pad between with spaces to fill the width
          origUnits = get(h_field(thisPage, footerNdx),'units');
          %determine how many spaces we can insert and still fit the width
          set(h_field(thisPage, footerNdx),'units','character');
          %how wide is the field?
          posit = get(h_field(thisPage, footerNdx),'position');
          set(h_field(thisPage, footerNdx),'units', origUnits);
          % how many characters are in the footer?
          a = '';
          for itemp = 1:length(string)
            a = sprintf('%s%s', a, char(string(itemp)));
          end
          % number of spaces are split to go between the text that originally was on 
          %  separate lines
          spcs = max(0, floor((posit(3) - length(a))/(length(string) - 1)));
          spaces(1:spcs) = ' ';
          outstring = '';
          for itemp = 1:length(string)
            outstring = sprintf('%s%s', outstring, char(string(itemp)));
            if itemp < length(string)
              outstring = sprintf('%s%s', outstring, spaces);
            end
          end % for itemp = 1:length(string)
        end % if newpos(4) > posit(4)
        set(h_field(thisPage, footerNdx),'String', outstring, 'HorizontalAlignment', hj)
      end %if (length(h_field) < 2) else
      % print the output file
      if printer.printEnable
        if (length(h_field) < 2)
          %final copy does not contain the printer configuration codes
          fprintf('\n lpt print %i', length(h_field));
          try
            if (copyNdx <= numCopies)
              err = dos (sprintf('copy "%s" %s', printedNamePath, printer.printerPort));
            end % if (copyNdx <= numCopies)
          catch
            err = 2;
          end
          if err
            errMsg = sprintf('>%s: error printing "%s" on "%s".', mfilename, printedNamePath, printer.printerPort);
            fprintf('\n***Err %i, %s', err, errMsg);
          end
          %       end % if (copyNdx <= numCopies)
        else %if (length(h_field) < 2)
          fprintf('\n figure print %i %s', length(h_field), char(copyList(copyNdx)) );
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %   ACTUAL PRINTING OF THE FIGURE GOES HERE!
          drawnow
          figure(h_field(thisPage, length(h_field)))
          %#IFDEF debugOnly
          % IDE... ask user
          if 1
            %IDE - user specifies printer... which also means there is a wait cycle
            hCancel = cancelCheckIfOpen;
            if ~hCancel
              cancel;
            end
            checkCancel;
            if userCancel
              err = 1;
              errMsg = sprintf('>%s: user cancel', mfilename);
              return
            end
            print ('-v','-r600', '-painters', h_field(thisPage, length(h_field)) )
          else
            % compiled - print to default
            %#ENDIF
            print ('-r600', '-painters', h_field(thisPage, length(h_field)) )
            %#IFDEF debugOnly
          end
          %#ENDIF
          % %       print ('-r600', '-painters', h_field(length(h_field)) )
        end % if (length(h_field) < 2) else
      end % if printer.printEnable
    end % for thisPage = 1:numPages
  end % for copyNdx = 1:copyList
  
  tryCatch = 0;
  firstErr = '';
catch %most of module
  tryCatch = 1;
  %in case there is another error in the following steps,
  %  save the current error.
  firstErr = lasterr;
end %try/catch: most of module
%whether or not we had an exception (try/catch)
%  we want to close any related figures.  We'll
%  have another try catch to be sure no program crash!
try %form closure
  if (printer.printEnable | (printEnable == 2))
    if (length(h_field) < 2)
      [pathstr,name,ext,versn] = fileparts(printedNamePath);
      printedName = sprintf('%s%s', name, ext) ;
    else %if (length(h_field) < 2)
      printedName = 'direct to printer.';
      %close the figure(s)
      delete(h_field(:, length(h_field)) )
    end % if (length(h_field) < 2) else
  end %if (printer.printEnable | (printEnable == 2)) else
catch %form closure
  tryCatch = 2;
end %try/catch form closure

if tryCatch
  %  what???!!!  An error!! how could this be!!! we want 
  %  (1) the program to continue: the try/catch-es above.
  %  (2) an error to be reported
  err = 100 ;
  if tryCatch > 1
    errMsg = sprintf('%s>: "%s" -> "%s"', mfilename, firstErr, lasterr);
  else
    errMsg = sprintf('%s>: %s', mfilename, lasterr);
  end %  if firstErr
  %  (3) the reported error to be logged to a file
  %just in case we cannot open the log file we'll use try/catch...again
  try
    % we could pass this in but that affects ALL calls.  This is easier...
    %  besides, we'll never need the try/catch........
    [err_1, errMsg_1, outpostNmNValues] = OutpostINItoScript;
    fid = fopen(sprintf('%s%s.log', outpostValByName('DirAddOnsPrgms', outpostNmNValues), mfilename),'a');
    if fid > 0
      [err_1, errMsg_1, date_time] = datevec2timeStamp(now);
      fprintf(fid, '\r\n%s error: %s ', date_time, errMsg);
      fprintf(fid, '\r\n    file: %s', fname);
      fprintf('\n%s error: %s', date_time, errMsg);
      fprintf('\n    file: %s', fname);
      fclose(fid);
    end
  catch
  end
end % if tryCatch
%-------------------------------------------------------------------------------------------
