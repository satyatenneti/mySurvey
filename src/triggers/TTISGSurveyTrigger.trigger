trigger TTISGSurveyTrigger on Trifecta_Survey__c (before delete) {
	
	Trifecta_Survey__c surveyRec;
	String userMessage;

	if(Trigger.isBefore && Trigger.isDelete) {
		surveyRec = Trigger.old[0];
		userMessage = TTISGSurveyUtils.checkForRecordOwnership(surveyRec.OwnerId,UserInfo.getUserId(),'Delete');
		
		if(userMessage != null) {
			surveyRec.addError(userMessage);
		}
	}
}
