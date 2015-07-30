@isTest
public with sharing class TTISGShareLinkTest {
	@testSetup
	static void initItems() {
		Trifecta_Survey__c survey = TTISGTestUtils.createSurvey('Sample Survey');
        List<Trifecta_Survey_Question__c> surveyQuestions = TTISGTestUtils.createSurveyQuestions(survey.Id);
        List<Id> surveyQuestionIds = TTISGSObjectUtils.pluckIds(surveyQuestions,'Id');
        TTISGTestUtils.createSurveyChoices(surveyQuestionIds);
	}

	/*@isTest
	static void testcontactSubmission() {
		Account testAccount = TTISGTestUtils.createAccount('Test Account');
		Contact testContact = TTISGTestUtils.createContact('Test','Rep',testAccount);

		Trifecta_Survey__c survey = [Select Id from Trifecta_Survey__c];
        
        Trifecta_Survey_Submission__c submissionToContact = TTISGTestUtils.createSubmission(survey.Id,testContact.Id,testContact.Name,false);

        List<Trifecta_Survey_Question__c> questions = [Select Id,Type__c from Trifecta_Survey_Question__c Order By Type__c];

        List<Trifecta_Survey_Question_Response__c> responsesForTheSurvey;

    	Trifecta_Survey_Question_Response__c surveyResponse1 = TTISGTestUtils.createResponseForQuestion( submissionToContact.Id,questions[0].Id,'CheckBoxOption1');
    	Trifecta_Survey_Question_Response__c surveyResponse2 = TTISGTestUtils.createResponseForQuestion( submissionToContact.Id,questions[1].Id,'RadioButtonOption1');
    	Trifecta_Survey_Question_Response__c surveyResponse3 = TTISGTestUtils.createResponseForQuestion( submissionToContact.Id,questions[2].Id,'Sample Answer');
    	
    	responsesForTheSurvey = new List<Trifecta_Survey_Question_Response__c>{surveyResponse1,surveyResponse2,surveyResponse3};
    	insert responsesForTheSurvey;

    	submissionToContact.Completed__c = true;
    	update submissionToContact;

    	PageReference pref = Page.TTISGShareLinkPage;
    	pref.getParameters().put('Survey',survey.Id);
    	pref.getParameters().put('id',submissionToContact.Id);
    	Test.setCurrentPage(pref);

    	new TTISGShareLinkPageController().createChatterPostAndRedirect();

    	System.assertEquals(1,[Select Count() from FeedItem],'Asserting for the Feed Item getting inserted');
    	System.assertEquals(1,[Select Count() from Attachment],'Asserting for the Attachment getting inserted'); 
    }*/
}