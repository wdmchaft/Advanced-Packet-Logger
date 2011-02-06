%doIt
logNPath = '\\AROSE_H\f\Program Files\Outpost\logs\packetCommLog_100417.csv';

if 1
  
fid = fopen(logNPath,'r');
textLine = '';
linesRead = 0;
%find the column heading line & determine the column containing the file name
while ~feof(fid) & ~findstrchr('FileName', textLine)
  [textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fid) ;
  linesRead = linesRead + 1 ;
  a = findstrchr('FileName', textLine) ;
  if a
    b = find(commasAt < a(1));
    fpathNameComma = b(length(b));
  end
end
a = findstrchr('FROM', textLine);
if a
  b = find(commasAt < a(1));
  fromComma = b(length(b));
end
a = findstrchr('MSG NO', textLine);
if a
  b = find(commasAt < a(1));
  msgNoComma = b(length(b));
end
a = findstrchr('TIME', textLine);
if a
  b = find(commasAt < a(2));
  formTimeComma = b(length(b));
end

if feof(fid)
  fprintf('\r\n File format not correct - couldn''t find column heading line.');
  return
end
[textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fid) ;
linesRead = linesRead + 1 ;
dupLine = 0;
while ~feof(fid)
  [textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fid) ;
  linesRead = linesRead + 1 ;
  if length(find(dupLine == linesRead))
    fprintf('\n Line %i already known to be duplicate of %i.', linesRead, dupOf(find(dupLine == linesRead)));
  else % if length(find(dupLine == linesRead))
    position = ftell(fid);
    [err, errMsg, fpathName] = extractStripQuotes(textLine, commasAt, fpathNameComma) ;
    %if this line specifies a fpathName, look at all remaining lines for any duplicates
    if length(fpathName)
      thisLine = linesRead;
      From = '';
      while ~feof(fid)
        [this_textLine, this_commasAt, this_textFieldQuotesAt, this_spacesAt] = fgetl_valid(fid) ;
        thisLine = thisLine + 1;
        [err, errMsg, thisFpathName] = extractStripQuotes(this_textLine, this_commasAt, fpathNameComma) ;
        if length(thisFpathName)
          if strcmp(thisFpathName, fpathName)
            if ~length(From)
              fprintf('\n duplicate on %i of "%s"', thisLine, fpathName);
              [err, errMsg, From] = extractStripQuotes(textLine, commasAt, fromComma) ;
              [err, errMsg, MsgNo] = extractStripQuotes(textLine, commasAt, msgNoComma) ;
              [err, errMsg, FormTime] = extractStripQuotes(textLine, commasAt, formTimeComma);
              fprintf('\n   first: from %s msg no %s, form time %s', From, MsgNo, FormTime);
            else
              fprintf('\n  another duplicate on %i"', thisLine);
            end
            [err, errMsg, thisFrom] = extractStripQuotes(this_textLine, this_commasAt, fromComma) ;
            [err, errMsg, thisMsgNo] = extractStripQuotes(this_textLine, this_commasAt, msgNoComma) ;
            [err, errMsg, thisFormTime] = extractStripQuotes(this_textLine, this_commasAt, formTimeComma) ;
            fprintf('\n   dup:   from %s msg no %s, form time %s', thisFrom, thisMsgNo, thisFormTime);
            dupLine(length(dupLine)+1)= thisLine;
            dupOf(length(dupLine)) = linesRead;
          end
        end %if length(thisFpathName)
      end % while ~feof(fid)
      fseek(fid, position, 'bof');
    end %if length(fpathName)
  end %if length(find(dupLine == linesRead)) else
end
fcloseIfOpen(fid);
end
fprintf('\n Total duplicates: %i', length(dupLine)-1 );
[dupOf,Ndx] = sort(dupOf);
dupLine = dupLine(Ndx);
Ndx = 2;
while Ndx < length(dupLine)
  a = find(dupOf == dupOf(Ndx));
  fprintf('\n  Line %i duplicated %i times on line(s)', dupOf(Ndx), length(a));
  for jtemp = 1:length(a)
    fprintf(' %i', dupLine(a(jtemp)) );
  end
  Ndx = a(length(a)) + 1;
end

%make a copy without the duplicate lines

[pathstr,name,ext,versn] = fileparts(logNPath);
out_logNPath = sprintf('%s%s_noDups%s', endWithBackSlash(pathstr),name,ext);

fid = fopen(logNPath,'r');
textLine = '';
linesRead = 0;
linesWritten = 0;
fidOut = fopen(out_logNPath, 'w');
while ~feof(fid)
  textLine = fgetl(fid) ;
  linesRead = linesRead + 1 ;
  if ~length(find(linesRead == dupLine))
    fprintf(fidOut,'%s\r\n', textLine);
    linesWritten = linesWritten + 1;
  end
end
fcloseIfOpen(fid);
fcloseIfOpen(fidOut);
fprintf('\n Done! Lines read: %i, lines written: %i, difference %i', linesRead, linesWritten, linesRead - linesWritten);
