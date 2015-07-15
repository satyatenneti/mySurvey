public with sharing class TTISGConfirmationPageController {
    public String submissionId {get; set;}
    public String surveyId {get; set;}
    public String submitterId {get; set;}
    public String confirmationMessage{get; set;}
    
    public TTISGConfirmationPageController () {
        submissionId = ApexPages.currentPage().getParameters().get('Id');
        getSurveyDetails(submissionId.trim());
        confirmationMessage= [select Auto_Response_Message__c from Trifecta_Survey__c where Id =:surveyId].Auto_Response_Message__c;
    }
    private void getSurveyDetails(Id submissionId) {
        Trifecta_Survey_Submission__c surveyRecord = [Select Survey__c, Submitted_To__c from Trifecta_Survey_Submission__c Where Id =:submissionId];
        submitterId = surveyRecord.Submitted_To__c;
        surveyId = surveyRecord.Survey__c;
    }
}