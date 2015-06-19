public interface EmailService {
	void sendEmailNotifications (List<Trifecta_Survey_Submission__c> submissions, Id SurveyId);
}