public with sharing class SendEmailComponentController {
    public String submissionId { get; set; }
    public String senderId { get; set; }
    public String getSurveyURL() {
    	return 'https://login.salesforce.com/apex/displayForm?Id='+submissionId+'&Survey='+getSurveyId(submissionId);
    }
    public String submittedToName {
        get {
            Trifecta_Survey_Submission__c submission = [select Submitted_To__c from Trifecta_Survey_Submission__c where id =:submissionId];
            if (submission.Submitted_To__c != null) {
    	        if (submission.Submitted_To__c.subString(0,3) == schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
    		        return [select Name from User where Id =:submission.Submitted_To__c].Name;
    	        } else if (submission.Submitted_To__c.subString(0,3) == schema.getGlobalDescribe().get('Contact').getDescribe().getKeyPrefix()) {
    		       return [select Name from Contact where Id =:submission.Submitted_To__c].Name;
    	        }
                return submission.Submitted_To__c.subString(0,submission.Submitted_To__c.indexOf('@'));
            }
            return null;
        }
        set;
    }
    public String getSurveyName() {
        return [Select Name from Trifecta_Survey__c where Id =:getSurveyId(submissionId)].Name;
    }
    private Id getSurveyId(Id submissionId) {
    	return [Select Survey__c from Trifecta_Survey_Submission__c Where Id =:submissionId][0].Survey__c;
    }
}