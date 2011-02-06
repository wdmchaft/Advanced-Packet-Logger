function [err, errMsg, textLine, fidLogIn, commasAt, ...
    chanNumComma, FreqComma, ModeComma, ShiftComma, OffsetComma, TXFreqComma, EncDecComma, ...
    ToneComma, CodeComma, ShowComma, NameComma, PowerComma, ScanComma, ClkComma, StepComma,...
    Scan2Comma, Scan3Comma, Scan4Comma, Scan5Comma, Scan6Comma, DescriptionComma, ...
    Bank1Comma, Bank2Comma, Bank3Comma, Bank4Comma, Bank5Comma, Bank6Comma, ...
    Bank7Comma, Bank8Comma, Bank9Comma, Bank10Comma] = ...
  readFT60Header(sourcePathName);
%#	 Freq	 Mode	 Shift	 Offset	 TX Freq	 Enc/Dec	 Tone	 Code	 Show	 Name	 Power	 Scan	 Clk	 Step	 
%Scan2	 Scan3	 Scan4	 Scan5	 Scan6	 Description	 Bank1	 Bank2	 Bank3	 Bank4	 Bank5	 Bank6	 Bank7	 Bank8	 Bank9	 Bank10	 
%Bank11	 Bank12	 Bank13	 Bank14	 Bank15	 Bank16	 Bank17	 Bank18	 Bank19	 Bank20	 Bank21	 Bank22	 Bank23	 Bank24	 PRFRQ	 SMSQL	 RXATT	 BELL	 Masked

%Channel Number	Receive Frequency	Transmit Frequency	Offset Frequency	Offset Direction	Operating Mode	Name	
%Show Name	Tone Mode	CTCSS	DCS	Tx Power	Skip	Step	Clock Shift	
%Bank 1	Bank 2	Bank 3	Bank 4	Bank 5	Bank 6	Bank 7	Bank 8	Bank 9	Bank 10	Comment	Tx Narrow	Pager Enable

[err, errMsg, modName] = initErrModName(mfilename);

chanNumComma = -1 ;
FreqComma = -1 ;
ModeComma = -1 ;
ShiftComma = -1 ;
OffsetComma = -1 ;
TXFreqComma = -1 ;
EncDecComma = -1 ;
ToneComma = -1 ;
CodeComma = -1 ;
ShowComma = -1 ;
NameComma = -1 ;
PowerComma = -1 ;
ScanComma = -1 ;
ClkComma = -1 ;
StepComma = -1 ;
Scan2Comma = -1 ;
Scan3Comma = -1 ;
Scan4Comma = -1 ;
Scan5Comma = -1 ;
Scan6Comma = -1 ;
DescriptionComma = -1 ;
Bank1Comma = -1 ;
Bank2Comma = -1 ;
Bank3Comma = -1 ;
Bank4Comma = -1 ;
Bank5Comma = -1 ;
Bank6Comma = -1 ;
Bank7Comma = -1 ;
Bank8Comma = -1 ;
Bank9Comma = -1 ;
Bank10Comma = -1 ;

fidLogIn = fopen (sourcePathName, 'r');
if (fidLogIn < 0)
  errMsg = sprintf('%s: unable to find the source file [%s]', modName, sourcePathName);
  err = 1;
  if nargin < 2
    try
      %#IFDEF debugOnly  
      close (hCancel);
      %#ENDIF
    catch
    end
  end
  return
end

[textLine, commasAt, quotesAt, spacesAt] = fgetl_valid(fidLogIn);
% % [commasAt, quotesAt, spacesAt] = findValidCommas(textLine);


[err, errMsg, chanNumComma] = findColumnOfData(textLine, 'Channel Number', commasAt, quotesAt, spacesAt);
[err, errMsg, FreqComma] = findColumnOfData(textLine, 'Receive Frequency', commasAt, quotesAt, spacesAt);
[err, errMsg, ModeComma] = findColumnOfData(textLine, 'Operating Mode', commasAt, quotesAt, spacesAt);
[err, errMsg, ShiftComma] = findColumnOfData(textLine, 'Offset Direction', commasAt, quotesAt, spacesAt); 
[err, errMsg, OffsetComma] = findColumnOfData(textLine, 'Offset Frequency', commasAt, quotesAt, spacesAt); 
[err, errMsg, TXFreqComma] = findColumnOfData(textLine, 'Transmit Frequency', commasAt, quotesAt, spacesAt); 
[err, errMsg, EncDecComma] = findColumnOfData(textLine, 'Tone Mode', commasAt, quotesAt, spacesAt); 
%		Tx Narrow	Pager Enable

[err, errMsg, ToneComma] = findColumnOfData(textLine, 'CTCSS', commasAt, quotesAt, spacesAt);
[err, errMsg, CodeComma] = findColumnOfData(textLine, 'DCS', commasAt, quotesAt, spacesAt);
[err, errMsg, ShowComma] = findColumnOfData(textLine, 'Show Name', commasAt, quotesAt, spacesAt);
[err, errMsg, NameComma] = findColumnOfData(textLine, 'Name', commasAt, quotesAt, spacesAt);
[err, errMsg, PowerComma] = findColumnOfData(textLine, 'Tx Power', commasAt, quotesAt, spacesAt);
[err, errMsg, ScanComma] = findColumnOfData(textLine, 'Skip', commasAt, quotesAt, spacesAt); 
[err, errMsg, ClkComma] = findColumnOfData(textLine, 'Clock Shift', commasAt, quotesAt, spacesAt); 
[err, errMsg, StepComma] = findColumnOfData(textLine, 'Step', commasAt, quotesAt, spacesAt); 
% % [err, errMsg, Scan2Comma] = findColumnOfData(textLine, '', commasAt, quotesAt, spacesAt);
% % [err, errMsg, Scan3Comma] = findColumnOfData(textLine, '', commasAt, quotesAt, spacesAt);
% % [err, errMsg, Scan4Comma] = findColumnOfData(textLine, '', commasAt, quotesAt, spacesAt);
% % [err, errMsg, Scan5Comma] = findColumnOfData(textLine, '', commasAt, quotesAt, spacesAt);
% % [err, errMsg, Scan6Comma] = findColumnOfData(textLine, '', commasAt, quotesAt, spacesAt);
[err, errMsg, DescriptionComma] = findColumnOfData(textLine, 'Comment', commasAt, quotesAt, spacesAt);
[err, errMsg, Bank1Comma] = findColumnOfData(textLine, 'Bank 1', commasAt, quotesAt, spacesAt); 
[err, errMsg, Bank2Comma] = findColumnOfData(textLine, 'Bank 2', commasAt, quotesAt, spacesAt); 
[err, errMsg, Bank3Comma] = findColumnOfData(textLine, 'Bank 3', commasAt, quotesAt, spacesAt); 
[err, errMsg, Bank4Comma] = findColumnOfData(textLine, 'Bank 4', commasAt, quotesAt, spacesAt); 
[err, errMsg, Bank5Comma] = findColumnOfData(textLine, 'Bank 5', commasAt, quotesAt, spacesAt); 
[err, errMsg, Bank6Comma] = findColumnOfData(textLine, 'Bank 6', commasAt, quotesAt, spacesAt); 
[err, errMsg, Bank7Comma] = findColumnOfData(textLine, 'Bank 7', commasAt, quotesAt, spacesAt); 
[err, errMsg, Bank8Comma] = findColumnOfData(textLine, 'Bank 8', commasAt, quotesAt, spacesAt); 
[err, errMsg, Bank9Comma] = findColumnOfData(textLine, 'Bank 9', commasAt, quotesAt, spacesAt); 
[err, errMsg, Bank10Comma] = findColumnOfData(textLine, 'Bank 10', commasAt, quotesAt, spacesAt);