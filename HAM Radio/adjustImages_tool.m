%adjustImages_tool

if 0
  %open the new page as a figure
  h_f = openfig('showForm','new');
  h_newPage = h_f;
  set(h_newPage,'units', get(h_f,'units') )
  set(h_newPage,'position', get(h_f,'position'));
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
  imagesc(formImageNewPages,'parent', axes1)
  get(axes1,'xlim')
  get(axes1,'ylim')
else
  %formImageNewPages
  %formImageThisPage
  %formImage
  figure(1)
  clf
  formImage_debug = formImage;
  %imgWi
  
  try
    %     formImageBlank = formImage;
    %     formImageBlank(:, :, :) = 255;
    thirds = floor(imgWi/3);
    a = [1:(thirds-1)];
    formImage_debug(:, 2*thirds+a,:) = formImageNewPages(:, a, :);
    formImage_debug(:, thirds+a,:) = formImageThisPage(:, a, :);
  catch
  end
  imagesc(formImage_debug);
  %using figure 1 'cause easy to manipulate
  ax1=get(1,'children')
  set(ax1,'position', [0 0 1 1])
end

hold on
Xlim = get(ax1,'xlim');
Xcenter = (Xlim(2)-Xlim(1))/2 + Xlim(1);
plot(Xlim, [1 1]*(imgHi-img_topMove),'b')
text(Xcenter, (imgHi-img_topMove),'imgHi-img_topMove')

%top of footer
plot(Xlim, [1 1]*(img_HdrBot),'g')
text(Xcenter, (img_HdrBot),'header bottom')
%find & copy footer region image
plot(Xlim, [1 1]*(imgHi-img_footTop),'m')
text(Xcenter, (imgHi-img_footTop),'footer top')


% newPos has new height but not new bottom-why? what is this used for?
% split the image in this script: one side is original & the other is the changed.