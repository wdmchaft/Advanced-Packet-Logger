function [err, errMsg, offsetRepeater] = getoffsetRepeater(textLine, commasAt, OffsetComma);

% repeater shift
[err, errMsg, offsetRepeater] = extractTextFromCSVText(textLine, commasAt, OffsetComma);
% need to remove "0"
if strcmp(offsetRepeater, '0')
  offsetRepeater = '';
else % if strcmp(offsetRepeater, '0')
  % need to convert kHz to MHz and remove the text
  a = findstrchr('khz', lower(offsetRepeater));
  if a % kHz
    % convert from kHz to MHz & remove "kHz"
    offsetRepeater = num2str(str2num(offsetRepeater(1:a-1))/1e3);
  else % if a % kHz
    a = findstrchr('mhz', lower(offsetRepeater));
    if a % MHz
      % remove "MHz"
      offsetRepeater = offsetRepeater(1:a-1);
    end %if a % MHz
  end % if a % kHz else
end % if strcmp(offsetRepeater, '0') else
offsetRepeater = strrep(offsetRepeater, ' ', '');
