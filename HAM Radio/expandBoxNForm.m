function [h_field, formField, moveNeeded] = expandBoxNForm(h_field, formField, primaryNdx, positExpandBox, newpos, thisPage, numPages, outpostNmNValues);
% When a PACF field contains more information than can be presented in its
%  box, the box will be expanded to be large enough for the information.
%  Any boxes parallel to or lower on the page than the expanded box will be expanded/shifted
%  down or rolled onto a new page as needed.  The background image is modified.
% The new page will be inserted after the current page and before any existing subsequent pages.
%In addition to performing the necessary modifications to the form,
% this function expands the arrays "h_field(page#, :)" & "formField(page#,:)"
%  *** this means any routines which intended to process all pages of these arrays should not 
%  used a "for" loop but rather a "while" loop because the array size can change within the loop.
%More details:
% * footer UI box(es) & background image of thisPage are duplicated to the new page.
% * footer UI box(es) are detected by: = find( ismember({formField(thisPage,:).digitizedName}, 'Footer') );
% * footer contents of course need to be appropriately loaded by the formFooterPrint.m function
% * header is similarly duplicated to the new page
% * header UI box(es) are detected by their location on the page:
%    find the box which has its top the highest on the page
%    find any other boxes with tops above the bottom of the highest box
% * the background image for the UI boxes that are moved is also moved whether down on this
%   page or onto the new page.
% * the background image just above the original bottom of the expanding box is duplicated 
%   as much as needed to expand the form.
% * the image is slid down the page the same amount except for the footer which is locked.
% FUTURE possible upgrades
% 1) improve the digitized contents to include identification/tagging of the header field(s)
% 2) avoid splitting of UI box groups & image ("widow/orphan") by identifying the groups in the digitized 
%    information.  One idea is to digitize the outline of the form for each group & giving these
%    outlines a specific name.  Using a frame UI might be appropropriate & having it invisible.
%    The code here could be updated to associate the UI elements within the frame and result in
%    the fram & elements being moved as a block.

%% might pass this in someday  if (nargin < 7)
headerNdx = [] ;
%%end

%moving the boxes also requires giving each a new Parent! get(h_field(2,45),'parent')
% as well as being removed as a Child from the original parent & added as a child to
% the new parent.
moveNeeded = 0; 
% 'cause script & not func, intialize
botAll = 0;
topAll = 0;

% find all OTHER boxes on this page
if primaryNdx(1) < 2
  a = 2:size(h_field, 2);
elseif primaryNdx(1) == size(h_field, 2)
  a = 2:(size(h_field, 2)-1);
else
  a = [1:primaryNdx(1)-1 primaryNdx(1)+1:size(h_field, 2)];
end
Ndx = find(ismember(get(h_field(thisPage, a),'type'),'uicontrol'));
Ndx = a(Ndx);
%get their locations - use same indexing as h_field, formField, etc.
positAll(Ndx) = get(h_field(thisPage, Ndx),'Position');
for itemp = 1:length(Ndx)
  botAll(Ndx(itemp)) = positAll{Ndx(itemp)}(2);
  topAll(Ndx(itemp)) = botAll(Ndx(itemp)) + positAll{Ndx(itemp)}(4);
end %for itemp = 1:size(positAll,1)

%if the header has not be defined, let's build one
if ~length(headerNdx)
  %find the box which has its top the highest on the page
  highestNdx = find(topAll == max(topAll));
  %find any other boxes with tops above the bottom of the highest box
  headerNdx = find(topAll > botAll(highestNdx));
end

footerNdx = find( ismember({formField(thisPage,:).digitizedName}, 'Footer') );

%percentage of the highest & lowest object on the page
hi = max(topAll) - min(botAll);
%expand any box with its bottom near or below the expanding box's bottom &
%  that has its top above the bottom of the expanding box
alsoExpandBoxes = find( (positExpandBox(2)+0.03*hi) > botAll & ...
  (positExpandBox(2) < topAll) );
if length(alsoExpandBoxes)
  alsoExpandBoxes = Ndx(alsoExpandBoxes);
end
%all boxes that are below the expanding box need to be moved.....except for the footer
mustMoxBoxesNdx = find( positExpandBox(2) >= botAll(Ndx));
if length(mustMoxBoxesNdx)
  mustMoxBoxesNdx = Ndx(mustMoxBoxesNdx);
  mustMoxBoxesNdx = mustMoxBoxesNdx(find(~ismember(mustMoxBoxesNdx, footerNdx)));
end


positFooter = get(h_field(thisPage, footerNdx),'Position');


% --------------------------
%   For now, we will not allow the expanding box to flow to one or more additional pages.
% That is definitely an upgrade we want.
%   This limitation means we need:
%    (1) to limit the expansion amount to be above the footer
%    (2) to reformat the text in the box to try to squeeze it into the 
%        available space.
%    (3) Need to do SOMETHING if #2 doesn't work.....

%new bottom = old bottom - downMove
%           = positExpandBox(2) - downMove;
%           = positExpandBox(2) - [newpos(4) - positExpandBox(4)];
%           = positExpandBox(2) -  newpos(4) + positExpandBox(4);

% if (newBottom)   <  (footer top)
%expand:
% if positExpandBox(2) - newpos(4) + positExpandBox(4)) < (positFooter(2) + positFooter(4)
%rearrange terms so the variable is on one side and the constants on the other:
% if positExpandBox(2) + positExpandBox(4) - positFooter(2) - positFooter(4) < newpos(4) 
%   the maximum height of the box is positExpandBox(2) + positExpandBox(4) - positFooter(2) - positFooter(4)
if (positExpandBox(2) - newpos(4) + positExpandBox(4)) < (positFooter(2) + positFooter(4))
  %get the field text as current formatted (& too many lines)
  str = get(h_field(thisPage, primaryNdx),'String');
  %reformat to reduce the number of lines by combining lines to obtain a fit
  [str, newpos, lineMergeNdx] = reformatToFit(h_field(thisPage, primaryNdx), str, newpos, (positExpandBox(2) + positExpandBox(4) - positFooter(2) - positFooter(4)) );
  %if message never fit....
  if ~lineMergeNdx
    %start the field with a warning to the operator
    str = [{'!!! message truncated: do manual print from Outpost/browser !!!'} str];
  end
  %place the reformatted text back into the UI box
  set(h_field(thisPage, primaryNdx),'String', str);
end %if (positExpandBox(2) - newpos(4) + positExpandBox(4)) < (positFooter(2) + positFooter(4))

%which boxes need to flow to another page?
% a) how much does bottom of the expanding box need to move down
downMove = newpos(4) - positExpandBox(4);

%   get the image from the figure:
a=get(get(h_field(1,size(h_field,2)),'CurrentAxes'),'children');
h_image = 0 ;
for itemp = 1:length(a)
  if strcmp(get(a(itemp),'type'), 'image')
    formImage = get(a(itemp),'CData');
    break
  end
end % for itemp = 1:length(a)

%%% The image can only be moved by a certain increment, namely the
%   resolution of the image.  The boxes on thisPage need to be 
%   moved by the exact same amount.
imgHi = size(formImage,1);
downMove = floor(downMove*imgHi) / imgHi;

% % [formImageThisPage, formImageNewPages, downMove] = adjustImages(formImage, positExpandBox, newpos, downMove, headerNdx, botAll, thisPage, positFooter) ;

% b) which boxes will no longer fit on the page:
%   any of the moving boxes with a post-move bottom that would be
%   below the top of the footer box.
newPgBoxesNdx = find( (botAll(mustMoxBoxesNdx) - downMove) < (positFooter(2)+positFooter(4)) );
if length(newPgBoxesNdx)
  newPgBoxesNdx = mustMoxBoxesNdx(newPgBoxesNdx);
  %define the index to the boxes which are moving but stay on this page
  thisPgMoveBxNdx = find(~ismember(mustMoxBoxesNdx, newPgBoxesNdx));
  %Learn the vertical gap between the highest box going to the
  %  new page and the lowest non-paged box.  We'll use that gap
  %  to position the paged boxes on the new page.
  if length(thisPgMoveBxNdx)
    thisPgMoveBxNdx = mustMoxBoxesNdx(thisPgMoveBxNdx);
    a = min( botAll(thisPgMoveBxNdx));
  else % if length(thisPgMoveBxNdx)
    a = positExpandBox(2);
  end % if length(thisPgMoveBxNdx) else
  gap = a - max(topAll(newPgBoxesNdx));
else % if length(newPgBoxesNdx)
  %all stay on this page - not sure this works right with the image-the image
  %  probably fills the page & now we're cropping it off the bottom.
  thisPgMoveBxNdx = mustMoxBoxesNdx;
  gap = 0;
end % if length(newPgBoxesNdx) else

c = max(topAll(newPgBoxesNdx)) - (positFooter(2) + positFooter(4));
if length(c)
  imageNextPgMove = max(downMove, max(c));
else
  imageNextPgMove = downMove;
end

[formImageThisPage, formImageNewPages, gap] = adjustImages(formImage, positExpandBox, newpos, downMove, headerNdx, botAll, thisPage, positFooter, imageNextPgMove, gap) ;
ff_newPgBoxesNdx = newPgBoxesNdx;
jtemp = length(ff_newPgBoxesNdx);
% if any items need to move to a new page, make sure
%   ALL items with the same PACFormTagPrimary are also moved.
%   This situation can develop when the digitizing was done to
%   also support using pre-printed forms where an area on the form
%   has lines to write on -> for alignment, each line may have been digitized
%   separately (ex: ActionTaken_13_line_1, ActionTaken_13_line_2, ActionTaken_13_line_3)
%  Those fields aren't used when we're printed the form and the data on a blank sheet of paper yet
%   they exist and need to be moved so they don't hide things.  (Hiding them - making them invisible
%   may also work but could be confusing - better to keep the group together)
if jtemp
  % look at each item we're moving to the new page...
  for itemp = 1:jtemp
    Ndx = ff_newPgBoxesNdx(itemp);
    % extract its PACFormTagPrimary
    fieldID = lower(formField(thisPage, Ndx).PACFormTagPrimary);
    % identify all entires with the same PACFormTagPrimary content...
    pNdx = find( ismember({formField(thisPage, :).PACFormTagPrimary}, fieldID) );
    % .... which will include the one we know is in the list: exclude that one
    a = find(~ismember(pNdx, ff_newPgBoxesNdx));
    % are there any additional ones?
    if length(a)
      % add the additional to the list
      ff_newPgBoxesNdx = [ff_newPgBoxesNdx pNdx(a)];
    end % 
  end % for itemp = 1:jtemp
  %get the list in numerical order
  ff_newPgBoxesNdx = sort(ff_newPgBoxesNdx) ;
end % if jtemp

%#IFDEF debugOnly  
% actions in IDE only
if 01
  %% for debugging let's see what we've got
  fprintf('\n(only shown in IDE) These need to be moved:\n')
  a = 0;
  for itemp = 1:length(mustMoxBoxesNdx)
    b = strtrim(formField(thisPage,mustMoxBoxesNdx(itemp)).PACFormTagPrimary);
    c = '';
    if ~length(b)
      b = sprintf('<%s>', formField(thisPage,mustMoxBoxesNdx(itemp)).digitizedName);
    else %if ~length(b)
      if length(formField(mustMoxBoxesNdx(itemp)).PACFormTagSecondary)
        c = sprintf(' (%s)', formField(mustMoxBoxesNdx(itemp)).PACFormTagSecondary);
      end
    end % if ~length(b) else
    if find(ismember(newPgBoxesNdx, mustMoxBoxesNdx(itemp) ))
      b = sprintf('%s <new page>', b);
    else % if find(ismember(newPgBoxesNdx, mustMoxBoxesNdx(itemp) ))
      b = sprintf('%s <down>', b);
    end % if find(ismember(newPgBoxesNdx, mustMoxBoxesNdx(itemp) )) else
    a = a + fprintf('%i:%s%s, ', mustMoxBoxesNdx(itemp), b, c);
    if (a>70)
      fprintf('\r\n');
      a = 0;
    end % if (a>70)
  end % for itemp = 1:length(mustMoxBoxesNdx)
  %% ^^^ end of debug display ^^^
end %if 0
%#ENDIF

%expand the box
% a) move the bottom
positExpandBox(2) = positExpandBox(2) - downMove;
% b) make it taller -> top doesn't move
positExpandBox(4) = newpos(4);
% c) do it!
set(h_field(thisPage, primaryNdx(1)),'Position', positExpandBox);

%adjust the form
origHidden = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')
a = get(h_field(thisPage, size(h_field,2)),'children');
b = find(ismember(get(a,'type'),'axes'));
axes1 = a(b);
imagesc(formImageThisPage,'parent', axes1);
axes(axes1)
set(0,'ShowHiddenHandles', origHidden)
set(axes1,'visible','off')

%move the boxes down on this page
for itemp = 1:length(thisPgMoveBxNdx)
  a = thisPgMoveBxNdx(itemp);
  b = positAll{a};
  %fprintf('\r\n%0.4f -> %0.4f', b(2), b(2) + moveAmt);
  b(2) = b(2) - downMove;
  set(h_field(thisPage, a),'position',b);
end

%assumption at this point is we need to flow
% some of the boxes from this page onto another, new
% page.



%We need to expand our arrays to include a new page.  The
%  arrays need to be initialized with blank/null data.  However
%  the structure of the arrays are not defined in this module so
%  we'll take advantage of a MATLAB feature where increasing an array
%  in one dimension intializes all elements to null for the new index
%Here, we know that the footer element is present on the new page:
%  this creates the arrays with at least footerNdx elements AND
%  creates the footer entries in these arrays
blankPage_formField(footerNdx) = formField(thisPage, footerNdx) ;
blankPage_h_field(footerNdx) = h_field(thisPage, footerNdx);
%also need a blank entry on the page
a = find(~ismember([1:length(blankPage_formField)], footerNdx));
if length(a)
  blank_fF_Entry = blankPage_formField(a(1));
  blank_h_f_Entry = blankPage_h_field(a(1));
else
  %nothing in array other than the footer!  We'll puff out the array
  blank_fF_Entry = blankPage_formField(1);
  % and clear the two fields we know are used to detect when the array
  % elements are used
end
blank_fF_Entry.digitizedName = '';
blank_fF_Entry.PACFormTagPrimary = '';
blank_fF_Entry.PACFormTagSecondary = '';
blank_h_f_Entry = 0;

%make sure we've enough elements in the arrays - footerNdx may not be the
%  last element.
if max(footerNdx) < size(formField, 2)
  blankPage_formField(size(formField, 2)) = blank_fF_Entry;
end
if max(footerNdx) < size(h_field, 2)
  blankPage_h_field(size(h_field, 2)) = blank_h_f_Entry;
end

%Is the page we're working on the last page of this form
% or does the form already contain additional pages?
oldfigName = '';
if (thisPage < numPages)
  %we need to insert a new page:
  %shift the setup for all existing pages beyond the current page up one page
  for itemp = numPages:-1:(thisPage+1)
    formField(itemp, :) = formField(itemp-1, :) ;
    h_field(itemp, :) = h_field(itemp-1, :) ;
    %adjust the page number portion of the figures's name
    [oldfigName] = expandAdjPageNum(formField, h_field, itemp);
  end % for itemp = numPages:-1:(thisPage+1)
end % if (thisPage < numPages)
numPages = numPages + 1;
newPage = thisPage+1;

% create the new page with blank entries
formField(newPage, :) = blankPage_formField ;
for itemp=1:size(formField,2)
  formField(newPage, itemp) = blank_fF_Entry;
end
h_field(newPage, :) = blankPage_h_field;

%open the new page as a figure
h_field(newPage, size(h_field, 2)) = openfig('showForm','new');
h_newPage = h_field(newPage, size(h_field, 2));
set(h_newPage,'units', get(h_field(thisPage, size(h_field, 2)),'units') )
set(h_newPage,'position', get(h_field(thisPage, size(h_field, 2)),'position'));
if length(oldfigName)
  set(h_newPage,'Name', oldfigName);
else
  expandAdjPageNum(formField, h_field, newPage, thisPage);
end
h_children = get(h_newPage,'children');
if length(h_children) < 2
  b = 1;
else %if length(h_children) < 2
  b = find(ismember(get(h_children,'type'),'axes'));
end %if length(h_children) < 2 else
if length(b)
  axes1 = h_children(b);
end
set(axes1,'position', [0 0 1 1])
origHidden = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')
imagesc(formImageNewPages,'parent', axes1)
load(strcat(outpostValByName('DirAddOnsPrgms', outpostNmNValues),'grayMap'))
set(h_newPage,'colormap', grayMap)
%Turn off the axis. Again, MATLAB doesn't show this is the method that works!
set(axes1,'visible','off')
set(0,'ShowHiddenHandles', origHidden)

%if any boxes move
if length(ff_newPgBoxesNdx)
  %now (finally) move the displaced boxes onto the new page...
  %  add to new page (blank except for the footer) &...
  %  ... copy the displaced boxes & . . .
  formField(newPage, ff_newPgBoxesNdx) = formField(thisPage, ff_newPgBoxesNdx) ;
  h_field(newPage, newPgBoxesNdx) = h_field(thisPage, newPgBoxesNdx);
  %%% ------->> new page << ----------
  set(h_field(newPage, newPgBoxesNdx), 'parent', h_newPage);
  %  .... delete from original page.
  for itemp = 1:length(ff_newPgBoxesNdx)
    Ndx = ff_newPgBoxesNdx(itemp);
    formField(thisPage, Ndx) = blank_fF_Entry;
  end
  % . . . and zero the array entry so we don't use it
  h_field(thisPage, newPgBoxesNdx) = blank_h_f_Entry;
end
% we've already copied the same footer to the new page
%%% ------->> new page << ----------
[h_field, formField] = duplicateUI(h_field, formField, thisPage, newPage, footerNdx);

% copy the header fields to the new page
[h_field, formField] = duplicateUI(h_field, formField, thisPage, newPage, headerNdx);

% position the moves fields on their new page:
%  want the vertical gap of the top of the highest to the bottom of
%  the header to be the same as that highest to whatever was above it
%  on the original page.  

%*** note: also need to work with the background image...
% May need to have groups so the explanation portion of the image is linked to
%  the boxes - image & boxes move together rather than cutting the image
if length(newPgBoxesNdx)
  moveAmt = min(botAll(headerNdx)) - max(topAll(newPgBoxesNdx)) - gap;
  for itemp = 1:length(newPgBoxesNdx)
    a = newPgBoxesNdx(itemp);
    b = positAll{a};
    %fprintf('\r\n%0.4f -> %0.4f', b(2), b(2) + moveAmt);
    b(2) = b(2) + moveAmt;
    set(h_field(newPage, a),'position',b);
  end
  %move the existing page's boxes as needed
end

%---------------------------------------
function [h_field, formField] = duplicateUI(h_field, formField, sourcePage, destPage, theseNdx)
%creates a UI on "destPage" with the same properties as the
%  UI on "sourcePage", places the handle of the new UI
%  into the h_field(page #, objectNdx) array using the same
%  objectNdx such that h_field(destPage, h_ndx) <-> h_field(sourcePage, h_ndx),
%  and copies formField such that formField(destPage,theseNdx) = formField(sourcePage, theseNdx);
%    (formField are the name & "rules" for the UI and is not a UI.  It can therefore be copied.)
%INPUT:
%   h_field: 2 D array of handles to UI elements, (page #, objectNdx)
%   sourcePage: page of the existing UI(s)
%   destPage: page where the duplicate UI(s) will be created
%   theseNdx: index/indices into the h_field array of the UI(s) to be
%      duplicated.

%cannot do a direct duplication of all properties [uicontrol(get(h_field(thisPage, footerNdx)))]
% because some are read only which means an error occurs when the uicontrol call results
% in an attempt to set them.  An alternative to the implementation here
% would be to (1) learn all the elements of the structure: a = get(h_field(thisPage, footerNdx))
% (2) attempt to learn & set each element within a "try"/catch" structure.
%Should use that to replace the itemp loop below

%loop through all UI(s) that are to be duplicated
for Ndx = 1:length(theseNdx)
  h_ndx = theseNdx(Ndx);
  h_obj = h_field(sourcePage, h_ndx);
  %the basics:
  h_field(destPage, h_ndx) = uicontrol('style', get(h_obj,'style'), ...
    'Units',get(h_obj,'Units'),...
    'Position',get(h_obj,'Position'),...
    'Visible','off',...
    'parent',h_field(destPage, size(h_field,2)));
  %the rest: doing it this way to reduce clutter
  %... list of properties we want to copy from the original UI
  a = {'FontWeight','FontAngle','FontName','FontUnits','FontSize',...
      'FontWeight','ForegroundColor','HorizontalAlignment',...
      'String','BackgroundColor','UserData','Visible','ToolTip'};
  %go through the list, setting the property of the new UI the same
  %  as the source UI
  for itemp =1:length(a)
    set(h_field(destPage, h_ndx),a{itemp}, get(h_obj, a{itemp}));
  end % for itemp =1:length(a)
  formField(destPage,theseNdx) = formField(sourcePage, theseNdx);
end % for Ndx = 1:length(theseNdx)
