global with sharing class TrifectaSurveyController {
    public Trifecta_Survey__c surveyObj{get;set;}
    public List<Trifecta_Survey_Question__c> surveyQuestionsList{get;set;}
    
    public TrifectaSurveyController(ApexPages.StandardController controllerInstance) {
        List<String> fields = new List<String>();
        fields.add('Help_Text__c');
        fields.add('Auto_Response_Message__c');
        controllerInstance.addFields(fields);
        surveyObj = (Trifecta_Survey__c) controllerInstance.getRecord();
        surveyQuestionsList = new List<Trifecta_Survey_Question__c>{new Trifecta_Survey_Question__c(Choices__c='Option 1')};
    }

    public void addNewSurveyQuestion() {
        surveyQuestionsList.add(new Trifecta_Survey_Question__c(Choices__c='Option 1'));
    }   
    
    public ApexPages.PageReference sendSurvey() {
        return null;
    }
    

    public void addSurveyQuestionChoice() {
    }
}