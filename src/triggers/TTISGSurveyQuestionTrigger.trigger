trigger TTISGSurveyQuestionTrigger on Trifecta_Survey_Question__c (before delete) {

    Trifecta_Survey_Question__c surveyQuestion;
    Trifecta_Survey__c surveyForTheQuestion;
    String userMessage;

    if(Trigger.isBefore && Trigger.isDelete) {
        surveyQuestion = Trigger.old[0];
        surveyForTheQuestion = new TTISGSurveyService().getSurveyById(surveyQuestion.Survey__c);
        
        userMessage = TTISGSurveyUtils.checkForRecordOwnership(surveyForTheQuestion.OwnerId,UserInfo.getUserId(),'Delete');
        
        if(userMessage != null) {
            surveyQuestion.addError(userMessage);
        }
    }
}