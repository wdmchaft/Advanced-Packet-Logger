function [err, errMsg, EncDecMode] = getEncDecMode(textLine, commasAt, EncDecComma);
[err, errMsg, EncDecMode] = extractTextFromCSVText(textLine, commasAt, EncDecComma);

if strcmp('0', EncDecMode);
  EncDecMode = 'Off';
else
  % good:
  if findstrchr(lower(EncDecMode),'none');
    EncDecMode = 'Off';
  end
  % good
  if findstrchr(lower(EncDecMode),'tone');
    EncDecMode = 'ENC';
  end
  % no!
  if findstrchr(lower(EncDecMode),'t sql');
    fprintf('\r\nunable to convert EncDecMode "%s" for %s', EncDecMode, textLine);
    EncDecMode = 'Off';
  end
  % no!
  if findstrchr(lower(EncDecMode),'rev ctcss');
    fprintf('\r\nunable to convert EncDecMode "%s" for %s', EncDecMode, textLine);
    EncDecMode = 'Off';
  end
  %   if findstrchr(lower(EncDecMode),'dcs');
  %     EncDecMode = 'Off';
  %   end

  % no!
  if findstrchr(lower(EncDecMode),'d code');
    fprintf('\r\nunable to convert EncDecMode "%s" for %s', EncDecMode, textLine);
    EncDecMode = 'Off';
  end
end
%input
% none, tone, T sql, Rev CTCSS, DCS, D Code

% output:
% off
% enc
% enc/dec  CTCSS on moth transmit and receive
% dcs

% software but I don't think the radio 
% d
% end/dcs
% d-dec