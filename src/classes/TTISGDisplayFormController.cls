public with sharing class TTISGDisplayFormController {
    public String surveyId;
    public String submissionId;
    
    public TTISGSurveyService surveyService;
    public Boolean isSubmittedAlready {get; set;}
    
    public static final String USER_CONFIRMATION_PAGE_URL = '/apex/TTISGConfirmation?id=';
    
    public Trifecta_Survey__c survey {get; set;}
    public List<Trifecta_Survey_Question__c> surveyQuestions {get; set;}
    public Map<String,List<Trifecta_Survey_Question_Choice__c>> surveyQuestionChoices{get; set;}
    
    public List<Trifecta_Survey_Question_Response__c> surveyResponses {get; set;}
    
    public Map<String,List<SelectOption>> questionChoices {get; set;}
    
    public Map<String,String> surveyQuestionChoiceMap{get;set;} 
    public Map<String,List<String>> checkboxChoiceMap {get; set;}
    

    public TTISGDisplayFormController() {
        surveyId = ApexPages.currentPage().getParameters().get('Survey');
        submissionId = ApexPages.currentPage().getParameters().get('Id');
        
        surveyService = new TTISGSurveyService();
        surveyResponses = new List<Trifecta_Survey_Question_Response__c>(); 
        
        if ([select Completed__c from Trifecta_Survey_Submission__c where Id=:submissionId].Completed__c ) {
            isSubmittedAlready = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This survey form has been submitted already.'));
        } else {
            survey  = surveyService.getSurveyById(surveyId);
            surveyQuestions = survey.Trifecta_Survey_Questions__r;
            surveyQuestionChoices = surveyService.getChoicesPerQuestion(TTISGSObjectUtils.pluckIds(surveyQuestions, 'Id'));  
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
        Trifecta_Survey_Submission__c surveySubmitted = [select id, Submitted_To__c, Completed__c from Trifecta_Survey_Submission__c where Id =:submissionId];
        if(!surveySubmitted.Completed__c) {
            saveResponses();
            PageReference confirmationPage;
            if (surveySubmitted.Submitted_To__c.substring(0,3) == Schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix() ) {
                confirmationPage = new PageReference(TTISGDisplayFormController.USER_CONFIRMATION_PAGE_URL+submissionId);
            } else {
                confirmationPage = new PageReference('http://ttidevfull-trifecta.cs14.force.com/SurveyGuru/TTISGConfirmation?id='+submissionId);
            }
            confirmationPage.setRedirect(true);
            return confirmationPage;
        } else {
             isSubmittedAlready = true;
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This survey form has been submitted already.'));
             return null;
        }        
    }   

    public void saveResponses() {
        surveyResponses = new List<Trifecta_Survey_Question_Response__c>();
        Trifecta_Survey_Question_Response__c surveyResponse = new Trifecta_Survey_Question_Response__c();
        
        for (Trifecta_Survey_Question__c eachQuestion: surveyQuestions) {
            if (eachQuestion.Type__c == 'Checkbox') {
                surveyResponse = new Trifecta_Survey_Question_Response__c(Survey_Submission__c=submissionId, 
                                Survey_Question__c = eachQuestion.Id, 
                                Answer__c = String.join(checkboxChoiceMap.get(eachQuestion.Load_Id__c), ','));
            } else {
                surveyResponse = new Trifecta_Survey_Question_Response__c(Survey_Submission__c=submissionId, 
                                Survey_Question__c = eachQuestion.Id, 
                                Answer__c = surveyQuestionChoiceMap.get(eachQuestion.Load_Id__c));
            }
            surveyResponses.add(surveyResponse);
        }
        insert surveyResponses;
        Trifecta_Survey_Submission__c surveySubmitted = [select id, Completed__c from Trifecta_Survey_Submission__c where Id =:submissionId];
        surveySubmitted.Completed__c = true;
        update surveySubmitted;
        //Task eachTask = [SELECT Id, WhatId, Status FROM Task WHERE WhatId = :submissionId];
//        if (eachTask != null) {
  //        eachTask.Status = 'Completed';
    //    upsert eachTask;
      //  }
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