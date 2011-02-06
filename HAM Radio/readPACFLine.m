function textLine = readPACFLine(textLine, fid);

%Prerequisite: a line is in "textLine"
%End-of-File:  (handled before this module is called)
% '#EOF'

%Comments - want to skip iff not within a Field
% blank lines
%  8 Hr.    Check if Staffed     24 Hrs  BED AVAILABILITY
% At this point, we've merely read a line and are not
%withint a Field.  Therefore we only need to test if this
%is not a Field.  

%Simple:
% 16a-I: [incident summary]

%Multiple:
% 33.   [Critical Care Beds (Adult)] Checked      NOT Checked [Critical Care Beds (Adult)]

%Different format (present in HOSPITAL-BEDS AVAILABILITY STATUS REPORT FORM DOC-9)
%     note there is no colon!
% 33.   [Critical Care Beds (Adult)] Checked      NOT Checked [Critical Care Beds (Adult)]

%Multiple line field(s)
% 16a-I: [incident 
% summary]

%need to find the start of the data: [ preceded by . or - or nothing...(so why test - might
%  be better to merely look for ": [")

%go past blank lines:
while (~length(textLine) & ~feof(fid))
  textLine = fgetl(fid);
end

%go past non-Field lines
while 1 & ~feof(fid)
  if findstrchr(': [', textLine)
    break
  end
  % %   leftBraceAt = findstrchr('[', textLine);
  % %   colonAt = findstrchr(':', textLine);
  % %   precedeAt = find(ismember(textLine(1:leftBraceAt(1)),'.-'));
  % %   if ~length(precedeAt)
  % %     precedeAt = 0;
  % %   end
  % %   if leftBraceAt & (colonAt | precedeAt)
  % %     if (colonAt(1) < leftBraceAt(1)) & (precedeAt(1) < leftBraceAt(1))
  % %       break
  % %     end
  % %   end % if leftBraceAt & colonAt
  textLine = fgetl(fid);
end % while 1

% keep reading and concatenating until a  line ends with ']' 
while ((findstrchr(']', textLine) ~= length(textLine)) & ~feof(fid))
  a = fgetl(fid);
  textLine = sprintf('%s\n%s',textLine, a);
end
