function [formImageThisPage, formImageNewPages, gap] = adjustImages(formImage, positExpandBox, newpos, expandAmount, headerNdx, botAll, thisPage, positFooter, imageNextPgMove, gap)
%source of the expanding image is the image under & l/r of the last visible line:
% need to relate position of the last visible line to the image units
% need image units per text lin
% need position of top of footer in image units
% 1) copy footer image to next page
% 2) copy header image to next page
% 3) determine how many image units the box will expand by
% 4) copy imageU_expand vertical elements starting above footer and going up the page onto next page
% 5) move imageU_expand vertical elements worth of units starting below last visible down the page
% 6) insert imageU_expand worth of duplicated background starting below last visible
%INPUTS
% formImage: background image on this form
% positExpandBox: 4 element position array for the box before expansion
% newpos: the new box size sufficient to contain the expanded text
% expandAmount: how much the box needs to expand downward
% headerNdx: array of indices to the boxes which comprise the header
% botAll: array of the bottom positions of all boxes
% thisPage: number of the page that contains the box which is being expanded
% positFooter: 4 element position array of the single box comprising the footer
% imageNextPgMove: vertical amount of the image that needs to be moved to the
%    new page.

%Things to know so this function makes sense:
%  the image arrays are (Row, Column, Color) where color is a 3 element array 0 == black & 255 == white
%              Row relates to Y & Column to X -> opposite of standard graphical notation!
%  The image is contained in the figure's axis where 
%         Xmin=0.5 & Xmax= (ColumnMax+0.5)
%         Ymin=0.5 & Ymax= (RowMax+0.5)
%  The boxes/UIs are positioned on the figure in terms of X & Y
%  Both Column & X index in the same order: their minimum at the left & maximum at the right
%  Row & Y index in opposite directions: Row=0 is at the top of the figure while Y=0 is at the bottom
%    To access a given Row of the image based on a Y value, calculate Row as follows:
%     Row = MaxRow - Y  where Y must be an integer (or converted to one)

imgHi = size(formImage,1);
imgWi = size(formImage,2);

%convert the various floating point Y values to integers in image array units

%number of image rows the box needs to expand (downward) in size:
img_expdAmt = floor(expandAmount*imgHi);
%number of image rows that need to be moved to the second image:
img_nextPg = ceil(imageNextPgMove*imgHi);
img_gap = ceil(gap*imgHi);
gap = img_gap/imgHi;

%%% The image can only be moved by a certain increment.  The boxes
%%% need to be moved by the exact same amount so we'll need to return
%%% a value of the same amount.
% % % expandAmount = floor(expandAmount*imgHi) / imgHi;

%  image row containing the bottom of the box before it expands
%     this tells us where in the image array the box is located
img_topMove = floor(positExpandBox(2)*imgHi);
%     
img_expd = ceil(newpos(2)*imgHi);

%initialize an image for the new page
% & make it white
formImageNewPages = formImage;
formImageNewPages(:, :, :) = 255;
%the above is much faster than: formImageNewPages = uint8(255*ones(size(formImage)));

% if 0
%   %for debug: show it
%   imagesc(formImageNewPages,'parent', axes1)
% end

%find header region on image & copy
img_HdrBot = ceil((1-min(botAll(headerNdx)))*imgHi);
a = [1:img_HdrBot];
imgWiNdx = 1:imgWi;
formImageNewPages(a, imgWiNdx, :) = formImage(a, imgWiNdx, :);
%find & copy footer region image
img_footTop = ceil((positFooter(2)+positFooter(4))*imgHi);
a = imgHi-[img_footTop:-1:0];
formImageNewPages(a, imgWiNdx, :) = formImage(a, imgWiNdx, :);

%image for the next page: placement starts one point below the header background
% 
% % % formImageNewPages(img_HdrBot+[1:img_expdAmt],imgWiNdx,:) = formImage(imgHi-(img_footTop+[img_expdAmt-1:-1:0]),imgWiNdx,:);
pullFrom = imgHi-(img_footTop+[img_nextPg-1:-1:0]);
formImageNewPages(img_HdrBot+img_gap+[1:img_nextPg],imgWiNdx,:) = formImage(pullFrom,imgWiNdx,:);
% imgHi-(img_footTop+[img_nextPg-1:-1:0])
%reversing the order:
% imgHi-(img_footTop+[0:img_nextPg-1])
%expanding
% imgHi-(img_footTop+0)   imgHi-(img_footTop+(img_nextPg-1))

formImageThisPage = formImage;

%now that we've pulled all needed image information from the orginal page we can
%  adjust that image for the expansion:
% a) slide the image down
sourceMoveRange = [min(pullFrom)-1:-1:imgHi-img_topMove+1]; 
% clear the rows that have been moved off the original page
formImageThisPage([max(sourceMoveRange)+1+img_expdAmt:(imgHi-img_footTop)], imgWiNdx, :) = 255;
%formImageThisPage([(imgHi-(img_footTop+img_nextPg-1)):(imgHi-img_footTop)], imgWiNdx, :) = 255;
for itemp = 1:length(sourceMoveRange)
  jtemp = sourceMoveRange(itemp);
  formImageThisPage(jtemp+img_expdAmt, :, :) = formImage(jtemp, :, :) ;
end
% b) repeat the image line that was just above the bottom of the original
%    bottom of the box from to all of the rows from just above the new
%    location of the bottom to the original row of the bottom.
for itemp = 1:img_expdAmt
  jtemp = jtemp + 1;
  formImageThisPage(jtemp, :, :) = formImageThisPage(imgHi-img_expd, :, :) ;
end
% % formImageThisPage(imgHi-(img_footTop + [1:img_expdAmt] + img_expdAmt), :, :) = formImageThisPage(imgHi-img_expd, :, :) ;


%#IFDEF debugOnly  
% just so we can set a breakpoint here after all the action
if 1 == 0
end
%#ENDIF
