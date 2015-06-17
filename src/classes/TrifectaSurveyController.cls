public with sharing class TrifectaSurveyController {
    public Trifecta_Survey__c surveyObj{get;set;}
    public List<Trifecta_Survey_Question__c> surveyQuestionsList{get;set;}
    public String questionloadId{get;set;}
    public String choiceLoadId{get;set;}
    public Map<String,List<Trifecta_Survey_Question_Choice__c>> surveyQuestionChoiceMap{get;set;}
    public static final String DEFAULT_QUESTION_TYPE = 'Multi Choice';
    
    public TrifectaSurveyController(ApexPages.StandardController controllerInstance) {
        surveyObj = (Trifecta_Survey__c) controllerInstance.getRecord();
        surveyQuestionsList = new List<Trifecta_Survey_Question__c>();
        surveyQuestionChoiceMap = new Map<String,List<Trifecta_Survey_Question_Choice__c>>();
        
        Trifecta_Survey_Question__c newQuestion = new Trifecta_Survey_Question__c(Type__c=TrifectaSurveyController.DEFAULT_QUESTION_TYPE);
        
        
        surveyObj.Load_Id__c = GuidUtil.NewGuid();
        newQuestion.Load_Id__c = GuidUtil.NewGuid();
        Trifecta_Survey_Question_Choice__c initialChoice = getNewChoice(newQuestion.Load_Id__c);
        initialChoice.Load_Id__c = GuidUtil.NewGuid();
        
        surveyQuestionChoiceMap.put(newQuestion.Load_Id__c,new List<Trifecta_Survey_Question_Choice__c>{initialChoice});
        
        surveyQuestionsList.add(newQuestion);
        questionloadId = '';
        choiceLoadId = '';
    }
    
    public void addNewSurveyQuestion() {
        Trifecta_Survey_Question__c newSurveyObjQuestion = new Trifecta_Survey_Question__c(Type__c='Multi Choice',Choices__c='Option 1');
        newSurveyObjQuestion.Load_Id__c = GuidUtil.NewGuid();
        surveyQuestionsList.add(newSurveyObjQuestion);
        
        Trifecta_Survey_Question_Choice__c initialChoice = getNewChoice(newSurveyObjQuestion.Load_Id__c);
        surveyQuestionChoiceMap.put(newSurveyObjQuestion.Load_Id__c,new List<Trifecta_Survey_Question_Choice__c>{initialChoice});
        
    }
    
    public void addNewSurveyQuestionChoice() {
        Trifecta_Survey_Question_Choice__c newSurveyObjQuestionChoice = getNewChoice(questionloadId);
        newSurveyObjQuestionChoice.Load_Id__c = GuidUtil.NewGuid();
        surveyQuestionChoiceMap.get(questionloadId).add(newSurveyObjQuestionChoice);
    }  
    
    public void deleteSurveyQuestion() {
        Integer rowIndex =0;
        for(Trifecta_Survey_Question__c eachQuestion : surveyQuestionsList) {
            if(eachQuestion.Load_Id__c != questionloadId) {
                rowIndex++;
            }
            else {
                break; 
            }
        }
        surveyQuestionsList.remove(rowIndex); 
    }
    
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
    
    public void saveSurvey(){
        for(Trifecta_Survey_Question__c eachQuestion : surveyQuestionsList) {
            eachQuestion.Survey__r = new Trifecta_Survey__c(Load_Id__c = surveyObj.Load_Id__c);
        }
        for(String eachQuestion : surveyQuestionChoiceMap.keySet()) {
            for(Trifecta_Survey_Question_Choice__c eachChoice : surveyQuestionChoiceMap.get(eachQuestion)){
                eachChoice.Survey_Question__r = new Trifecta_Survey_Question__c(Load_Id__c = eachQuestion);
            }
        }
        try {
            insert surveyObj;
            insert surveyQuestionsList;
            insert SObjectUtils.flatten(surveyQuestionChoiceMap.values());
        }
        catch (Exception dmlException) { 
            System.debug('An Exception Occured While DML'+dmlException.getMessage());
        }
    }
    
    public PageReference sendSurvey(){
        saveSurvey();
        PageReference referenceToNewPage = new PageReference('/apex/SendSurvey?id='+surveyObj.Id);
        referenceToNewPage.setRedirect(true);
        return referenceToNewPage;
    }
    
    private Trifecta_Survey_Question_Choice__c getNewChoice(String questionLoadId) {
        String defaultValue = 'Option ';
        defaultValue += (surveyQuestionChoiceMap.get(questionloadId) != null ) ? (String.valueOf(surveyQuestionChoiceMap.get(questionloadId).size()+1)) : '1';
        return new Trifecta_Survey_Question_Choice__c(Value__c=defaultValue);
    }
                                                                                                   }