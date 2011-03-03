%testCompileNeeded.m

%reads 'makeDiagnosticList.m' to determine compile modules &
% then determines if any modules contained in the code are newer
% than the compiled code.  Modules from Mathworks (i.e.: under \Matlab\..)
% are ignored.

newerList = {};
fid = fopen('makeDiagnosticList.m', 'r');
if fid < 1
  fprintf('\nUnable to find "makeDiagnosticList.m". Aborting');
  progress('updateStatusCurrent', 'fail');
  return
end
coreNameList = {};
while ~feof(fid)
  textLine = fgetl(fid);
  if ~findstrchr('%', textLine)
    a = findstrchr('.m', textLine);
    if ~a
      a = length(textLine)+1;
    end
    coreNameList(length(coreNameList)+1) = {strtrim(textLine(1:a-1))};
  end
end

needCompile(1:length(coreNameList)) = 0;
for coreNdx = 1:length(coreNameList)
  coreName = char(coreNameList(coreNdx))
  
  [list,builtins,classes,prob_files,prob_sym,eval_strings,...
      called_from,java_classes] = depfun(strcat(coreName,'.m'));
  [nonMLFunctionCount, nonMLFunctionNames] = findNonMLfunctions(list);
  
  [err, errMsg, outpostNmNValues] = OutpostINItoScript; 
  if findstrlen('OutpostINItoScript', coreName)
    toPath = outpostValByName('DirOutpost', outpostNmNValues);
  else
    toPath = outpostValByName('DirAddOnsPrgms', outpostNmNValues);
  end
  % %   compiled = dir(sprintf('C:\\Program Files (x86)\\Outpost\\AddOns\\Programs\\%s.exe',coreName));
  compiled = dir(sprintf('%s%s.exe',toPath, coreName));
  if length(compiled)
    compiledDateNum = datenum(compiled.date);
  else %if length(compiled)
    % %     compiled = dir(sprintf('C:\\Program Files (x86)\\Outpost\\%s.exe',coreName));
    % %     if length(compiled)
    % %       compiledDateNum = datenum(compiled.date);
    % %     else %if length(compiled) (2nd)
    compiledDateNum = 0;
    % %     end % if length(compiled) (2nd) else
  end % if length(compiled) else
  newer = 0;
  for itemp = 1:nonMLFunctionCount
    thisFile = char(nonMLFunctionNames(itemp));
    thisDir = dir(thisFile);
    if datenum(thisDir.date) > compiledDateNum
      fprintf('\n%s is newer than compiled code.', thisFile);
      newer = newer + 1;
      newerList(coreNdx, newer) = {thisFile};
      needCompile(coreNdx) = 1 ;
    end
  end
end

for coreNdx = 1:size(newerList, 1)
  f = 0 ;
  for newer = 1:size(newerList, 2)
    if iscellstr(newerList(coreNdx, newer))
      if ~f
        fprintf('\n%s:', char(coreNameList(coreNdx)));
        f = 1;
      end
      fprintf('\n   %s', char(newerList(coreNdx, newer)));
    end
  end
end
for coreNdx = 1:length(coreNameList)
  if needCompile(coreNdx)
    fprintf('\nNeed to compile %s.', char(coreNameList(coreNdx)));
  end
end
