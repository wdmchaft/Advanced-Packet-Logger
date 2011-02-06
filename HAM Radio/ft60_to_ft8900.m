function [err, errMsg] = ft60_to_ft8900(sourceFilePathName, targetFilePathName);

% Want a pretty sheet suitable for printing all info on one page.
% See  H:\ARES_RACES\ft8900_thirdVersion.xls

[err, errMsg, modName] = initErrModName(mfilename);

freqRange = [28,29.7,  50,54,  108,180,  320,480,  700,985] ;

% this is where we are repeating memory frequencies for the FT-60
maxMemory = 400;
maxNameLength = 6;

digits = char(48+[0:9]);

if nargin < 1
  a = {'H:\ARES_RACES\ft60_initalSetup.csv',...
      'C:\Documents and Settings\andy\My Documents\WM_andy My Documents\HAM Radio\ft60_thirdVersion.csv'};
  b = {'H:\ARES_RACES\ft8900_initalSetup.csv', ...
      'C:\Documents and Settings\andy\My Documents\WM_andy My Documents\HAM Radio\ft8900_thirdVersion.csv'};
  fid = 0 ;
  itemp = 0 ;
  while ((fid < 1) & (itemp < length(a)))
    itemp = itemp + 1;
    sourceFilePathName = char(a(itemp)) ;
    fid = fopen(sourceFilePathName,'r');
  end
  if ~fid
    fprintf('\r\nUnable to find source file.')
    return
  end
  targetFilePathName = char(b(itemp)) ;;
end

fidOut = fopen(targetFilePathName, 'w');
if fidOut < 1
  fprintf('\r\nUnable to open "%s" - make sure it isn''t open in Excel', targetFilePathName);
  return;
end
fcloseIfOpen(fidOut);

%#	 Freq	 Mode	 Shift	 Offset	 TX Freq	 Enc/Dec	 Tone	 Code	 Show	 Name	 Power	 Scan	 Clk	 Step	 
%Scan2	 Scan3	 Scan4	 Scan5	 Scan6	 Description	 Bank1	 Bank2	 Bank3	 Bank4	 Bank5	 Bank6	 Bank7	 Bank8	 Bank9	 Bank10	 
%Bank11	 Bank12	 Bank13	 Bank14	 Bank15	 Bank16	 Bank17	 Bank18	 Bank19	 Bank20	 Bank21	 Bank22	 Bank23	 Bank24	 PRFRQ	 SMSQL	 RXATT	 BELL	 Masked

[err, errMsg, textLine, fidIn, commasAt, ...
    chanNumComma, FreqComma, ModeComma, ShiftComma, OffsetComma, TXFreqComma, EncDecComma, ...
    ToneComma, CodeComma, ShowComma, NameComma, PowerComma, ScanComma, ClkComma, StepComma,...
    Scan2Comma, Scan3Comma, Scan4Comma, Scan5Comma, Scan6Comma, DescriptionComma, ...
    Bank1Comma, Bank2Comma, Bank3Comma, Bank4Comma, Bank5Comma, Bank6Comma, ...
    Bank7Comma, Bank8Comma, Bank9Comma, Bank10Comma] = ...
  readFT60Header(sourceFilePathName);

if err
  return
end

headerLineOut = '#,Freq,Mode,Shift,Offset,TX Freq,Enc/Dec,Tone,Code,Show,Name,Power,Scan,Clk,Step,';	 
headerLineOut = sprintf('%sBank1,Bank2,Bank3,Bank4,Bank5,Bank6,Bank7,Bank8,Bank9,Bank10', headerLineOut);	 
% headerLineOut = sprintf('%sScan2,Scan3,Scan4,Scan5,Scan6,Description,Bank1,Bank2,Bank3,Bank4,Bank5,Bank6,Bank7,Bank8,Bank9,Bank10', headerLineOut);	 
% Bank11	 Bank12	 Bank13	 Bank14	 Bank15	 Bank16	 Bank17	 Bank18	 Bank19	 Bank20	 Bank21	 Bank22	 Bank23	 Bank24	 PRFRQ	 SMSQL	 RXATT	 BELL	 Masked
fidOut = fopen(targetFilePathName, 'w');
fprintf(fidOut,'%s\r\n', headerLineOut);
fcloseIfOpen(fidOut);
fprintf('%s\r\n', headerLineOut);
while ~feof(fidIn)
  [textLine, commasAt, quotesAt, spacesAt] = fgetl_valid(fidIn);
  if ~length(textLine)
    break
  end
  %[err, errMsg, text] = extractTextFromCSVText(textLine, commasAt, chanNumComma);
  [err, errMsg, chanNum] = extractFromCSVText(textLine, commasAt, chanNumComma);
  if maxMemory < chanNum
    fprintf('\r\nMaximum specified memory %i reached.', chanNum);
    break;
  end
  
  if chanNum == 85
    fprintf('llll');
  end
  
  %frequency
  [err, errMsg, freq] = extractFromCSVText(textLine, commasAt, FreqComma);
  validFreq = 0;
  % impossible frequency?
  if (freq < freqRange(1)) | (freq > freqRange(length(freqRange)) )
  else %if (freq < freqRange(1)) | (freq > freqRange(length(freqRange)) )
    for itemp = 1:2:(length(freqRange)-1)
      if (freq >= freqRange(itemp)) & (freq <= freqRange(itemp+1))
        validFreq = 1;
        break
      end %if (freq >= freqRange(itemp)) & (freq <= freqRange(itemp+1))
    end % for itemp = 1:(length(freqRange)-1)
  end % if (freq < freqRange(1)) | (freq > freqRange(length(freqRange)) )
  
  if ~validFreq
    fprintf('\r\nInvalid frequency for memory %i of %f MHz.  This will not be sent and the memory will not be used.', chanNum, freq);
  else %if ~validFreq
    %frequency is valid, continue
    
    % memory location:
    textLineOut = sprintf('%i', chanNum);
    textLineOut = sprintf('%s,%.3f', textLineOut, freq);
    %headerLineOut = '#,Freq,Mode,Shift,Offset,TX Freq,Enc/Dec,Tone,Code,Show,Name,Power,Scan,Clk,Step,';	 
    
    %modulation mode
    [err, errMsg, mode] = extractTextFromCSVText(textLine, commasAt, ModeComma);
    if ~strcmp(mode,'FM')
      % %       if find(ismember(mode, digits))
      % %       fprintf('\r\nMemory %i was using modulation "%s".  Changed to "FM".', chanNum, mode);
      mode = 'FM';
    end
    textLineOut = sprintf('%s,%s', textLineOut, mode);
    
    [err, errMsg, shiftRepeater] = getShiftRepeater(textLine, commasAt, ShiftComma);
    textLineOut = sprintf('%s,%s', textLineOut, shiftRepeater);

    [err, errMsg, offsetRepeater] = getoffsetRepeater(textLine, commasAt, OffsetComma);
    textLineOut = sprintf('%s,%s', textLineOut, offsetRepeater);

    [err, errMsg, TXFreq] = extractFromCSVText(textLine, commasAt, TXFreqComma);
    if ~TXFreq 
      textLineOut = sprintf('%s,', textLineOut);
    else
      textLineOut = sprintf('%s,%.3f', textLineOut, TXFreq);
    end
    
    [err, errMsg, EncDecMode] = getEncDecMode(textLine, commasAt, EncDecComma);
    textLineOut = sprintf('%s,%s', textLineOut, EncDecMode);
        
    % determine the CTCSS frequency
    [err, errMsg, tone] = getCTCSSTone(textLine, commasAt, ToneComma);
    textLineOut = sprintf('%s,%s', textLineOut, tone);
    
    %DCS code
    [err, errMsg, dcsCode] = extractFromCSVText(textLine, commasAt, CodeComma);
    if ~dcsCode 
      textLineOut = sprintf('%s,', textLineOut);
    else
      textLineOut = sprintf('%s,%i', textLineOut, dcsCode);
    end

    [err, errMsg, showName] = getShowName(textLine, commasAt, ShowComma);
    textLineOut = sprintf('%s,%s', textLineOut, showName);
        
    [err, errMsg, name] = extractTextFromCSVText(textLine, commasAt, NameComma);
    if length(name) > maxNameLength
      fprintf('\r\n***** warning ***** Name length exceeds maximum allowed: truncated from "%s"',name);
      name = name(1:6);
      fprintf(' to "%s".', name);
    end
    textLineOut = sprintf('%s,%s', textLineOut, name);
    
    [err, errMsg, power] = getPower(textLine, commasAt, PowerComma);
    textLineOut = sprintf('%s,%s', textLineOut, power);

    [err, errMsg, skipScan] = getScan(textLine, commasAt, ScanComma);
    textLineOut = sprintf('%s,%s', textLineOut, skipScan);

    [err, errMsg, clockShift] = getClockShift(textLine, commasAt, ClkComma);
    textLineOut = sprintf('%s,%s', textLineOut, clockShift);
    
    [err, errMsg, inBank_1] = getBank(textLine, commasAt, Bank1Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_1);
    [err, errMsg, inBank_2] = getBank(textLine, commasAt, Bank2Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_2);
    [err, errMsg, inBank_3] = getBank(textLine, commasAt, Bank3Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_3);
    [err, errMsg, inBank_4] = getBank(textLine, commasAt, Bank4Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_4);
    [err, errMsg, inBank_5] = getBank(textLine, commasAt, Bank5Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_5);
    [err, errMsg, inBank_6] = getBank(textLine, commasAt, Bank6Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_6);
    [err, errMsg, inBank_7] = getBank(textLine, commasAt, Bank7Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_7);
    [err, errMsg, inBank_8] = getBank(textLine, commasAt, Bank8Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_8);
    [err, errMsg, inBank_9] = getBank(textLine, commasAt, Bank9Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_9);
    [err, errMsg, inBank_10] = getBank(textLine, commasAt, Bank10Comma);
    textLineOut = sprintf('%s,%s', textLineOut, inBank_10);
    
    fidOut = fopen(targetFilePathName, 'a');
    fprintf(fidOut,'%s\r\n', textLineOut);
    fcloseIfOpen(fidOut);
    fprintf('\r\n%s', textLineOut);
    
  end % if ~validFreq else

end % while ~feof(fidIn)
fcloseIfOpen(fidIn);
if nargout < 1
  if ~err
    clear err errMsg
  end
end
