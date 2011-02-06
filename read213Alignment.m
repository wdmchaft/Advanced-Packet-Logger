function [top_fromMsgHdrBtm, left_fromMsgHdr, right_fromMsgHdr, bottom_fromOpratrUseBtm, fromFile, pathNameOfWord] = read213Alignment(pathName)

%set some default values
top_fromMsgHdrBtm = 3.5;          % Row
left_fromMsgHdr = 2.5;            % Column
right_fromMsgHdr = 79.75;         % Column
bottom_fromOpratrUseBtm = 52.4;   % Row
fromFile = 0;
pathNameOfWord = '';

fid = fopen(pathName, 'r');
if (fid > 0)
  [a, foundFlg] = findNextractNum('top_fromMsgHdrBtm', 0, 0, fid);
  if foundFlg
    top_fromMsgHdrBtm = a;
  end
  [a, foundFlg] = findNextractNum('left_fromMsgHdr', 0, 0, fid);
  if foundFlg
    left_fromMsgHdr = a;
  end
  [a, foundFlg] = findNextractNum('right_fromMsgHdr', 0, 0, fid);
  if foundFlg
    right_fromMsgHdr = a;
  end
  [a, foundFlg] = findNextractNum('bottom_fromOpratrUseBtm', 0, 0, fid);
  if foundFlg
    bottom_fromOpratrUseBtm = a;
  end
  fromFile = foundFlg ;
  [a, foundFlg] = findNextract('pathNameOfWord', 0, 0, fid);
  if foundFlg
    pathNameOfWord =  a;
  end
end
fcloseIfOpen(fid);
