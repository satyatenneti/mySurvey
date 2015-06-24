public with sharing class TrifectaSurveyController {
  
    public Trifecta_Survey__c survey{get;set;}
    public Map<String,Trifecta_Survey_Question__c> surveyQuestions{get;set;}
    public Map<String,List<Trifecta_Survey_Question_Choice__c>> surveyQuestionChoiceMap{get;set;}
    
    public String questionloadId{get;set;}
    public String choiceLoadId{get;set;}
    public static final String DEFAULT_QUESTION_TYPE = 'Multi Choice';
    public static final String SEND_SURVEY_PAGE_URL = '/apex/SendSurvey?id=';
    public static final String DEFAULT_QUESTION_TITLE = 'Untitled Question';
    public Id surveyId;
    public Integer questionCount{
        get{ return surveyQuestions.size(); 

        }
        set;
    }
    
    public TrifectaSurveyController(ApexPages.StandardController controllerInstance) {

        questionloadId = '';
        choiceLoadId = '';
        
        surveyId = ApexPages.currentPage().getParameters().get('Id');
        // Loading Existing Survey
        if(surveyId != null) {

            SurveyWrapper dbSurvey = TrifectaSurveyControllerHelper.createTrifectaSurveyWrapper(surveyId);
            survey = dbSurvey.survey;
            surveyQuestions = dbSurvey.surveyQuestions;
            surveyQuestionChoiceMap = dbSurvey.surveyQuestionChoices;
        }
        else {
            // Get the current Survey Record 
            survey = (Trifecta_Survey__c) controllerInstance.getRecord();
            survey.Load_Id__c = GuidUtil.NewGuid();

            surveyQuestions = new Map<String,Trifecta_Survey_Question__c>();
            surveyQuestionChoiceMap = new Map<String,List<Trifecta_Survey_Question_Choice__c>>();
            
            Trifecta_Survey_Question__c newQuestion = getNewQuestion();
            surveyQuestions.put(newQuestion.Load_Id__c,newQuestion);
            
            surveyQuestionChoiceMap.put(newQuestion.Load_Id__c,new List<Trifecta_Survey_Question_Choice__c>{getNewChoice(newQuestion.Load_Id__c)});
        }
    }

    /**
    * Adds new Question
    */
    public void addNewSurveyQuestion() {
        Trifecta_Survey_Question__c newQuestion = getNewQuestion();
        surveyQuestions.put(newQuestion.Load_Id__c,newQuestion);
        surveyQuestionChoiceMap.put(newQuestion.Load_Id__c,new List<Trifecta_Survey_Question_Choice__c>{getNewChoice(newQuestion.Load_Id__c)});
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
        surveyQuestions.remove(questionloadId); 
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

    /*
    * Toggling Edit of the Question
    */
    public void toggleQuestionEdit() {
        Trifecta_Survey_Question__c question = surveyQuestions.get(questionloadId);
        
        question.isEdit__c = (question.isEdit__c == true ) ? false : true;
        
        for(Trifecta_Survey_Question__c eachOtherQuestion : surveyQuestions.values()) {
            if(eachOtherQuestion.Load_Id__c != question.Load_Id__c){
                eachOtherQuestion.isEdit__c = false;
            }
        }
    }

    /**
    * Saves the Current Survey
    */
    public void saveSurvey(){
    
        Set<String> questionLoadIdsToRemain = new Set<String>();
        Set<String> choicesLoadIdsToRemain = new Set<String>();

        Set<String> textQuestionLoadIds = new Set<String>();

        //Link Survey with Survey Questions via External Id
        for(Trifecta_Survey_Question__c eachQuestion : surveyQuestions.values()) {
            if(eachQuestion.Survey__c == null) {
                eachQuestion.Survey__r = new Trifecta_Survey__c(Load_Id__c = survey.Load_Id__c);
            }
            eachQuestion.isEdit__c = false;
            questionLoadIdsToRemain.add(eachQuestion.Load_Id__c);
            if(eachQuestion.Type__c == 'Text') {
                textQuestionLoadIds.add(eachQuestion.Load_Id__c);
            }
        }
        //Link Survey Question Choices with Survey Question via External Id
        for(String eachQuestion : surveyQuestionChoiceMap.keySet()) {
            if(textQuestionLoadIds.contains(eachQuestion)) {
                surveyQuestionChoiceMap.remove(eachQuestion);
            }
            else {
                for(Trifecta_Survey_Question_Choice__c eachChoice : surveyQuestionChoiceMap.get(eachQuestion)){
                    if(eachChoice.Survey_Question__c == null) {
                        eachChoice.Survey_Question__r = new Trifecta_Survey_Question__c(Load_Id__c = eachQuestion);
                    } 
                    choicesLoadIdsToRemain.add(eachChoice.Load_Id__c);
                }
            }
        }

        if(surveyId != null) {
            TrifectaSurveyControllerHelper.checkForSurveyQuestionsAndChoicesToRemain(surveyId,questionLoadIdsToRemain,choicesLoadIdsToRemain);
        }
        
        //Save all the records
        try {
            upsert survey;
            upsert surveyQuestions.values();
            upsert getChoicesToUpsert(surveyQuestionChoiceMap.values());
        }
        catch (Exception dmlException) { 
            System.debug('An Exception Occured While DML'+dmlException.getMessage());
            system.assert(false,dmlException.getMessage());
        }
    }

    /**
    * Saves the Survey and redirects the user to Send Survey page 
    * @return PageReference Redirects the users to SendSurvey Page 
    */
    public PageReference sendSurvey(){
        //Save the survey before the user can be redirected to Send Survey Page
        saveSurvey();
        PageReference sendSurveyPage = new PageReference(TrifectaSurveyController.SEND_SURVEY_PAGE_URL+survey.Id);
        
        sendSurveyPage.setRedirect(true);
        return sendSurveyPage;
    }
    
    /**
    * Copies the requested question and its choices and creates a duplicate copy
    */
    public void copyQuestion() {
        
        Trifecta_Survey_Question__c copyQuestion = surveyQuestions.get(questionloadId).clone(false,true);
        copyQuestion.Load_Id__c = GuidUtil.NewGuid();
        copyQuestion.isEdit__c = false;
        surveyQuestions.put(copyQuestion.Load_Id__c,copyQuestion);

        Trifecta_Survey_Question_Choice__c tempSurveyChoice = new Trifecta_Survey_Question_Choice__c();
        List<Trifecta_Survey_Question_Choice__c> copyQuestionChoices = new List<Trifecta_Survey_Question_Choice__c>();
        
        for(Trifecta_Survey_Question_Choice__c eachChoiceForTheQuestion : surveyQuestionChoiceMap.get(questionloadId)) {
            tempSurveyChoice = eachChoiceForTheQuestion.clone(false,true);
            tempSurveyChoice.Load_Id__c = GuidUtil.NewGuid();
            copyQuestionChoices.add(tempSurveyChoice);
        }
        
        this.questionloadId = copyQuestion.Load_Id__c;
        //Move the copied question to editMode.
        toggleQuestionEdit();

        surveyQuestionChoiceMap.put(copyQuestion.Load_Id__c,copyQuestionChoices);
    }

    public void changeType(){ 
    
    }

    private Trifecta_Survey_Question__c getNewQuestion() {
      return new Trifecta_Survey_Question__c(
                                      Type__c=TrifectaSurveyController.DEFAULT_QUESTION_TYPE, 
                                      Load_Id__c=GuidUtil.NewGuid(),
                                      Title__c=TrifectaSurveyController.DEFAULT_QUESTION_TITLE,
                                      isRequired__c = false,
                                      isEdit__c = true);
    }

    private Trifecta_Survey_Question_Choice__c getNewChoice(String questionLoadId) {
        String defaultValue = 'Option ';
        defaultValue += (surveyQuestionChoiceMap.get(questionloadId) != null ) ? (String.valueOf(surveyQuestionChoiceMap.get(questionloadId).size()+1)) : '1';
        return new Trifecta_Survey_Question_Choice__c(Value__c=defaultValue, Load_Id__c=GuidUtil.NewGuid());
    }

    private List<Trifecta_Survey_Question_Choice__c> getChoicesToUpsert(List<List<Trifecta_Survey_Question_Choice__c>> mapChoices){
        List<Trifecta_Survey_Question_Choice__c> choicesToReturn = new List<Trifecta_Survey_Question_Choice__c>();
        for(List<Trifecta_Survey_Question_Choice__c> eachQuestionChoices : mapChoices) {
            choicesToReturn.addAll(eachQuestionChoices);
        }
        return choicesToReturn;
    }
    
    public class SurveyWrapper{
        public Trifecta_Survey__c survey;
        public Map<String,Trifecta_Survey_Question__c> surveyQuestions;
        public Map<String,List<Trifecta_Survey_Question_Choice__c>> surveyQuestionChoices;

        public SurveyWrapper(){
        
        }
    }
}