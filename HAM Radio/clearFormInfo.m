function [form, printedName, printedNamePath] = clearFormInfo;
form.senderMsgNum = '';
form.receiverMsgNum = '';  %don't know how packet will use this but it is on the forms
form.MsgNum = '';
form.date = '' ;
form.time = '' ;
form.comment = '';
form.subject = '' ;
form.replyReq = ''; 
form.replyWhen = ''; 
form.type = '';
form.sitSevere = '' ;
form.handleOrder = '' ;

printedName = ''; 
printedNamePath = ''; 
