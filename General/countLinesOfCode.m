function countLinesOfCode(pathToCode)

linesOfCode = 0;
total_linesOfCode = 0;
total_Files = 0;


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
    coreLwrNameList(length(coreNameList)) = {lower(strtrim(textLine(1:a-1)))};
  end
end
fclose(fid);

a = dir('debug_*');
%only include directories
dirNameList = {};
for itemp = 1:length(a)
  if a(itemp).isdir
    dirNameList(length(dirNameList)+1) = {a(itemp).name};
    %pull the common prefix "debug_"
    b = a(itemp).name;
    b = b(7:length(b));
    dirShortNameList(length(dirNameList)) = {lower(b)};
  end
end

sourceFilesList = {};

for prgmNdx = 1:length(coreNameList)
  thisPrgm = coreLwrNameList{prgmNdx};
  thisDirNdx = find(ismember(dirShortNameList, thisPrgm));
  if length(thisDirNdx)
    pathToCode = endWithBackSlash(dirNameList{thisDirNdx});
    mFileList = dir(strcat(pathToCode, '*.m'));
    commentLines = 0;
    
    for mListNdx = 1:length(mFileList)
      thisFile = mFileList(mListNdx).name;
      if ~any(ismember(sourceFilesList, {thisFile}))
        sourceFilesList(length(sourceFilesList)+1) = {thisFile};
        fid = fopen(strcat(pathToCode, thisFile),'r');
        if fid > 0
          %fprintf('\nScanning %s.. (lines of code up to now: %i, comments %i)', thisFile, linesOfCode, commentLines);
          while ~feof(fid)
            textLine = fgetl(fid);
            a = findstrchr('%', strtrim(textLine));
            if a ~= 1
              linesOfCode = linesOfCode + 1;
            else
              commentLines = commentLines + 1;
            end
          end
          fclose(fid);
        end
      else % if ~any(ismember(sourceFilesList, {thisFile})
        %%fprintf('\n %s already counted.', thisFile);
      end %if ~any(ismember(sourceFilesList, {thisFile}) else
    end %for mListNdx = 1:length(mFileList)
    fprintf('\n%s: Lines of code: %i in %i files, comments %i', thisPrgm, linesOfCode, length(mFileList), commentLines);
    total_linesOfCode = total_linesOfCode + linesOfCode;
    total_Files = total_Files + length(mFileList);
  end %if length(thisDirNdx)
end
fprintf('\nTotal lines of code: %i in %i files.', total_linesOfCode, total_Files);
