@isTest(seeAllData=false)
private class TTISGTrifectaSurveyControllerTest {
    
    //simulating saving a straight forward survey with Three different type of questions
    @isTest static void saveSurveyTest() {
        
        ApexPages.StandardController controllerInstance = new ApexPages.StandardController(new Trifecta_Survey__c());
        TTISGTrifectaSurveyController testController = new TTISGTrifectaSurveyController(controllerInstance);

        testController.survey = new Trifecta_Survey__c(Name='Sample survey', Auto_Response_Message__c = 'Thank you', 
                                                       Help_Text__c = 'Survey help', Load_Id__c = TTISGGuidUtil.NewGuid(),
                                                       Threshold_Weightage__c = 0);
        testController.getRecordTypes();
        testController.getQuestionTypes();

        Trifecta_Survey_Question_Choice__c tempQuestionChoice;
        Trifecta_Survey_Question__c tempQuestion;

        //===================== Configuring Constructor Provided Question and increasing its choices=================//

        tempQuestion = testController.surveyQuestions[0];

        tempQuestion.Title__c = 'Sample Question 1';
        tempQuestion.Help_Text__c = 'Sample Help Text 1';
        tempQuestion.Type__c = 'Radio Button';

        testController.questionloadId = tempQuestion.Load_Id__c;

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[0];
        tempQuestionChoice.Value__c = 'Choice 1';
        tempQuestionChoice.Weightage__c = 1;

        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[1];
        tempQuestionChoice.Value__c = 'Choice 2';
        tempQuestionChoice.Weightage__c = 2;

        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[2];
        tempQuestionChoice.Value__c = 'Choice 3';
        tempQuestionChoice.Weightage__c = 3;

        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[3];
        tempQuestionChoice.Value__c = 'Choice 4';
        tempQuestionChoice.Weightage__c = 4;
        
        //===================================Start of Ques 2 ========================================================= //

        testController.addNewSurveyQuestion();

        tempQuestion = testController.surveyQuestions[1];

        tempQuestion.Title__c = 'Sample Question 2';
        tempQuestion.Help_Text__c = 'Sample Help Text 2';
        tempQuestion.Type__c = 'Checkbox';
		

		testController.qType = 'Checkbox';	

        testController.changeQuestionType();        

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[0];
        tempQuestionChoice.Value__c = 'Choice 1';
        
        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[1];
        tempQuestionChoice.Value__c = 'Choice 2';
        
        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[2];
        tempQuestionChoice.Value__c = 'Choice 3';
        
        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[3];
        tempQuestionChoice.Value__c = 'Choice 4';
        
        //============================================Start of Ques 3=============================================//

        testController.addNewSurveyQuestion();

        tempQuestion = testController.surveyQuestions[2];

        tempQuestion.Title__c = 'Sample Question 3';
        tempQuestion.Help_Text__c = 'Sample Help Text 3';
        tempQuestion.Type__c = 'Text';

        testController.qType = 'Text';

        testController.changeQuestionType();

        //===================================================================================================//

        System.assertEquals(3,testController.surveyQuestions.size(),'Failed to assert the Size of the Questions for the Survey');
        System.assertEquals(4,testController.surveyQuestionChoiceMap.get(testController.surveyQuestions[0].Load_Id__c).size(),'Failed Assertion the Size of the Choices for the First Radio Question');
    	System.assertEquals(4,testController.surveyQuestionChoiceMap.get(testController.surveyQuestions[1].Load_Id__c).size(),'Failed Assertion the Size of the Choices for the Second Checkbox Question');
    	
    	testController.saveSurvey();

    	System.assertEquals(1 , [Select Count() from Trifecta_Survey__c Where Name='Sample survey'],'Failed for the assertion of the saved survey count');
    	System.assertEquals(3 , [Select Count() from Trifecta_Survey_Question__c Where Survey__c =: testController.survey.Id],'Failed for the assertion count of the Questions for the Survey');
    	System.assertEquals(4, [Select Count() from Trifecta_Survey_Question_Choice__c Where Survey_Question__c =: testController.surveyQuestions[0].Id],'Failed for the assertion of Count of Choices for the Radio button question');
    	System.assertEquals(4, [Select Count() from Trifecta_Survey_Question_Choice__c Where Survey_Question__c =: testController.surveyQuestions[1].Id],'Failed for the assertion of Count of Choices for the Checkbox question');
    	System.assertEquals(0, [Select Count() from Trifecta_Survey_Question_Choice__c Where Survey_Question__c =: testController.surveyQuestions[2].Id],'Failed for the assertion of Count of Choices for the Text Type question');
    }
    
    // simulating Other methods in the class	
    @isTest static void test_method_two() {

        ApexPages.StandardController controllerInstance = new ApexPages.StandardController(new Trifecta_Survey__c());
        TTISGTrifectaSurveyController testController = new TTISGTrifectaSurveyController(controllerInstance);

        testController.survey = new Trifecta_Survey__c(Name='Sample survey', Auto_Response_Message__c = 'Thank you', 
                                                       Help_Text__c = 'Survey help', Load_Id__c = TTISGGuidUtil.NewGuid(),
                                                       Threshold_Weightage__c = 0);
        testController.getRecordTypes();
        testController.getQuestionTypes();

        Trifecta_Survey_Question_Choice__c tempQuestionChoice;
        Trifecta_Survey_Question__c tempQuestion;

        //===================== Configuring Constructor Provided Question and increasing its choices=================//

        tempQuestion = testController.surveyQuestions[0];

        tempQuestion.Title__c = 'Sample Question 1';
        tempQuestion.Help_Text__c = 'Sample Help Text 1';
        tempQuestion.Type__c = 'Radio Button';

        testController.questionloadId = tempQuestion.Load_Id__c;

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[0];
        tempQuestionChoice.Value__c = 'Choice 1';
        tempQuestionChoice.Weightage__c = 1;

        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[1];
        tempQuestionChoice.Value__c = 'Choice 2';
        tempQuestionChoice.Weightage__c = 2;

        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[2];
        tempQuestionChoice.Value__c = 'Choice 3';
        tempQuestionChoice.Weightage__c = 3;

        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[3];
        tempQuestionChoice.Value__c = 'Choice 4';
        tempQuestionChoice.Weightage__c = 4;
        
        //===================================Start of Ques 2 ========================================================= //

        testController.addNewSurveyQuestion();

        tempQuestion = testController.surveyQuestions[1];

        tempQuestion.Title__c = 'Sample Question 2';
        tempQuestion.Help_Text__c = 'Sample Help Text 2';
        tempQuestion.Type__c = 'Checkbox';
        

        testController.qType = 'Checkbox';  

        testController.changeQuestionType();        

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[0];
        tempQuestionChoice.Value__c = 'Choice 1';
        
        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[1];
        tempQuestionChoice.Value__c = 'Choice 2';
        
        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[2];
        tempQuestionChoice.Value__c = 'Choice 3';
        
        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[3];
        tempQuestionChoice.Value__c = 'Choice 4';
        
        //============================================Start of Ques 3=============================================//

        testController.addNewSurveyQuestion();

        tempQuestion = testController.surveyQuestions[2];

        tempQuestion.Title__c = 'Sample Question 3';
        tempQuestion.Help_Text__c = 'Sample Help Text 3';
        tempQuestion.Type__c = 'Text';

        testController.qType = 'Text';

        testController.changeQuestionType();

        //===================================================================================================//

        System.assertEquals(3,testController.surveyQuestions.size(),'Failed to assert the Size of the Questions for the Survey');
        System.assertEquals(4,testController.surveyQuestionChoiceMap.get(testController.surveyQuestions[0].Load_Id__c).size(),'Failed Assertion the Size of the Choices for the First Radio Question');
        System.assertEquals(4,testController.surveyQuestionChoiceMap.get(testController.surveyQuestions[1].Load_Id__c).size(),'Failed Assertion the Size of the Choices for the Second Checkbox Question');
        
        //=============================================Start of Ques 4 (Used for delete Callings)=======================================//

        testController.addNewSurveyQuestion();

        tempQuestion = testController.surveyQuestions[3];

        tempQuestion.Title__c = 'Sample Question 4';
        tempQuestion.Help_Text__c = 'Sample Help Text 4';
        tempQuestion.Type__c = 'Radio Button';

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[0];
        tempQuestionChoice.Value__c = 'Choice 1';
        tempQuestionChoice.Weightage__c = 1;

        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[1];
        tempQuestionChoice.Value__c = 'Choice 2';
        tempQuestionChoice.Weightage__c = 2;

        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[2];
        tempQuestionChoice.Value__c = 'Choice 3';
        tempQuestionChoice.Weightage__c = 3;

        testController.addNewSurveyQuestionChoice();

        tempQuestionChoice = testController.surveyQuestionChoiceMap.get(testController.questionloadId)[3];
        tempQuestionChoice.Value__c = 'Choice 4';
        tempQuestionChoice.Weightage__c = 4;

        testController.choiceLoadId = tempQuestionChoice.Load_Id__c;
        testController.deleteSurveyQuestionChoice(); ////////////////////////////// Deleting Fourth Choice of the Fourth Question

        testController.copyQuestion();    ///////// Copying 4th Question and hence making 5th question out of it

        tempQuestion = testController.surveyQuestions[4];

        tempQuestion.Title__c = 'Sample Question 5';
        tempQuestion.Help_Text__c = 'Sample Help Text 5';     /////////// Configuring 5th Question
        tempQuestion.Type__c = 'Radio Button';

        testController.questionloadId = testController.surveyQuestions[3].Load_Id__c;

        testController.deleteSurveyQuestion();          ///////// deleting 4th question from which 5th was cloned

        System.assertEquals(4,testController.surveyQuestions.size(),'Failed to assert the Size of the Questions for the Survey');
        System.assertEquals(4,testController.surveyQuestionChoiceMap.get(testController.surveyQuestions[0].Load_Id__c).size(),'Failed Assertion the Size of the Choices for the First Radio Question');
        System.assertEquals(4,testController.surveyQuestionChoiceMap.get(testController.surveyQuestions[1].Load_Id__c).size(),'Failed Assertion the Size of the Choices for the Second Checkbox Question');        
        System.assertEquals(3,testController.surveyQuestionChoiceMap.get(testController.surveyQuestions[3].Load_Id__c).size(),'Failed Assertion the Size of the Choices for the Second Checkbox Question');

        testController.oldIndex = 3;
        testController.newIndex = 2;
        testController.updateQuestionOrder();

        testController.oldIndex = 2;
        testController.newIndex = 3;
        testController.updateQuestionOrder();

        testController.oldIndex = 3;
        testController.newIndex = 2;
        testController.updateQuestionOrder();

        testController.questionloadId = testController.surveyQuestions[2].Load_Id__c;
        testController.oldIndex = 2;
        testController.newIndex = 1;
        testController.updateChoiceOrder();

        testController.oldIndex = 1;
        testController.newIndex = 2;
        testController.updateChoiceOrder();      //////////////// Toggling the Question and Choice Orders for the 

        testController.sendSurvey();

        System.assertEquals(1 , [Select Count() from Trifecta_Survey__c Where Name='Sample survey'],'Failed for the assertion of the saved survey count');
        System.assertEquals(4 , [Select Count() from Trifecta_Survey_Question__c Where Survey__c =: testController.survey.Id],'Failed for the assertion count of the Questions for the Survey');
        System.assertEquals(4, [Select Count() from Trifecta_Survey_Question_Choice__c Where Survey_Question__c =: testController.surveyQuestions[0].Id],'Failed for the assertion of Count of Choices for the Radio button question');
        System.assertEquals(4, [Select Count() from Trifecta_Survey_Question_Choice__c Where Survey_Question__c =: testController.surveyQuestions[1].Id],'Failed for the assertion of Count of Choices for the Checkbox question');
        System.assertEquals(3, [Select Count() from Trifecta_Survey_Question_Choice__c Where Survey_Question__c =: testController.surveyQuestions[2].Id],'Failed for the assertion of Count of Radio Button Type question');
        System.assertEquals(0, [Select Count() from Trifecta_Survey_Question_Choice__c Where Survey_Question__c =: testController.surveyQuestions[3].Id],'Failed for the assertion of Count of Choices for the Text Type question');
    }
    
    @isTest
    static void test_method_three() {
        Trifecta_Survey__c survey = TTISGTestUtils.createSurvey('Sample Survey');
        List<Trifecta_Survey_Question__c> surveyQuestions = TTISGTestUtils.createSurveyQuestions(survey.Id);
        List<Id> surveyQuestionIds = TTISGSObjectUtils.pluckIds(surveyQuestions,'Id');
        TTISGTestUtils.createSurveyChoices(surveyQuestionIds);

        PageReference pref = Page.TTISGCreateSurvey;
        pref.getParameters().put('Id',survey.Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController controllerInstance = new ApexPages.StandardController(survey);
        TTISGTrifectaSurveyController testController = new TTISGTrifectaSurveyController(controllerInstance);

        testController.getQuestionTypes();
        testController.getRecordTypes();
        
        pref = testController.cloneSurvey();

        List<Trifecta_Survey__c> surveys = [Select Id,Name,CreatedDate from Trifecta_Survey__c Where Name = 'Sample Survey' AND Load_Id__c !=: survey.Load_Id__c];

        System.assertEquals(true,pref.getUrl().contains('/apex/TTISGCreateSurvey?id='+surveys[0].Id));
        System.assertEquals(2 , [Select Count() from Trifecta_Survey__c Where Name='Sample survey'],'Failed for the assertion of the saved survey count');
     }    
}