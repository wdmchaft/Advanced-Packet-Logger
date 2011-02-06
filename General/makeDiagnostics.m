%makeDiagnostics
%General UI for chosing which diagnostic module to compile.
%The possible choices are read in from "makeDiagnosticList.m"
%VSS revision   $ $
%Last checkin   $ $
%Last modify    $ $
%Last changed by $$
%  $NoKeywords: $

%open with pretty much nothing bu tthis does allow us to show "user input" button
% as all the steps between here and the 1st call to "progress" in makeExe_general.m
[h_progress, err, maxStepLabels] = progress({'Program initialization'}, -1, '', pwd, '');
progress('updateStatus', 1, 'running');

fprintf('\r\nThe displayed list is loaded from "makeDiagnosticList.txt".');
fprintf('\r\nIf you want to add to this list, press "Cancel", then');
fprintf('\r\ncheckout the list from VSS, and edit the list.');

%make sure we're not in the wrong directory...
[err, errMsg] = compileDirectoryConfirm;
if err
  progress('updateStatusCurrent', 'fail');
  return
end
originalPWD = endWithBackSlash(pwd);
% ...the directory test for the is not 100% perfect but the following increases its robustness
% because the file being accessed is under VSS control
fid = fopen('makeDiagnosticList.m', 'r');
if fid < 1
  fprintf('\nUnable to find "makeDiagnosticList.m". Aborting');
  progress('updateStatusCurrent', 'fail');
  return
end
nameForReload = sprintf('%s.txt', mfilename);
fid_r = fopen(nameForReload, 'r');
if fid_r > 0
  [choiceNdx, fid_r] = readArrayKeyText('choiceNdx', fid_r, nameForReload);
  fcloseIfOpen (fid_r);
else
  choiceNdx = 0;
end

ucPrompt = {};
while ~feof(fid)
  a = strtrim(fgetl(fid));
  b = findstrchr('%', a);
  %ignore any comment-only lines
  if (b ~= 1)
    %if there is a comment on the line, pull the comment
    if b
      a = a(1:b-1);
    end
    %pull spaces
    a = strrep(a, ' ','');
    if length(a)
      [pathstr, name, ext,versn] = fileparts(a);
      %if no extension, make it a '.m'
      if length(ext) < 1
        a = strcat(name, '.m');
        ext = '.m';
      end
      %only allow '.m' in the list for the source
      if strcmp(lower(ext),'.m')
        ucPrompt{length(ucPrompt)+1} = a;
        %add date information
        mDir = dir(a);
        ucPrompt(length(ucPrompt)+1) = {sprintf(' | m   date %s', mDir(1).date)};
        a = dir(sprintf('%s*.exe', name));
        if length(a)
          [b, Ndx] = sort({a.name});
          ucPrompt(length(ucPrompt)+1) = {sprintf(' | exe date %s', a(Ndx(length(Ndx))).date)};
          if datenum(mDir(1).date) > datenum(a(Ndx(length(Ndx))).date)
            ucPrompt(length(ucPrompt)-1) = {sprintf('%s  newer', char(ucPrompt(length(ucPrompt)-1)))};
          else
            ucPrompt(length(ucPrompt)) = {sprintf('%s  newer', char(ucPrompt(length(ucPrompt))))};
          end
        end
      end %if ~strcmp(lower(ext),'.m')
    end %if length(a)
  end
end
fclose(fid);
% % ucPrompt = sort(ucPrompt);

choiceNdx = userChoice(ucPrompt, 'Choose file to compile. (Cancel if not on list)', choiceNdx);
if choiceNdx < 1
  errMsg = sprintf('>%s: user cancel', mfilename);
  err = -1;
  progress('updateStatusCurrent', 'fail');
  return
end

coreModules = char(ucPrompt(choiceNdx));
%in case the user selected an information line, back up to
% the line containing the source code name
a = findstrchr('|', coreModules);
while a
  choiceNdx = choiceNdx - 1;
  coreModules = char(ucPrompt(choiceNdx));
  a = findstrchr('|', coreModules);
end

%save the choice for the next run
fid = fopen(nameForReload, 'w');
if fid > 0
  writeArrayKeyText('choiceNdx', choiceNdx, fid);
  fcloseIfOpen (fid);
end %if fid > 0

[err, errMsg, targetDir] = makeExe_general(coreModules, 1); %flag that we've just opened "progress": no need for 2nd refresh

