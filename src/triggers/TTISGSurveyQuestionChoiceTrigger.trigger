trigger TTISGSurveyQuestionChoiceTrigger on Trifecta_Survey_Question_Choice__c (before delete) {

	Trifecta_Survey_Question_Choice__c surveyQuestionChoice;
	Trifecta_Survey_Question__c surveyQuestionForTheChoice;
    Trifecta_Survey__c surveyForTheQuestion;
    String userMessage;

    if(Trigger.isBefore && Trigger.isDelete) {
        surveyQuestionChoice = Trigger.old[0];
        surveyQuestionForTheChoice = [Select Id,Survey__c from Trifecta_Survey_Question__c Where Id =:surveyQuestionChoice.Survey_Question__c];
        surveyForTheQuestion = new TTISGSurveyService().getSurveyById(surveyQuestionForTheChoice.Survey__c);
        
        userMessage = TTISGSurveyUtils.checkForRecordOwnership(surveyForTheQuestion.OwnerId,UserInfo.getUserId(),'Delete');
        if(userMessage != null) {
            surveyQuestionChoice.addError(userMessage);
        }
    }
}