public with sharing class SendSurveyController {
    private final Trifecta_Survey__c survey;
    public SendSurveyController() {
        survey = [select name, Auto_Response_Message__c, Description__c, Help_Text__c, Load_Id__c, Survey_Type__c, 
        		 (select Submitted_To__c from Trifecta_Survey_Submissions__r )from Trifecta_Survey__c where id = :ApexPages.currentPage().getParameters().get('id')];
    }
    public Trifecta_Survey__c getSurveyById() {
        return null;
    }
    public list<Id> getActiveUsers() {
        return null;
    }
    public list<Id> getContacts() {
        return null;
    }
    public list<Id> getGroups() {
        return null;
    }
    public void sendForm() {
    }
}