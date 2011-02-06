function count213Overhead

pathTo = 'C:\Outpost Oct 2010 drills\XSC\archive\InTray';

pathTo = endWithBackSlash(pathTo);

msgList = dir(strcat(pathTo,'*.mss'));

total_bytesNeeded = 0;
total_bytesExtra = 0;
msgFilesFound = 0;
for msgListNdx = 1:length(msgList)
  thisMsg = msgList(msgListNdx).name;
  if findstrchr('ICS213', thisMsg) & ~findstrchr('DELIVERED', thisMsg)
    msgFilesFound = msgFilesFound + 1;
    fid = fopen(strcat(pathTo, thisMsg),'r');
    extraLineText = {};
    neededLineTxt = {};
    textLine = '';
    %get past the Outpost heading overhead
    while (~feof(fid) & ~findstrchr('!PACF!', textLine))
      textLine = fgetl(fid);
    end
    %count the needed heading information
    bytesNeeded(msgFilesFound) = length(textLine) + 1;
    neededLineTxt(length(neededLineTxt)+1) = {textLine};
    while (~feof(fid) & ~findstrchr('FORMFILENAME: ', textLine))
      textLine = fgetl(fid);
      bytesNeeded(msgFilesFound) = length(textLine) + 1 + bytesNeeded(msgFilesFound);
      neededLineTxt(length(neededLineTxt)+1) = {textLine};
    end
    %count the extra heading overhead - the "help" information
    bytesExtra(msgFilesFound) = length(textLine) + 1;
    extraLineText(length(extraLineText)+1) = {textLine};
    while (~feof(fid) & (1 == findstrchr('#', textLine)))
      textLine = fgetl(fid);
      bytesExtra(msgFilesFound) = length(textLine) + 1 + bytesExtra(msgFilesFound);
      extraLineText(length(extraLineText)+1) = {textLine};
    end
    % count the lines with blank fields as extra & non-blank as needed
    fieldsUsed(msgFilesFound) = 0;
    fieldsUnUsed(msgFilesFound) = 0;
    while (~feof(fid) & (~findstrchr('#EOF', textLine)))
      textLine = readPACFLine(textLine, fid);
      if findstrchr('[]', textLine)
        bytesExtra(msgFilesFound) = length(textLine) + 1 + bytesExtra(msgFilesFound);
        extraLineText(length(extraLineText)+1) = {textLine};
        fieldsUnUsed(msgFilesFound) =  fieldsUnUsed(msgFilesFound) + 1;
      else
        bytesNeeded(msgFilesFound) = length(textLine) + 1 + bytesNeeded(msgFilesFound);
        neededLineTxt(length(neededLineTxt)+1) = {textLine};
        fieldsUsed(msgFilesFound) = fieldsUsed(msgFilesFound) + 1;
      end
      textLine = fgetl(fid);
    end
    bytesExtra(msgFilesFound) = length(textLine) + 1 + bytesExtra(msgFilesFound);
    extraLineText(length(extraLineText)+1) = {textLine};
    fcloseIfOpen(fid);
    if msgFilesFound == 1
      fprintf('\nNeeded lines:');
      for itemp = 1:length(neededLineTxt)
        fprintf('\n%s', neededLineTxt{itemp});
      end  
      fprintf('\nExtra lines:');
      for itemp = 1:length(extraLineText)
        fprintf('\n%s', extraLineText{itemp});
      end  
    end
    fprintf('\nTotal files %i. %s:', msgFilesFound, thisMsg);
    fprintf('\n Total Bytes %s. Bytes required %s.  Bytes Extra %s. Reduction when extra removed %s%%', ...
      strNumAddCommas(bytesNeeded(msgFilesFound)+bytesExtra(msgFilesFound)),...
      strNumAddCommas(bytesNeeded(msgFilesFound)), ...
      strNumAddCommas(bytesExtra(msgFilesFound)), ...
      strNumAddCommas(round(bytesExtra(msgFilesFound)/(bytesNeeded(msgFilesFound)+bytesExtra(msgFilesFound))*100)));
    fprintf('\n   fields used %i.  fields ununsed %i', fieldsUsed(msgFilesFound), fieldsUnUsed(msgFilesFound));
    total_bytesNeeded = total_bytesNeeded + bytesNeeded(msgFilesFound);
    total_bytesExtra = total_bytesExtra + bytesExtra(msgFilesFound);
    percentImprov(msgFilesFound) = round(bytesExtra(msgFilesFound)/(bytesNeeded(msgFilesFound)+bytesExtra(msgFilesFound))*100);
  end %if findstrchr('ICS213', thisMsg)
end %for msgListNdx = 1:length(msgList)
[percentImprov, Ndx] = sort(percentImprov);
fieldsUsed = fieldsUsed(Ndx);
fieldsUnUsed = fieldsUnUsed(Ndx);
bytesNeeded = bytesNeeded(Ndx);
bytesExtra = bytesExtra(Ndx);

fprintf('\nTotal files %s.  Total Bytes: %s. Bytes required: %s.  Bytes Extra: %s. Reduction when extra removed %s%%', ...
  strNumAddCommas(msgFilesFound), strNumAddCommas(total_bytesNeeded+total_bytesExtra), ...
  strNumAddCommas(total_bytesNeeded),...
  strNumAddCommas(total_bytesExtra),...
  strNumAddCommas(round(total_bytesExtra/(total_bytesNeeded+total_bytesExtra)*100)));