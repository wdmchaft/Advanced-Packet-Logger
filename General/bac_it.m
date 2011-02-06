function [err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bac_it(pathFrom, pathTo, fileSpecifier, limitedMsgs, overRideReadOnly, h_existWait);
%function [err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bac_it(pathFrom, pathTo, fileSpecifier[, limitedMsgs[, overRideReadOnly[, h_existWait]]]);
%limitedMsgs[optional]: absent or 0: all messages
%     1: only display when copying/updating or when there is an error
%h_existWait[optional]: either
%  1) text per the help on 'movegui' to position the figure.  If
%  empty or not passed in, position is the default which is the center.
%  or
%  2) numeric handle to another waitbar (or figure, etc.): this new wait bar will be positioned
%  below and left aligned with it.  If negative, the new position will be above & left aligned.
%
%VSS revision   $Revision: 10 $
%Last checkin   $Date: 6/16/08 8:01p $
%Last modify    $Modtime: 10/27/07 8:28a $
%Last changed by$Author: Arose $
%  $NoKeywords: $
global userCancel

err = 0;
errMsg = '';
modName = '>bac_it';

copyupdateList = {};
errorList ={};
userCancel = 0;

if (nargin < 4)
  limitedMsgs = 0;
end
if (nargin < 5)
  overRideReadOnly = 0;
end
if (nargin < 6)
  h_existWait = '';
end

pathFrom = endWithBackSlash(pathFrom);
pathTo = endWithBackSlash(pathTo);

if iscell(fileSpecifier)
  fileSpecifier = char(fileSpecifier);
end

for fSpecNdx = 1:size(fileSpecifier,1)
  thisFileSpecifier = fileSpecifier(fSpecNdx, :);
  
  if ~limitedMsgs
    fprintf('\nChecking from %s for %s in %s.', pathFrom, thisFileSpecifier, pathTo);
  end
  fromList = dir(strcat(pathFrom, thisFileSpecifier));
  h_waitBar = 0;
  if ~limitedMsgs & length(fromList) > 10
    [nextWaitScanUpdate, h_waitBar] = ...
      initWaitBar(sprintf('Checking from %s for %s files %s in %s.', pathFrom, strNumAddCommas(length(fromList)), thisFileSpecifier, pathTo), 0, h_existWait);
  end
  errors = 0;
  copied = 0;
  for (numFiles = 1:length(fromList) )
    if ( ~fromList(numFiles).isdir & ~strcmp(fromList(numFiles).name, '..'))
      b = dir(strcat(pathTo,fromList(numFiles).name));
      update = 1 ;
      if (length(b))
        for bNdx = 1:length(b);
          if strcmp(lower(fromList(numFiles).name), lower(b(bNdx).name));
            if ( ~(datenum(fromList(numFiles).date) > datenum(b(bNdx).date) ))
              update = 0;
            end
            break % out of "for bNdx = 1:length(b);"
          end
        end %for bNdx = 1:length(b);
      end
      if (update)
        frmPathName = strcat(pathFrom, fromList(numFiles).name);
        fprintf('\r Copying/updating %s', frmPathName);
        status = copyfile(frmPathName, pathTo);
        if ((~status) & (overRideReadOnly))
          a = findstrEDC('~', char(fromList(numFiles).name));
          if (a == 1)
            fprintf('\nInvalid file for intent of this copying procedure %s: skipping.', char(fromList(numFiles).name));
          else %if (a == 1)
            %check to see if an "attribute" issue
            r_to = 0;
            %1) read-only on target file?
            %  test of the file exists...
            fidTest = fopen(strcat(pathTo, char(fromList(numFiles).name)),'r');
            if (fidTest > 0)
              fclose(fidTest);
              [s_to, h_to, r_to] = learnAttrib(strcat(pathTo, char(fromList(numFiles).name)));
              if r_to
                fprintf('\nNeed to remove read-only on target: doing that...');
                dos(sprintf('attrib -r "%s%s"', pathTo, char(fromList(numFiles).name)));
              end
            end
            attr_from = '';
            %if the source file has size
            a = dir(frmPathName);
            if length(a)
              if (a(1).bytes)
                if (overRideReadOnly > 1)
                  [s_from, h_from, r_from] = learnAttrib(frmPathName);
                  if h_from
                    attr_from = '-h';
                  end
                  if s_from
                    attr_from = strcat(attr_from,' -s');
                  end
                  if length(attr_from)
                    fprintf('\nNeed to change attributes on source: %s doing that...', attr_from);
                    dos(sprintf('attrib %s "%s"', attr_from, frmPathName));
                  end
                end  %if (overRideReadOnly > 1)
                fprintf('\n copying');
                status = copyfile(frmPathName, pathTo);
                if r_to
                  fprintf('\nRestoring read-only...');
                  dos(sprintf('attrib +r "%s%s"', pathTo, char(fromList(numFiles).name)));
                end
                if length(attr_from)
                  attr_from = strrep(attr_from, '-', '+');
                  fprintf('\n    restoring attributes on source: %s.', attr_from);
                  dos(sprintf('attrib %s "%s"', attr_from, frmPathName));
                  fprintf('\n    setting same attributes on target: %s.', attr_from);
                  dos(sprintf('attrib %s "%s%s"', attr_from, pathTo, char(fromList(numFiles).name) ));
                end
              end %if (a(1).bytes)
            end %if length(a)
          end %if (a == 1) else
        end % if ((~status) & (overRideReadOnly))
        if (~status)
          a = dir(frmPathName);
          if length(a)
            if (~a(1).bytes)
              fprintf('\n **** error:  0 bytes in %s ****', frmPathName);
            else
              fprintf('\n **** error: unable to copy/update %s to %s ****', frmPathName, pathTo);
              errors = errors + 1;
              errorList(errors) = {frmPathName};
            end
          else %if length(a)
            fprintf('\n **** error: unable to copy/update %s to %s ****', frmPathName, pathTo);
            errors = errors + 1;
            errorList(errors) = {frmPathName};
          end %if length(a)else
        else
          copied = copied + 1;
          copyupdateList(copied) = {frmPathName};
        end
      end % if (update)
    end % if ( ~fromList(numFiles).isdir & ~strcmp(fromList(numFiles).name, '..'))
    if h_waitBar
      checkUpdateWaitBar(numFiles/length(fromList), h_waitBar);
      if userCancel
        break
      end
    end %if h_waitBar
  end % for (numFiles = 1:length(fromList) )
  if userCancel
    break
  else
    numFiles = length(fromList);
  end
  if ~limitedMsgs
    fprintf('\n Files checked: %i.  Files copied: %i.  Number of errors: %i', numFiles, copied, errors)
  end
  if h_waitBar
    close(h_waitBar);
  end
end % for fSpecNdx = 1:size(fileSpecifier,1)
if userCancel
  if h_waitBar
    close(h_waitBar);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
