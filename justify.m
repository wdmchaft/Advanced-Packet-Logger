function [row, col] = justify(thisField, fieldText);
%Calculates row & col expecting "leftJustifyText" to be used next.

%key phrase that must be included within the read-in justifications
horJustKeys = {'left','center','right'};
vertJustKeys = {'bottom','middle','top'};
row = 0;
col = 0;
for itemp = 1:length(horJustKeys)
  a = findstrchr(char(horJustKeys(itemp)), lower(char(thisField.HorizonJust)) );
  if a 
    switch itemp
    case 1 % left
      % "ceil" so we'll not be before the left edge
      col = ceil(thisField.lftTopRhtBtm(1));
    case 2 % center
      col = thisField.lftTopRhtBtm(1) + (thisField.lftTopRhtBtm(3) - thisField.lftTopRhtBtm(1)) / 2;
      col = round(col - length(fieldText)/2) ;
    case 3 % right
      col = thisField.lftTopRhtBtm(3) ;
      col = floor(col - length(fieldText) );
    end %switch itemp
    for jtemp = 1:length(vertJustKeys)
      a = findstrchr(char(vertJustKeys(jtemp)), lower(char(thisField.VertJust)) );
      if a 
        switch jtemp
        case 1 % bottom
          % "fkoor" so we're not below the bottom edge (row increases as we go down the page)
          row = floor(thisField.lftTopRhtBtm(4));
        case 2 % middle
          row = round(thisField.lftTopRhtBtm(2) + (thisField.lftTopRhtBtm(4) - thisField.lftTopRhtBtm(2)) / 2) ;
        case 3 % top
          %need to add 1 since we're controlling the bottom of the printed characters
          row = ceil(thisField.lftTopRhtBtm(2) + 1) ;
        end %switch jtemp
        break
      end % if a
    end %for jtemp = 1:length(vertJustKeys)
    break
  end % if a 
end % for itemp = 1:length(horJustKeys)
