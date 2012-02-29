function [err, errMsg, printed, form] = print_ICS_213(fid, fname, receivedFlag, pathDirs, printer, outpostHdg, outpostNmNValues, h_field);
%function [err, errMsg, printed] = print_ICS_213(fid, fname, receivedFlag, PathConfig);
% Continues to read the open text file which has been identified as 
%containing an ICS213 'PACForms' format message.
% Extracts the information desired for the Packet Log (into the structure "form") and
%  may print the contents.  Currently only capable of printing to fill in the fields
%  of a pre-printed form.  Future enhancement is to print the titles of the fields as 
%  well so blank paper can be used, the output will be readable, and the printing time
%  as well as ink/toner consumption will be minimized.
%INPUT:
% fid: open file handle to the message we're reading.
% fname: path and name of the file we're handling.  This is used
%      to name the output file: printed_213_<fname> 
%==========[ADD THE PRINTER'S PORT TO THE CALIBRATION FILE - & SEE IF THAT WORKS!]==============
% receivedFlag: 1=file is a received message, <1=sent message (0=sent, -1=sent was transcribed from paper.  
%    Controls the names of the recipients which is per the instructions for an ICS213 form.
% PathConfig: path to the control files (inTray_copies.txt, outTray_copies.txt, & print_ICS_213.ini)
% printEnable: 
%    0: printer disabled
%    1: pre-printed form in printer & printer enabled. may be reset by the INI files - cannot be set by the INI file.
%       i.e.: to print this passed in variable must be set AND if the INI file is found and has a value for print 
%       enable, it must to set.  No printing will occur if the file doesn't exist, doesn't contain printEnable, 
%       or if its value for printEnable is cleared.
%    2: blank paper in printer, printer enable, & "h_field" must be passed in from "showForm" -> data will
%       be loaded into figure's form, printer activated for <# of copies> (loaded from 'print_ICS_213.ini'), and the 
%       form will be closed.
%    3: blank paper in printer, printer disabled, & "h_field" must be passed in from "showForm" -> data will
%       be loaded into figure's form.  No printing and form will be left open
% printer. : structure including 
%            .qualLetter: applies only to pre-printed forms, no effect on blank paper printing
%            .printEnable:
%            .printerPort:
%            .HPL3: global value applies only to pre-printed forms, no effect on blank paper printing
%                over-ridden by the value from "print_ICS_213.ini"
% h_field[optional]: handles to the field display objects returned from "showForm"  When present and
%        containing more than one entry, the fields will be loaded from the PACF message.  Based on status
%        of printEnable, the form will either be dumped to the printer and closed or displayed without 
%        printing.
%
%OUTPUT:
% err: 0 when no errors detected; non-zero otherwise.
% errMsg: empty string when no error; error message and calling "stack" modName>modName: error message
% printed.Name: name of the file created by this module - this is a subset of the "printedNamePath" variable.
% printed.NamePath: path & name of the file created by this module.
% printed.Date: date & time the printed was performed.
%
%SUPPORT MODULES & FILES - all files expected in 'PathConfig'
% loadICS213FormPositions: loads the physical locations of the fields for the pre-printed
%   ICS213 form and the alignment/calibration information of the printed to the form using:
%      printerAlign_ICS213.txt: (user file) printer alignment information for left, right, top, & bottom in terms
%                  of rows & columns.  The numbers do not need to be integers.  These are determined by a user
%                  after printing rows & column of text on top of a pre-printed form.  The user then
%                  determines the four intersection points and entering them into this file.  Additionally
%                  contains the port of the printer.
%      ICS213.mat: (not a user file) field locations.  The names and digitized high resolution locations of
%                  all the fields on a ICS-213 form.  File is creaded by "digitizePoints".  This high resolution 
%                  information is not limited to the printer's row & column resolution.
%      ICS213_crossRef.csv: (not a user file) cross-references the field names used when the form was digitized to the
%                  PACForm field names.  By the nature of the 213 form, a PACForm field may cover more than one digitized
%                  field: for example, the Message can occupy up to 6 lines; the Situation Severity can have one of 3
%                  boxes checked.  This file additionally contains the justification desired for each field - horizontal
%                  and vertical.
% inTray_copies.txt [optional]: names of the recipients of copies of incoming messages.  Default: 'ADDRESSEE','PLANNING','RADIO'
% outTray_copies.txt [optional]: names of the recipients of copies of incoming messages.  Default: 'RADIO','PLANNING','ORIGINATOR'
%
%ACTIONS PERFORMED
% This program reads the indicated message file, decodes the file to determine the contents of
% each field, "maps" the contents of each field onto a standard pre-printed ICS213 form, creates a file
% with all the mapped fields, and copies this file to the printer.  The default condition is to
% perform three (3) printings each with a different recipient indicated in the footer.  Each footer includes
% the date & time of the printing.  The same file name is used for all copies and the final file
% contains no footer - it isn't printed but is created for archival purposes.
%
% Before this routine is called, the message file needs to be in the comment
% section where each line begins with a "#".  This routine will continue to read
% past the comment section/heading

%This module will skip ahead & start processing the message with the line after
% # Answers are enclosed in brackets

[err, errMsg, modName, form, printed, printer ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint, addressee, originator]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printer, 'ICS213', fname, fid, outpostHdg);

while 1 % read & detect the field for each line of the entire message
  % clear the print line so the line will not be altered unless the field
  %   has an entry. 
  printLine = 0;
  if (1 == findstrchr(textLine, '#EOF'))
    break
  end
  textLine = readPACFLine(textLine, fid);
  if feof(fid)
    err = 1 ;
    errMsg = sprintf('%s: incomplete message: End-of-message but no "#EOF"', modName);
    break
  end
  [fieldText, fieldID] = extractPACFormField(textLine) ;
  % Decode the information for the Packet Log:
  %ID/names as contained within the Outpost form of the message
  fT = strtrim(fieldText);
  switch fieldID
  case '2.'
    form.senderMsgNum = fT ;
    fieldsFound = fieldsFound + 1;
  case 'MsgNo'
    form.MsgNum = fT ;
    fieldsFound = fieldsFound + 1;
  case '3.'
    form.receiverMsgNum = fT ;
    fieldsFound = fieldsFound + 1;
  case '1a.'
    form.date = fT ;
    fieldsFound = fieldsFound + 1;
  case '1b.'
    form.time = fT ;
    fieldsFound = fieldsFound + 1;
  case '4.'
    form.comment = sprintf('%s %s', form.comment, fT);
    form.sitSevere = fT ;
    fieldsFound = fieldsFound + 2;
  case '5.'
    form.comment = sprintf('%s %s', form.comment, fT);
    form.handleOrder = fT ;
    fieldsFound = fieldsFound + 2;
  case '7.'
    %only used if printing is enabled so 'fieldsFound' isn't incremented
    addressee = fT;
  case '8.'
    %only used if printing is enabled so 'fieldsFound' isn't incremented
    originator = fT;
  case '10.' 
    form.subject = fT ;
    fieldsFound = fieldsFound + 1;
  case '6b.'
    form.replyReq = fT; 
    fieldsFound = fieldsFound + 1;
  case '6d.' % when
    form.replyWhen = fT ;
    fieldsFound = fieldsFound + 1;
  otherwise
  end
  if printer.printEnable
    %#IFDEF debugOnly
    if strcmp(fieldID,'12.')
      fprintf('IDE (debug): Message Field found in %s', mfilename);
    end
    %#ENDIF
    [err, errMsg, textToPrint, h_field, formField, moveNeeded] = fillFormField(fieldID, fieldText, formField, h_field, textToPrint, spaces, outpostNmNValues);
  else %if printer.printEnable
    %not printing - exit when we've extracted all we need
    if fieldsFound > 11
      break
    end
  end % if printer.printEnable else
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message

fcloseIfOpen(fid);

if (~err & printer.printEnable)
  [err, errMsg, printed] = ...
    formFooterPrint(printer, h_field, formField, fname, originator, addressee, textToPrint, outpostHdg, receivedFlag);
end % if (~err & printer.printEnable)

