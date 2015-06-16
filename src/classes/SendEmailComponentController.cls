public with sharing class SendEmailComponentController {
    public Id submissionId { get; set; }
    public Id senderId { get; set; }
    public String getSurveyURL() {
    	return 'https://login.salesforce.com/apex/displayForm?Id='+submissionId+'&Survey='+getSurveyId(submissionId);
    }
    private Id getSurveyId(Id submissionId) {
    	return [Select Survey__c from Trifecta_Survey_Submission__c Where Id =:submissionId][0].Survey__c;
    }
}