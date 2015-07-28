trigger TTISurveyLockStatus on Trifecta_Survey__c (before update) {
    for(Trifecta_Survey__c survey : trigger.new) {
		
		Integer count = [SELECT count() FROM Trifecta_Survey_Submission__c where Survey__c  = :survey.Id and Completed__c = false];
		if(count>0) {
			survey.addError('This Survey has been locked for responses. You cannot make any changes.');
		}
	}
}