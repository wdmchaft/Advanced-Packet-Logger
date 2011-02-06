function prep213


pathToDrill = 'F:\Drill\';

msgPrefix = {'Sr', 'FS4'};

for preNdx = 1:length(msgPrefix)
  prefix = char(msgPrefix(preNdx));
  
  drillFiles = dir(sprintf('%s%s*.*', pathToDrill, prefix));
  
  for itemp =1:length(drillFiles)
    thisFName = strcat(pathToDrill,drillFiles(itemp).name );
    fid = fopen(thisFName,'r');
    count = 0;
    subject = ''; 
    if fid > 0
      while ~feof(fid)
        textLine = fgetl(fid);
        if (findstrchr('4.:', textLine) == 1)
          [fieldText, fieldID] = extractPACFormField(textLine);
          count = count + 1;
          severity = sprintf('-%s', fieldText(1:1));
        else % if (findstrchr('4.:', textLine) == 1)
          if (findstrchr('5.:', textLine) == 1)
            [fieldText, fieldID] = extractPACFormField(textLine);
            count = count + 1;
            handlingOrder = sprintf('/%s', fieldText(1:1));
          else %if (findstrchr('5.:', textLine) == 1)
            if (findstrchr('10.:', textLine) == 1)
              [fieldText, fieldID] = extractPACFormField(textLine);
              count = count + 1;
              subject = sprintf('-%s', fieldText);
            end % if (findstrchr('10.:', textLine) == 1)
          end % if (findstrchr('5.:', textLine) == 1) else
        end % if (findstrchr('4.:', textLine) == 1) else
        if count > 2
          subject = sprintf('%s%s%s', severity, handlingOrder, subject);
          subject = strrep(subject, ' ', '_');
          if itemp < 2
            fidCntrl = fopen(sprintf('%s%sdrillCntrl.txt', pathToDrill, prefix),'w');
          else
            fidCntrl = fopen(sprintf('%s%sdrillCntrl.txt', pathToDrill, prefix),'a');
          end
          fprintf(fidCntrl, '%s,%s,', drillFiles(itemp).name, subject);
          fclose(fidCntrl);
          fprintf('\n%s,%s', drillFiles(itemp).name, subject);
          break %next file
        end %if count > 2
      end %while ~feof(fid)
    end %if fid > 0
    fcloseIfOpen(fid);
  end %for itemp =1:length(drillFiles)
end

