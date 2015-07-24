@isTest
private class TTISGDisplayFormControllerTest {
	
	@isTest public static void validUserSubmission() {
	Trifecta_Survey__c survey = setData();
        
        Trifecta_Survey_Submission__c surveySubmission = [SELECT ID FROM Trifecta_Survey_Submission__c WHERE Survey__c = :survey.ID];
        
        Test.setCurrentPage(Page.TTISGDisplayForm);
        ApexPages.currentPage().getParameters().put('Survey',survey.Id);
        ApexPages.currentPage().getParameters().put('Id',surveySubmission.Id);
        
        TTISGDisplayFormController displayForm = new TTISGDisplayFormController();
        
        
        displayForm.submitSurvey();

        List<Trifecta_Survey_Question_Response__c> responseList = [SELECT Id FROM Trifecta_Survey_Question_Response__c WHERE Survey_Submission__c = :surveySubmission.Id];
        System.assertEquals(3, responseList.size(), 'no.of responses are not equal to questions');
        
        Boolean validUser = displayForm.getUser();

	}

	@isTest public static void validContactSubmission() {
	Trifecta_Survey__c survey = setData();
        Trifecta_Survey_Submission__c surveySubmission = [SELECT ID FROM Trifecta_Survey_Submission__c WHERE Survey__c = :survey.ID];

        Contact newContact = new Contact(LastName ='pavan kumar', Email ='test@test.com');
        insert newContact;

        surveySubmission.Submitted_To__c = newContact.Id;
        update surveySubmission;

        Test.setCurrentPage(Page.TTISGDisplayForm);
        ApexPages.currentPage().getParameters().put('Survey',survey.Id);
        ApexPages.currentPage().getParameters().put('Id',surveySubmission.Id);
        
        TTISGDisplayFormController displayForm = new TTISGDisplayFormController();
        displayForm.submitSurvey();

        List<Trifecta_Survey_Question_Response__c> responseList = [SELECT Id FROM Trifecta_Survey_Question_Response__c WHERE Survey_Submission__c = :surveySubmission.Id];
        System.assertEquals(3, responseList.size(), 'no.of responses are not equal to questions');
        
	}

	@isTest public static void invalidURLTest() {
	Trifecta_Survey__c survey = setData();
        Trifecta_Survey_Submission__c surveySubmission = [SELECT ID FROM Trifecta_Survey_Submission__c WHERE Survey__c = :survey.ID];
        Test.setCurrentPage(Page.TTISGDisplayForm);
        
        TTISGDisplayFormController displayForm = new TTISGDisplayFormController();

        System.assertEquals(true, ApexPages.hasMessages(), 'invalid URL');

	}

	@isTest public static void alreadySubmittedTest() {
	Trifecta_Survey__c survey = setData();
        Trifecta_Survey_Submission__c surveySubmission = [SELECT ID FROM Trifecta_Survey_Submission__c WHERE Survey__c = :survey.ID];
        surveySubmission.Completed__c = true;
        update surveySubmission;

        Test.setCurrentPage(Page.TTISGDisplayForm);
        ApexPages.currentPage().getParameters().put('Survey',survey.Id);
        ApexPages.currentPage().getParameters().put('Id',surveySubmission.Id);

        TTISGDisplayFormController displayForm = new TTISGDisplayFormController();
        displayForm.submitSurvey();

        System.assertEquals(true, ApexPages.hasMessages(), 'submiited already');


	}

	private static Trifecta_Survey__c setData() {
	
        Trifecta_Survey__c survey = new Trifecta_Survey__c(Name='new survey', Auto_Response_Message__c = 'thank you', 
        						Help_Text__c = 'survey help', Load_Id__c = TTISGGuidUtil.NewGuid(),
        						Threshold_Weightage__c = 0);
	insert survey;
	Trifecta_Survey_Question__c radioQuestion = new Trifecta_Survey_Question__c(Title__c = 'Radio Button question', 
										Type__c = TTISGSurveyUtils.QUESTION_TYPE_RADIO, isRequired__c = true, 
										Load_Id__c = TTISGGuidUtil.NewGuid(), 
										Help_text__c = 'Radio button question help text', Survey__c = survey.Id);
        Trifecta_Survey_Question__c checkQuestion = new Trifecta_Survey_Question__c(Title__c = 'Check Box question', 
										Type__c = 'Checkbox', isRequired__c = true, 
										Load_Id__c = TTISGGuidUtil.NewGuid(), 
										Help_text__c = 'Check Box question help text', Survey__c = survey.Id);
        Trifecta_Survey_Question__c textQuestion = new Trifecta_Survey_Question__c(Title__c = TTISGSurveyUtils.DEFAULT_QUESTION_TITLE, Type__c = 'Text', 
        									isRequired__c = true, Load_Id__c = TTISGGuidUtil.NewGuid(), 
        									Help_text__c = 'Text question help text', Survey__c = survey.Id);
        List<Trifecta_Survey_Question__c> questionList = new List<Trifecta_Survey_Question__c>();
        questionList.add(radioQuestion);
        questionList.add(checkQuestion);
        questionList.add(textQuestion);
        insert questionList;
        List<Trifecta_Survey_Question_Choice__c> choiceList = new List<Trifecta_Survey_Question_Choice__c>();
        Trifecta_Survey_Question_Choice__c radioButtonOption1 = new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(), 
        											Value__c = 'radioButtonOption1', 
        											Weightage__c = 2, Survey_Question__c = radioQuestion.Id );
        Trifecta_Survey_Question_Choice__c radioButtonOption2 = new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(), 
        											Value__c = 'radioButtonOption2', 
        											Weightage__c = 4, Survey_Question__c = radioQuestion.Id);
        Trifecta_Survey_Question_Choice__c checkBoxOption1 = new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(), 
        											Value__c = 'checkBoxOption1', Survey_Question__c = checkQuestion.Id);
        Trifecta_Survey_Question_Choice__c checkBoxOption2 = new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(), 
        											Value__c = 'checkBoxOption2', Survey_Question__c = checkQuestion.Id);
        choiceList.add(radioButtonOption1);
        choiceList.add(radioButtonOption2);
        choiceList.add(checkBoxOption1);
        choiceList.add(checkBoxOption2);
        insert choiceList;

        Trifecta_Survey_Submission__c surveySubmission = new Trifecta_Survey_Submission__c(Survey__c=survey.id, Submitted_To__c=UserInfo.getUserId());
        insert surveySubmission;

        return survey;
	}
}