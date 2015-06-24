public with sharing class DisplayFormController {
	public String surveyId;
 	public String submissionId;
 	public Trifecta_Survey__c survey {get; set;}
 	public Map<String,Trifecta_Survey_Question__c> surveyQuestions{get; set;}
 	public Map<String,List<Trifecta_Survey_Question_Choice__c>> surveyQuestionChoices{get; set;}
 	public List<Trifecta_Survey_Question_Response__c> surveyResponses {get; set;}
 	public static final String THANKING_YOU_PAGE_URL = '/apex/ThankingYou?id=';
 	public Map<String,List<SelectOption>> questionChoices {get; set;}
 	public Map<String,String> surveyQuestionChoiceMap{get;set;} 
 	public Map<String,List<String>> checkboxChoiceMap {get; set;}

 	public DisplayFormController() {
  		surveyId = ApexPages.currentPage().getParameters().get('Survey');
  		submissionId = ApexPages.currentPage().getParameters().get('Id');
  		if ([select Completed__c from Trifecta_Survey_Submission__c where Id=:submissionId].Completed__c ) {
  			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your Survey form has been successfully submitted.'));
  		} else {
  			TrifectaSurveyController.SurveyWrapper surveyData = TrifectaSurveyControllerHelper.createTrifectaSurveyWrapper(surveyId);
  			survey = surveyData.survey;
  			surveyQuestions = surveyData.surveyQuestions;
  			if (surveyQuestions.size() == 1) {
  				List<Trifecta_Survey_Question__c> tempQuestion = surveyQuestions.values();
  				if (tempQuestion[0].Type__c == 'Text') {
  					surveyQuestionChoices = new Map<String, List<Trifecta_Survey_Question_Choice__c>>();
	  			} else {
  					surveyQuestionChoices = surveyData.surveyQuestionChoices;
  				}
  			} else {
	  			surveyQuestionChoices = surveyData.surveyQuestionChoices;
  			}
  			surveyQuestionChoiceMap = new Map<String,String>();
  			checkboxChoiceMap = new Map<String, List<String>>();
	  		questionChoices = new Map<String,List<SelectOption>>();
  			surveyResponses = new List<Trifecta_Survey_Question_Response__c>();
  			for (String eachQuestionId : surveyQuestions.keySet()) {
   				List<SelectOption> tempOptions = new List<SelectOption>();
	   			if (surveyQuestionChoices.size() != 0) {
		   			for(Trifecta_Survey_Question_Choice__c eachChoice : surveyQuestionChoices.get(eachQuestionId)){
	    				tempOptions.add(new SelectOption(eachChoice.Value__c,eachChoice.Value__c));
   					}
   					questionChoices.put(eachQuestionId, tempOptions);
	   			}
	   			if (surveyQuestions.get(eachQuestionId).Type__c == 'Checkbox') {
	   				checkboxChoiceMap.put(eachQuestionId,new List<String>());
	   			}
	   			else {
   					surveyQuestionChoiceMap.put(eachQuestionId,'');
   				}
  			}	
 		} 
 	}
	public PageReference submitSurvey(){
        //Save the survey before the user can be redirected to Send Survey Page
        saveResponses();
        PageReference thankingYouPage = new PageReference(DisplayFormController.THANKING_YOU_PAGE_URL+submissionId);
        thankingYouPage.setRedirect(true);
        return thankingYouPage;
  	}	


	public void saveResponses() {
  		Trifecta_Survey_Question_Response__c surveyResponse = new Trifecta_Survey_Question_Response__c();
  		for (String eachResponse: surveyQuestionChoiceMap.keySet()) {
  			if (surveyQuestions.get(eachResponse).Type__c == 'Checkbox') {
  				surveyResponse = new Trifecta_Survey_Question_Response__c(Survey_Submission__c=submissionId, 
       							Survey_Question__c = surveyQuestions.get(eachResponse).Id, 
       							Answer__c = String.join(checkboxChoiceMap.get(eachResponse), ','));
  			}
  			else {
  				surveyResponse = new Trifecta_Survey_Question_Response__c(Survey_Submission__c=submissionId, 
       							Survey_Question__c = surveyQuestions.get(eachResponse).Id, 
       							Answer__c = surveyQuestionChoiceMap.get(eachResponse));
  			}
  			surveyResponses.add(surveyResponse);
  		}
  		insert surveyResponses;
  		Trifecta_Survey_Submission__c surveySubmitted = [select id, Completed__c from Trifecta_Survey_Submission__c where Id =:submissionId];
  		surveySubmitted.Completed__c = true;
  		update surveySubmitted;
 	}
}