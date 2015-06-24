public with sharing class TrifectaSurveyControllerHelper {

    public static TrifectaSurveyController.SurveyWrapper createTrifectaSurveyWrapper(Id surveyId) {
      
        TrifectaSurveyController.SurveyWrapper surveyInstance = new TrifectaSurveyController.SurveyWrapper();
        surveyInstance.surveyQuestions = new Map<String,Trifecta_Survey_Question__c>();
        surveyInstance.surveyQuestionChoices = new Map<String,List<Trifecta_Survey_Question_Choice__c>>();

        List<String> surveyFields = SoqlUtils.star('Trifecta_Survey__c');
        surveyFields.add('('+SoqlUtils.getSelect(SoqlUtils.star('Trifecta_Survey_Question__c'), 'Trifecta_Survey_Questions__r').toString()+')');
        SoqlUtils.Soqlquery query = SoqlUtils.getSelect(surveyFields,'Trifecta_Survey__c').withCondition(SoqlUtils.getEq('Id',surveyId));

        for(Trifecta_Survey__c eachSurvey : Database.query(query.toString())) {
            surveyInstance.survey = eachSurvey;
            for(Trifecta_Survey_Question__c eachQuestion : eachSurvey.Trifecta_Survey_Questions__r){
                surveyInstance.surveyQuestions.put(eachQuestion.Load_Id__c,eachQuestion);
            }
        }
      
        if(surveyInstance.surveyQuestions.size() > 0) {
            List<String> surveyQuestionFields = SoqlUtils.star('Trifecta_Survey_Question__c');

            List<String> surveyQuestionChoiceFields = SoqlUtils.star('Trifecta_Survey_Question_Choice__c');
            surveyQuestionChoiceFields.add('Survey_Question__r.Load_Id__c');

            surveyQuestionFields.add('('+SoqlUtils.getSelect(surveyQuestionChoiceFields, 'Trifecta_Survey_Question_Choices__r').toString()+')');
            List<Id> questionIds = SobjectUtils.pluckIds(surveyInstance.surveyQuestions.values(),'Id');
            SoqlUtils.Soqlquery questionQuery = SoqlUtils.getSelect(surveyQuestionFields,'Trifecta_Survey_Question__c').withCondition(SoqlUtils.getIn('Id',questionIds));

            for(Trifecta_Survey_Question__c eachQuestion : Database.query(questionQuery.toString())) {
                for(Trifecta_Survey_Question_Choice__c eachChoice : eachQuestion.Trifecta_Survey_Question_Choices__r) {
                    if(!surveyInstance.surveyQuestionChoices.containsKey(eachChoice.Survey_Question__r.Load_Id__c)){
                        surveyInstance.surveyQuestionChoices.put(eachChoice.Survey_Question__r.Load_Id__c, new List<Trifecta_Survey_Question_Choice__c>{});
                    }    
                    surveyInstance.surveyQuestionChoices.get(eachChoice.Survey_Question__r.Load_Id__c).add(eachChoice);
                }
            }
        }
        
        return surveyInstance;  
    }
 
    public static void checkForSurveyQuestionsAndChoicesToRemain(Id surveyId,Set<String> questionsToRemain,Set<String> choicesToRemain) {
        List<Trifecta_Survey_Question__c> questionsToDelete = [Select Id,Name from Trifecta_Survey_Question__c Where Load_Id__c NOT IN : questionsToRemain AND Survey__c =:surveyId];
        List<Trifecta_Survey_Question_Choice__c> choicesToDelete = [Select Id,Name from Trifecta_Survey_Question_Choice__c Where Load_Id__c NOT IN : choicesToRemain AND Survey_Question__r.Survey__c =:surveyId];
      
        if(questionsToDelete.size() > 0) {
           delete questionsToDelete;
        }
        if(choicesToDelete.size() > 0) {
           Database.delete(choicesToDelete,false);
        }
    }
}