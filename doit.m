%doIt


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