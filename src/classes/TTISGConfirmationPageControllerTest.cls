@isTest
private class TTISGConfirmationPageControllerTest {
	
	@isTest static void pageDisplayTest() {
	Trifecta_Survey__c survey = setData();
        Trifecta_Survey_Submission__c surveySubmission = [SELECT ID FROM Trifecta_Survey_Submission__c WHERE Survey__c = :survey.ID];
        Test.setCurrentPage(Page.TTISGConfirmation);
        ApexPages.currentPage().getParameters().put('Id',surveySubmission.Id);
        TTISGConfirmationPageController confirmationPage = new TTISGConfirmationPageController();

        System.assertEquals(confirmationPage.confirmationMessage, survey.Auto_Response_Message__c, 'Not Equal');
        
	}
	
	private static Trifecta_Survey__c setData() {
	
        Trifecta_Survey__c survey = new Trifecta_Survey__c(Name='new survey', Auto_Response_Message__c = 'thank you', 
        						Help_Text__c = 'survey help', Load_Id__c = TTISGGuidUtil.NewGuid(),
        						Threshold_Weightage__c = 0);
	insert survey;

	Trifecta_Survey_Submission__c surveySubmission = new Trifecta_Survey_Submission__c(Survey__c=survey.id, Submitted_To__c=UserInfo.getUserId());
        insert surveySubmission;

        return survey;
	}
}