function combinedText = leftJustifyText(newText, textSoFar, startCol, spaces); 
% if the existing text is shorted than the startCol, 
%   adds the necessary number of leading spaces & then 'newText'
% if the existing text goes beyond the startCol,
%   inserts 'newText' into the existing text overwriting any existing text in these positions
%   but preserving all existing text before and after newText's location.
existingText = char(textSoFar) ;
%if no new text, don't do anything
if ~length(newText)
  combinedText = existingText;
  return
end
% is this an insert?
if startCol <= length(existingText)
  %we're going to be brutual: overwrite anything in this area in the text
  % is there existing text after the new text?
  if length(existingText) > (startCol + length(newText))
    combinedText = sprintf('%s%s%s', existingText(1:startCol-1), newText, existingText(startCol+length(newText)) );
  else
    %no: we're trimming the exist & adding more than was there
    combinedText = sprintf('%s%s', existingText(1:startCol-1), newText);
  end
else
  %not an insert but an append: we'll add enough spaces and then the text of interest
  a = startCol - length(existingText);
  if a
    combinedText = sprintf('%s%s%s', existingText, spaces(1:a), newText);
  else
    combinedText = sprintf('%s%s', existingText, newText);
  end
end
