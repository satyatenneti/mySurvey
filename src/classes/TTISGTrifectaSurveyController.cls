public with sharing class TTISGTrifectaSurveyController {
  
    public Trifecta_Survey__c survey{get;set;}
    public List<Trifecta_Survey_Question__c> surveyQuestions{get;set;}
    public String questionloadId{get;set;}
    public String choiceLoadId{get;set;}
    public String qType{get;set;}
    public Map<String,List<Trifecta_Survey_Question_Choice__c>> surveyQuestionChoiceMap{get;set;}
    public TTISGSurveyService surveyService;
    public Integer newIndex {get; set;}
    public Integer oldIndex {get; set;}
    public String surveyId {get; set;}
    
    public TTISGTrifectaSurveyController(ApexPages.StandardController controllerInstance) {

        surveyService = new TTISGSurveyService();

        surveyId = ApexPages.currentPage().getParameters().get('Id');

        if(surveyId != null) {
            //Load the current Survey details
            loadExistingSurvey(surveyId);

        } else {
            // New survey
            survey = (Trifecta_Survey__c) controllerInstance.getRecord();

            survey.Load_Id__c = TTISGGuidUtil.NewGuid();

            surveyQuestions = new List<Trifecta_Survey_Question__c>();
            surveyQuestionChoiceMap = new Map<String,List<Trifecta_Survey_Question_Choice__c>>();
            
            Trifecta_Survey_Question__c newQuestion = getNewQuestion();
            surveyQuestions.add(newQuestion);
            
            surveyQuestionChoiceMap.put(newQuestion.Load_Id__c,new List<Trifecta_Survey_Question_Choice__c>{getNewChoice(newQuestion.Load_Id__c)});
        }

        questionloadId = '';
        choiceLoadId = '';
        qType = '';
    }
    
    /**
    * Adds new Question
    */
    public void addNewSurveyQuestion() {
      Trifecta_Survey_Question__c newQuestion = getNewQuestion();
      this.questionloadId = newQuestion.Load_Id__c;
      newQuestion.isEdit__c = false;
      //Make this to edit mode.
      surveyQuestions.add(newQuestion);
      surveyQuestionChoiceMap.put(newQuestion.Load_Id__c,new List<Trifecta_Survey_Question_Choice__c>{getNewChoice(newQuestion.Load_Id__c)});
      toggleEdit();  
    }
    
    /**
    * Adds a new choice to the question identified by questionLoadId
    */
    public void addNewSurveyQuestionChoice() {
        surveyQuestionChoiceMap.get(questionloadId).add(getNewChoice(questionloadId));
    }  
    
    /**
    * Deletes the Question identified by questionLoadId
    */
    public void deleteSurveyQuestion() {
        surveyQuestions.remove(getQuestionIndex(questionloadId));
        surveyQuestionChoiceMap.remove(questionloadId);
    }
    
    /**
    * Deletes the Choice related to a particular Question 
    * (The method will identify the choice to be deleted from the valeus questionLoadId and choiceLoadId)    
    */
    public void deleteSurveyQuestionChoice() {
        Integer rowIndex = 0;
        for(Trifecta_Survey_Question_Choice__c tempSurveyChoices : surveyQuestionChoiceMap.get(questionloadId)) {
            
            if(tempSurveyChoices.Load_Id__c != choiceLoadId){
                rowIndex++;
            }
            else {
                break;
            }
        }
        surveyQuestionChoiceMap.get(questionloadId).remove(rowIndex);
    }
    
    public List<SelectOption> getQuestionTypes() {
        List<SelectOption> options = TTISGSurveyUtils.getAllQuestionTypes();
        return options;
    }

    public void copyQuestion(){
        Trifecta_Survey_Question__c currentQuestion = surveyQuestions.get(getQuestionIndex(questionloadId));
        Trifecta_Survey_Question__c newQuestion = surveyService.cloneQuestion(currentQuestion);
        surveyQuestions.add(newQuestion);

        List<Trifecta_Survey_Question_Choice__c> clonedChoices = new List<Trifecta_Survey_Question_Choice__c>();

        for (Trifecta_Survey_Question_Choice__c ch: surveyQuestionChoiceMap.get(questionloadId)) {
            clonedChoices.add(surveyService.cloneChoice(ch));
        }
        
        surveyQuestionChoiceMap.put(newQuestion.Load_Id__c, clonedChoices);
        newQuestion.isEdit__c = false;
        
        this.questionloadId = newQuestion.Load_Id__c;
        toggleEdit();  
    }
    
    public void toggleEdit() {
        for(Integer i =0; i < surveyQuestions.size(); i++) {
             if (surveyQuestions.get(i).Load_Id__c != questionloadId) {
                surveyQuestions.get(i).isEdit__c = false;
             } else {
                surveyQuestions.get(i).isEdit__c = (surveyQuestions.get(i).isEdit__c) ? false: true;
             }
        }
    }
    
    public void changeQuestionType() {
        Trifecta_Survey_Question__c question = surveyQuestions.get(getQuestionIndex(questionloadId));
        question.Type__c = qType;

        if(qType == 'Text') {
            surveyQuestionChoiceMap.get(questionloadId).clear();
        } else {
            if(surveyQuestionChoiceMap.get(questionloadId).size() == 0 ) {
                surveyQuestionChoiceMap.get(questionloadId).add(getNewChoice(questionloadId));
            }
        }
    }
    
    public void updateQuestionOrder() {
        
        Trifecta_Survey_Question__c question = surveyQuestions.remove(oldIndex);
        
        if(surveyQuestions.size()==newIndex)
            surveyQuestions.add(question);
        else
            surveyQuestions.add(newIndex, question);
    }
    
    /*
    * Clones the survey given by surveyId. The Page is redirected to detail page of the 
    * newly cloned survey.
    */
    public PageReference cloneSurvey() {
        if (surveyId != null) {
            Id newSurveyId = surveyService.cloneSurvey(surveyId);
            PageReference newSurveyPage = new PageReference('/apex/TTISGCreateSurvey?id='+newSurveyId);
            newSurveyPage.setRedirect(true);
            return newSurveyPage;
        }
        return null;
    }
    
    /**
    * Saves the Current Survey
    */
    public PageReference saveSurvey(){

        //fill non-required fields with default values.
        if(String.isBlank(survey.Name)) {
            survey.Name = TTISGSurveyUtils.DEFAULT_SURVEY_NAME;
        }

        if(String.isBlank(survey.Auto_Response_Message__c)) {
            survey.Auto_Response_Message__c = TTISGSurveyUtils.DEFAULT_AUTO_RESPONSE;
        }


      //Link Survey with Survey Questions via External Id
        Integer sortIndex = 0;
        for(Trifecta_Survey_Question__c eachQuestion : surveyQuestions) {
            eachQuestion.Survey__r = new Trifecta_Survey__c(Load_Id__c = survey.Load_Id__c);
            eachQuestion.isEdit__c = false;
            eachQuestion.Sort_Index__c = sortIndex;
            sortIndex++;
        }
      //Link Survey Question Choices with Survey Question via External Id
      for(String eachQuestion : surveyQuestionChoiceMap.keySet()) {
            Integer sortIndex1 = 0;
            for(Trifecta_Survey_Question_Choice__c eachChoice : surveyQuestionChoiceMap.get(eachQuestion)){
                eachChoice.Survey_Question__r = new Trifecta_Survey_Question__c(Load_Id__c = eachQuestion);
                eachChoice.Sort_Index__c = sortIndex1;
                sortIndex1++;
            }
        }
      
      //Save all the records
      try {
            upsert survey;
            upsert surveyQuestions;
            //system.assert(false,JSON.serialize(SObjectUtils.flatten(surveyQuestionChoiceMap.values())));
            List<Trifecta_Survey_Question_Choice__c> choices = prepareChoicesToUpsert(surveyQuestionChoiceMap.values());

            upsert choices;
            surveyService.retainQuestionsAndChoicesDeleteAllOthers(survey.Id, 
                                            TTISGSObjectUtils.pluckIds(surveyQuestions, 'Id'),
                                            TTISGSObjectUtils.pluckIds(choices, 'Id'));

            
            loadExistingSurvey(survey.Id);

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Survey created/updated successfully.'));
            PageReference newSurveyPage = new PageReference('/apex/TTISGCreateSurvey?id='+survey.Id);
            newSurveyPage.setRedirect(true);
            return newSurveyPage;
        }
        catch (Exception dmlException) { 
            System.debug('An Exception Occured While DML'+dmlException.getMessage());
        }
        return null;
    }
    
    /**
    * Saves the Survey and redirects the user to Send Survey page 
    * @return PageReference Redirects the users to SendSurvey Page 
    */
    public PageReference sendSurvey(){
        //Save the survey before the user can be redirected to Send Survey Page
        saveSurvey();
        PageReference sendSurveyPage = 
          new PageReference(TTISGSurveyUtils.SEND_SURVEY_PAGE_URL+survey.Id);
        
        sendSurveyPage.setRedirect(true);
        return sendSurveyPage;
    }
    
    
    private void loadExistingSurvey(String surveyId) {
        survey  = surveyService.getSurveyById(surveyId);
        surveyQuestions = survey.Trifecta_Survey_Questions__r;
        surveyQuestionChoiceMap = surveyService.getChoicesPerQuestion(TTISGSObjectUtils.pluckIds(surveyQuestions, 'Id'));
    }
    
    private Integer getQuestionIndex(String qLoadId) {
        for(Integer i =0; i < surveyQuestions.size(); i++) {
            if (surveyQuestions.get(i).Load_Id__c == qLoadId) {
                return i;
            } else {
                //When the question index is searched 
                //moving all the questions in preview mode;
                surveyQuestions.get(i).isEdit__c = false;
            }     
        }
        return null;
    }
    
    private Trifecta_Survey_Question_Choice__c getNewChoice(String questionLoadId) {
        String defaultValue = 'Option ';
        defaultValue += (surveyQuestionChoiceMap.get(questionloadId) != null ) ? (String.valueOf(surveyQuestionChoiceMap.get(questionloadId).size()+1)) : '1';
        return new Trifecta_Survey_Question_Choice__c(Value__c=defaultValue, Weightage__c = 0,  Load_Id__c=TTISGGuidUtil.NewGuid());
    }

    private Trifecta_Survey_Question__c getNewQuestion() {
      return new Trifecta_Survey_Question__c(
                                      Type__c=TTISGSurveyUtils.QUESTION_TYPE_RADIO, 
                                      Load_Id__c=TTISGGuidUtil.NewGuid(),
                                      Title__c=TTISGSurveyUtils.DEFAULT_QUESTION_TITLE,
                                      isRequired__c = false,
                                      isEdit__c=true);
    }
    
    private static List<Trifecta_Survey_Question_Choice__c> prepareChoicesToUpsert(List<List<Trifecta_Survey_Question_Choice__c>> choicesList){
        List<Trifecta_Survey_Question_Choice__c> choicesToReturn = new List<Trifecta_Survey_Question_Choice__c>();
        for(List<Trifecta_Survey_Question_Choice__c> eachListOfChoices : choicesList){
            if(eachListOfChoices.size() > 0){
                choicesToReturn.addAll(eachListOfChoices);
            }
        }
        return choicesToReturn;
    }
}