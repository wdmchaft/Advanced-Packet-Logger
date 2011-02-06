function [err, errMsg, moduleAlias] = moduleAliasFromList(moduleName, enableWaitBar)
%function [err, errMsg, moduleAlias] = moduleAliasFromList(moduleName[, enableWaitBar])
% Given a true module name, returns an obfuscated alias for that module.
% The alias comes from a list such that a given module will always have
% the same obfuscated name.  The obfuscated name is generated from a
% sequential numberical list that is expanded as/when needed.
% INPUT
% moduleName: can be a cell array of modules or a single module name
%   all path names are ignored.
% enableWaitBar[optional]: if absent or set, operates a waitbar, closing all that are open!
% OUTPUT
% moduleAlias: list of alias.  List has a one to one correspondence
%   to the entries in the input "moduleName" list
% ADDITIONAL
% The file "moduleAlias.txt" must be present, available for reading &
%  for when new entries are found in the "moduleName" list, writing
%  must be allowed.  This file contains a list of the module names and
%  their alias and is the master list.  It is never shortened but will
%  be expanded as new module names are added.  This means an alias is
%  never re-used.
%VSS revision   $Revision: 2 $
%Last checkin   $Date: 8/21/06 8:43a $
%Last modify    $Modtime: 8/15/06 5:07p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

[err, errMsg, modName] = initErrModName(mfilename);
if nargin < 2 
  enableWaitBar = 1;
end

fid = fopen('moduleAlias.txt','r');
%to avoid redoing/restarting the list, we'll require that it be found
if fid < 1
  errMsg = sprintf('%s: file "%s" not found.', modName,'moduleAlias.txt');
  err = 301;
  for itemp = 1:length(moduleName)
    moduleAlias(itemp) = {''};
  end
  %%%%%%%%%%%%%%%%%%%
  return
  %%%%%%%%%%%%%%%%%%%
end

if enableWaitBar
  closeAllWaitBars
  initWaitBar(sprintf('Reading the existing Alias list'));
end
count = 0;
nameFound = 0; 
nameList = {};
aliasList = {};
%we're using one wait bar for 3 loops: initialize the total duration
totalLength = 3 * length(moduleName);
%read in the entire current list:
while ~feof(fid)
  [textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fid);
  if length(textLine)
    count = count + 1;
    [err, errMsg, text] = extractTextFromCSVText(textLine, commasAt, 0);
    nameList(count) = {text};
    [err, errMsg, text] = extractTextFromCSVText(textLine, commasAt, 1);
    aliasList(count) = {text};
  end %if length(textLine)
  if enableWaitBar
    checkUpdateWaitBar(count/totalLength);
  end
end %while ~feof(fid)
fcloseIfOpen(fid);
%index array so we don't search the list more than we have to
if count
  nameFound(count) = 0;
  %the first few lines MAY contain the VSS information: consider them found so they won't be searched
  itemp = 1;
  while 1 == findstrchr('%', char(nameList(itemp)))
    nameFound(itemp) = 1;
    itemp = itemp + 1;
  end
end
%list without the path of the EDC functions that we've parsed.  Not all of these end up compiled
% but we'll generate an alias because at the point where this module is called there is no way of
% knowing which modules are not called.  That can't be known until the files are auto-edited!
% Not a problem to have unused aliases.
for itemp = 1:length(moduleName)
  [pathstr,name,ext,versn] = fileparts(char(moduleName(itemp)));
  moduleName(itemp) = {name};
  if enableWaitBar
    checkUpdateWaitBar((itemp+count)/totalLength);
  end
end
barCount = count + itemp;
prefix = '0000';
newCount = 0;

%Find 'em!
%go through all entered names...
for inputNdx = 1:length(moduleName)
  thisModule = char(moduleName(inputNdx));
  % look for the name in the existing list
  found = 0;
  if count
    listNotFound = find(nameFound < 1);
    for listNdx = 1:length(listNotFound)
      jtemp = listNotFound(listNdx);
      if strcmp(char(nameList(jtemp)), thisModule)
        found = 1;
        %set the return variable
        moduleAlias(inputNdx) = {char(aliasList(jtemp))};
        %set the flag so we don't search this location again
        nameFound(jtemp) = 1;
        break %out of the "listNdx": quit searching the alias list for this name
      end %if strcmp(char(nameList(jtemp)), thisModule)
    end %for listNdx = 1:length(listNotFound)
  end %if count
  %if this module was not in the alias list...
  if ~found
    %expand the alias list:
    newCount = length(aliasList);
    newCount = newCount + 1;
    a = num2str(newCount);
    %...create a new sequential entry...
    aliasList(newCount) = {strcat(prefix([length(a):length(prefix)]), a)};
    %...and add this name to the list:
    nameList(newCount) = {thisModule};
    %add to the return list
    moduleAlias(inputNdx) = aliasList(newCount);
  end %if ~found
  if enableWaitBar
    checkUpdateWaitBar((barCount + inputNdx)/totalLength);
  end
end %for inputNdx = 1:length(moduleName)

%if the list has grown in size...
if newCount > count
  %re-write the entire file
  fid = fopen('moduleAlias.txt','w');
  %to avoid redoing/restarting the list, we'll require that it be found
  if fid < 1
    errMsg = sprintf('%s: unable to write file "%s".', modName,'moduleAlias.txt');
    err = 302;
    return
  end
  for itemp = 1:length(aliasList)
    fprintf(fid, '%s,%s\r\n', char(nameList(itemp)), char(aliasList(itemp)));
  end %for itemp = 1:length(aliasList)
end %if newCount > count
fcloseIfOpen(fid);
if enableWaitBar
  closeAllWaitBars
end
