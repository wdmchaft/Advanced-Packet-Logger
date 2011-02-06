function [err, errMsg, outHeading] = createHeading;


outHeading = 'Zipcode,StreetAddress,State Province 1,City,Address Type 2,Blankets,BlanketsAware,BlanketsAwareComm,BlanketsBudget,BlanketsBudgetComm,BlanketsGov,';
outHeading = sprintf('%sBlanketsGovComm,BlanketsNever,BlanketsNeverComm,BlanketsNR,BlanketsOther,BlanketsOtherComm,BlanketsParent,', outHeading );
outHeading = sprintf('%sBlanketsParentComm,BlanketsPickup,BlanketsPickupComm,BlanketsToDo,BlanketsToDoComm,Capacity,CensusCity,CensusZip,', outHeading );
outHeading = sprintf('%sCenters Reporting,City Cluster,Contact,ContactFirst,ContactLast,Conversation Notes,date entered,date recieved,', outHeading );
outHeading = sprintf('%sdate resent,DistrictOffice,DOTelephone#,Email,Email Address with Name,Enrollment,EntryKinder_2,Facility Other,', outHeading );
outHeading = sprintf('%sFacility#,FacilityName,Focus Group,Food,FoodAware,FoodAwareComm,FoodBudget,FoodBudgetComm,FoodGov,FoodGovComm,', outHeading );
outHeading = sprintf('%sFoodNever,FoodNeverComm,FoodNR,FoodOther,FoodParent,FoodParentComm,FoodPickup,FoodPickupComm,FoodToDo,FoodToDoComm,', outHeading );
outHeading = sprintf('%sFull Name,K entry,LicenseStatus,Max Age,Min Age,Most Recent Form Layout,New Address,Notes,Number,Raddress,Raise Aware,', outHeading );
outHeading = sprintf('%sRcity,Receive Results,Reply Address,Reply City,Reply email,reply enrollment,Reply Facility,Reply FNme,Reply LNme,', outHeading );
outHeading = sprintf('%sReply phone,Reply ZIP,Report Results,resend received,Responded,Response In,Returned Undeliverable,Returned:new.updated address,', outHeading );
outHeading = sprintf('%sRname,Rstate,Rzip,Scratch,Similar By,Similar Company Key,Similar Name Key,Similars Count,Similars Key,Similars MultiKey,', outHeading );
outHeading = sprintf('%sSimilars Tab Label,Staff,StaffAware,StaffAwareComm,StaffBudget,StaffBudgetComm,StaffGov,StaffGovComm,StaffNever,', outHeading );
outHeading = sprintf('%sStaffNeverComm,StaffNR,StaffNRComm,StaffOther,StaffPickup,StaffPickupComm,StaffToDo,StaffToDoComm,State Province 2,', outHeading );
outHeading = sprintf('%sStreet 1,Street 2,Telephone,', outHeading );
outHeading = sprintf('%sToilet,ToiletAware,ToiletAwareComm,ToiletBudget,ToiletBudgetComm,ToiletGov,ToiletGovComm,ToiletNever,ToiletNeverComm,', outHeading );
outHeading = sprintf('%sToiletNR,ToiletNRComm,ToiletOther,ToiletParent,ToiletParentComm,ToiletPickup,ToiletPickupComm,ToiletToDo,ToiletToDoComm,', outHeading );
outHeading = sprintf('%sType facility,Water,Water Aware,Water AwareComm,WaterBudget,WaterBudgetComm,WaterGov,WaterGovComm,WaterNever,WaterNeverComm,', outHeading );
outHeading = sprintf('%sWaterNR,WaterOther,WaterParent,WaterParentComm,WaterPickup,WaterPickupComm,WaterToDo,WaterToDoComm', outHeading );

[commasAt, quotesAt, spacesAt] = findValidCommas(outHeading);

[err, errMsg, Zipcode] = findColumnOfData(outHeading, 'Zipcode', commasAt, quotesAt, spacesAt);
[err, errMsg, StreetAddress] = findColumnOfData(outHeading, 'StreetAddress', commasAt, quotesAt, spacesAt);
%% [err, errMsg, State Province 1] = findColumnOfData(outHeading, 'State Province 1', commasAt, quotesAt, spacesAt);
[err, errMsg, City] = findColumnOfData(outHeading, 'City', commasAt, quotesAt, spacesAt);
%%[err, errMsg, Address Type 2] = findColumnOfData(outHeading, 'Address Type 2', commasAt, quotesAt, spacesAt);

categories = {'Blankets','Food','Water','Staff','Toilet'};

for itemp = 1:length(categories)
  thisCat = char(categories(itemp));
  getFieldComma(sprintf('%s', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sAware', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sAwareComm', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sBudget', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sBudgetComm', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sGov', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sGovComm', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sNever', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sNeverComm', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sNR', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sOther', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sOtherComm', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sParent', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sParentComm', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sPickup', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sPickupComm', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sToDo', thisCat), outHeading, commasAt, quotesAt, spacesAt);
  getFieldComma(sprintf('%sToDoComm', thisCat), outHeading, commasAt, quotesAt, spacesAt);
end
fprintf('\nstuff');


function getFieldComma(fieldName, outHeading, commasAt, quotesAt, spacesAt)

[err, errMsg, thisComma] = findColumnOfData(outHeading, fieldName, commasAt, quotesAt, spacesAt);

assignin('caller', sprintf('%sComma', fieldName), thisComma)