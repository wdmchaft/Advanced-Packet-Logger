function [err, errMsg, printEnable, copyList, numCopies, formField, h_field] = readPrintCnfg(receivedFlag, pathDirs, printEnable, formCoreName, fname)
%when called with only 3 arguments (not passing formCoreName & fname) creates a Simple form
%INPUT
% receivedFlag: determines which configuration file is loaded.
%  -1 sent message that was transcribed from paper 'outTrayPaper_copies.txt'
%   0 sent message 'outTray_copies.txt'
%   1 received message 'inTray_copies.txt'
%   2 received message, simple & is delivery receipt 'inTray_DelvrRecp.txt'
% if nargin >4, will open jpg for PacFORM... unless first character of <formCoreName> is -
%   The - indicates jpg is not available and PacF will be opened in browser.
%OUTPUT:
% formField(pageNumber, fieldIndex): structure
% h_field(pageNumber, handleIndex): handles to the fields 1:1 correspondence between handleIndex & fieldIndex
%     although handleIndex has one more entry: last non-zero entry on each page is figure's handle
h_field = 0;
formField = '';

[err, errMsg, printEnableRec, printEnableSent, printEnableDelvrRecp, ...
    numCopies4recv, numCopies4sent, numCopies4sentFromPaper, numCopies4DelvrRecp, HPL3] = ...
  readPrintICS_213INI(pathDirs.addOns, printEnable);

switch receivedFlag
case -1 %sent message that was transcribed from paper
  numCopies = numCopies4sentFromPaper;
  printEnable = printEnableSent;
  [copyList, err, errMsg] = readRecipients(strcat(pathDirs.addOns,'outTrayPaper_copies.txt'));
  a = 'Sent: ';
case 0 %sent message 
  numCopies = numCopies4sent;
  printEnable = printEnableSent;
  [copyList, err, errMsg] = readRecipients(strcat(pathDirs.addOns,'outTray_copies.txt'));
  a = 'Sent: ';
case 1 % received message
  printEnable = printEnableRec;
  numCopies = numCopies4recv;
  [copyList, err, errMsg] = readRecipients(strcat(pathDirs.addOns,'inTray_copies.txt'));
  a = 'Received: ';
case 2 % received message, simple & is delivery receipt
  numCopies = numCopies4DelvrRecp;
  printEnable = printEnableDelvrRecp * (numCopies~=0);
  [copyList, err, errMsg] = readRecipients(strcat(pathDirs.addOns,'inTray_DelvrRecp.txt'));
  a = 'Received: ';
otherwise
  err = 1;
  errMsg = sprintf('%s: internal error: unknown value for passed in received flag (%i)', mfilename, receivedFlag);
  printEnable = 0;
  copyList = {};
  numCopies = -1;
end % switch receivedFlag

if err
  errMsg = sprintf('>%s%s', mfilename, errMsg);
  return
end
if printEnable
  printEnable = printEnable * (length(copyList)>0);
end

% %%% might want to split here for printing initiated by operator for "this" form
% hmm, but operator needs to call the specific form routine anyway and that's how we got here.
% May want to pass more through that routing.

if printEnable
  fprintf('\n printEnable = %i', printEnable);
  if (nargin > 4)
    %patch for forms that cannot auto-print: bring 'em up in browser
    if strcmp('-', formCoreName(1:1))
      [err, errMsg] = viewToPrintPACF(pathDirs.DirPF, pathDirs.addOnsPrgms, fname);
      printEnable = 0;
      return
    end
    %formCoreName: --- multiple page forms not implemented for ICS213 because tyhat is a single page form
    %   core for .mat, the digitized fields: 
    %      single page form    <formCoreName>.mat
    %      multiple page form  <formCoreName><_pg#>.mat  where a separate mat exists for each page
    %   any cross-reference file: <formCoreName>_crossRef.csv  *** NOTE: only implemented for ICS213
    %   align file: either formAlign<formCoreName>.txt  or printerAlign<formCoreName>.txt
    %      single page form    formAlign<formCoreName>.txt
    %      multiple page form  formAlign<formCoreName><_pg#>.txt  where a separate .txt exists for each page
    %   image file for the display or blank-paper printing: <formCoreName>.jpg
    %      single page form    <formCoreName>.jpg
    %      multiple page form  <formCoreName><_pg#>.jpg  where a separate .jpg exists for each page
    if (printEnable > 1)
      formName = strcat('formAlign_', formCoreName);
    else % if (printEnable > 1)
      formName = strcat('printerAlign_', formCoreName);
    end % if (printEnable > 1) else
    
    %load the form field positions and information
    if findstrchr('ics213', lower(formName))
      [err, errMsg, formField, printerPort] = loadICS213FormPositions(pathDirs.addOns, formName);
      dirPgMat = [];
      showFormPName = strcat(pathDirs.addOnsPrgms, formCoreName);
    else % if findstrchr('ics213', lower(formName))
      pathNameMat = sprintf('%s%s', pathDirs.addOns, formCoreName);
      %check for a multiple page form:
      dirPgMat = dir(sprintf('%s_pg*.mat', pathNameMat));
      calPName = sprintf('%s%s', pathDirs.addOns, formName) ;
      if ~length(dirPgMat)
        [err, errMsg, formField] = loadAlignFormPosition(pathNameMat, calPName);
        showFormPName = strcat(pathDirs.addOnsPrgms, formCoreName);
      else %if ~length(dirPgMat)
        %load each page: formField goes from a one dimension array and becomes two dimensioned (:) -> formField(:, pg)
        for pageNdx = 1:length(dirPgMat)
          %get the page number for this page
          thisMat = dirPgMat(pageNdx).name;
          a = findstrchr('.',thisMat);
          thisMat = thisMat(1:(a(length(a))-1));
          pgTxt = thisMat(findstrchr('_pg',thisMat):length(thisMat));
          %build the name for this page...
          pathNameMat = sprintf('%s%s', pathDirs.addOns, thisMat);
          calPName = sprintf('%s%s%s', pathDirs.addOns, formName, pgTxt) ;
          showFormPName(pageNdx) = {sprintf('%s%s%s', pathDirs.addOnsPrgms, formCoreName, pgTxt)};
          %load the page fields and alignment
          [err, errMsg, ff] = loadAlignFormPosition(pathNameMat, calPName);
          if pageNdx > 1
            %include the load into the array
            formField(pageNdx, 1:length(ff)) = ff;
          else
            formField = ff;
          end
        end % for pageNdx = 1:length(a)
      end % if ~length(dirPgMat) else
    end % if findstrchr('ics213', lower(formName)) else
    if err
      errMsg = sprintf('>%s', mfilename, errMsg);
      fprintf('\n*** %s', errMsg);
      return
    end
    
    if (printEnable > 1)
      %load each page: formField goes from a one dimension array and becomes two dimensioned (:) -> formField(:, pg)
      figPosition = 0 ;
      for pageNdx = 1:max(1,length(dirPgMat))
        if ~length(dirPgMat)
          %single page form not considering expansion/elastic sized fields
          [err, errMsg, h_f] = showForm(showFormPName, pathDirs.addOns, formField);
          last_h_f = length(h_f);
        else
          % multiple page form
          [err, errMsg, h_f, a, figPosition] = showForm(char(showFormPName(pageNdx)), pathDirs.addOns, formField(pageNdx,:), figPosition);
          %first page may not have the most number of fields 
          %  so we'll not include this information until all pages are read.
          h_fig(pageNdx) = h_f(length(h_f));
          last_h_f = length(h_f) - 1;
        end
        if err
          fprintf('\n******* error: %s', errMsg);
        end
        if (length(h_f) > 1) 
          [pathstr,name,ext,versn] = fileparts(fname);
          %%%%%% NOTE: exact wording of "page " is critical: expandBoxNForm.m needs to find this
          %  when inserting a page so renumbering will work.  %%%%%%%%%%%%
          set(h_f(length(h_f)), 'Name', sprintf('%s%s page %i', name, ext, pageNdx));
          footerNdx = find( ismember({formField(pageNdx,:).digitizedName}, 'Footer') );
          if length(footerNdx)
            for itemp = 1:length(footerNdx)
              ttp = get(h_f(footerNdx), 'toolTip');
              %if there is an existing tooltip, we'll add a NewLine at the end and then append the file info
              if length(ttp)
                ttp = sprintf('%s\n', ttp);
              end % if length(ttp)
              set(h_f(footerNdx), 'toolTip', sprintf('%sfile: %s%s\nlocation: %s', ttp, name, ext, pathstr));
            end % for itemp = 1:length(footerNdx)
          end % if length(footerNdx)
        else
          fprintf('\n******* h_field short! %s ', strcat(pathDirs.addOnsPrgms, formCoreName));
        end
        if pageNdx > 1
          %include the load into the array
          h_field(pageNdx, 1:last_h_f) = h_f(1:last_h_f);
        else
          h_field = h_f(1:last_h_f);
        end
      end %for pageNdx = 1:max(1,length(dirPgMat))
      if pageNdx > 1
        %now that all pages are loaded, the size of the 2nd dimension of
        % h_field has been established.  The last entry needs to be the
        % handle to the figure for each page
        %Add one more element to each page...
        a = size(h_field, 2) + 1;
        for itemp = 1:pageNdx
          %.. containing the handle to the figure containing the page
          h_field(itemp, a) = h_fig(itemp);
        end
      end
    end %if (printEnable > 1)
  else %if (nargin > 4)
    if (printEnable > 1)
      %Simple message type
      [err, errMsg, h_field, formField] = showForm('', '', '');
      if err
        fprintf('\n******* error: %s', errMsg);
      end
      if (length(h_field) < 2) 
        fprintf('\n******* h_field short! %s ', strcat(pathDirs.addOnsPrgms, formCoreName));
      end
    end %if (printEnable > 1)
  end % if (nargin > 4) else
  %clear the .PACFormTagPrimary of every field that doesn't have a UI object/handles associated with it.
  %  Necessary to allow searches in filFormField to work:
  %       find( ismember({formField.PACFormTagPrimary}, lower(fieldID)) )
  % %   %   for thisPage = 1:size(h_field,1)
  % %   %     invalidNdx = find(h_field(thisPage,1:size(h_field,2)-1)<1);
  % %   %     for itemp = 1:length(invalidNdx)
  % %   %       formField(thisPage, invalidNdx(itemp)).PACFormTagPrimary = '';
  % %   %     end % for itemp = 1:length(invalidNdx)
  % %   %   end % for thisPage = 1:size(h_field,1)
end % if printEnable

