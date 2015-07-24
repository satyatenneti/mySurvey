public with sharing class TTISGSurveyService {
    public TTISGSurveyService() {
        
    }
    
    /*
     * Returns existing Trifecta_Survey__c record for the given id. 
     * @param id Id of the record
     * @returns Trifecta_Survey__c the record for the given id
     */ 
    public Trifecta_Survey__c getSurveyById(String id) {
        List<String> surveyFields = TTISGSoqlUtils.star('Trifecta_Survey__c');
        surveyFields.add('('+TTISGSoqlUtils.getSelect(TTISGSoqlUtils.star('Trifecta_Survey_Question__c'), 'Trifecta_Survey_Questions__r').withOrder(TTISGSoqlUtils.getOrder('Sort_Index__c')).toString()+')');
        TTISGSoqlUtils.Soqlquery query = TTISGSoqlUtils.getSelect(surveyFields,'Trifecta_Survey__c')
            .withCondition(TTISGSoqlUtils.getEq('Id',id));
        
        return Database.query(query.toString());
    }
    
    /*
     * Returns the Map all the choices grouped by the question loadId. The Map contains the List of choices for 
     * every key value (question loadId). 
     * @param questionIds List of question Ids for which the choices are to be returned.
     * @returns Map<String, List<Trifecta_Survey_Question_Choice__c>> Map of the choices per question (identified by loadId)
     */ 
    public Map<String, List<Trifecta_Survey_Question_Choice__c>> getChoicesPerQuestion(List<String> questionIds) {
        Map<String, List<Trifecta_Survey_Question_Choice__c>> choicesPerQuestion = new Map<String, List<Trifecta_Survey_Question_Choice__c>>();
        
        //start the process only if the questionIds is not empty.
        if(questionIds != null && !questionIds.isEmpty()) {
        	List<String> surveyQuestionFields = TTISGSoqlUtils.star('Trifecta_Survey_Question__c');
        
            List<String> surveyQuestionChoiceFields = TTISGSoqlUtils.star('Trifecta_Survey_Question_Choice__c');
            surveyQuestionFields.add('('+TTISGSoqlUtils.getSelect(surveyQuestionChoiceFields, 
                                                                  'Trifecta_Survey_Question_Choices__r')
                                                        .withOrder(TTISGSoqlUtils.getOrder('Sort_Index__c')).toString()+')');
            TTISGSoqlUtils.Soqlquery soqlQuery = TTISGSoqlUtils.getSelect(surveyQuestionFields,
                                                                  'Trifecta_Survey_Question__c')
                                                        .withCondition(TTISGSoqlUtils.getIn('Id',questionIds));
            for(Trifecta_Survey_Question__c q: Database.query(soqlQuery.toString())) {
                if (q.Type__c == 'Text' ) {
                    choicesPerQuestion.put(q.Load_Id__c, new List<Trifecta_Survey_Question_Choice__c>());
                } else {
                    choicesPerQuestion.put(q.Load_Id__c, q.Trifecta_Survey_Question_Choices__r);
                }
            }
        } 
        return choicesPerQuestion;    
        
    }
    
    /*
     * Retains all the questions and choices that sent here and removes other questions and choices from the database.
     * This is used when Survey is updated with deleting/adding questions.
     * @param surveyId - Id of the Trifecta_Survey__c for which the questions and choices are to be retained
     * @param List<Id> - Ids of the Trifecta_Survey_Question__cs which are to be ratained
     * @param List<Id> - Ids of the Trifecta_Survey_Question_Choice__c which are to be retained
     */ 
    public void retainQuestionsAndChoicesDeleteAllOthers(Id surveyId,List<Id> qIds,List<Id> chIds) {
        
        //fetch the other questions for the survey than given in the list qIds
        List<Trifecta_Survey_Question__c> questionsToDelete = [Select Id,Name from Trifecta_Survey_Question__c Where ID NOT IN : qIds AND Survey__c =:surveyId];
        //fetch the other choices for the survey questions than given in the list chIds
        List<Trifecta_Survey_Question_Choice__c> choicesToDelete = [Select Id,Name from Trifecta_Survey_Question_Choice__c Where ID NOT IN : chIds AND Survey_Question__r.Survey__c =:surveyId];
        
        if(questionsToDelete.size() > 0) {
            delete questionsToDelete;
        }
        if(choicesToDelete.size() > 0) {
            Database.delete(choicesToDelete,false);
        }
    }
    
    /*
     * Clones the current question and returns newly created question
     * @param original - current Trifecta_Survey_Question__c which needs to be cloned
     * @returns Trifecta_Survey_Question__c - newly created question
     * 
     * These custom methods are written to avoid some reference conflicts while using the standard clone method.
     */ 
    public Trifecta_Survey_Question__c cloneQuestion(Trifecta_Survey_Question__c original) {
        return new Trifecta_Survey_Question__c(Load_Id__c = TTISGGuidUtil.NewGuid(),
                                               Help_text__c = original.Help_text__c,
                                               Sort_Index__c = original.Sort_Index__c,
                                               Title__c = original.Title__c,
                                               Type__c = original.Type__c,
                                               isEdit__c = original.isEdit__c,
                                               isRequired__c = original.isRequired__c);
    }
    
    /*
     * Clones the current choices and returns newly created choice
     * @param original - current Trifecta_Survey_Question_Choices__c which needs to be cloned
     * @returns Trifecta_Survey_Question_Choice__c - newly created choice
     * 
     * These custom methods are written to avoid some reference conflicts while using the standard clone method.
     */ 
    public Trifecta_Survey_Question_Choice__c cloneChoice(Trifecta_Survey_Question_Choice__c original) {
        return new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(),
                                                      Value__c = original.Value__c,
                                                      Weightage__c = original.Weightage__c);
    }
    
    /*
     * Clones the entire survey along with its questions and choices.
     * @param Id - Id of the Trifecta_Survey__c which needs to be cloned.
     * @returns Id - Id of the newly created Survey 
     */ 
    public Id cloneSurvey(Id surveyId) {
        Trifecta_Survey__c oldSurvey = getSurveyById(surveyId);
        
        List<String> oldQuestionIds = TTISGSObjectUtils.pluckIds(oldSurvey.Trifecta_Survey_Questions__r, 'Id');
        
        Map<String, List<Trifecta_Survey_Question_Choice__c>> oldChoices = getChoicesPerQuestion(oldQuestionIds);
        
        // creating new survey
        Trifecta_Survey__c newSurvey = new Trifecta_Survey__c(Name=oldSurvey.Name,
                                                              Auto_Response_Message__c = oldSurvey.Auto_Response_Message__c,
                                                              Help_Text__c = oldSurvey.Help_Text__c,
                                                              Load_Id__c = TTISGGuidUtil.NewGuid(),
                                                              RecordTypeId = oldSurvey.RecordTypeId,
                                                              Is_Anonymous__c = oldSurvey.Is_Anonymous__c,
                                                              Threshold_Weightage__c = oldSurvey.Threshold_Weightage__c);
        insert newSurvey;
        
        // creating new question with choices 
        List<Trifecta_Survey_Question__c> newQuestions = new List<Trifecta_Survey_Question__c>();
        List<Trifecta_Survey_Question_Choice__c> newChoices = new List<Trifecta_Survey_Question_Choice__c>();
        for (Trifecta_Survey_Question__c eachQuestion : oldSurvey.Trifecta_Survey_Questions__r) {
            Trifecta_Survey_Question__c newChildQuestion = cloneQuestion(eachQuestion);
            newChildQuestion.Survey__c = newSurvey.Id;
            for (Trifecta_Survey_Question_Choice__c eachChoice : oldChoices.get(eachQuestion.Load_Id__c)) {
                Trifecta_Survey_Question_Choice__c newChoice = cloneChoice(eachChoice);
                newChoice.Survey_Question__r = new Trifecta_Survey_Question__c(Load_Id__c = newChildQuestion.Load_Id__c );
                newChoices.add(newChoice);
            }            
            newQuestions.add(newChildQuestion);
        }
        insert newQuestions;
        insert newChoices;
        
        return newSurvey.Id;
        
    }
    
    /*
    * Returns the Survey Id for a given submission.
    * @param submissionId - Id of the submission
    * @returns Id - Id of the Survey 
    */
    public static Id getSurveyId(Id submissionId) {
      return [Select Survey__c from Trifecta_Survey_Submission__c Where Id =:submissionId][0].Survey__c;
    }


    public List<SelectOption> getSurveyRecordTypes() {
        Map<String, Schema.RecordTypeInfo> mapOfInfos = Schema.getGlobalDescribe().get('Trifecta_Survey__c').getDescribe().getRecordTypeInfosByName();

        List<SelectOption> recordTypes = new List<SelectOption>();
        for(String recordTypeName: mapOfInfos.keySet()) {
            //Skip the default Master Record type.
            if(!recordTypeName.equalsIgnoreCase('Master')) {
                recordTypes.add(new SelectOption(String.valueOf(mapOfInfos.get(recordTypeName).getRecordTypeId()), recordTypeName));    
            }
        }
        return recordTypes;
    }
	
	public Map<String,Trifecta_Survey_Question_Response__c> getSurveySubmissionResponses(String submissionId) {
       List<String> surveyResponseFields = TTISGSoqlUtils.star('Trifecta_Survey_Question_Response__c');
       surveyResponseFields.add('Survey_Question__r.Load_Id__c');

       Map<String,Trifecta_Survey_Question_Response__c> questionResponseMap = new Map<String,Trifecta_Survey_Question_Response__c>();

        TTISGSoqlUtils.Soqlquery query = TTISGSoqlUtils.getSelect(surveyResponseFields,'Trifecta_Survey_Question_Response__c')
                                                        .withCondition(TTISGSoqlUtils.getEq('Survey_Submission__c',submissionId));
        
        for(Trifecta_Survey_Question_Response__c eachResponse : Database.query(query.toString()) ) {
            questionResponseMap.put(eachResponse.Survey_Question__r.Load_Id__c,eachResponse);
        }
        return questionResponseMap;
    }
}