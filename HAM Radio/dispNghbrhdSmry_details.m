
15 columns as follows:
% Fires=  Gas Leak=  Water Leak=  Electrical=  Chemical=
% Bldg.: Light=  Mod=  Heavy=
% People:Immediate=  Delayed=  Trapped=  Morgue=
% Roads: Access=  No access=  Neighborhood % surveyed=
  Need more column(s)
time of last update
Neighborhood name

currently 12 neighborhoods.  Let's allow room for more of course
Total

need manual entry method to process information received via
  voice

create series of backups - every time a new report comes in.  Keep
  all backups.  Also back up the standard method (i.e. the logs themselves)

  
Deleted the following UI from the figure:
  displayCounts('listboxAllStation_Callback',gcbo,[],guidata(gcbo))
  displayCounts('listboxScoreboard_Callback',gcbo,[],guidata(gcbo))
  displayCounts('listboxScoreboardSumm_Callback',gcbo,[],guidata(gcbo))
  textDetail
  textSummary
  text2
  togglebutton1
  togglebutton2
  togglebutton3
  togglebutton4
  togglebutton5
  togglebutton6
  togglebutton6
  popupmenuWhichLog
  listboxAllStation
  
Code needs to set UI elements to have units as normalized - don't
  do this in Guide because adjusting the basic figure size for designing
  changes all th elements!