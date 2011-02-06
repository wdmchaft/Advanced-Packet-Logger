function [textToPrint] = formatMessageBox(message, textToPrint, formField, spaces);
% wraps message to fit within the columns by breaking message at a whitespace,
%  whitespace defined as a space, comma, semi-colon, period, CR, or LF
%calls leftJustifyText so any previous contents on this line will survive
%  as long as they are not in locations where the new text is located.

thisLine = 1;
whiteSpace = [' ', ',', char(10), char(12), ';','.'] ;
remainingMsg = message ;

%the message may span several lines.  This loop formats the message
% to a number of line with each line's contents ending at a whiteSpace
while (length(remainingMsg)) & (thisLine <= length(formField))
  % % while (length(remainingMsg) > lineLength) & (thisLine <= length(formField))
  lineLength = floor(formField(thisLine).lftTopRhtBtm(3) - formField(thisLine).lftTopRhtBtm(1) + 1) ;
  %if the remaining message is longer than the line. . .
  if (length(remainingMsg) > lineLength)
    %locate whiteSpaces for this line
    a = find(ismember(remainingMsg(1:lineLength), whiteSpace));
    % if white spaces are found
    if length(a)
      % find the location of the last white space that will fit on this line
      b = a(length(a));
    else
      % no white spaces before line ends: force a break
      b = lineLength;
    end
  else %if (length(remainingMsg) > lineLength)
    % formatted line is longer than the remaining message
    b = length(remainingMsg);
  end % if (length(remainingMsg) > lineLength) else
  [row, col] = justify(formField(thisLine), remainingMsg(1:b));
  textToPrint(row) = {leftJustifyText(remainingMsg(1:b), textToPrint(row), col, spaces)};
  % trim "remainingMsg" by removing what we just formatted
  if (b < length(remainingMsg))
    remainingMsg = remainingMsg(b+1:length(remainingMsg));
  else
    % this will break us out of the loop
    remainingMsg = '';
  end
  thisLine = thisLine + 1 ;
end % while length(remainingMsg) > lineLength

