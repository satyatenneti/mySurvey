@isTest
public with sharing class TTISGTestUtils {
	
	public static Trifecta_Survey__c createSurvey(String surveyName) {
    	
    	Trifecta_Survey__c survey = new Trifecta_Survey__c(Name = surveyName, Auto_Response_Message__c = 'Thank You', 
                                  						   Help_Text__c = 'Test Help', Load_Id__c = TTISGGuidUtil.NewGuid(),
                                  						   Threshold_Weightage__c = 0, Is_Anonymous__c = false);
    	insert survey;
    	return survey;
  	}

  	public static List<Trifecta_Survey_Question__c> createSurveyQuestions(Id surveyId) {
  		
  		Trifecta_Survey_Question__c radioQuestion = new Trifecta_Survey_Question__c(Title__c = 'Radio Button question', 
                                              										Type__c = TTISGSurveyUtils.QUESTION_TYPE_RADIO, 
                                              										isRequired__c = true, 
                                              										Load_Id__c = TTISGGuidUtil.NewGuid(), 
                                              										Help_text__c = 'Radio button question help text', 
                                              										Survey__c = surveyId);

        Trifecta_Survey_Question__c checkQuestion = new Trifecta_Survey_Question__c(Title__c = 'Check Box question', 
                                              										Type__c = TTISGSurveyUtils.QUESTION_TYPE_CHECKBOX, 
                                              										isRequired__c = true, 
                                              										Load_Id__c = TTISGGuidUtil.NewGuid(), 
                                              										Help_text__c = 'Check Box question help text', 
                                              										Survey__c = surveyId);

        Trifecta_Survey_Question__c textQuestion = new Trifecta_Survey_Question__c(Title__c = TTISGSurveyUtils.DEFAULT_QUESTION_TITLE, 
        																		   Type__c = TTISGSurveyUtils.QUESTION_TYPE_TEXT, 
                                              									   isRequired__c = true, 
                                              									   Load_Id__c = TTISGGuidUtil.NewGuid(), 
                                              									   Help_text__c = 'Text question help text', 
                                              									   Survey__c = surveyId);

        List<Trifecta_Survey_Question__c> questionList = new List<Trifecta_Survey_Question__c>{radioQuestion,checkQuestion,textQuestion};
        insert questionList;
        return questionList;
  	}

  	public static List<Trifecta_Survey_Question_Choice__c> createSurveyChoices(List<Id> questionIds) {
  		
        Trifecta_Survey_Question_Choice__c radioButtonOption1 = new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(), 
                                                        											   Value__c = 'RadioButtonOption1', 
                                                        											   Weightage__c = 2, 
                                                        											   Survey_Question__c = questionIds[0]);

        Trifecta_Survey_Question_Choice__c radioButtonOption2 = new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(), 
                                                        											   Value__c = 'RadioButtonOption2', 
                                                        											   Weightage__c = 4, 
                                                        											   Survey_Question__c = questionIds[0]);

        Trifecta_Survey_Question_Choice__c checkBoxOption1 = new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(), 
                                                        											Value__c = 'CheckBoxOption1', 
                                                        											Survey_Question__c = questionIds[1]);

        Trifecta_Survey_Question_Choice__c checkBoxOption2 = new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(), 
                                                        											Value__c = 'CheckBoxOption2', 
                                                        											Survey_Question__c = questionIds[1]);

        List<Trifecta_Survey_Question_Choice__c> choiceList = new List<Trifecta_Survey_Question_Choice__c>{radioButtonOption1,radioButtonOption2,
        																								   checkBoxOption1,checkBoxOption2};

        insert choiceList;
  		return choiceList;
  	}
	
	public static Account createAccount(String accName) { 
        Account testAcc = new Account(Name=accName); 
        insert testAcc;
        return testAcc;
    }
    public static Contact createContact(String firstName,String lastName,Account acc) {
        Contact testContact = new Contact(AccountId= acc.Id,LastName=lastName,FirstName=firstName);
        insert testContact;
        return testContact;
    }

    public static Trifecta_Survey_Question_Response__c createResponseForQuestion(Id submissionId,Id questionId,String answer) {
        Trifecta_Survey_Question_Response__c responseToReturn = new Trifecta_Survey_Question_Response__c();
        responseToReturn.Survey_Submission__c = submissionId;
        responseToReturn.Survey_Question__c = questionId;
        responseToReturn.Answer__c = answer;
        return responseToReturn;
    }

    public static Trifecta_Survey_Submission__c createSubmission(Id surveyId,Id submittedToId,String submittedToName,Boolean isCompleted) {
        Trifecta_Survey_Submission__c submission = new Trifecta_Survey_Submission__c();
        submission.Survey__c = surveyId;
        submission.Submitted_To__c = submittedToId;
        submission.Submitted_To_Name__c = submittedToName;
        submission.Completed__c = isCompleted;
        insert submission;
        return submission;
    }
}