public with sharing class SendEmailComponentController {
    public String submissionId { get; set; }
    public String senderId { get; set; }
    public String SurveyURL{get; set;}
    public String submittedToName {
        get {
            Trifecta_Survey_Submission__c submission = [select Submitted_To__c from Trifecta_Survey_Submission__c where id =:submissionId];
            if (submission.Submitted_To__c != null) {
                if (submission.Submitted_To__c.subString(0,3) == schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
                    SurveyURL = 'https://login.salesforce.com/apex/displayForm?Id='+submissionId+'&Survey='+getSurveyId(submissionId);
                    return [select Name from User where Id =:submission.Submitted_To__c].Name;
                }
                else {
                    String siteAddress = [Select Site_Address__c from Survey_Global_Settings__c].Site_Address__c;
                    SurveyURL = siteAddress +'displayForm?Id='+submissionId+'&Survey='+getSurveyId(submissionId);
                    return [select Name from Contact where Id =:submission.Submitted_To__c].Name;
                }
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