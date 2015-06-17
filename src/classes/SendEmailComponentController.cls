public with sharing class SendEmailComponentController {
    public Id submissionId { get; set; }
    public Id senderId { get; set; }
    public String getSurveyURL() {
    	return 'https://login.salesforce.com/apex/displayForm?Id='+submissionId+'&Survey='+getSurveyId(submissionId);
    }
    public String getName() {
    	String personId = [select Submitted_To__c from Trifecta_Survey_Submission__c where id =:submissionId][0].Submitted_To__c;
    	if (personId.subString(0,3) == schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
    		return [select Name from User where Id =:personId][0].Name;
    	}
    	if (personId.subString(0,3) == schema.getGlobalDescribe().get('Contact').getDescribe().getKeyPrefix()) {
    		return [select Name from Contact where Id =:personId][0].Name;
    	}
    	return null;
    }
    private Id getSurveyId(Id submissionId) {
    	return [Select Survey__c from Trifecta_Survey_Submission__c Where Id =:submissionId][0].Survey__c;
    }
}