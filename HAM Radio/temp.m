origHidden = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')

figure1 = openfig('showForm','new');%axes
a=get(figure1,'children');
b = find(ismember(get(a,'type'),'axes'));
if length(b)
  axes1 = a(b);
end
set(axes1,'position', [0 0 1 1])

imagesc(formImageThisPage,'parent', axes1)

axes(axes1)

ax1 = axis;

set(0,'ShowHiddenHandles', origHidden)
[err, errMsg, outpostNmNValues] = OutpostINItoScript;
load(strcat(outpostValByName('DirAddOnsPrgms', outpostNmNValues),'grayMap'))
set(figure1,'colormap', grayMap)

%Turn off the axis. Again, MATLAB doesn't show this is the method that works!
set(axes1,'visible','off')

return


[formImageThisPage, formImageNewPages, downMove] = adjustImages(formImage, positExpandBox, newpos, downMove) ;

imagesc(formImageThisPage,'parent', axes1)
%Turn off the axis. Again, MATLAB doesn't show this is the method that works!
set(axes1,'visible','off')

% These need to be moved:
% 34:13 <down>, 37:ccmgt <down> (checked), 38:ccops <down> (checked), 39:ccplan <down> (checked), 
% 40:cclog <down> (checked), 41:ccfin <down> (checked), 
%
% 42:rec-sent <new page> (received), 
% 43:rec-sent <new page> (sent), 44:method <new page> (telephone), 45:method <new page> (dispatch center), 
% 46:method <new page> (eoc radio), 47:method <new page> (fax), 48:method <new page> (courier), 
% 49:method <new page> (amateur radio), 50:method <new page> (other), 51:other <new page>, 
% 52:opcall <new page>, 53:opname <new page>, 54:opdate <new page>, 55:optime <new page>, 

newPos =  imgHi-(img_footTop + itemp)
frmPos =  imgHi-(img_footTop + itemp + img_expdAmt)

numMovePts = img_topMove - (img_footTop + img_expdAmt)


a = get(h_field(thisPage, size(h_field,2)),'children');
b = find(ismember(get(a,'type'),'axes'));
axes1 = a(b);
imagesc(formImageThisPage,'parent', axes1);
set(axes1,'visible','off')