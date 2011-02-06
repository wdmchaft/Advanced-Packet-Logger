function [err, errMsg,outHeading] = learnHeading;

err = 0 ;
errMsg = '';
fid = fopen('test.mer'',''r');
if fid > 0
else
  outHeading = {'Zipcode','StreetAddress','State Province 1','City','Address Type 2','Blankets','BlanketsAware','BlanketsAwareComm','BlanketsBudget','BlanketsBudgetComm','BlanketsGov'};
  outHeading = [outHeading, {'BlanketsGovComm','BlanketsNever','BlanketsNeverComm','BlanketsNR','BlanketsOther','BlanketsOtherComm','BlanketsParent'} ] ;
  outHeading = [outHeading, {'BlanketsParentComm','BlanketsPickup','BlanketsPickupComm','BlanketsToDo','BlanketsToDoComm','Capacity','CensusCity','CensusZip'} ] ;
  outHeading = [outHeading, {'Centers Reporting','City Cluster','Contact','ContactFirst','ContactLast','Conversation Notes','date entered','date recieved'} ] ;
  outHeading = [outHeading, {'date resent','DistrictOffice','DOTelephone#','Email','Email Address with Name','Enrollment','EntryKinder_2','Facility Other'} ] ;
  outHeading = [outHeading, {'Facility#','FacilityName','Focus Group','Food','FoodAware','FoodAwareComm','FoodBudget','FoodBudgetComm','FoodGov','FoodGovComm'} ] ;
  outHeading = [outHeading, {'FoodNever','FoodNeverComm','FoodNR','FoodOther','FoodParent','FoodParentComm','FoodPickup','FoodPickupComm','FoodToDo','FoodToDoComm'} ] ;
  outHeading = [outHeading, {'Full Name','K entry','LicenseStatus','Max Age','Min Age','Most Recent Form Layout','New Address','Notes','Number','Raddress','Raise Aware'} ] ;
  outHeading = [outHeading, {'Rcity','Receive Results','Reply Address','Reply City','Reply email','reply enrollment','Reply Facility','Reply FNme','Reply LNme'} ] ;
  outHeading = [outHeading, {'Reply phone','Reply ZIP','Report Results','resend received','Responded','Response In','Returned Undeliverable','Returned:new.updated address'} ] ;
  outHeading = [outHeading, {'Rname','Rstate','Rzip','Scratch','Similar By','Similar Company Key','Similar Name Key','Similars Count','Similars Key','Similars MultiKey'} ] ;
  outHeading = [outHeading, {'Similars Tab Label','Staff','StaffAware','StaffAwareComm','StaffBudget','StaffBudgetComm','StaffGov','StaffGovComm','StaffNever'} ] ;
  outHeading = [outHeading, {'StaffNeverComm','StaffNR','StaffNRComm','StaffOther','StaffPickup','StaffPickupComm','StaffToDo','StaffToDoComm','State Province 2'} ] ;
  outHeading = [outHeading, {'Street 1','Street 2','Telephone'} ] ;
  outHeading = [outHeading, {'Toilet','ToiletAware','ToiletAwareComm','ToiletBudget','ToiletBudgetComm','ToiletGov','ToiletGovComm','ToiletNever','ToiletNeverComm'} ] ;
  outHeading = [outHeading, {'ToiletNR','ToiletNRComm','ToiletOther','ToiletParent','ToiletParentComm','ToiletPickup','ToiletPickupComm','ToiletToDo','ToiletToDoComm'} ] ;
  outHeading = [outHeading, {'Type facility','Water','Water Aware','Water AwareComm','WaterBudget','WaterBudgetComm','WaterGov','WaterGovComm','WaterNever','WaterNeverComm'} ] ;
  outHeading = [outHeading, {'WaterNR','WaterOther','WaterParent','WaterParentComm','WaterPickup','WaterPickupComm','WaterToDo','WaterToDoComm'} ] ;
end
% % 
% % [commasAt',' quotesAt',' spacesAt] = findValidCommas(outHeading);
% % 
% % [err',' errMsg',' Zipcode] = findColumnOfData(outHeading',' 'Zipcode'',' commasAt',' quotesAt',' spacesAt);
% % [err',' errMsg',' StreetAddress] = findColumnOfData(outHeading',' 'StreetAddress'',' commasAt',' quotesAt',' spacesAt);
% % %% [err',' errMsg',' State Province 1] = findColumnOfData(outHeading',' 'State Province 1'',' commasAt',' quotesAt',' spacesAt);
% % [err',' errMsg',' City] = findColumnOfData(outHeading',' 'City'',' commasAt',' quotesAt',' spacesAt);
% % %%[err',' errMsg',' Address Type 2] = findColumnOfData(outHeading',' 'Address Type 2'',' commasAt',' quotesAt',' spacesAt);
% % 
% % categories = {'Blankets'',''Food'',''Water'',''Staff'',''Toilet'};
% % 
% % for itemp = 1:length(categories)
% %   thisCat = char(categories(itemp));
% %   getFieldComma([outHeading, {''',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'Aware'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'AwareComm'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'Budget'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'BudgetComm'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'Gov'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'GovComm'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'Never'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'NeverComm'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'NR'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'Other'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'OtherComm'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'Parent'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'ParentComm'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'Pickup'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'PickupComm'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'ToDo'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% %   getFieldComma([outHeading, {'ToDoComm'',' thisCat)',' outHeading',' commasAt',' quotesAt',' spacesAt);
% % end
% % fprintf('\nstuff');
% % 
% % 
% % function getFieldComma(fieldName',' outHeading',' commasAt',' quotesAt',' spacesAt)
% % 
% % [err',' errMsg',' thisComma] = findColumnOfData(outHeading',' fieldName',' commasAt',' quotesAt',' spacesAt);
% % 
% % assignin('caller'',' [outHeading, {'Comma'',' fieldName)',' thisComma)