public with sharing class TrifectaSurveyController {
  
    public Trifecta_Survey__c survey{get;set;}
    public List<Trifecta_Survey_Question__c> surveyQuestions{get;set;}
    public String questionloadId{get;set;}
    public String choiceLoadId{get;set;}
    public Map<String,List<Trifecta_Survey_Question_Choice__c>> surveyQuestionChoiceMap{get;set;}
    public static final String DEFAULT_QUESTION_TYPE = 'Multi Choice';
    public static final String SEND_SURVEY_PAGE_URL = '/apex/SendSurvey?id=';
    
    public TrifectaSurveyController(ApexPages.StandardController controllerInstance) {

        // Get the current Survey Record 
        survey = (Trifecta_Survey__c) controllerInstance.getRecord();
        survey.Load_Id__c = GuidUtil.NewGuid();

        surveyQuestions = new List<Trifecta_Survey_Question__c>();
        surveyQuestionChoiceMap = new Map<String,List<Trifecta_Survey_Question_Choice__c>>();
        
        Trifecta_Survey_Question__c newQuestion = getNewQuestion();
        surveyQuestions.add(newQuestion);
        
        surveyQuestionChoiceMap.put(newQuestion.Load_Id__c,new List<Trifecta_Survey_Question_Choice__c>{getNewChoice()});
        
        questionloadId = '';
        choiceLoadId = '';
    }
    /**
    * Adds new Question
    */
    public void addNewSurveyQuestion() {
      Trifecta_Survey_Question__c newQuestion = getNewQuestion();
      surveyQuestions.add(newQuestion);
      surveyQuestionChoiceMap.put(newQuestion.Load_Id__c,new List<Trifecta_Survey_Question_Choice__c>{getNewChoice()});
    }
    
    /**
    * Adds a new choice to the question identified by questionLoadId
    */
    public void addNewSurveyQuestionChoice() {
        surveyQuestionChoiceMap.get(questionloadId).add(getNewChoice());
    }  
    
    /**
    * Deletes the Question identified by questionLoadId
    */
    public void deleteSurveyQuestion() {
        Integer rowIndex =0;
        for(Trifecta_Survey_Question__c eachQuestion : surveyQuestions) {
            if(eachQuestion.Load_Id__c != questionloadId) {
                rowIndex++;
            }
            else {
                break; 
            }
        }
        surveyQuestions.remove(rowIndex); 
    }
    
    /**
    * Deletes the Choice related to a particular Question 
    * (The method will identify the choice to be deleted from the valeus questionLoadId and choiceLoadId)    
    */
    public void deleteSurveyQuestionChoice() {
        Integer rowIndex;
        for(Trifecta_Survey_Question_Choice__c tempSurveyChoices : surveyQuestionChoiceMap.get(questionloadId)) {
            rowIndex = 0;
            
            if(tempSurveyChoices.Load_Id__c != choiceLoadId){
                rowIndex++;
            }
            else {
                break;
            }
        }
        surveyQuestionChoiceMap.get(questionloadId).remove(rowIndex);
    }
    /**
    * Saves the Current Survey
    */
    public void saveSurvey(){
      //Link Survey with Survey Questions via External Id
        for(Trifecta_Survey_Question__c eachQuestion : surveyQuestions) {
            eachQuestion.Survey__r = new Trifecta_Survey__c(Load_Id__c = survey.Load_Id__c);
        }
      //Link Survey Question Choices with Survey Question via External Id
      for(String eachQuestion : surveyQuestionChoiceMap.keySet()) {
            for(Trifecta_Survey_Question_Choice__c eachChoice : surveyQuestionChoiceMap.get(eachQuestion)){
                eachChoice.Survey_Question__r = new Trifecta_Survey_Question__c(Load_Id__c = eachQuestion);
            }
        }
      
      //Save all the records
      try {
            insert survey;
            insert surveyQuestions;
            insert SObjectUtils.flatten(surveyQuestionChoiceMap.values());
        }
        catch (Exception dmlException) { 
            System.debug('An Exception Occured While DML'+dmlException.getMessage());
        }
    }
    /**
    * Saves the Survey and redirects the user to Send Survey page 
    * @return PageReference Redirects the users to SendSurvey Page 
    */
    public PageReference sendSurvey(){
        //Save the survey before the user can be redirected to Send Survey Page
        saveSurvey();
        PageReference sendSurveyPage = 
          new PageReference(TrifectaSurveyController.SEND_SURVEY_PAGE_URL+survey.Id);
        
        sendSurveyPage.setRedirect(true);
        return sendSurveyPage;
    }
    
    private Trifecta_Survey_Question_Choice__c getNewChoice() {
        String defaultValue = 'Option ';
        defaultValue += (surveyQuestionChoiceMap.get(questionloadId) != null ) ? (String.valueOf(surveyQuestionChoiceMap.get(questionloadId).size()+1)) : '1';
        return new Trifecta_Survey_Question_Choice__c(Value__c=defaultValue, Load_Id__c=GuidUtil.NewGuid());
    }

    private Trifecta_Survey_Question__c getNewQuestion() {
      return new Trifecta_Survey_Question__c(
                                      Type__c=TrifectaSurveyController.DEFAULT_QUESTION_TYPE, 
                                      Load_Id__c=GuidUtil.NewGuid());
    }
}