public with sharing class TTISGSurveyService {
    public TTISGSurveyService() {
        
    }

    public Trifecta_Survey__c getSurveyById(String id) {
        List<String> surveyFields = TTISGSoqlUtils.star('Trifecta_Survey__c');
        surveyFields.add('('+TTISGSoqlUtils.getSelect(TTISGSoqlUtils.star('Trifecta_Survey_Question__c'), 'Trifecta_Survey_Questions__r').withOrder(TTISGSoqlUtils.getOrder('Sort_Index__c')).toString()+')');
        TTISGSoqlUtils.Soqlquery query = TTISGSoqlUtils.getSelect(surveyFields,'Trifecta_Survey__c')
                                                .withCondition(TTISGSoqlUtils.getEq('Id',id));

        return Database.query(query.toString());
    }

    public Map<String, List<Trifecta_Survey_Question_Choice__c>> getChoicesPerQuestion(List<String> questionIds) {

        List<String> surveyQuestionFields = TTISGSoqlUtils.star('Trifecta_Survey_Question__c');

        List<String> surveyQuestionChoiceFields = TTISGSoqlUtils.star('Trifecta_Survey_Question_Choice__c');
        surveyQuestionFields.add('('+TTISGSoqlUtils.getSelect(surveyQuestionChoiceFields, 'Trifecta_Survey_Question_Choices__r').withOrder(TTISGSoqlUtils.getOrder('Sort_Index__c')).toString()+')');
        TTISGSoqlUtils.Soqlquery soqlQuery = TTISGSoqlUtils.getSelect(surveyQuestionFields,'Trifecta_Survey_Question__c').withCondition(TTISGSoqlUtils.getIn('Id',questionIds));

        Map<String, List<Trifecta_Survey_Question_Choice__c>> choicesPerQuestion = new Map<String, List<Trifecta_Survey_Question_Choice__c>>();
        for(Trifecta_Survey_Question__c q: Database.query(soqlQuery.toString())) {
            if (q.Type__c == 'Text' ) {
                choicesPerQuestion.put(q.Load_Id__c, new List<Trifecta_Survey_Question_Choice__c>());
            } else {
               choicesPerQuestion.put(q.Load_Id__c, q.Trifecta_Survey_Question_Choices__r);
            }
        }
        return choicesPerQuestion;
    }

    public void retainQuestionsAndChoicesDeleteAllOthers(Id surveyId,List<Id> qIds,List<Id> chIds) {
        List<Trifecta_Survey_Question__c> questionsToDelete = [Select Id,Name from Trifecta_Survey_Question__c Where ID NOT IN : qIds AND Survey__c =:surveyId];
        List<Trifecta_Survey_Question_Choice__c> choicesToDelete = [Select Id,Name from Trifecta_Survey_Question_Choice__c Where ID NOT IN : chIds AND Survey_Question__r.Survey__c =:surveyId];
      
        if(questionsToDelete.size() > 0) {
           delete questionsToDelete;
        }
        if(choicesToDelete.size() > 0) {
           Database.delete(choicesToDelete,false);
        }
    }

    public Trifecta_Survey_Question_Choice__c cloneChoice(Trifecta_Survey_Question_Choice__c original) {
        return new Trifecta_Survey_Question_Choice__c(Load_Id__c = TTISGGuidUtil.NewGuid(),
                                                        Value__c = original.Value__c,
                                                        Weightage__c = original.Weightage__c);
    }

    public Trifecta_Survey_Question__c cloneQuestion(Trifecta_Survey_Question__c original) {
        return new Trifecta_Survey_Question__c(Load_Id__c = TTISGGuidUtil.NewGuid(),
                                                    Help_text__c = original.Help_text__c,
                                                    Sort_Index__c = original.Sort_Index__c,
                                                    Title__c = original.Title__c,
                                                    Type__c = original.Type__c,
                                                    isEdit__c = original.isEdit__c,
                                                    isRequired__c = original.isRequired__c);
    }

    public Id cloneSurvey(Id surveyId) {
        Trifecta_Survey__c oldSurvey = getSurveyById(surveyId);

        List<String> oldQuestionIds = new List<String>();
        for (Trifecta_Survey_Question__c eachQuestion : oldSurvey.Trifecta_Survey_Questions__r) {
            oldQuestionIds.add(eachQuestion.id);
        }
        Map<String, List<Trifecta_Survey_Question_Choice__c>> oldChoices = getChoicesPerQuestion(oldQuestionIds);

        // creating new survey
        Trifecta_Survey__c newSurvey = new Trifecta_Survey__c(Name=oldSurvey.Name,
                                                            Auto_Response_Message__c = oldSurvey.Auto_Response_Message__c,
                                                            Description__c = oldSurvey.Description__c,
                                                            Help_Text__c = oldSurvey.Help_Text__c,
                                                            Load_Id__c = TTISGGuidUtil.NewGuid(),
                                                            Threshold_Weightage__c = oldSurvey.Threshold_Weightage__c);
        insert newSurvey;
        
        // creating new question with choices 
        List<Trifecta_Survey_Question__c> childQuestions = new List<Trifecta_Survey_Question__c>();
        List<Trifecta_Survey_Question_Choice__c> childChoices = new List<Trifecta_Survey_Question_Choice__c>();
        for (Trifecta_Survey_Question__c eachQuestion : oldSurvey.Trifecta_Survey_Questions__r) {
            Trifecta_Survey_Question__c newChildQuestion = cloneQuestion(eachQuestion);
            newChildQuestion.Survey__c = newSurvey.Id;
            for (Trifecta_Survey_Question_Choice__c eachChoice : oldChoices.get(eachQuestion.Load_Id__c)) {
                Trifecta_Survey_Question_Choice__c newChoice = cloneChoice(eachChoice);
                newChoice.Survey_Question__r = new Trifecta_Survey_Question__c(Load_Id__c = newChildQuestion.Load_Id__c );
                childChoices.add(newChoice);
            }            
            childQuestions.add(newChildQuestion);
        }
        insert childQuestions;
        insert childChoices;
                
        return newSurvey.Id;

    }
}