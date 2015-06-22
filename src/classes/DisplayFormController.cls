public with sharing class DisplayFormController {
	public String surveyId;
	public String submissionId;
	public Trifecta_Survey__c survey {get; set;}
	public List<Trifecta_Survey_Question__c> surveyQuestions{get; set;}
	public List<Trifecta_Survey_Question_Choice__c> surveyQuestionChoices{get; set;}
	public List<Trifecta_Survey_Question_Response__c> surveyResponses {get; set;}
	public static final String THANKING_YOU_PAGE_URL = '/apex/thankingYou?id=';
    
	public Map<String,String> surveyQuestionChoiceMap{get;set;} 
	public DisplayFormController() {
		surveyId = ApexPages.currentPage().getParameters().get('Survey');
		submissionId = ApexPages.currentPage().getParameters().get('Id');
		TrifectaSurveyController.SurveyWrapper surveyData = TrifectaSurveyControllerHelper.createTrifectaSurveyWrapper(surveyId);
		survey = surveyData.survey;
		surveyQuestions = surveyData.surveyQuestions;
		surveyQuestionChoices = surveyData.surveyQuestionChoices;
	}
	public PageReference submitSurvey(){
        //Save the survey before the user can be redirected to Send Survey Page
        saveResponses();
        PageReference thankingYouPage = 
          new PageReference(DisplayFormController.THANKING_YOU_PAGE_URL+submissionId);
        
        thankingYouPage.setRedirect(true);
        return thankingYouPage;
    }
	public void saveResponses() {
		Trifecta_Survey_Question_Response__c surveyResponse;
		for (String eachResponse: surveyQuestionChoiceMap.keySet()) {
			surveyResponse = new Trifecta_Survey_Question_Response__c(Survey_Submission__c=submissionId, 
									Survey_Question__c = eachResponse, 
									Answer__c = surveyQuestionChoiceMap.get(eachResponse) );
			surveyResponses.add(surveyResponse);
		}
		insert surveyResponses;
	}
}