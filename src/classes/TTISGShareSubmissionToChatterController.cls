public with sharing class TTISGShareSubmissionToChatterController {
    
    public String surveyId;
    public String submissionId;
    
    public TTISGSurveyService surveyService;
    
    public Trifecta_Survey__c survey {get; set;}
    public Trifecta_Survey_Submission__c surveySubmitted{get;set;}
    public List<Trifecta_Survey_Question__c> surveyQuestions {get; set;}
    
    public Map<String,Trifecta_Survey_Question_Response__c> surveyResponses {get; set;}
    
    
    public Map<String,String> surveyQuestionChoiceMap{get;set;} 
    public Map<String,List<String>> checkboxChoiceMap {get; set;}

    public TTISGShareSubmissionToChatterController() {
        surveyId = ApexPages.currentPage().getParameters().get('Survey');
        submissionId = ApexPages.currentPage().getParameters().get('Id');

        surveySubmitted = [select Id, Submitted_To__c, Completed__c from Trifecta_Survey_Submission__c where Id =:submissionId];

        surveyService = new TTISGSurveyService();
        
    	survey = surveyService.getSurveyById(surveyId); 
    	surveyQuestions = survey.Trifecta_Survey_Questions__r;
    	surveyResponses = surveyService.getSurveySubmissionResponses(submissionId);

    }
}