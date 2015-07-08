public with sharing class TTISGConfirmationPageController {
    public String submissionId {get; set;}
    public String surveyId {get; set;}
    public String submitterId {get; set;}
    public String submitterName {get; set;}
    public String confirmationMessage{get; set;}
    public TTISGConfirmationPageController () {
        submissionId = ApexPages.currentPage().getParameters().get('id');
        getSurveyDetails(submissionId.trim());
        confirmationMessage= [select Auto_Response_Message__c from Trifecta_Survey__c where Id =:surveyId].Auto_Response_Message__c;
        if (submitterId.substring(0,3) == schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
            submitterName = [select Name from User where Id =:submitterId.trim()].Name;
        }
        else {
            submitterName = [select Name from Contact where Id =:submitterId.trim()].Name;
        }
    }
    private void getSurveyDetails(Id submissionId) {
        Trifecta_Survey_Submission__c surveyRecord = [Select Survey__c, Submitted_To__c from Trifecta_Survey_Submission__c Where Id =:submissionId];
        submitterId = surveyRecord.Submitted_To__c;
        surveyId = surveyRecord.Survey__c;
    }
}