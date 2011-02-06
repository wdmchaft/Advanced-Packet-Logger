%doit


aa = {'Hleft','Hcenter','Hright'};
bb = {'Vbottom','Vmiddle','Vtop'};

for h = 1:3
  thisField.HorizonJust = char(aa(h));
  for v = 1:3
    thisField.VertJust = char(bb(v));
    %key phrase that must be included within the read-in justifications
    horJustKeys = {'left','center','right'};
    vertJustKeys = {'bottom','middle','top'};
    row = 0;
    col = 0;
    for itemp = 1:length(horJustKeys)
      a = findstrchr(char(horJustKeys(itemp)), lower(char(thisField.HorizonJust)) );
      if a 
        switch itemp
        case 1 % left
          % "ceil" so we'll not be before the left edge
          col = ceil(thisField.lftTopRhtBtm(1));
        case 2 % center
          col = thisField.lftTopRhtBtm(1) + (thisField.lftTopRhtBtm(3) - thisField.lftTopRhtBtm(1)) / 2;
          col = round(col - length(fieldText)/2) ;
        case 3 % right
          col = thisField.lftTopRhtBtm(3) ;
          col = floor(col - length(fieldText) );
        end %switch itemp
        for jtemp = 1:length(vertJustKeys)
          a = findstrchr(char(vertJustKeys(jtemp)), lower(char(thisField.VertJust)) );
          if a 
            switch jtemp
            case 1 % bottom
              % "floor" so we're not below the bottom edge
              row = floor(thisField.lftTopRhtBtm(4));
            case 2 % middle
              row = round(thisField.lftTopRhtBtm(2) + (thisField.lftTopRhtBtm(4) - thisField.lftTopRhtBtm(2)) / 2) ;
            case 3 % top
              %need to add 1 since we're controlling the bottom of the printed characters
              row = ceil(thisField.lftTopRhtBtm(2) + 1) ;
            end %switch jtemp
            break
          end % if a
        end %for jtemp = 1:length(vertJustKeys)
        break
      end % if a 
    end % for itemp = 1:length(horJustKeys)
    fprintf('\r\n %s %s %i %i', thisField.HorizonJust, thisField.VertJust, row, col);
  end
end
    
return



fid = fopen('\\dg60x821\H\PO thesis\test junk.mer','r');
for itemp=1:5
  testLine(itemp)={fgetl(fid)};
end; 
size(testLine)

a = char(testLine(1));
[commasAt,quotesAt,spacesAt] = findValidCommas(a);
[err,errMsg,Type_facility] = findColumnOfData(a,'Type facility',commasAt,quotesAt,spacesAt);
[err,errMsg,test] = findColumnOfData(a,'Raddress',commasAt,quotesAt,spacesAt);

% for itemp=1:5;
%   a= char(testLine(itemp));
%   [commasAt,quotesAt,spacesAt] = findValidCommas(a);
%   [err, errMsg, text] = extractTextFromCSVText(a, commasAt, test);
%   text
% end
for itemp=1:4;
  a= char(testLine(itemp));
  [commasAt,quotesAt,spacesAt] = findValidCommas(a);
  [err, errMsg, text] = extractTextFromCSVText(a, commasAt, Type_facility);
  text
end

return


fn = fieldnames(handles)
found = 0;
for itemp = 1:length(fn)
  v = getfield(handles,{1,1},char(fn(itemp)))
  if (v == h)
    found = 1;
    break
  end
end %for itemp = 1:length(fn)
if ~found
  fprintf('Ooops! not found!');
end
callBackName = strcat(char(fn(itemp)), '_Callback')

return

global userCancel

cancel

a =dir('diary');
totalBytes = a(1).bytes;
fid =fopen('diary','r');
digits = ['0','1','2','3','4','5','6','7','8','9'];
filesChecked = 0;
filesCopied = 0;
filesXCopied = 0;
numberOfErrors = 0;
bytesRead = 0;
closeAllWaitBars;
[nextWaitScanUpdate, h_existWait] = initWaitBar('running');

while ~feof(fid)
  textLine = fgetl(fid);
  bytesRead = bytesRead + 2 + length(textLine);
  [nextWaitScanUpdate, lastWaitRatio] = checkUpdateWaitBar(bytesRead/totalBytes);
  checkCancel;
  if userCancel
    break
  end
  if length(textLine)
    if findstrEDC('Files checked:', textLine)
      colonsAt = findstrEDC(':', textLine);
      numsHere = find(ismember(textLine,digits));
      filesChecked = filesChecked + str2num(textLine(numsHere(find(numsHere > colonsAt(1) & numsHere < colonsAt(2)))));
      filesCopied = filesCopied + str2num(textLine(numsHere(find(numsHere > colonsAt(2) & numsHere < colonsAt(3)))));
      numberOfErrors = numberOfErrors + str2num(textLine(numsHere(find(numsHere > colonsAt(3) & numsHere < length(textLine)))));
    else
      if findstrEDC('error:', textLine)
        fprintf('\nErrors %i: %s', numberOfErrors+1, textLine);
      end
      if (findstrEDC('F:\', textLine) == 1)
        filesXCopied = filesXCopied + 1;
      end
    end
  end
end
fclose(fid);
fprintf('\nFiles checked: %s     files copied: %s     files xcopied: %s    errors: %s', ...
  strNumAddCommas(filesChecked), strNumAddCommas(filesCopied), strNumAddCommas(filesXCopied), strNumAddCommas(numberOfErrors))
%Files checked: 49.  Files copied: 0.  Number of errors: 0a =
return


%waterfall for pong:

global preLiq preName; %2 dimensional array of the wg & well conditions: length, length tolerance, SOS, SOS thermal tolerance
% length, Speed (negtaive)Tolerance, positive tolerance, thermal coefficient
global lenNdx sosNdx tolrNdx tolrPosNdx thermSosNdx
%preLiq's second index element; definitions in InitLevl
global sourNdx wgNdx coupNdx plateNdx liqNdx wellSrchNdx lensFocalNdx signalAcqrNdx

[err, errMsg, fullPongWave, pong_x0, pong_Dx, pong_numPts, pongWaveName, pongNextWaveName, thisWaveNum, totalWaves, pongLiqInfo, pongSonar, ...
    pongGenNumPulses, pongPatNum, pongMode, pongErrRec, pongSpareInt, pongSpareString] = ...
  pongLoadWave(pongPathFileName, ping_liq_info, -1);

pkdet_holdtime = 1/pongSonar/2;

ptsPerPingNdx = 9;
numPingWaves = pong_numPts/pongLiqInfo(ptsPerPingNdx);

couplingTime = pongLiqInfo(1)/preLiq(sosNdx, coupNdx)*2;
plotStartNdx = 230; %round(couplingTime/pong_Dx);
plotEndNdx = round(20e-6/pong_Dx);
%want the waterfall to be in mm, not seconds
plotDx = pong_Dx * preLiq(sosNdx, liqNdx) / 2 * 1e3;

firstWave = 1900;
figure(12);
zAxisMax = 0;
wavesProcessed = 0;
for pingWaveNdx = firstWave:(firstWave+99) % numPingWaves
  if ~wavesProcessed
    startPt = 1 + pongLiqInfo(ptsPerPingNdx) * (pingWaveNdx-1);
    endPt = startPt + pongLiqInfo(ptsPerPingNdx)-1;
  end
  wavesProcessed = wavesProcessed + 1;
  pong_wave = fullPongWave([startPt:endPt]);
  peak_wave= peakwave(pong_wave, pong_Dx, pongLiqInfo(ptsPerPingNdx), pkdet_holdtime, 0);
  zData(:,wavesProcessed)= (abs(peak_wave));
  if (wavesProcessed < 101)
    plotWave = abs(peak_wave(plotStartNdx:plotEndNdx) );
    plotNumPts = length(plotWave);
    zAxisMax = max(zAxisMax, max(peak_wave));
    if (wavesProcessed < 2)
      %                                            lldWaterfall(arrayIn,    x0,     Dx,      numPts, zAxisMax, T_brst, M_thick_text, arrayOfWaves, useSurfEDC)
      [err, errMsg, arrayOfWaves, arrayXdataOut] = lldWaterfall(plotWave, pong_x0, plotDx, plotNumPts);
      xlabel('Liquid Level (mm)');
      ylabel('Ping-in-pong number');
    else
      [err, errMsg, arrayOfWaves, arrayXdataOut] = lldWaterfall(plotWave, pong_x0, plotDx, plotNumPts, zAxisMax, 0, '', arrayOfWaves);
    end
  end
  startPt = endPt + 1;
  endPt = endPt + pongLiqInfo(ptsPerPingNdx);
end
view(0,90)
return

% % firstPt = 1;%max(floor(3e-6/Dx), 1);
% % new_x0 = firstPt * Dx;
% % lastPt = min(ceil(13e-6/Dx), numPts);
% % [err, errMsg, arrayOfWaves, arrayXdataOut] = lldWaterfall;
% % [err, errMsg, arrayOfWaves, arrayXdataOut] = lldWaterfall(newWave1(firstPt:lastPt, 1), new_x0, Dx, lastPt, 0, 0, '');
% % for itemp=2:10;
% %   [err, errMsg, arrayOfWaves, arrayXdataOut] = lldWaterfall(newWave1(firstPt:lastPt, itemp), new_x0, Dx, lastPt, 0, 0, '', arrayOfWaves);
% % end
% % 
% % return


% % ndx2use(1:length(errMeasAll));
a = find(margin(1,:)>1);
figure(1)
plot(margin(1,:), [1:size(margin,2)],'*');grid

return

fid = fopen('C:\Documents and Settings\arose.EDC\bitpim.csv','r');
% fidOut = fopen('temp.csv','w');
textLine = fgetl(fid);
commasAt = findstrEDC(',',textLine);
a(length(a)+1) = length(textLine)+1;
b = 1;
for itemp = 1:length(a)
  fprintf(fidOut,'%s\r\n', textLine(b:a(itemp)-1) );
  b = a(itemp)+1;
end
fclose(fid);
fclose(fidOut);

return
%need to sort by location and then by length of name
% find locals with drive letter: sort by drive ltter & then tool
% find those on Tool_Data
% find those on the network

machineRootPathLength = 0;
lengthsFound = [];
for itemp = 1:length(machineRootPath)
  machineRootPathLength(itemp) = length(char(machineRootPath(itemp)));
  a = find(machineRootPathLength(itemp) == lengthsFound);
  if ~length(a)
    lengthsFound(length(lengthsFound)+1) = machineRootPathLength(itemp);
  end
end
lengthsFound = sort(lengthsFound);
newSort = {};
for itemp = 1:length(lengthsFound)
  grp = find(machineRootPathLength == lengthsFound(itemp))
  a = sort(machineRootPath(grp));
  newSort(length(newSort)+[1:length(a)]) = a;
end

return

pathToData = '\\tool_data\tools\Tool_1\EDCB\HTS Data\Process\070719\5PZ001';
logPathAndName = strcat(pathToData,'.csv');
pathToData = endWithBackSlash(pathToData);
fileList = dir(strcat(pathToData,'*measlld.wpb'));
for itemp = 1:length(fileList)
  [pathstr,name,ext,versn] = fileparts(fileList(itemp).name);
  FileName(itemp) = {name};
end

[err, errMsg, retryFiles, extractLogPathAndName] = retryWavesMeasLLDExtract(FileName, logPathAndName)
return

for itemp = 165:180
  textArray = char(a(itemp));
  [err, errMsg, liq_info, newSonar, newNumPulses, measPatNum, measMode, measErrRec, measSpareInt, measSpareString, fidParam, LLParamFile] = ...
    rerunReadParm(textArray, pongFileType, overflowDirs, netDataPath, dataPath);
  fprintf('\n %i %s mode = %i, PG amp = %.3f', itemp, textArray, measMode, liq_info(8));
  fclose(fidParam);
end 
return


[errLoad, errMsgLoad, new_wave, x0, Dx, numPts] = loadwave(char(textArray), 0, '', verbose_print, fidParam);
[errMeas, errMsgMeas, lensToLiqDist, numBrst, mThick, mThickText, T_brst, dft_brst, lastNonLiqNdx, bestLiqNdx]...
  = measLLD(new_wave, x0, Dx, numPts, measPatNum, sonar_hz, liq_info, errRecovery, measMode, spareInt, spareString);

return

% http://www.theinquirer.net/default.aspx?article=28522

%log scan: 
%  needs to detect and suitable skip vision lines!  (can be do same as extractexper.. does it
%  needs to pass date_time to fluor reader so most appropriate of multiple scans can be accessed!

% summary:
% number of good profiles (~= number of experiments/runs)
% number of failed profiles  (do we care to look at llerrlog.txt to look at those that had 12 points)
% number due to bubbles (how to tell the difference between these and other causes such as bad gap/operator issues)
% days with nprdata but those not in the log
% days with no nprdata

%log error decode needs work: updates for obfuscated code (at least)

% a stand alone program for Process development
%  scans log and links the runs to the fluorescence
%  reports CV by run excluding only those wells skipped/not attempted to spot (reports num skipped)
%  plots F vs event; F by well, F vs LL, Hist of F

a = 0 ;
b = 0 ;
bb= 0 ;
cc= 0;
for itemp=1:length(valMdNdx);
  %fine amp, boundary
  a(itemp) = all_dft_brst(finePosNdx, wgNdx, valMdNdx(itemp));
  b(itemp) = all_dft_brst(finePosNdx, coupNdx, valMdNdx(itemp));
  bb(itemp) = all_dft_brst(fineAmpNdx, coupNdx, valMdNdx(itemp));
  cc(itemp) = all_dft_brst(fineAmpNdx, wgNdx, valMdNdx(itemp));
end;
c = (b-a)*Dx/2*1500;
figure(1)
d = find(c > 0);
plot(d,c(d)*1e3)
grid
figure(99)
plot(c(d)*1e3, bb(d)./cc(d)*100, '+')

return

sizeNew = size(metrics);
last_b = 0;
numElems = prod(sizeNew) ;
for b=1:sizeNew(2)
  fprintf('\n');
  for a=1:sizeNew(1)
    fprintf('%g -> %g    ', old_value(a, b)/baseMult, new_value(a, b)/baseMult) ;
  end
end
  fprintf('\n*******************');


for itemp = 1:numElems
  if any(sizeNew > 1)
    a = mod(itemp, sizeNew(1));
    if ~a
      a = sizeNew(1);
    end
    b = floor((itemp-1)/sizeNew(1))+1;
    if last_b < b
      fprintf('\n');
      last_b = b;
    end
    fprintf('%g -> %g    ', old_value(a, b)/baseMult, new_value(a, b)/baseMult) ;
  else
    fprintf('%g -> %g    ', old_value/baseMult, new_value/baseMult);
  end % if any(sizeNew > 1)
end % for itemp = 1:numElems

return
 

for ii = -1:0
  filename = strcat(full_pathTo, char(full_filesListNoPath(LLfilesNdx(itemp+ii))));
  [err, errMsg, liq_info, newSonar, newNumPulses, measPatNum, measMode, measErrRec, measSpareInt, measSpareString, fidParam] = readParm(filename);
  [err, errMsg, new_wave, Dx, x0, binWave, Xzero, Xoffset, Xincr, Yzero, Ymult, Yoffset, bytesPerPoint, numPts, a, fileWriter] = readBinWave('', fidParam);
  Ymult
  figure(201+ii);
  clf;
  plot(binWave);
  grid;
  hold on;
  ax=axis;
  plot(new_wgtestResults(5)*[1 1], [ax(3) ax(4)],'m');
  % plot(new_wgtestResults(5),new_wgtestResults(4),'*');
  title(sprintf('bin %s, Ymult = %.2f uV/bit', filename, Ymult*1e6));
  ylabel('Count')

  figure(101+ii);
  clf
  plot(new_wave);
  grid;
  hold on;
  ax = axis';
  ax(4) = max(max(new_wave), -min(new_wave));
  ax(3) = -ax(4);
  axis(ax);
  cx(1:4, ii+2) = ax;
  plot(new_wgtestResults(5)*[1 1], [ax(3) ax(4)],'m');
  %plot(new_wgtestResults(5),new_wgtestResults(4),'*');
  title(sprintf('float %s, Ymult = %.2f uV/bit', filename, Ymult*1e6));
  ylabel('Volts')
end
bx(4) = max(-min(cx(3,:)), max(cx(4,:)));
bx(3) = -bx(4);
bx(1:2) = cx(1:2,1);
figure(100)
axis(bx)
figure(101)
axis(bx)
figure(2)


return
[err, errMsg, full_filesListNoPath, full_filesDayTimeInSec, fileListNdx, ...
    listLength, valMdNdx, invalMdNdx, fileMeasuredSig, LLfilesNdx, all_pgAmp]...
  = plotPGAmpAdjust('\\arose_w2k\d\EDC\plotpgampadjust_ATS3_070313.mat');

figure(50)
a = fileMeasuredSig(:,2)./all_pgAmp';
plot(a);grid
ndx=find(a < 0.08); %>.44);
full_filesListNoPath(LLfilesNdx(ndx(1:10)))
%     if length(b)
%       %shorten the list: pull those just detected
%       a = a(find(all_measModeUsed(a) ~= modesToAnalyze(itemp)) );
%     end



return

figure(11)
clf
for itemp = 1:sourceWellCount
  [colr, lineStyle, colorOrder] = setColorLine(itemp);
  validPts = [1:countsInWell(itemp)];
  m = markerStyle(mod(itemp-1, length(markerStyle)) + 1);
  c = PlateEchoCRSorted(validPts,itemp);
  mx = max(PlateEchoCRSorted(validPts,itemp))
  [a,b] = find(mx == c)
  TrueEstZSorted(a,itemp)+ CoupDistSorted(a,itemp)
  plot(PlateEchoCRSorted(validPts,itemp), m,'Color',colr);
  % % plot(-TrueEstZSorted(validPts,itemp)+CoupDistSorted(validPts,itemp), PlateEchoCRSorted(validPts,itemp), m,'Color',colr);
  hold on
end
grid

return

xPlate = sosCoupling * plate2lensT_CR(:, Tp2Lens) /2;
xLiq = sosCoupling *(T_brsts_sorted(coupNdx, validLiquidNdx) - T_brsts_sorted(wgNdx, validLiquidNdx))/2;
xLL = 3.6e-3;

maxPlateAmp = max(plate2lensT_CR(:, Apecho));
f_plate = 1 / sqrt(maxPlateAmp);
maxLiqAmp = max(liquidCR);
f_liq = 1 / sqrt(maxLiqAmp);

Xf_plate= xPlate*1e3 .*sqrt(plate2lensT_CR(:, Apecho)) ;
Xf_plate_f = Xf_plate * f_plate;
maxXf_plate= max(Xf_plate);
maxXf_plate_f = max(Xf_plate_f);

Xf_liq = (xLL + xLiq)*1e3 .* sqrt(liquidCR);
Xf_liq_f = Xf_liq * f_liq;
maxXf_liq = max(Xf_liq);
maxXf_liq_f = max(Xf_liq_f);

firstFig = 3;
pltCnt = 0;
for itemp = firstFig:(firstFig+2)
  lgnd = {};
  count = 0;
  figure(itemp);
  clf;
  ttle = '';
  if itemp ~= 4
    count = count + 1;
    lgnd(count) ={'Xf_plate'};
    [colr, lineStyle, colorOrder] = setColorLine(count);
    plot(xPlate*1e3, Xf_plate/maxXf_plate*100, '-o', 'Color', colr);
    grid;
    hold on;
    count = count + 1;
    lgnd(count) ={'Xf_cnvrs'};
    [colr, lineStyle, colorOrder] = setColorLine(count);
    plot(xPlate*1e3, Xf_plate_f/maxXf_plate_f*100, '--*','Color', colr);
    count = count + 1;
    lgnd(count) ={'Amp_plate'};
    [colr, lineStyle, colorOrder] = setColorLine(count);
    plot(xPlate*1e3, plate2lensT_CR(:, Apecho)/maxPlateAmp * 100, 'Color', colr);
    ttle = 'Plate Data';
    pltCnt = count;
  end
  if itemp ~=3
    if itemp == (firstFig+2)
      pltCnt = 0;
    end
    count = count + 1;
    lgnd(count) ={'Xf_liq'};
    [colr, lineStyle, colorOrder] = setColorLine(count+pltCnt);
    plot(xLiq*1e3, Xf_liq/maxXf_liq*100, '-o', 'Color', colr);
    grid on
    hold on
    count = count + 1;
    lgnd(count) ={'Xf_liq_f'};
    [colr, lineStyle, colorOrder] = setColorLine(count+pltCnt);
    plot(xLiq*1e3, Xf_liq_f/maxXf_liq_f*100, '--*', 'Color', colr);
    count = count + 1;
    lgnd(count) ={'Amp_liq'};
    [colr, lineStyle, colorOrder] = setColorLine(count+pltCnt);
    plot(xLiq*1e3, liquidCR/maxLiqAmp*100, 'Color', colr);
    if length(ttle)
      ttle = strcat(ttle, ' & ');
    end
    ttle = 'Liquid Data';
  end
  title(strcat(ttle, ' versus Measured Coupling Distance'));
  legend(lgnd, 0);
  ylabel('Amplitude');
  xlabel('Coupling distance');
end

a = find(maxXf_liq == Xf_liq);
xLiq(a(1));
b = find(maxXf_plate == Xf_plate);
fprintf('\nPlate focus?: %.3f mm', (xPlate(b(1)))*1e3)
fprintf('\nLiquid focus?: %.3f mm', (xLiq(a(1)))*1e3)
fprintf('\nMotion from plate Focus to liquid focus: %.3f mm', (xPlate(b(1))-xLiq(a(1)))*1e3)


figure(6)
clf
plot(xLiq*1e3, liquidCR/maxLiqAmp*100, 'm');
grid
hold on
count = 1;
lgnd(count) ={'Amp_liq'};
Xf_liq=0;
minL = -4;
maxL = 4;
numSt = 10;
dS = (maxL - minL)/numSt;
nrm = maxPlateAmp/maxLiqAmp;
for xLLNdx = 1:numSt+1
  xLL = (minL + dS * (xLLNdx-1)) * 1e-3;
  for itemp=1:length(liquidCR);
    Xf_liq(itemp) = (xLL + xLiq(itemp))*1e3*sqrt(liquidCR(itemp));
  end
  maxXf_liq=max(Xf_liq);
  [colr, lineStyle, colorOrder] = setColorLine(xLLNdx);
  %plot(xLiq*1e3, Xf_liq/nrm, 'Color', colr);
  plot(xLiq*1e3, Xf_liq/maxXf_liq*100, 'Color', colr);
  count = count + 1;
  lgnd(count) ={sprintf('%.1f', xLL*1e3)};
end  
legend(lgnd, 0);
ax = axis;
ax(3) = 0;
axis(ax)

figure(2)
plot(xPlate*1e3, Xf_plate_f);grid

return

Tliq2pl = 3.7e-6;
deltaMove = 2.985e-3;
rActiveArea = 1.5e-3;
Lfocus = 8.11e-3;
SOSplate = 2670;
SOScoupling = 1490;
Lplate = .11e-3;
%SOSmin, SOSmax

      [sosLiqBest, LLbest, SOSliq_srch, LLerr_srch, LLtof, bestNdx] = ...
        SOS_liq(Tliq2pl, deltaMove, rActiveArea, Lfocus, SOSplate, SOScoupling, Lplate, SOSmin, SOSmax);
sosLiqBest, LLbest
return
% a = [size(X,1):-1:1];
% X_2 = X(a, :);
% X_2(size(X,1)+[1:size(X,1)], :) = X;
figure(1)
clf
x = X_2(:,1);
y = X_2(:,2);
[sigmaNew,muNew,Anew]=mygaussfit(x,y);
y=Anew*exp(-(x-muNew).^2/(2*sigmaNew^2));
hold on; plot(x,y,'.r');
plot(X_2(:,1),X_2(:,2))

return
X_2(:,1) = [1:size(X_2,1)]';

[u,covar,t,iter] = fit_mix_2D_gaussian( X_2,1);

a=0;
b=max(X_2(:,2));
s = std(X_2(:,1));
for itemp=1:size(X_2,1);
  %a(itemp)=1/(s*sqrt(2*pi))*exp(-(X_2(itemp,1)-u(1))^2/(2*s^2));
  a(itemp)= b*exp(-(itemp-u(1))^2/(2*s^2));
end
figure(1)
clf
%plot(X_2(:,1),a/max(a)*100);grid
%hold on
%plot(X_2(:,1),X_2(:,2)/max(X_2(:,2))*100,'r')

% plot(X_2(:,1),a);grid
% hold on
% plot(X_2(:,1),X_2(:,2),'r')

plot(a);
grid
hold on
plot(X_2(:,2),'r')

return

lastFig = 1;
count = 0
for itemp = 1:length(fileList_valid)
  [err, errMsg, lastFig, valid, sourceWellCount] = graphFocusScan(char(fileList_valid(itemp).name), 0, lastFig);
  %   if (sourceWellCount > 1)
  %    count = count + 1;
  %    fileList_valid(count) = fileList(itemp);
  %  end
end
fprintf('\nDone!');
return

fid = fopen('multi_line_c_text.txt','r')
textLine = fgetl(fid);
keyText = 'mclVsv(';
[err, errMsg, textLine] = obfuscate_mult_line_C(keyText, textLine, fid);

fprintf('\nDone!');
return

pathToFiles = 'D:\Tool_ATS_3\EDCB\ATS Data\Process\060802\20PZ207\' ;
coreName = 'measLLD.wpb';
nameMask = strcat('*', coreName);
pathToFiles = endWithBackSlash(pathToFiles);
cfgPath = pathToFiles;
allFiles = dir(strcat(pathToFiles, nameMask));

firstFileName = '060802_100523458measLLD.wpb';
lastFileName = '060802_100524301measLLD.wpb';
  a = findstrEDC(firstFileName, coreName);
  dateTime = firstFileName(1:a-1);
  [err, errMsg, textArray, firstDayTime] = date_time2Sec(dateTime);
  a = findstrEDC(lastFileName, coreName);
  dateTime = lastFileName(1:a-1);
  [err, errMsg, textArray, lastDayTime] = date_time2Sec(dateTime);

[nextWaitScanUpdate, h_scanProgress] = initWaitBar(sprintf('Processing: determining available files.'));
lastWaitScanRatio = 0;
count = 0;
useFileNdx = 0;
for itemp = 1:length(allFiles)
  checkUpdateWaitBar(itemp / length(allFiles));
  thisFile = allFiles(itemp).name;
  a = findstrEDC(thisFile, coreName);
  dateTime = thisFile(1:a-1);
  [err, errMsg, textArray, thisDayTime] = date_time2Sec(dateTime);
  allFilesTime(itemp) = thisDayTime;
  if thisDayTime >= firstDayTime
    count = count + 1;
    useFileNdx(count) = itemp;
  end
  if thisDayTime >= lastDayTime
    break
  end
end
closeAllWaitBars
initWaitBar(sprintf('Learning all coupling distances'));
liqInfo = 0;
pingWave = 0;
measModeAll = 0;
coupDist = 0;
fileNameList = {};
zAxisMax = 0;
T_brst = 0;
M_thick_text = '';
useSurfEDC = 0;
for itemp = 1:count
  fileNameList(itemp) = {sprintf('%s%s', pathToFiles, char(allFiles(useFileNdx(itemp)).name))};
  [err, errMsg, liq_info, newSonar, newNumPulses, measPatNum, measMode, measErrRec, measSpareInt, measSpareString, fidParam] = readParm(char(fileNameList(itemp)));
  coupDist(itemp) = liq_info(1) ;
  liqInfo(1:length(liq_info), itemp) = liq_info';
  measModeAll(itemp) = measMode;
  [err, errMsg, new_wave, x0, Dx, numPts, wasMAT, savedADCandPGsetting, prepWaveRevision, saved_lld_version] = loadwave(filename, 0, '', 1, fidParam);
  pingWave(1:numPts, itemp) = new_wave;
  [errMeas, errMsgMeas, lensToLiqDist, numBrst, mThick, mThickText, T_brst, dft_brst, lastNonLiqNdx, bestLiqNdx]...
    = measLLD(new_wave, x0, Dx, numPts, measPatNum, SonarHz, liq_info, measErrRec, measMode, measSpareInt, measSpareString);
  %   if itemp < 2
  %     [err, errMsg, arrayOfWaves, arrayXdataOut] = lldWaterfall(new_wave, x0, Dx, numPts, zAxisMax, 0, M_thick_text, 0, useSurfEDC)
  %   else
  %     [err, errMsg, arrayOfWaves, arrayXdataOut] = lldWaterfall(new_wave, x0, Dx, numPts, zAxisMax, 0, M_thick_text, arrayOfWaves, useSurfEDC)
  %   end
  checkUpdateWaitBar(itemp/count);
end %  for itemp = 1:count
% b) perform the sorting
closeAllWaitBars
return
        
        
if 0
  [err, errMsg, ch1Wave, x0, Dx, numPts, wasMAT, savedADCandPGsetting, prepWaveRevision, saved_lld_version]...
    = loadwave('g:\temp\060511_142125_1.hdr', 1, '', 1);err
  figure(1);
  clf
  plot(ch1Wave)
  grid
  hold on
  [err, errMsg, ch2Wave, x0, Dx, numPts, wasMAT, savedADCandPGsetting, prepWaveRevision, saved_lld_version]...
    = loadwave('g:\temp\060511_142207_2.hdr', 1, '', 1);err
  plot(ch2Wave,'r')
  
  meanCh2 = mean(ch2Wave);
  hi_1 = zeros(size(ch1Wave));
  hi_2 = hi_1;
  hi_1(find(ch1Wave > meanCh2)) = 1;
  hi_2(find(ch2Wave > meanCh2)) = 1;
  
  a = 2:length(ch1Wave);
  up_1 = zeros(size(ch1Wave));
  up_2 = zeros(size(ch1Wave));
  dn_1 = zeros(size(ch1Wave));
  dn_2 = zeros(size(ch1Wave));
  for itemp = 2:length(ch1Wave)
    if hi_1(itemp) & ~hi_1(itemp-1)
      up_1(itemp) = 1;
    else
      if ~hi_1(itemp) & hi_1(itemp-1)
        dn_1(itemp) = 1;
      end
    end
    if hi_2(itemp) & ~hi_2(itemp-1)
      up_2(itemp) = 1;
    else
      if ~hi_2(itemp) & hi_2(itemp-1)
        dn_2(itemp) = 1;
      end
    end
  end
end
a = find(up_1);
b = find(up_2);
upCounts = 0;
dnCounts = 0;
dnAt = 0;
upAt = 0;
for itemp=1:length(a)
  if hi_2(a(itemp))
    dnCounts =  dnCounts + 1;
    dnAt(a(itemp)) = 1;
  else
    upCounts = upCounts + 1;
    upAt(a(itemp)) = 1;
  end
end
for itemp=1:length(b)
  if hi_1(b(itemp))
    upCounts = upCounts + 1;
    upAt(b(itemp)) = 1;
  else
    dnCounts =  dnCounts + 1;
    dnAt(b(itemp)) = 1;
  end
end
c = min(length(a),length(b));
d = 1:c;
e = a(d) - b(d);
a = find(dn_1);
b = find(dn_2);
for itemp=1:length(b)
  if hi_1(b(itemp))
    dnCounts =  dnCounts + 1;
    dnAt(b(itemp)) = 1;
  else
    upCounts = upCounts + 1;
    upAt(b(itemp)) = 1;
  end
end
for itemp=1:length(a)
  if hi_2(a(itemp))
    upCounts = upCounts + 1;
    upAt(a(itemp)) = 1;
  else
    dnCounts =  dnCounts + 1;
    dnAt(a(itemp)) = 1;
  end
end
upCounts
dnCounts
c = min(length(a),length(b));
d = 1:c;
f = a(d) - b(d);
figure(2)
clf
plot(e,'c')
grid
hold on
plot(f,'k')
legend('Up delta','Down delta',0)

figure(3);clf;plot(dnAt+1.25,'r');grid;hold;plot(upAt)
  

fprintf('\n done')
return


if 0
  % % fprintf('Copying dll to A2...');
  % % dos('copy "D:\Cpack200\EDC\data\matlld.dll" "\\Alpha2\Alpha2 D\EDCB\HTS-01\Lib\MatlabRTL\bin\win32\*.*"')
  % % return
  t_cwgOnly = cwgOnly;
  t_wg_envelope = wg_envelope;
  t_wg_idx = wg_idx;
  t_wg_max = wg_max;
  t_wgOnlyY = wgOnlyY;
  t_wgOnly_x0 = wgOnly_x0;
  t_wgOnly_Dx = wgOnly_Dx;
  t_wgOnly_numPts = wgOnly_numPts;
  t_SonarPulses = SonarPulses;
  t_SonarHz = SonarHz;
  t_verbose_print = verbose_print;
  save('temp','t_cwgOnly','t_wg_envelope','t_wg_idx','t_wg_max','t_wgOnlyY','t_wgOnly_x0','t_wgOnly_Dx','t_wgOnly_numPts','t_SonarPulses','t_SonarHz','t_verbose_print')
  return
end
%for breakpoint @ c3PkNdx = c3PkNdx -p2(2) / (2 * p2(1)) * mu2(2) + mu2(1) - a(1) ; in corr_finex1Fit
fig = 201;
fig = fig+1;
figure(fig);
clf
plot(c_sig3)
grid
hold on;
ax=axis;
plot( (c3PkNdx(1))*[1 1],[ax(3) ax(4)])
%pts used in fit
plot(x,c_sig3(x),'*r')
%this can draw the fitted location
plot( (-p2(2) / (2 * p2(1)) * mu2(2) + mu2(1))*[1 1], [ax(3) ax(4)], 'm')
[y,delta] = polyval(p2,x,S2,mu2);
plot(x,y,'m')

fig = fig+1;
figure(fig);
clf;
plot(x,c_sig3(x),'r')
% plot([1:length(c_sig4)]-a(1),c_sig4);
grid;
hold on;
plot(x,y,'k');
yN=find(y==max(y));
plot(x(yN),y(yN),'*k')
p = -p2(2) / (2 * p2(1)) * mu2(2) + mu2(1);
plot(p, polyval(p2,p,S2,mu2),'+m')
legend('Actual','Fitted','Peak Actual','Peak Fitted',0)

return

if 0
  measLensToLiquid = 0.0071;
  measCR = 0.15;
  couplingDistanceUncorrected = 0.0036;
end

[fakeLensToLiquid, currentOffset, previousCount] = ...
  stepFocusScan(previousCount, measLensToLiquid, measCR, couplingDistanceUncorrected, minZ, maxZ, lensToWellPlateGap, thisSourceWell, numSourceWells, numTrgtWellsBySource)

return
jtemp = 1000;
% 3 ideas:
% 1) upsample just the one lobe and find it's peak
% 2) perform a 1st order fit to the derivative of the peak & find the zero crossing
% 3) perform a 2nd order fit to the peak & find the zero crossing of the derviative of the fit (ie: the peak)
[ierr, rs_lens_pos, rs_c_sig3, rs_T_brst, rs_dft_brst]=corr_finex1(ilens0,c_sig1,dft_brst,T_brst,Dx,lensMax1,wgNdx, x0, rs_ratio);

loc_max = max(rs_c_sig3);
ix3 = find(rs_c_sig3==loc_max) - 1 ;        % peak position within this echo segment relative to the first element
itemp = ix3;
while rs_c_sig3(itemp)>=0;
  itemp=itemp-1;
end;
firstNdx=itemp+1;
itemp = ix3;
while rs_c_sig3(itemp)>=0;
  itemp=itemp+1;
end;
lastNdx=itemp-1;
%1) upsample just the one peak & find its max
testRatio = 10;

x = [firstNdx:lastNdx];
timeIt = toc;
for itemp =1:jtemp
  c_sig4 = fast_fit(rs_c_sig3(x),testRatio)*testRatio;
  upSamNdx = find(c_sig4 == max(c_sig4));
  Ndx = (upSamNdx-1)/testRatio + firstNdx;
end
timeItText(2) ={sprintf('1 peak %ix upsample', testRatio)};
Ndx(2) = (upSamNdx-1)/testRatio + firstNdx;
timeIt(2) = toc;

figure(51)
clf
plot(rs_c_sig3)
lgnd ={'Normal c_sig3'};
hold on;
grid on;
plot(firstNdx+([0:1/testRatio:(length(c_sig4)-1)/testRatio]),c_sig4,'r')
plot(Ndx, max(c_sig4), '*r')
lgnd(2) = timeItText(2);
lgnd(3) = {'Peak of Upsample'};

%2) straight fit to derivative
a=[firstNdx:lastNdx-1];
timeIt(3) = toc;
for itemp =1:jtemp
  % b=c_sig3(a+1)-c_sig3(a);
  %[p,S,mu] = polyfit(a,b',1);
  [p2,S2,mu2] = polyfit(x,rs_c_sig3(x)', 2);
  Ndx(4) = -p2(2) / (2 * p2(1)) * mu2(2) + mu2(1);
end
timeItText(4) ={'2nd order fit'};
timeIt(4) = toc;
%3) 2nd order fit to peak
timeIt(5) = toc;
fitOrder = 4 ;
for itemp =1:jtemp
  [p4,S4,mu4] = polyfit(x,rs_c_sig3(x)', fitOrder);
  for ktemp=1:fitOrder;
    pp(ktemp)=(fitOrder+1-ktemp)*p4(ktemp);
  end;
  a = roots(pp);
  b = find(abs(a) == min(abs(a)));
  Ndx(6) = a(b) * mu4(2)+mu4(1);
end
timeItText(6) ={sprintf('%i order fit', fitOrder)};
timeIt(6) = toc;
xx = [x(1):0.001:x(length(x))];
plot(xx, polyval(p2,xx,S2,mu2),'k')
lgnd(4) = timeItText(6);
timeIt(7) = toc;
for itemp =1:jtemp
  [ierr, xlens_pos, xc_sig3, xT_brst, xdft_brst]=corr_finex1(ilens0,c_sig1,dft_brst,T_brst,Dx,lensMax1,wgNdx, x0, rs_ratio*10);
end
timeItText(8) ={'All 10x upsample'};
timeIt(8) = toc;
Ndx(8) = xlens_pos;
legend(lgnd)
for itemp = 2:2:length(timeIt)
  fprintf('\n %s:, %.3f, sec, %f', char(timeItText(itemp)), timeIt(itemp) - timeIt(itemp-1), Ndx(itemp));
end
return



% %   clockSlip_corrStart = corr_start - 2; %allow for 1.9999 early 
aa = [clockSlip_corrStart:corr_stop];   % extraction range from input signal 
timeIt = toc;
for itemp = 1:jtemp
end
timeIt(2) = toc;
% overall time: measLLD call
% for itemp =1:jtemp
%   [errMeas, errMsgMeas, lensToLiqDist, numBrst, mThick, mThickText, T_brst, dft_brst, lastNonLiqNdx, bestLiqNdx] = measLLD(new_wave, x0, Dx, numPts, measPatNum, sonar_hz, liq_info, errRecovery, measMode, spareInt, spareString);
% end
% timeIt(3) = toc;
% timeIt(3)-timeIt(2)
% return

% +/-1 clock align
% for itemp = 1:jtemp
%   [err, errMsg, new_wave1, iofst, x] = corr_align1(new_wave,mode,numPts);    % 10/24/02 JC simple timing alignment
%   c_sig1 = conv(new_wave1, ref1);                      % conv of signal with ref
% end
timeIt(3) = toc;

for itemp = 1:jtemp
% %   clockSlip_corrStart = corr_start - 2; %allow for 1.9999 early 
% %   a = [clockSlip_corrStart:corr_stop];   % extraction range from input signal 
  %extract into an array whose 1st point has an offset of the clockSlip_corrStart.  (all earlier points are automatically zero)
  new_wave1 = 0; %zeros(1,c_window+corr_stop)' ; %>>>> not in the functional code!
  new_wave1(aa) = new_wave(corr_Offset + aa - 1);  
  new_wave1 = [new_wave1,zeros(1,c_window)]'; % append trailing 0s to removing checking for valid range later in corr_finex1
  %only convolve the lens search region: this allows us to save time since we may need to adjust the timing alignment
  % % c_sig1 = conv(new_wave1(1:lens_stop), ref1);                      % conv of signal with ref
  
  relativeGain = dft_brst(wgNdx,fineAmpNdx)/wgdft_brst(wgNdx, fineAmpNdx);
  %%%% >>> need the lens locator, above, to be performed at the higher sample ratio "wg_rs_ratio"
  % % delta = maxWgNdx - maxWaveNdx;
  % startNdx & finalNdx describe the range of the points in base units
  %  of the region to be cancelled.  
  % ??? %  (NOTE: if full waveform, some additional bookkeeping is needed for the beginning/ending of the waveform(s)
  startNdx = ceil(dft_brst(wgNdx, finePosNdx) + burst_Ndxwidth); %a little past the actual lens location
  finalNdx = corr_stop;
  deltaNdx = wgdft_brst(wgNdx, finePosNdx) - dft_brst(wgNdx, finePosNdx);
  extractStart = round((deltaNdx + startNdx - 1) * wg_rs_ratio + 1);
  %beginning bookkeeping: cannot extract before the first point
  if extractStart < 1
    %we'll zero fill automatically by starting the cancellation waveform at an element > 1
    % 1) determine number of "banks" of umsampled regions we need to shift over
    startCancel = floor(-extractStart/wg_rs_ratio) + 1;
    % 2) shift the extraction pointer to the wg upsampled so it is positive
    extractStart = extractStart + wg_rs_ratio * startCancel;
  else
    startCancel = 0;
  end
  c = extractStart + wg_rs_ratio * [0:(finalNdx-startNdx-startCancel)] ;
  %check that we don't try to extract beyond the last point
  if c(length(c)) > length(wgOnlyYupSampled)
    c = find(c <= length(wgOnlyYupSampled) );
  end
  % % wgCancelWave((startCancel+[1:length(a)]), 1) = wgOnlyYupSampled(c)/relativeGain ; 
  %   %ending bookkeeping: must be same length so zero fill to correct length (in case we ran out of wgOnlyYupSampled)
  %   % % this also fills out for the back porch points added to new_wave1
  %   if length(wgCancelWave) < numPts_newWave1
  %     wgCancelWave(numPts_newWave1) = 0;
  %   end
  %new_wave1 is offset by corrOffset, wgCancelWave is not
  a = [startNdx:finalNdx] - corr_Offset + 1;
  % % new_wave1(a) = new_wave1(a) - wgCancelWave;
  new_wave1(a) = new_wave1(a) - wgOnlyYupSampled(c)/relativeGain;
  % b = [startNdx:numPts_newWave1];
  b = [plate_start-corr_Offset:numPts_newWave1];
  %perform convolution on the aligned, cancelled waveform
  % % c = (length(b)+length(ref1)-2);
% %   c_sig1(b(1) + c) = 0;
% %   c_sig1(b(1)+[0:c]) = conv(new_wave1(b), ref1);
   % % a(length(b)+length(ref1)-1) = 0;
   a = conv(new_wave1(b), ref1);
% %   c_sig1(b(1)+[0:(length(a)-1)]) = a;
end
timeIt(4) = toc;
overHead = timeIt(2)-timeIt(1);
timeIt(4)-timeIt(3)-overHead
% +/- clock align timeIt(3)-timeIt(2)-overHead
% fprintf('\r\n New/Old %.0f%%',(timeIt(4)-timeIt(3)-overHead)/(timeIt(3)-timeIt(2)-overHead)*100);
return

arLng=length(z_lens2liqArrayPing);


figure(56);
clf
plotByColor(sortedSpotParam(validData)*spotParamMult, wellXYsrcYposByPing(validData, thisPing), diaColor(validData, :));
grid;
title({sprintf('Source Ypos versus %s', sortText), liqTitle}, 'Interpreter','none');
ylabel('Ypos from transducer');
xlabel(sortText)
a = axis;
a(1:2) = dispAxis(1:2);
axis(a)

figure(57);
clf
plotByColor(sortedSpotParam(validData)*spotParamMult, wellXYsrcXposByPing(validData, thisPing), diaColor(validData, :));
grid;
title({sprintf('Source Xpos versus %s', sortText), liqTitle}, 'Interpreter','none');
ylabel('Xpos from transducer');
xlabel(sortText)
a = axis;
a(1:2) = dispAxis(1:2);
axis(a)

figure(58);
clf
plotByColor(sortedSpotParam(validData)*spotParamMult, wellSequenceNumberByPing(validData, thisPing), diaColor(validData, :));
grid;
title({sprintf('Sequence number versus %s', sortText), liqTitle}, 'Interpreter','none');
ylabel('Number');
xlabel(sortText)
a = axis;
a(1:2) = dispAxis(1:2);
axis(a)


figure(55);
clf
plotByColor(sortedSpotParam(validData)*spotParamMult, focusByPing(validData, thisPing), diaColor(validData, :));
grid;
title({sprintf('Focus versus %s', sortText), liqTitle}, 'Interpreter','none');
ylabel('Focus in mm');
xlabel(sortText)
a = axis;
a(1:2) = dispAxis(1:2);
b = 0.02 * (a(4) - a(3));
if a(3) == min(focusByPing(validData, thisPing));
  a(3) = a(3) - b;
end
if a(4) == max(focusByPing(validData, thisPing));
  a(4) = a(4) + b;
end
axis(a)

figure(53);
clf
plotByColor(sortedSpotParam(validData)*spotParamMult, wellXYnumOfBurstByPing(validData, thisPing), diaColor(validData, :));
grid;
title({sprintf('Number of bursts versus %s', sortText), liqTitle}, 'Interpreter','none');
ylabel('Number of bursts');
xlabel(sortText)
a = axis;
a(1:2) = dispAxis(1:2);
axis(a)


%lens echo amp
figure(54)
ax=axis;
ax(2)=arLng;
ax(3)=0;
ax(4)=20;
axis(ax)
%liquid level
figure(52)
ax=axis;
ax(2)=arLng;
ax(3)=0;
ax(4)=4;
axis(ax)

figure(51)
ax=axis;
ax(2)=arLng;
ax(3)=7;
ax(4)=8;
axis(ax)
return


% Need to correct the phase.  The first thought is to look at the + & - zero crossings and make them equal.
% The limitation is that the error in the + motion may be different than the - motion.
% Another idea is to look at the fundamental content of the difference wave and adjust the phase
% of the fitted wave to minimize it.

%for speed, we might be able to reduce the number of points by performing a box-car average
% whose width/number of points is related to the determined frequency and the basic sample rate
firstPhase = angle(Y(magPeakNdx));
newPhase = firstPhase;
stepAmount = 0.001; %phase step in radians
minStepPhase = 0.00001;
thisPhase = 0;
if 1
  %decide which way to go: which ever direction produces a difference wave with the lower fundamental content.
  for itemp = 1:3
    thisPhase(itemp) = newPhase+(itemp-2)*stepAmount;
    newFit = -gain * sin(x_data*Df*(newfittedPeakAtdouble-1)*2*pi+ thisPhase(itemp) )';
    newDelt = inputWave - newFit;
    y = fft(newDelt, numBins);
    yMag(itemp) = abs(y(magPeakNdx));
  end
  minAmp = yMag(2);
  if yMag(1) < yMag(3)
    %answer in the reduce phase direction
    stepDirUp = -1;
    itemp = 3;
    jtemp = 1;
  else
    %answer in the increase phase direction
    stepDirUp = 1;
    itemp = 1;
    jtemp = 3;
  end
  last_2_yMag = yMag(2);
  last_2_yMag(2) = yMag(jtemp);
  last_thisPhase = thisPhase(2) * 180/pi;
  last_thisPhase(2) = thisPhase(jtemp) * 180/pi;
  %have we all ready bracketted or found the best phase?
  % measure the fundamental at 1/2 the step all ready measured
  newFit = -gain * sin(x_data*Df*(newfittedPeakAtdouble-1)*2*pi+ newPhase+(stepDirUp/2*stepAmount) )';
  newDelt = inputWave - newFit;
  y = fft(newDelt, numBins);
  a = abs(y(magPeakNdx));
  %if 1/2 step has less amplitude
  if a < yMag(jtemp)
    stepDivide = 1/2;
    chunking = 0;
  else
    chunking = 1;
    stepDivide = 1;
    newPhase = newPhase + (stepDirUp*2*stepAmount);
    last_phase = newPhase;
  end
  %safety valve loop: should break out before max count
  maxLoops = 100;
  yMag = yMag(itemp);
  yMag = last_2_yMag(2); %hack
  ktemp = fprintf('\n %.3g @ %.3f, %.3g @ %.3f',last_2_yMag(1), last_thisPhase(1),last_2_yMag(2), last_thisPhase(2));
  aTemp = 0;
  bTemp = 0;
  for jtemp = 1:maxLoops
    %%%%%%%%%%%%%%%%%
    
    last_stepDirUp = stepDirUp;
    
    newFit = -gain * sin(x_data*Df*(newfittedPeakAtdouble-1)*2*pi+ newPhase )';
    newDelt = inputWave - newFit;
    y = fft(newDelt, numBins);
    yMag = abs(y(magPeakNdx));
    ktemp = ktemp + fprintf(' %.6g @ %.6f, ', yMag,  newPhase * 180/pi);
    if ktemp > 100
      ktemp = 0;
      fprintf('\n');
    end
    %stepDirUp = (yMag > last_yMag) + ;%if
    %break when increment is "close enough" in frequency
    aTemp(jtemp) = yMag;
    bTemp(jtemp) = newPhase*180/pi;
    if stepAmount < minStepPhase;
      if yMag > minAmp
        newPhase = phaseOfMinAmp;
        newFit = -gain * sin(x_data*Df*(newfittedPeakAtdouble-1)*2*pi+ newPhase )';
        newDelt = inputWave - newFit;
      end
      break
    end
    % Look for crossing over answer
    if chunking % if we've not had a cross-over
      if yMag > last_2_yMag(2) % if content increased
        chunking = 0; %turn off testing for cross-over
        fprintf('<< *');
        stepDivide = 1/2; %go on now by 1/2
        last_phase = last2_phase;
        lastChunk = 1;
      end %if last_stepDirUp ~= stepDirUp
    end %if chunking
    %new increment:
    stepAmount = stepAmount * stepDivide; 
    %new phase:
    if yMag < minAmp
      phaseOfMinAmp = newPhase;
      minAmp = yMag;
    end
    %if chunking or if the latest magnitude is smaller than that 2 ago...
    if chunking
      newPhase = last_phase + stepDirUp * stepAmount;
    else %if chunking
      if yMag < last_2_yMag(2)
        %if getting closer, keep going
        newPhase = last_phase + stepDirUp * stepAmount;
      else %if yMag < last_2_yMag(2)
        %past the peak.... now which way to steer?
        if yMag < last_2_yMag(1)
          %... answer on this side of the previous answer
          newPhase = last2_phase + stepDirUp * stepAmount;
        else
          %if not chunking & latest magnitude is greater or equal to that 2 ago
          % answer on the other side of the
          newPhase = last2_phase - stepDirUp * stepAmount;
        end
        stepDirUp = -stepDirUp; %reverse direction
      end %if yMag < last_2_yMag(2) else
      %       if lastChunk
      %         lastChunk = 0;
      %         stepDirUp = -stepDirUp; %reverse direction
      %       end
    end %if chunking else
    last2_phase = last_phase;
    last_phase = newPhase;
    last_2_yMag(1) = last_2_yMag(2);
    last_2_yMag(2) = yMag;
    %fittedMagPeakAt = fittedMagPeakAt + stepDirUp * stepAmount;
  end%for jtemp=1:maxLoops
else
  figure(1);
  clf
  plot(newDelt)
  grid
  hold on;
  %
  points_per_period = 1/(Df * newfittedPeakAtdouble) / Dx;
  %[err, errMsg, phase, magnitude, re, im] = edc_DFT(newDelt, 1, numPts, points_per_period, 1);
  y = fft(newDelt, numBins);
  yMag = abs(y(magPeakNdx));
  yFFT = yMag;
  %fprintf('\n 1: mag of single freq DFT %.3g, mag of FFT %.3g', magnitude, yMag);
  legnd = {sprintf('%i %.2f', 1, newPhase*180/pi)};
  jtemp = 11;
  ktemp = 0;
  thisPhase = newPhase;
  for itemp = 2:10000
    newPhase = newPhase + 0.00001;
    thisPhase(itemp) = newPhase;
    legnd(itemp) = {sprintf('%i %.2f', itemp, newPhase*180/pi)};
    newFit = -gain * sin(x_data*Df*(newfittedPeakAtdouble-1)*2*pi+newPhase)';
    newDelt = inputWave - newFit;
    %jtemp = jtemp - 1;
    if ~jtemp
      ktemp = ktemp + 1;
      [colr, lineStyle, colorOrder] = setColorLine(ktemp);
      plot(newDelt,'color', colr, 'LineStyle', lineStyle)
      jtemp = 11;
    end
    %[err, errMsg, phase, magnitude2, re, im] = edc_DFT(newDelt, 1, numPts, points_per_period, 1);
    a = newDelt - mean(newDelt);
    y = fft(newDelt, numBins);
    yMag_2 = abs(y(magPeakNdx));
    yFFT(itemp) = yMag_2;
    if yMag_2 > 2*yFFT(1)
      break
    end
    %fprintf('\n %i: mag of single freq DFT %.3g, change from #1%.3g, RMS of newDelt %.3g, mag of FFT %.3g, change of from #1 FFT %.3g', itemp, magnitude2, magnitude2 - magnitude, norm(a)/sqrt(numPts), yMag_2, (yMag-yMag_2));
  end
  legend(legnd, 0)
  figure(30)
  plot(thisPhase, yFFT,'+')
  grid
end %if 1
return  

  
%playing with FFT: resolution, centering, bins...
Fsine = 20;
nCycles = 10; %number of cycles
Fsample = 20e3;
nSamples = nCycles / Fsine * Fsample;
x_data = EDClinspace(0, 1/Fsample, nSamples);
fundamental = sin(x_data * Fsine *2 * pi)';
harmonic3rd = 0.1*sin(x_data * 3* Fsine *2 * pi)'; %3rd harmonic
y_data = fundamental + harmonic3rd ;
% plot(x_data, y_data)
% grid on 
% hold on
a = round(y_data' * 10^4)/10^4;
%y_data(:, 2) = a';
figure(1)
clf
plot(x_data, y_data)
grid on 
hold on
plot(x_data, fundamental,'r')
plot(x_data, harmonic3rd, 'k')

fftResolution  = 1/ x_data(length(x_data));

% % numBins = 64*8192;
numBins = Fsample / fftResolution + 1;
f = Fsample*(0:numBins/2)/numBins;
fft_y_data = 0;
for itemp = 1:size(y_data, 2)
  Y = fft(y_data(:, itemp),numBins);
  b = [1:length(Y)];
  fft_y_data(b,itemp) = Y;
  all_mag(b,itemp) = abs(Y);
  P = angle(Y);
  % all_theta(b,itemp) = unwrap(P);
end %for itemp = 1:size(y_data, 2)

Df = f(2);

a = [1:length(f)];
mag = all_mag(a, :);
%mag = Y.* conj(Y) / numBins;
mag = mag(1:numBins/2+1);
amplitudeMeasured = max(mag);

rawPeakNdx = find(amplitudeMeasured == mag);
newfittedPeakAt = rawPeakNdx;
frequencyMeasured = (newfittedPeakAt-1) * Df;
searchRange = round(fftResolution/2 / Df);
searchRange = [-searchRange:searchRange];
for harmonic = 2:6
  a = harmonic * round(newfittedPeakAt-1)+ 1 + searchRange;
  mg = max(mag(a));
  amplitudeMeasured(harmonic) = mg/mag(rawPeakNdx) * amplitudeMeasured(1); %%%need to work on this: what is "mag" linear or log or...
  frequencyMeasured(harmonic) = harmonic * frequencyMeasured(1);
end
figure(3)
hold on
clf
semilogy(f, mag/amplitudeMeasured(1))
grid
hold on
amplitudeMeasured(1)/amplitudeMeasured(3),amplitudeMeasured(1)
return


[err, errMsg, failedNames, pongCouplingFailCount, pongCoupFailMsg, pongFreqFailCount, pongFreqFailCountMsg, ...
    zfocusCalcFailCount, focusCalcFailMsg, pingCouplingFailCount, pingCoupFailMsg, ...
    LLFailPongCount, pongLLFailMsg, ZfocusTolerance, pongLLTolerance, ...
    deltaCalcFocus, deltaPongCD, deltaPingCD, deltaLog2PongLL, numLogLinesFocusChecked, ...
    numPingFilesChecked, numPongFilesChecked, LLVersionNames, LLVersionTimestampNames, ...
    LVSWVerNames, LVSWVerTimestampNames, focusCalcFailLiqSOS, zfocusMeasFailCount, focusMeasFailMsg, focusMeasFailLiqSOS, deltaMeasFocus]...
  = checkIfLogNwpbValid;
return

[couplingDistanceAtBestLiquid, liquidToWellBottomTime, focalDistanceInCouplingFluid, sosCoupling, wellBottomThickness] = ...
  sosDetermination(wellXYdft_brstPing, wellXYT_brstPing, z_lens2liqCorrRatioArrayPing, z_lens2PlateCorrRatioArrayPing, ...
  wellXYfocusPing, wellXYmThickPing, wellXYliq_infoPing, wgT_brst);
return

[err, errMsg, dmsoLiqVolExpPing, fluorFigs, dmsoFigs, liqVolFigs] = ...
  dmsoCalc(dmsoLiqLevlExpPing, target2SourceExpPing, exp, dataSetName, amountDispenseTxt, fluorPing, dmsoPing, ...
  includeReadSetsInFit, initialDMSO, initialDMSORows, initFlour, firstFig, weight, sosLiqLevlExpPing, ...
  SOSmx_b, weightConc, wellNoSpotExpPing, wellLoggedExpPing, expDMSOconc, amountDispense);
