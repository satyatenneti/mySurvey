public with sharing class TTISGDisplayFormController {
    public String surveyId;
    public String submissionId;
    
    public TTISGSurveyService surveyService;
    public Boolean isSubmittedAlready {get; set;}
    
    public static final String USER_CONFIRMATION_PAGE_URL = '/apex/TTISGConfirmation?id=';
    public static final String CONTACT_CONFIRMATION_PAGE_URL = Survey_Global_Settings__c.getOrgDefaults().Site_Address__c+'TTISGConfirmation?id=';
    
    public Trifecta_Survey__c survey {get; set;}
    public List<Trifecta_Survey_Question__c> surveyQuestions {get; set;}
    public Map<String,List<Trifecta_Survey_Question_Choice__c>> surveyQuestionChoices{get; set;}
    
    public List<Trifecta_Survey_Question_Response__c> surveyResponses {get; set;}
    
    public Map<String,ChoiceWrapper> questionChoices {get; set;}
    
    public Map<String,String> surveyQuestionChoiceMap{get;set;} 
    public Trifecta_Survey_Submission__c surveySubmitted {get; set;}
    public String questionLoadId {get; set;}
    public String selection {get; set;}

    public TTISGDisplayFormController() {
        surveyId = ApexPages.currentPage().getParameters().get('Survey');
        submissionId = ApexPages.currentPage().getParameters().get('Id');
        
        if( surveyId != null && submissionId != null ) {
            surveyService = new TTISGSurveyService();
            surveyResponses = new List<Trifecta_Survey_Question_Response__c>(); 
            surveySubmitted = [select Id, Submitted_To__c, Completed__c from Trifecta_Survey_Submission__c where Id =:submissionId];
            
            if ([select Completed__c from Trifecta_Survey_Submission__c where Id=:submissionId].Completed__c ) {
                isSubmittedAlready = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Sorry, this survey form has been submitted already.'));
            } else {
                survey  = surveyService.getSurveyById(surveyId);
                surveyQuestions = survey.Trifecta_Survey_Questions__r;
                surveyQuestionChoices = surveyService.getChoicesPerQuestion(TTISGSObjectUtils.pluckIds(surveyQuestions, 'Id'));  
                loadResponseMaps();
            }    
        } else {
            isSubmittedAlready = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid URL'));    
        }
        
    }
    
    private void loadResponseMaps () {
    
        surveyQuestionChoiceMap = new Map<String,String>();
        questionChoices = new Map<String,ChoiceWrapper>();
        
        for (Trifecta_Survey_Question__c eachQuestion : surveyQuestions) {
            ChoiceWrapper wr = new ChoiceWrapper();
            wr.choices = surveyQuestionChoices;
            wr.generateChoiceValues();
            questionChoices.put(eachQuestion.Load_Id__c, wr);
        }
    }
    
    public PageReference submitSurvey(){
        //Save the survey before the user can be redirected to Send Survey Page
        Trifecta_Survey_Submission__c surveySubmitted = [select id, Submitted_To__c, Completed__c from Trifecta_Survey_Submission__c where Id =:submissionId];
        if(surveySubmitted != null && !surveySubmitted.Completed__c) {
            saveResponses();

            //Change the surveySubmission status to 'completed'
            surveySubmitted.Completed__c = true;
            upsert surveySubmitted;
            PageReference confirmationPage;
            if (TTISGSurveyUtils.isValidId(surveySubmitted.Submitted_To__c, 'User')) {
                confirmationPage = new PageReference(TTISGDisplayFormController.USER_CONFIRMATION_PAGE_URL+submissionId);
            } else {
                confirmationPage = new PageReference(TTISGDisplayFormController.CONTACT_CONFIRMATION_PAGE_URL+submissionId);
            }
            confirmationPage.setRedirect(true);
            return confirmationPage;
        } else {
             isSubmittedAlready = true;
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Sorry, this survey form has been submitted already.'));
             return null;
        }        
    }   

    private void saveResponses() {
        surveyResponses = new List<Trifecta_Survey_Question_Response__c>();
       
        
        for (Trifecta_Survey_Question__c eachQuestion: surveyQuestions) {
            ChoiceWrapper wr = questionChoices.get(eachQuestion.Load_Id__c);
            Trifecta_Survey_Question_Response__c surveyResponse = new Trifecta_Survey_Question_Response__c(
                                                                        Survey_Submission__c=submissionId, 
                                                                        Survey_Question__c = eachQuestion.Id);
            if (eachQuestion.Type__c == 'Checkbox') {
                //for checkbox type questions, choices will be returned as List<String> from UI
                surveyResponse.Answer__c = String.join(wr.checkboxChoices, ','); 
            } else {
                surveyResponse.Answer__c = wr.answer;
                surveyResponse.Justification_Message__c = wr.justificationMessage;
            }
            surveyResponses.add(surveyResponse);
        }
        insert surveyResponses;
        
        //Task eachTask = [SELECT Id, WhatId, Status FROM Task WHERE WhatId = :submissionId];
        //if (eachTask != null) {
        //  eachTask.Status = 'Completed';
        //upsert eachTask;
        //}
    }
    /* Used to control the display of Trifecta Logo from Salesforce Users */
    public Boolean getUser() {
        return TTISGSurveyUtils.isValidId(surveySubmitted.Submitted_To__c, 'User');
    }

    public void verifyResponse() {
       // System.assert(false, 'Load Id: '+questionLoadId+' CHoice: '+selection);
        for(Trifecta_Survey_Question__c question: surveyQuestions) {
            if(question.Load_Id__c == questionLoadId) {
                ChoiceWrapper wr = questionChoices.get(questionLoadId);

                for(Trifecta_Survey_Question_Choice__c ch: wr.choices.get(questionLoadId)) {
                    if(ch.Value__c == selection 
                        && ch.Weightage__c <= survey.Threshold_Weightage__c 
                        && String.isBlank(wr.justificationMessage.trim())) {
                        wr.justificationRequired = true;
                    }
                }
            }
        }
        System.assert(false, JSON.serializePretty(questionChoices.get(questionLoadId).choices+'----:----'+questionChoices.get(questionLoadId).justificationRequired));
    }

    public class ChoiceWrapper {
        public List<String> checkboxChoices {get; set;} 
        public String justificationMessage {get; set;}
        public Boolean justificationRequired {get; set;}
        public String answer{get; set;}
        public Decimal expectedWeightage{get; set;}
        public Map<String, List<Trifecta_Survey_Question_Choice__c>> choices {get; set;} 
        public List<SelectOption> choiceValues {get; set;} 

        public ChoiceWrapper() {
            checkboxChoices = new List<String>();
            justificationMessage = '';
            answer = '';
            expectedWeightage = 0.0;
            choices = new Map<String, List<Trifecta_Survey_Question_Choice__c>>();
        }

        public void generateChoiceValues() {
            if(choices != null & choices.size() > 0) {
                for(String qLoadId : choices.keySet()) {
                    choiceValues = new List<SelectOption>();
                    for(Trifecta_Survey_Question_Choice__c choice: choices.get(qLoadId)) {
                        choiceValues.add(new SelectOption(choice.Value__c, choice.Value__c));
                    }
                }
            }
        }
    }
}