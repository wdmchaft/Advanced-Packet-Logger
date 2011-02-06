function [err, errMsg, textToPrint, h_field, formField, moveNeeded] = fillFormField(fieldID, fieldText, formField, h_field, textToPrintIn, spaces, outpostNmNValues);
% if length(h_field) > 1, the fields on the form are loaded
% if not, textToPrint is loaded
%INPUT
% fieldID: decoded current PACF field ID from the text version of the message
% fieldText: decoded field contents
% formField: structure containing the location and names of every field
%     digitizedName
%     PACFormTagPrimary - special case if == '7' or == '8'
%     PACFormTagSecondary
%     HorizonJust
%     VertJust
%     lftTopRhtBtm
% h_field: for a screen version of the form, this contains the handles of
%      every field and has a 1:1 correspondence to the formField
% textToPrint: for use with preprinted forms in a printer, this is a text
%      arrray of "row" length and each entry is the number of printable columns 
%      on the page
% spaces: pre-loaded with "column" number of blank spaces - only used for pre-printed
%     forms so while it must be present, it can be a null string for blank paper forms.

err = 0;
errMsg = '';
moveNeeded = 0;

if (nargin < 7)
  outpostNmNValues = {};
end

textToPrint = textToPrintIn;

%safety valve.  This should never trip.  If it
%  does, we want 
%  (1) the program to continue
%  (2) an error to be reported
%  (3) (maybe) the loading of the form to be disabled
%  (4) the reported error to be logged to a file
try
  %PACF use an upside down question mark as the first character in a field
  % to indicate the field is allowed to expand its size dynamically. We don't
  % want that to be displayed.
  %Additionally it uses that character to indicate a line feed.
  %We'll implement the following rules
  %  1) first character of field: remove it
  %  2) anywhere else in field: remove and replace with new line
  expandBox = 0 ; %0 = not allowed; 1: search for text actually overflowing UI box; 2: overflow occurred & re-size needed
  if length(fieldText)
    if strcmp(char(191), fieldText(1))
      expandBox = 1 ;
      if size(fieldText, 1) > 1
        fieldText(1,1:length(fieldText)-1) = fieldText(1,2:length(fieldText));
        fieldText(1,length(fieldText))= ' ';
      else % if size(fieldText, 1) > 1
        fieldText = fieldText(1,2:length(fieldText));
        % remove any LF characters.  These aren't in the orignal message so
        %  are probably inserted at packet boundaries.
        ft = strrep(fieldText, char(10),'');
        % replace any upside down question marks with LF
        fieldText = strrep(ft, char(191), char(10));
      end % if size(fieldText, 1) > 1 else
    end % if strcmp(char(191), fieldText(1))
  end % if length(fieldText)
  
  %determine where this fieldID is in our list:
  primaryNdx = find( ismember({formField.PACFormTagPrimary}, lower(fieldID)) );
  if ~any(primaryNdx);
    %pull trailing '.'
    a = findstrchr('.', fieldID);
    if a(length(a)) == length(fieldID);
      fieldID = fieldID(1:length(fieldID)-1);
    end
    primaryNdx = find( ismember({formField.PACFormTagPrimary}, lower(fieldID)) );
    if ~any(primaryNdx);
      %%%%
    end
  end
  numPages = size(formField, 1);
  if (numPages > 1)
    % determine the page(s) that contain the primaryNdx.
    %   formField(page, Ndx) when accessed as formField(:) sequences
    %     1 == page1, Ndx1; 2== page2, Ndx1; 3 == page1, Ndx2
    b = mod(primaryNdx, numPages);
    pages = b(1);
    %build a list of all the pages
    b = find(b~=pages);
    for itemp = 1:length(b)
      pages(length(pages)+1) = b(itemp);
    end
    a = find(pages < 1) ;
    if a
      pages(a) = numPages;
    end
  else % if (pages > 1)
    pages = 1;
  end % if (pages > 1) else
  
  for pageNdx = 1:length(pages)
    thisPage = pages(pageNdx);
    primaryNdx = find( ismember({formField(thisPage, :).PACFormTagPrimary}, lower(fieldID)) );
    
    %if there is information within formField.PACFormTagSecondary, some sort of a checkbox
    b = strcmp('checked',fieldText);
    if length(char(formField(thisPage, primaryNdx).PACFormTagSecondary)) | b
      secondaryNdx = find( ismember({formField(thisPage,:).PACFormTagSecondary}, lower(fieldText))) ;
      a = find(ismember(primaryNdx, secondaryNdx)) ;
      if ~length(a)
        a = b;
      end
      if (length(h_field) > 1)
        if length(a)
          if (a>0)
            oldpos = get(h_field(thisPage, primaryNdx(a(1))),'position');
            [outstring,newpos] = textwrap(h_field(thisPage, primaryNdx(a(1))),{'X'});
            newpos(1) = oldpos(1) + (oldpos(3) - newpos(3))/2;
            newpos(2) = oldpos(2) + (oldpos(4) - newpos(4))/2;
            set(h_field(thisPage, primaryNdx(a(1))),'string', outstring, 'position', newpos,'Visible', 'on')
          else
            % clear & hide
            set(h_field(thisPage, primaryNdx(a(1))),'string', '','Visible', 'off')
          end
        end %if length(a)
      else %if (length(h_field) > 1)
        if a
          primaryNdx = primaryNdx(a(1));
          fieldText = 'XX';
        else
          fieldText = '';
        end
      end %if (length(h_field) > 1) else
    else %  if length(char(formField(thisPage, primaryNdx).PACFormTagSecondary))
      %not a check box so some sort of text
      hj = formField(thisPage, primaryNdx(1)).HorizonJust;
      hj = hj(2:length(hj));
      %if multiple matches (no secondary tags)...
      if (length(primaryNdx) > 1)
        %must be a multiple line field:
        if (length(h_field) > 1)
          %multiple line boxes have been combined into a single text box 
          %We want to preserve CR . . .
          %  find positions of all CR
          a = findstr(char(13), fieldText);
          %  add one pointer just beyond the end
          a(length(a)+1) = length(fieldText) + 1;
          ft = {};
          strt = 1;
          %extract each set of text that is bounded by CR into 
          % separate elements in the cell array "ft"
          for itemp = 1:length(a)
            ft(itemp) = {fieldText(strt:(a(itemp)-1))};
            strt = a(itemp)+1;
          end
          [outstring,newpos] = textwrap(h_field(thisPage, primaryNdx(1)), ft);
          if expandBox
            positPrim = get(h_field(thisPage, primaryNdx(1)),'Position');
            expandBox = 2 * (newpos(4) > positPrim(4));
          end
          set(h_field(thisPage, primaryNdx(1)),'String', outstring, 'HorizontalAlignment', hj)
        else %if (length(h_field) > 1)
          %  get them in name order as named when digitzed
          f = formField(thisPage, primaryNdx);
          [g, ndx] = sort({f.digitizedName});
          textToPrint = formatMessageBox(fieldText, textToPrint, f(ndx), spaces);
        end %if (length(h_field) > 1) else
      else %if (length(thisPage, primaryNdx) > 1)
        %single line 
        if (length(h_field) > 1)
          %if this is the MsgNo field, we want largest type that will fit
          if strcmp(formField(thisPage, primaryNdx).PACFormTagPrimary, 'msgno')
            set(h_field(thisPage, primaryNdx), 'FontUnits','normalized');
            fontOrig = get(h_field(thisPage, primaryNdx), 'FontSize');
            pos = get(h_field(thisPage, primaryNdx), 'Position');
            [outstring,newpos] = textwrap(h_field(thisPage, primaryNdx), {fieldText});
            font_2 = (min(pos(4)/newpos(4), pos(3)/newpos(3)) * fontOrig);
            set(h_field(thisPage, primaryNdx), 'FontSize', font_2);
            [outstring,newpos2] = textwrap(h_field(thisPage, primaryNdx), {fieldText});
            set(h_field(thisPage, primaryNdx), 'String',outstring)
          else
            [outstring,newpos] = textwrap(h_field(thisPage, primaryNdx), {fieldText});
          end
          set(h_field(thisPage, primaryNdx),'String', outstring, 'HorizontalAlignment', hj); 
        else %if (length(h_field) > 1)
          if length(fieldText)
            [row, col] = justify(formField(thisPage, primaryNdx), fieldText);
            %row & col have been calculated knowing we're calling "leftJustifyText"
            textToPrint(row) = {leftJustifyText(fieldText, textToPrint(row), col, spaces)};
          end % if length(fieldText)
        end %if (length(h_field) > 1) else
      end %  if (length(thisPage, primaryNdx) > 1) else
      if (expandBox > 1)
        [h_field, formField, moveNeeded] = expandBoxNForm(h_field, formField, primaryNdx(1), positPrim, newpos, thisPage, numPages, outpostNmNValues );
      end % if expandBox
    end %  if length(char(formField(thisPage, primaryNdx).PACFormTagSecondary)) else
  end % for pageNdx = 1:length(pages)
  tryCatch = 0;
catch
  %  what???!!!  An error!! we want 
  %  (1) the program to continue: this catch.
  %  (2) an error to be reported
  err = 100
  errMsg = sprintf('%s>: %s', mfilename, lasterr);
  %  (3) (maybe) the loading of the form to be disabled
  %  (4) the reported error to be logged to a file
  tryCatch = 1;
end %try/catch
if tryCatch
  %just in case we cannot open the log file we'll use try/catch
  try
    fid = fopen(sprintf('%s%s.log', outpostValByName('DirAddOnsPrgms', outpostNmNValues), mfilename),'a');
    if fid > 0
      [err, errMsg, date_time] = datevec2timeStamp(now);
      fprintf(fid, '\r\n%s error: %s on field ID %s: %s', date_time, lasterr, fieldID, fieldText);
      fprintf('\n%s in %s, error: %s on field ID %s: %s', date_time, mfilename, lasterr, fieldID, fieldText);
      fclose(fid);
    end
  catch
  end
end % if tryCatch
%-------------------------------------------------------------------------------------------
