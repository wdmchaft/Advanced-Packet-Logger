%doIt

% check for duplicates & remove them
% a is ordered pairs: dup checking on name, 1st of pair:
return

% Re-dating drill data to current date
a = dir('F:\PacketDemoLogs');
str = 'packetCommLog_';

fid = fopen('rename.bat','w')
for itemp = 1:length(a)
  name = char(a(itemp).name);
  if findstrchr(str, name)
    name_start = str;
    underAt = findstrchr('_', name);
    name_end = name(underAt(2):length(name));
    newName = sprintf('%s111022%s', name_start, name_end);
    fprintf(fid, 'ren %s%s %s\r\n', 'F:\PacketDemoLogs\', name, newName);
  end
end
fclose(fid)
edit('rename.bat')

return

% Test re-sizing of the window dispNghbrhdSmry
thisCERT = thisCERT + 1 ;
newReportArea = 'Red Cross Shelters';
handles.tacCall(length(handles.tacCall)+1) = {from} ;
handles.tacAlias(length(handles.tacAlias)+1) = {newReportArea} ;
handles.rowNames(length(handles.rowNames)+1) = {newReportArea} ;
% newReportArea = '';
handles.mtvCERTNdx(thisCERT) = length(handles.tacCall) ;
neighborhoodAmts(thisCERT, :) = 0;
handles.neighborhoodAmts(thisCERT, :) = -1;
handles.neighborhoodAmtsFlg(thisCERT, :) = 0;
handles.neighborhoodDate(thisCERT) = {''};
handles.neighborhoodCmt(thisCERT) = {''};
handles.neighUpdate(thisCERT) = 0;
handles.neighUpdateAmt(thisCERT, :) = 0;
handles.messagePathName(thisCERT) = {''};
% read the abbreviation file on the chance the new location has an abbreviation.
[handles, err, errMsg] = readTacFriendAbbrev(handles, handles.DirAddOns);
%%%%%%%%%%%%%%%%%%%
% the call to actually add the row to the display
handles = dispNghbrhdSmry('addLineToDisp', handles, thisCERT, handles.positNeigh(4));
handles = dispNghbrhdSmry('frameGroupBorders', handles);

return
% need to get figure name copied
% need to fill in header

thisPage = 1 ;
while length(str)
  primaryNdx = find( ismember({formField(thisPage,:).PACFormTagPrimary}, lower('message')) ) ;
  primaryNdx = primaryNdx(1) ;
  hj = formField(thisPage, primaryNdx(1)).HorizonJust ;
  hj = hj(2:length(hj)) ;
  [outstring,newpos] = textwrap(h_field(thisPage, primaryNdx), str);
  positPrim = get(h_field(thisPage, primaryNdx),'Position');
  if (newpos(4) > positPrim(4))
    willFit = floor(length(str) * positPrim(4) / newpos(4) - 1) ;
    [outstring,newpos] = textwrap(h_field(thisPage, primaryNdx), str(1:willFit) );
    set(h_field(thisPage, primaryNdx(1)),'String', outstring, ...
      'HorizontalAlignment', hj)
    % shorten str to what hasn't been placed on a form
    str = str(willFit+1:length(str));
    %open another form
    [err, errMsg, h_f, ff] = showForm('', '', '');
    %increment page number
    thisPage = thisPage + 1;
    % merge arrays
    last_h_f = length(h_f);
    h_field(thisPage, 1:last_h_f) = h_f(1:last_h_f);
    formField(thisPage, 1:length(ff)) = ff;
  else % if (newpos(4) > positPrim(4))
    set(h_field(thisPage, primaryNdx(1)),'String', outstring, ...
      'HorizontalAlignment', formField(thisPage, primaryNdx).HorizonJust)
    str = {};
  end % if (newpos(4) > positPrim(4)) else
end % while length(str)

return


fn = fieldnames(aRouting);
for itemp = 1:length(fn);
  try 
    if getfield(aShowform,char(fn(itemp))) ~= getfield(aRouting,char(fn(itemp)))
      fprintf('\n Miscompare on %s, %i', char(fn(itemp)), itemp);
      getfield(aShowform,char(fn(itemp)))
      getfield(aRouting,char(fn(itemp)))
    end
  catch
    fprintf('\n Error on %s, %i', char(fn(itemp)), itemp);
      getfield(aShowform,char(fn(itemp)))
      getfield(aRouting,char(fn(itemp)))
  end
end


return



fn = fieldnames(form);
for itemp = 1:length(fn);
  b = char(getfield(form,char(fn(itemp))));
  a = findstrchr(char(191), b);
  if a(1)
    for jtemp = length(a):-1:1
      if a(jtemp) == 1
        b = b(2:length(b));
      else
        b = sprintf('%s; %s', b(1:a(jtemp)-1), b(a(jtemp)+1:length(b)) );
      end
    end
     form = setfield(form,char(fn(itemp)), b);
  end % if a(1)
end
return

pathIt = 'C:\ProgramData\SCCo Packet\archive\TestFiles\'
notFound = [1:12];
dirList = dir(strcat(pathIt, '*.txt'));
for dirNdx = 1:length(dirList)
  fpathName = strcat(pathIt, dirList(dirNdx).name);
  [err, errMsg, outpost, fid, fpPosition, msg, linesRead, fpathName] = readOutpostHeading(fpathName, 'post time not avail', 0);
  [PACF, linesRead] = detectPacFORM(fid);
  if PACF
    [err, errMsg, pacfListNdx, thisForm, textLine] = getPACFType(fid);
    fprintf('\nPACF (%s): %i, %s', dirList(dirNdx).name, pacfListNdx, thisForm);
    notFound(pacfListNdx) = 0;
  else
    fprintf('\nNot PACF (%s)', dirList(dirNdx).name);
  end
  fcloseIfOpen(fid);
end
find(notFound ~= 0)
return


thisNdx = find(ismember(groupName,'8g:=emergency'));
aa = groupName(1:thisNdx-1);
aa(thisNdx) = {'8g'};
nxt = thisNdx + 3;
for Ndx = thisNdx + 3:length(groupName);
  aa(Ndx-2) = groupName(Ndx);
end

% % 
% % aa = groupName([1:44]);
% % aa(45) = {'24missed'};
% % for itemp = 46:57
% %   aa(itemp) = groupName(itemp-1);
% % end
% %  aa(58:60)=groupName(58:60)
% % return


%shorten the arrays of digitizePoints
for itemp = 1:min(Ndx-2+1, min(size(pH,3), size(plotPtH,3)))
  for jtemp = 1:size(pH,2)
    for ktemp = 1:size(pH,1)
      ppH(ktemp, jtemp, itemp) = pH(ktemp, jtemp, itemp);
    end
  end
  %plotPtH                    7x2x58          6496  double array (global)
  for ktemp = 1:size(plotPtH,1)
    for jtemp = 1:size(plotPtH,2)
      a_plotPtH(ktemp, jtemp, itemp) = plotPtH(ktemp, jtemp, itemp);
    end
    a_xOfGroup(ktemp, itemp)  = xOfGroup(ktemp, itemp); %                 7x58            3248  double array (global)
    a_yOfGroup(ktemp, itemp)  = yOfGroup(ktemp, itemp); %                 7x58            3248  double array (global)
  end
end
% groupName = aa;
% xOfGroup=a_xOfGroup;
% yOfGroup=a_yOfGroup;
% plotPtH=a_plotPtH;
return


for thisPage = 1:size(h_field,1)
  invalidNdx = find(h_field(thisPage,1:size(h_field,2)-1)<1);
  for itemp = 1:length(invalidNdx)
    formField(thisPage, invalidNdx(itemp)).PACFormTagPrimary = '';
  end
end

return

a = size(formImageThisPage);
ag = 0;
for itemp = 1:a(1)
  ag(itemp) = 0;
  for jtemp = 1:a(2)
    for ktemp =  1:a(3)
      ag(itemp) = ag(itemp) + double(formImageThisPage(itemp, jtemp, ktemp));
    end
  end
  ag(itemp) = ag(itemp)/(a(2)*a(3));
end

% % imagesc(formImageNewPages,'parent', get(gcf,'CurrentAxes'))

return

if 0
  updateFile = 0;
  %changing format of digitized names from '_' to ':=' as indication of embedded PACFormTagSecondary
  dirList = dir('C:\Program Files (x86)\Outpost\AddOns\*.mat');
  for dirNdx = 1:length(dirList)
    thisFile = strcat('C:\Program Files (x86)\Outpost\AddOns\', dirList(dirNdx).name);
    if ~findstrchr('ICS213.mat', thisFile)
      found = 0;
      fprintf('\n = = = %s = = = =', dirList(dirNdx).name);
      load(thisFile);
      for itemp = 1:length(groupName)
        thisGrpNm = char(groupName(itemp));
        underAt = findstrchr('_', thisGrpNm);
        if underAt
          chg = ~findstrchr('q', thisGrpNm);
          if chg 
            a = underAt;
          else % if chg
            if findstrchr('q', thisGrpNm) & ~findstrchr(':=', thisGrpNm)
              chg = (findstrchr('yes', thisGrpNm) | findstrchr('no', thisGrpNm));
              if ~chg 
                chg = findstrchr('_8c', thisGrpNm) ;
                if chg
                  a = chg+length('_8c');
                  fprintf('\n    %s', thisGrpNm);
                  thisGrpNm = sprintf('%s_checked', thisGrpNm(1:a-1));
                else
                  chg = findstrchr('_24c', thisGrpNm) ;
                  if chg
                    a = chg+length('_24c');
                    fprintf('\n    %s', thisGrpNm);
                    thisGrpNm = sprintf('%s_checked', thisGrpNm(1:a-1));
                    %                   %rules:
                    %                   digsAt = find(ismember(thisGrpNm,'123456789'));
                    %                   if length(digsAt)
                    %                     find((digsAt+1) == c);
                    %                     % _#c -> #c:=checked
                    %                     % _#c_<something> -> #c:=<something>
                    %                   end % if length(digsAt)
                  end % if findstrchr('c', thisGrpNm) ))
                end
              end % if ~chg
            end % if (findstrchr('q', thisGrpNm)
          end % if chg else
          if chg 
            found = found+1;
            fprintf('\nchange: %s -> ', thisGrpNm);
            thisGrpNm = sprintf('%s:=%s', thisGrpNm(1:a-1), thisGrpNm(a+1:length(thisGrpNm)));
            fprintf('%s', thisGrpNm);
            if updateFile
              groupName(itemp) = {thisGrpNm};
            end
          else
            a = '_checked';
            b = findstrchr(a, thisGrpNm);
            if b  
              if ((b+length(a)-1) == length(thisGrpNm))
                found = found+1;
                fprintf('\nchange: %s -> ', thisGrpNm);
                thisGrpNm = thisGrpNm(1:b-1);
                fprintf('%s', thisGrpNm);
                if updateFile
                  groupName(itemp) = {thisGrpNm};
                end
              end
            end
          end % if chg else
        end % if a
      end  
      if found
        if updateFile
          save(thisFile,'currentGroup','totalGroups','pointsInGroup','xOfGroup','yOfGroup','figsUsed','pH',...
            'plotPtH','lineColorNdx','groupName','scaleDistance','scaleFeetPerPixel','scaleOrientation','scaleOrientationText',...
            'pathNName');
          fprintf('\n  Updated file "%s" with %i changes', thisFile, found);
        else
          fprintf('\n  "%s" needs %i changes', thisFile, found);
        end
      end
    end
  end
  
  return
end
%doing the math
% b(1) = (a(1) - handles.ax1(1))/(handles.ax1(2) - handles.ax1(1))
% (handles.ax1(2) - handles.ax1(1)) * b(1) = a(1) - handles.ax1(1)
% (handles.ax1(2) - handles.ax1(1)) * b(1) + handles.ax1(1) = a(1) 
try
  delete(handles.figure1)
catch
end

[err, errMsg, outpostNmNValues] = OutpostINItoScript;
pathAddOns = outpostValByName('DirAddOns', outpostNmNValues);
pathPrgms = outpostValByName('DirAddOnsPrgms', outpostNmNValues);
printEnable = 3;
printer.printEnable = 1;
printMsg = printEnable;

receivedFlag = 0;
pathDirs.addOns = pathAddOns;
pathDirs.addOnsPrgms = pathPrgms;

pathToText = 'C:\Program Files (x86)\Outpost\archive\TestFiles\';

pacfListNdx = 3;
switch pacfListNdx
case 1
  fpathName = strcat(pathToText, 'cityScanFlash.txt');
  fid = fopen(fpathName,'r');
  [PACF, linesRead] = detectPacFORM(fid, 0, 100);
  [err, errMsg, printedName, printedNamePath, form] = ...
    cityScanFlash(fid, fpathName, receivedFlag, pathDirs, printMsg, printer);
case 2
  fpathName = strcat(pathToText, 'logistics-request.txt');
  fid = fopen(fpathName,'r');
  [PACF, linesRead] = detectPacFORM(fid, 0, 100);
  [err, errMsg, printedName, printedNamePath, form] = logisticsRequest(fid, fpathName, receivedFlag, pathDirs, printMsg, printer);
case 3
  fname = 'S_101021_111923_MLA_5_E~I_ICS213_VICTIM_TRANSPORT.txt';
  a = strcat('f:\Program Files\Outpost\archive\SentTray\',fname);
  a = strcat('C:\SCCo Packet\archive\SentTray\',fname);
  fid = fopen(a,'r');
  [PACF, linesRead] = detectPacFORM(fid, 0, 100);
  [err, errMsg, printedName, printedNamePath, form] = ...
    print_ICS_213(fid, fname, receivedFlag, pathDirs, printEnable, printer); %, h_field);
case 4
  fpathName = strcat(pathToText, 'CityMAR.txt');
  fid = fopen(fpathName,'r');
  [PACF, linesRead] = detectPacFORM(fid, 0, 100);
  [err, errMsg, printedName, printedNamePath, form] = cityMAR(fid, fpathName, receivedFlag, pathDirs, printMsg, printer);
case 5 % 'SHORT FORM HOSPITAL STATUS',  ...
  fpathName = strcat(pathToText, 'shortFormHospitalStatus.txt');
  fid = fopen(fpathName,'r');
  [PACF, linesRead] = detectPacFORM(fid, 0, 100);
  [err, errMsg, printedName, printedNamePath, form] = shortHospitalStatus(fid, fpathName, receivedFlag, pathDirs, printMsg, printer);
case 10 % FORM DOC-9 HOSPITAL-STATUS REPORT  (see also #6 which is the previous version of this PacFORM)
  fpathName = strcat(pathToText, 'doc9.txt');
  fid = fopen(fpathName,'r');
  [PACF, linesRead] = detectPacFORM(fid, 0, 100);
  [err, errMsg, printedName, printedNamePath, form] = doc9HospitalStatusReport(fid, fpathName, receivedFlag, pathDirs, printMsg, printer);
otherwise
  return
end
%%  [err, errMsg, formField, h_field] = showForm(fPathNameExt, pathAddOns, pacfListNdx);
if err
  fprintf('\n******* error: %s', errMsg);
  return
end
% set(handles.figure1,'position', [350.4 2.61538461538462 153.6 76.3846153846154])



return

pos = [10 10 100 100];
h = uicontrol('Style','Text','Position',pos,'FontUnits','normalized');
fontOrig = get(h, 'FontSize');
string = {'MLN-002'};
[outstring,newpos] = textwrap(h,string);
font_2 = (min(pos(4)/newpos(4), pos(3)/newpos(3)) * fontOrig);
set(h,'FontSize', font_2);
[outstring,newpos2] = textwrap(h,string);
set(h,'String',outstring)