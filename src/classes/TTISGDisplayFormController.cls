public with sharing class TTISGDisplayFormController {
    public String surveyId;
    public String submissionId;
    public Trifecta_Survey__c survey {get; set;}
  public List<Trifecta_Survey_Question__c> surveyQuestions {get; set;}
  public Map<String,List<Trifecta_Survey_Question_Choice__c>> surveyQuestionChoices{get; set;}
  public TTISGSurveyService surveyService;
    public List<Trifecta_Survey_Question_Response__c> surveyResponses {get; set;}
    public static final String CONFIRMATION_PAGE_URL = '/apex/Confirmation?id=';
    public Map<String,List<SelectOption>> questionChoices {get; set;}
    public Map<String,String> surveyQuestionChoiceMap{get;set;} 
    public Map<String,List<String>> checkboxChoiceMap {get; set;}
  public Boolean isSubmittedAlready {get; set;}

    public TTISGDisplayFormController() {
        surveyId = ApexPages.currentPage().getParameters().get('Survey');
        submissionId = ApexPages.currentPage().getParameters().get('Id');
        if ([select Completed__c from Trifecta_Survey_Submission__c where Id=:submissionId].Completed__c ) {
        isSubmittedAlready = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This survey form has been submitted already.'));
        } else {
        surveyService = new TTISGSurveyService();
        survey  = surveyService.getSurveyById(surveyId);
        surveyQuestions = survey.Trifecta_Survey_Questions__r;
        surveyQuestionChoices = surveyService.getChoicesPerQuestion(TTISGSObjectUtils.pluckIds(surveyQuestions, 'Id'));  
            
        surveyResponses = new List<Trifecta_Survey_Question_Response__c>(); 
        loadResponseMaps();
        } 
    }

  private void loadResponseMaps () {
    surveyQuestionChoiceMap = new Map<String,String>();
    checkboxChoiceMap = new Map<String, List<String>>();
    questionChoices = new Map<String,List<SelectOption>>();
    for (Trifecta_Survey_Question__c eachQuestion : surveyQuestions) {
      List<SelectOption> tempOptions = new List<SelectOption>();
      if (surveyQuestionChoices.size() != 0 && eachQuestion.Type__c != 'Text' ) {
        for(Trifecta_Survey_Question_Choice__c eachChoice : surveyQuestionChoices.get(eachQuestion.Load_Id__c)){
          tempOptions.add(new SelectOption(eachChoice.Value__c,eachChoice.Value__c));
        }
        questionChoices.put(eachQuestion.Load_Id__c, tempOptions);
      }
      if (eachQuestion.Type__c == 'Checkbox') {
        checkboxChoiceMap.put(eachQuestion.Load_Id__c,new List<String>());
      }
      else {
        surveyQuestionChoiceMap.put(eachQuestion.Load_Id__c,'');
      }
    }
  }
    public PageReference submitSurvey(){
        //Save the survey before the user can be redirected to Send Survey Page
        Trifecta_Survey_Submission__c surveySubmitted = [select id, Completed__c from Trifecta_Survey_Submission__c where Id =:submissionId];
        if(!surveySubmitted.Completed__c) {
          saveResponses();
        PageReference confirmationPage = new PageReference(TTISGDisplayFormController.CONFIRMATION_PAGE_URL+submissionId);
        confirmationPage.setRedirect(true);
        return confirmationPage;
        } else {
          isSubmittedAlready = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This survey form has been submitted already.'));
          return null;
        }        
    }   


    public void saveResponses() {
        Trifecta_Survey_Question_Response__c surveyResponse = new Trifecta_Survey_Question_Response__c();
        for (Trifecta_Survey_Question__c eachResponse: surveyQuestions) {
            if (eachResponse.Type__c == 'Checkbox') {
                surveyResponse = new Trifecta_Survey_Question_Response__c(Survey_Submission__c=submissionId, 
                                Survey_Question__c = eachResponse.Id, 
                                Answer__c = String.join(checkboxChoiceMap.get(eachResponse.Load_Id__c), ','));
            }
            else {
                surveyResponse = new Trifecta_Survey_Question_Response__c(Survey_Submission__c=submissionId, 
                                Survey_Question__c = eachResponse.Id, 
                                Answer__c = surveyQuestionChoiceMap.get(eachResponse.Load_Id__c));
            }
            surveyResponses.add(surveyResponse);
        }
        insert surveyResponses;
        Trifecta_Survey_Submission__c surveySubmitted = [select id, Completed__c from Trifecta_Survey_Submission__c where Id =:submissionId];
        surveySubmitted.Completed__c = true;
        update surveySubmitted;
      Task eachTask = [SELECT Id, WhatId, Status FROM Task WHERE WhatId = :submissionId];
      eachTask.Status = 'Completed';
      update eachTask;
    }
  
  public Boolean getUser() {
    Trifecta_Survey_Submission__c submit = [SELECT Id, Submitted_To__c FROM Trifecta_Survey_Submission__c WHERE Id =:submissionId];
    if (submit.Submitted_To__c.substring(0,3) == Schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
      return false;
    } else {
      return true;
    }
  }
}