function [err, errMsg] = digitizePACF(pacfTxtDir);

% Paper version of County forms do not have all the fields desired
%   by the packet operation.
% 
%   1) bring form up in a browser.
%   2a) print preview from the browser:
%      * click on Page Setup Tab & under "Format & Options", uncheck "print background (colors & images)
%      * under the "Margins & Header/Footer" tab
%        * all margins to zero
%        * all header & footer entries to "blank"
%      * click OK
%      * adjust size until form fits appropriately: no wider than one page & 
%        typically no taller than one.  (Clicking on "Shrink to fit Page Width" may be a good starting point)
%    2b) print to a PDF "printer" such as CutePDF: 
%      * the PACF will remove a lot of the instructions and comments
%        before printing - check via "print preview"
%      * set the "printer" to a high resolution such as 300 DPI 
%      * set to B&W gray scale printing
%      * click on print
%      * give the printed file the same name you want for the field alignment file, the
%        high/lo res alignment file, and the name all will be in the form field extraction 
%        program ****** If the form is a multiple page form, add "_pgnn" at the end of the name
%        where nn is the page number ***
%    2c) repeat 2b but use a lower resolution such as 150 and include that in the name ex: "_150dpi"
%    2d) for multiple page forms, repeat 2b & 2c for each page adjusting nn in "_pgnn" as needed.
%   3) Fill out sample information in the form for subsequent confirmation
%      of this entire process.  ESPECIALLY check all boxes that are stand-alone check boxes -
%      in other words, boxes that are not 'chose one of the following'
%   4) Click on "send to text".  A new window will open.  Open an instance
%      of notepad.  Cut & paste the contents of the window into notepad
%      leaving out the help lines.  Save the notefad file giving it a simple
%      form-related name with ,txt extension.  This is not used during printing
%      merely during the form creation process.
%   3) Open the pdf twice in PhotoShop 
%        * low resolution to digitize the location of the fiels. 200 dpi
%          seems fine although lower resolutions may also work.
%          Low resolution speeds the motion during digitizing
%        * high resolution for actual use. Suggest the same as
%          used during the "printing" which was 600 dpi.
%   4) Crop the form as desired - both can be cropped but do not have
%      to be exactly the same - the critical one is the high resolution.
%   5) Create a jpg for each: Save a Copy As, smallest size seems to be sufficient quality.
%      Give the files simple, form-related names such as CityMAReq.jpg for the high-res & 
%      CityMAReq_200dpi.jpg for the low res
%   6) bring up & run this program to select the .txt file & the low res .jpg file and
%      the digitizer will start.
%   7) Nearly done! Now time to align the high res jpg to the low res digitized image.
%       Run "figImageAlign"

%modify the function related to the form if not already modified:
% a) add to end of calling variables: , h_field -> reserved for future
% b) add after .. = clearFormInfo;
%   if nargin < 7
%     h_field = 0;
%   end
%   [err, errMsg, printEnable, copyList, numCopies, formField, h_field] = readPrintCnfg(receivedFlag, pathDirs, printMsg, 'CityMAReq', msgFname);
%   if err
%     printEnable = 0;
%     errMsg = strcat(modName, errMsg);
%   end
%   fieldsFound = 0;
% 
% c) add to each extracted field
%     fieldsFound = fieldsFound + 1;
% d) add after the "switch" structure and just before   textLine = fgetl(fid);
%   if printMsg 
%     [err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '') ;
%   else % if printMsg 
%     %If we are not printing and we've found all the desired fields
%     %  presuming each fieldID occurs only once in the message
%     if fieldsFound > 9
%       break
%     end
%   end % if printMsg else
% e) modify the just added "if fieldsFound > 9" so the number is correct for the
%     number of fields that will be located in the switch (this "if" is the
%     routine exit when printing is not enabled
% f) make sure "originator" is assigned to the approriate entry on the form
% f) finally after the fclose..., add where 'Planning' is the appropriate section
%     addressee = 'Planning';
%     if (~err & printEnable)
%       [err, errMsg, printed] = formFooterPrint(printer, printEnable, copyList, numCopies, h_field, formField, msgFname, originator, addressee, textToPrint);
%     end % if (~err & printEnable)
%     

% Toss in some instructions for the entire process from
% digitizing the image, conversion from PDF to jpgs (low res for digitizing
% & high res for usage), then calling this procedure to perform the digitizing
% 
%Code identifies which fields are used for text and which are used for check boxes
%  such as one-of-multiple, yes, no, and check
% one check box in situation severity must be checked
% one check box in msg handling order must be checked
%  all other check boxes must be checked
% either yes or no must be checked for any item with those choices

%rules of what types of field CONTENTS indicate check boxes
% "otherwise" => not a check box type of field
% when a field's contents contains any one of the braced sets {},
%   we will create a field name for all of the elements in that set.
%   Each will start with the fieldID followed by a "_" and then the element name.
%
%"loadAlignFormPosition" will separate the fieldID into the .PrimaryTag and the element
%  name into the .SecondaryTag for checkbox types. For fields other than a checkbox,
%  the SecondaryTag will be empty.
%
%"fillFormField" when decoding a PACF a SecondaryTag with contents is recognized as a check box and
%  the decoded fieldID is used to chose the field(s) with the matching PrimaryTag and use the 
%  decoded field text (contents) to activate the appropriate check mark if anything is to be checked.
%  When the SecondaryTag is null, the decoded field text is transferred directly into the displayed 
%  (or printed) field - a check mark is not subsituted.

%Set the Rules for what contents indicate a check box
%  also, form-specific rules will be loaded from a file 'digitizePACF_<form name>.txt'
%   where <form name> is returned by "getPACFType".  ex: 'digitizePACF_SEMS SITUATION.txt'
checkBoxContents = {...
    {'yes','no'};...
    {'emergency','urgent','other'};...
    {'checked'};... 
    {'immediate','priority','routine'};...
    {'Telephone','Dispatch Center','EOC Radio','FAX','Courier','Amateur Radio','Amateur Radio','Other'};...
    {'Received','Sent'};...
    };
%    {'checked'};...  <- this is not a good indicator because this is only the content when the checkbox is checked!
%             Therefore run-time determination in fillFormField that this content indicates a checkbox
%             Not the best since the visible off cannot be implemented

checkBoxFieldKey(1:size(checkBoxContents,1)) ={''};

if nargin < 1
  pacfTxtDir = 'C:\ProgramData\SCCo Packet\archive\TestFiles';
end

%list of all formats supported by "imread"
a = {'*.mss','Logger messages',...
    '*.txt','Windows Cursor resources',...
  };
b = char(a(1));
for itemp = 3:2:length(a)
  b = sprintf('%s;%s', b, char(a(itemp)) );
end
fileMask = {b,sprintf('All supported PACF text (ASCII) files (%s)',b)};
for itemp = 1:2:length(a)
  b = size(fileMask,1)+1 ;
  c = char(a(itemp));
  fileMask(b,1) = {sprintf('%s', c) };
  fileMask(b,2) = {sprintf('%s (%s)',char(a(itemp+1)), c) };
end

origDir = pwd;
cd(pacfTxtDir)
[fname,pname] = uigetfile(fileMask, 'PACF ASCII File');
cd(origDir)
if isnumeric(fname);
  if fname < 1
    fprintf('\nUser cancel.');
    return
  end
end

pathNName = strcat(pname, fname);
fid = fopen(pathNName, 'r');
if (fid < 1)
  fprintf('\nUnable to open to read "%s".', pathNName);
  return
end
%learn all the fields:
groupNameInNdx = 0;
groupNameIn = {};
PACF = detectPacFORM(fid, 0, 1e3);
if ~PACF
  fprintf('\nNot recognized as a PACF "%s".', pathNName);
  fcloseIfOpen(fid);
  return
end

[err, errMsg, pacfListNdx, thisForm, textLine] = getPACFType(fid);
if err
  fprintf('\nError %s.', errMsg);
  fcloseIfOpen(fid);
  return
end
%text if there is an auxiliary information file with form-specific rules
%  each line that starts with % is ignored
%  each active line is a CSV with the first item the field number.... used to filter
%    the field contents so if they happen to occur in another field, that
%    field is not expanded/altered to be check boxes.  The rest of the line 
%    are the field contents as they would be loaded by PACF.
%   ex:  1.,City, Operational Area, OES Region, OES Headquarters
auxFile = sprintf('%s_%s.txt', mfilename, thisForm);
fid_aux = fopen(auxFile, 'r');
%we have a file?
if fid_aux > 0
  fprintf('\n*** Form-specific "rules" file located...');
  fieldKey = {};
  while ~feof(fid_aux)
    textLine = fgetl(fid_aux);
    if 1 ~= findstrchr('%', strtrim(textLine))
      txt = {};
      commasAt = findstrchr(',', textLine);
      [err, errMsg, text] = extractTextFromCSVText(textLine, commasAt, 0);
      fieldKey(length(fieldKey)+1) = {lower(strtrim(text))};
      fprintf('\n  for field named "%s", added checkboxes for ', strtrim(text));
      %extract the information from the line
      for itemp = 1:length(commasAt)
        [err, errMsg, text] = extractTextFromCSVText(textLine, commasAt, itemp );
        txt(length(txt) + 1) = {lower(strtrim(text))};
        fprintf('%s, ', strtrim(text));
      end % for itemp = 1:length(commasAt)
      %add to the rules list.
      checkBoxContents{size(checkBoxContents,1)+1,:} = txt ;
      checkBoxFieldKey(size(checkBoxContents,1)) = fieldKey(length(fieldKey));
    end % if ~findstrchr('%', textLine)
  end %while ~feof(fid_aux)
  fcloseIfOpen(fid_aux);
end %if fid_aux
%get past the PACF header
% skip through the comment/heading
textLine = '#' ;
while (1==findstrchr('#', textLine) & ~feof(fid))
  textLine = fgetl(fid);
end

while 1 % read & detect the field for each line of the entire message
  % clear the print line so the line will not be altered unless the field
  %   has an entry. 
  printLine = 0;
  if (1 == findstrchr(textLine, '#EOF')) | feof(fid)
    break
  end
  textLine = readPACFLine(textLine, fid);
  if feof(fid)
    err = 1 ;
    errMsg = sprintf('%s: incomplete message: End-of-message but no "#EOF"', modName);
    break
  end
  [fieldText, fieldID] = extractPACFormField(textLine) ;
  a = findstrchr('.', fieldID);
  % . is not embedded  ex: A. & not A.0
  if (a(length(a)) == length(fieldID))
    fieldIDNoPeriod = fieldID(1:a-1);
  else
    fieldIDNoPeriod = fieldID;
  end
  %if this is a legitimate PACF field....
  if length(fieldID)
    %determine if this is a field using check box(es) - we've got rules
    %  of what types of field CONTENTS indicate check boxes
    %"otherwise" => not a check box type of field
    %using the checkBoxContents list
    found = 0;
    lwr = lower(fieldText);
    for itemp = 1:size(checkBoxContents,1)
      if any(ismember(checkBoxContents{itemp,:}, lwr))
        if length(checkBoxFieldKey{itemp})
          found = strcmp(fieldID, checkBoxFieldKey{itemp});
        else % if length(checkBoxFieldKey{itemp})
          found = 1;
        end % % if length(checkBoxFieldKey{itemp}) else
        break
      end % if any(ismember(checkBoxContents{itemp,:}, lwr))
    end % for itemp = 1:size(checkBoxContents,1)
    if found
      % create a field name for all of the elements in that set.
      %   Each will start with the fieldID followed by a "_" and then the element name.        
      [groupNameIn, groupNameInNdx] = extendChoices(fieldIDNoPeriod, checkBoxContents{itemp,:}, groupNameIn, groupNameInNdx);
    else
      %field content not found in the check box "rules" - must be a text box
      groupNameInNdx = groupNameInNdx + 1;
      groupNameIn(groupNameInNdx) = {fieldID};
    end
  end
  textLine = fgetl(fid);
end %while 1
%done reading the sample file
fcloseIfOpen(fid);

%add housekeeping fields
lastNonhouseNdx = groupNameInNdx;
houseKeeping = {'AlignmentBox','Footer','Header','end-no points (hit OK & then "q")'};
for itemp = 1:length(houseKeeping)
  groupNameInNdx = groupNameInNdx + 1;
  groupNameIn(groupNameInNdx) = houseKeeping(itemp);
end

%chose and load the image we'll be digitizing
[err, errMgs, figToTrack, figMagd, pathNName] = digitizeSelectImage;
[pathstrImage,name,ext,versn] = fileparts(pathNName);
load(strcat(pathstrImage,'\grayMap'))
set(figToTrack,'colormap', grayMap)
set(figMagd,'colormap', grayMap)

if err
  fprintf('\nErr: %s', errMsg);
  return
end

button = questdlg('Is this part of a multiple-page form?',...
  'Multiple Page Form','Yes','No','Yes');
if strcmp(button, 'Yes') 
  listIn = {};
  for itemp = 1:lastNonhouseNdx
    listIn(itemp) = groupNameIn(itemp);
  end
  choice = userChoice(listIn, 'First group on this page of the form', 1);
  if choice < 1
    fprintf('\r\nUser canceled!');
    return
  end
  firstGroupNdx = choice;
  choice = userChoice(listIn, 'Last group on this page of the form', firstGroupNdx+1);
  if choice < 1
    fprintf('\r\nUser canceled!');
    return
  end
  lastGroupNdx = choice;
  thisPageNdx = firstGroupNdx:lastGroupNdx;
  while strcmp(button, 'Yes')
    thisList = groupNameIn(thisPageNdx);
    fprintf('\nThe following fields are on this page:');
    for itemp = 1:length(thisList)
      fprintf('\n%s', thisList{itemp});
    end
    button = questdlg('Do you want to add more fields?',...
      'Add fields','Yes','No','Yes');
    if strcmp(button, 'Yes')
      listIn = {};
      for itemp = 1:lastNonhouseNdx
        if ~find(itemp) == thisList
          listIn(itemp) = groupNameIn(itemp);
        end
      end
      choice = userChoice(listIn, 'Additional group on this page', 1);
      if choice < 1
        fprintf('\r\nUser canceled!');
        return
      end
      thisList(length(thisList)+1) = choice;
    end % if strcmp(button, 'Yes')
  end %while strcmp(button, 'Yes')
  %number of house keeping added
  a = groupNameInNdx - lastNonhouseNdx;
  thisList(length(thisList)+[1:a]) = groupNameIn(lastNonhouseNdx + [1:a]);
  groupNameIn = thisList;
end % if strcmp(button, 'Yes') part of multipage form

%finally digitize by prompting for each of the fields we've found
keyMOUSEpress = -2; %cell array "groupName" has been loaded but nothing else
digitizePoints(figToTrack, figMagd, keyMOUSEpress, pathNName, groupNameIn);

button = questdlg(sprintf('Are you done locating the fields on "%s" and \nare you now ready to align the high resolution form image?', strcat(name,ext)),...
  'Procede with Alignment','Yes','No','Yes');
if ~strcmp(button, 'Yes') 
  return
end
% 
prompt  = {'Top alignment','Left alignment', 'Right alignment', 'Bottom Alignment'};
title   = 'Description of features used for alignment box.';
lines= 1;
def     = {'line beneath heading','outside edge of left border',' outside edge of right border', 'bottom edge of bottom border'};
answer  = inputdlg(prompt,title,lines,def);
alignDescript = answer;

figImageAlign(alignDescript)

%---------------------------------------------------------------------------
function [groupNameIn, groupNameInNdx] = extendChoices(baseName, subNameList , groupNameIn, groupNameInNdx);

for itemp = 1:length(subNameList)
  groupNameIn(groupNameInNdx + itemp) = {sprintf('%s:=%s', baseName, char(subNameList(itemp)) )};
end
groupNameInNdx = groupNameInNdx + itemp;
%---------------------------------------------------------------------------
