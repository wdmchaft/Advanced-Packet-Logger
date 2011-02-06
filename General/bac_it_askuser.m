function [err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bac_it_askuser(pathFrom, pathTo, fileSpecifier, limitedMsgs, minDate, ignoreList);
%function [err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bac_it_askuser(pathFrom, pathTo, fileSpecifier, limitedMsgs, minDate, ignoreList);
%
%fileSpecifier: either string, e.g. '*.doc', or cell array of strings, e.g. {'*.txt','*.m','*.fig','*.doc'}
%limitedMsgs[optional]: absent or 0: all messages
%     1: only display when copying/updating or when there is an error
%minDate[optional]: if present, needs to be the format Da-Mon-Year -> '1-Jan-0000'
%        to pass in but keep inactive, set to null string: ''
%ignoreList[optional]: list of files not to be include.  Each item in the list is allowed to contain
%  no more than one "*" as a wild card: ex 'diary*.txt'
%VSS revision   $Revision: 7 $
%Last checkin   $Date: 11/10/06 3:23p $
%Last modify    $Modtime: 11/10/06 3:23p $
%Last changed by$Author: Arose $
%  $NoKeywords: $
global userCancel

err = 0;
errMsg = '';
modName = strcat('>' ,mfilename);

closeAllWaitBars
copyupdateList = {};
errorList ={};
userCancel = 0;
errors = 0;
copied = 0;
numFiles = 0;

if nargin < 4
  limitedMsgs = 0;
end
if nargin < 5
  minDate = '';
end
if ~length(minDate)
  minDate = '1-Jan-0000';
end
if nargin < 6
  ignoreList = {};
end

pathFrom = endWithBackSlash(pathFrom);
pathTo = endWithBackSlash(pathTo);
if ~exist(pathTo)
  err = 1 ;
  errMsg = fprintf('%s: unable to find "to": %s', modName, pathTo);
  return
end
if ~exist(pathFrom)
  err = 1 ;
  errMsg = fprintf('%s: unable to find "from": %s', modName, pathFrom);
  return
end

if iscell(fileSpecifier)
  fileSpecifier = char(fileSpecifier);
end

for fSpecNdx = 1:size(fileSpecifier,1)
  thisFileSpecifier = fileSpecifier(fSpecNdx, :);
  if ~limitedMsgs
    fprintf('\nChecking from %s for %s in %s.', pathFrom, thisFileSpecifier, pathTo);
  end
  fromList = dir(strcat(pathFrom, thisFileSpecifier));
  if length(ignoreList)
    fromList = useIgnoreList(fromList, ignoreList);
  end
  h_waitBar = 0;
  if ~limitedMsgs & length(fromList) > 10
    [nextWaitScanUpdate, h_waitBar] = initWaitBar(sprintf('Checking from %s for %s in %s.', pathFrom, thisFileSpecifier, pathTo));
  end
  this_numFiles = 0 ;
  this_copied = 0 ;
  this_errors = 0 ;
  for (this_numFiles = 1:length(fromList) )
    if ( ~fromList(this_numFiles).isdir &...
        ~strcmp(fromList(this_numFiles).name, '..') )
      b = dir(strcat(pathTo,fromList(this_numFiles).name));
      update = 1 ;
      if (length(b))
        threshold = 1/(24*60*60) * 2; %if within 2 seconds, don't
        % or if due to daylight savings versus standard time
        if ( ~(datenum(fromList(this_numFiles).date) > datenum(b.date)+threshold)...
            | (datenum(minDate) > datenum(fromList(this_numFiles).date)) )
          update = 0;
        end
        if update
          if abs(datenum(fromList(this_numFiles).date) - datenum(b.date) - 1/(24) ) < threshold
            fprintf('\nSkipping %s: times different by 1 hour -> Daylights versus standard time.', b.name);
            fprintf('\n  %s, %s, %i bytes\n   & %s, %s, %i bytes', b.name, b.date, b.bytes, fromList(this_numFiles).name, fromList(this_numFiles).date, fromList(this_numFiles).bytes)
            update = 0 ;
          end
        end
      end
      %confirm with user
      if update
        if length(b)
          p = sprintf('Do you want to replace \n%s, %s, %i\n with\n %s, %s, %i?', b.name, b.date, b.bytes, fromList(this_numFiles).name, fromList(this_numFiles).date, fromList(this_numFiles).bytes);
        else
          p = sprintf('Do you want to copy %s, %s, %i?', fromList(this_numFiles).name, fromList(this_numFiles).date, fromList(this_numFiles).bytes);
        end
        button = questdlg(p, sprintf('Confirm from %s', pathFrom), 'Yes');
        if strcmp(button,'Yes')
        elseif strcmp(button,'No')
          fprintf('\nSkipping update/copy of %s', fromList(this_numFiles).name);
          update = 0;
        elseif strcmp(button,'Cancel')
          err = 1;
          errMsg = strcat(modName, ': user abort.');
          return
        end  
      end
      if (update)
        frmPathName = strcat(pathFrom, fromList(this_numFiles).name);
        fprintf('\r Copying/updating %s', frmPathName);
        status = copyfile(frmPathName, pathTo);
        if (~status)
          fprintf('\nNeed to remove read-only on target: doing that...');
          dos(sprintf('attrib -r %s%s', pathTo, char(fromList(this_numFiles).name)));
          fprintf('\n copying');
          status = copyfile(frmPathName, pathTo);
          fprintf('\nRestoring read-only...');
          dos(sprintf('attrib +r %s%s', pathTo, char(fromList(this_numFiles).name)));
        end
        if (~status)
          fprintf('**** error: unable to copy/update %s to %s ****', frmPathName, pathTo);
          errors = errors + 1;
          this_errors = this_errors + 1;
          errorList(errors) = {frmPathName};
        else
          this_copied = this_copied + 1;
          copied = copied + 1;
          copyupdateList(copied) = {frmPathName};
        end
      end
    end
    if h_waitBar
      checkUpdateWaitBar(this_numFiles/length(fromList), h_waitBar);
      if userCancel
        break
      end
    end
  end %for (this_numFiles = 1:length(fromList) )
  if ~limitedMsgs
    fprintf('\n Files checked: %i.  Files copied: %i.  Number of errors: %i', this_numFiles, this_copied, this_errors);
  end
  if h_waitBar
    close(h_waitBar);
  end
  if ~userCancel
    numFiles = length(fromList) + numFiles;
  else
    break
  end
end %for fSpecNdx = 1:size(fS,1)

function fromList = useIgnoreList(fromList, ignoreList)
keepFile(1:length(fromList)) = 1;
for itemp = 1:length(ignoreList)
  thisIg= char(ignoreList(itemp)); 
  wildAt = findstrchr('*', thisIg);
  if ~wildAt
    a = find(ismember({fromList.name}, thisIg));
    if length(a)
      keepFile(a) = 0;
      fprintf('\ndropping %s: on ignore list.',  fromList(a).name);
    end
  else %if ~length(wildAt)
    for jtemp = 1:length(wildAt)
      if (wildAt(1) == 1)
        str = thisIg(2:length(thisIg));
        for ktemp = 1:length(fromList)
          if (findstrchr(str, fromList(ktemp).name))
            keepFile(ktemp) = 0;
            fprintf('\ndropping %s: on ignore list.',  fromList(ktemp).name);
          end %if (findstrchr(str, fromList(ktemp).name))
        end %for ktemp = 1:length(fromList)
      else %if (wildAt(1) == 1)
        str = thisIg(1:wildAt(1)-1);
        str2 = thisIg(wildAt(1)+1:length(thisIg));
        for ktemp = 1:length(fromList)
          if (findstrchr(str, fromList(ktemp).name))
            if (findstrchr(str2, fromList(ktemp).name))
              keepFile(ktemp) = 0;
              fprintf('\ndropping %s: on ignore list.',  fromList(ktemp).name);
            end
          end %if (findstrchr(str, fromList(ktemp).name))
        end %for ktemp = 1:length(fromList)
      end %if (wildAt(1) == 1) else
    end %for jtemp = 1:length(wildAt)
  end %if ~length(wildAt)
  fromList = fromList(find(keepFile));
  keepFile = keepFile(find(keepFile));
end %for itemp = 1:ignoreList
% 
