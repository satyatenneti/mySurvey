public interface TTISGEmailService {
    void sendInternalEmailNotifications (List<Trifecta_Survey_Submission__c> submissions, Id SurveyId);
    void sendExternalEmailNotifications (List<Trifecta_Survey_Submission__c> submissions, Id SurveyId);
}