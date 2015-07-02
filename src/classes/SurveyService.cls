public with sharing class SurveyService {
	public SurveyService() {
		
	}

	public Trifecta_Survey__c getSurveyById(String id) {
		List<String> surveyFields = SoqlUtils.star('Trifecta_Survey__c');
        surveyFields.add('('+SoqlUtils.getSelect(SoqlUtils.star('Trifecta_Survey_Question__c'), 'Trifecta_Survey_Questions__r').withOrder(SoqlUtils.getOrder('Sort_Index__c')).toString()+')');
        SoqlUtils.Soqlquery query = SoqlUtils.getSelect(surveyFields,'Trifecta_Survey__c')
        										.withCondition(SoqlUtils.getEq('Id',id));

        return Database.query(query.toString());
    }

    public Map<String, List<Trifecta_Survey_Question_Choice__c>> getChoicesPerQuestion(List<String> questionIds) {

    	List<String> surveyQuestionFields = SoqlUtils.star('Trifecta_Survey_Question__c');

    	List<String> surveyQuestionChoiceFields = SoqlUtils.star('Trifecta_Survey_Question_Choice__c');
    	surveyQuestionFields.add('('+SoqlUtils.getSelect(surveyQuestionChoiceFields, 'Trifecta_Survey_Question_Choices__r').withOrder(SoqlUtils.getOrder('Sort_Index__c')).toString()+')');
        SoqlUtils.Soqlquery soqlQuery = SoqlUtils.getSelect(surveyQuestionFields,'Trifecta_Survey_Question__c').withCondition(SoqlUtils.getIn('Id',questionIds));

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
        return new Trifecta_Survey_Question_Choice__c(Load_Id__c = GuidUtil.NewGuid(),
                                                        Value__c = original.Value__c,
                                                        Weightage__c = original.Weightage__c);
    }

    public Trifecta_Survey_Question__c cloneQuestion(Trifecta_Survey_Question__c original) {
        return new Trifecta_Survey_Question__c(Load_Id__c = GuidUtil.NewGuid(),
                                                    Help_text__c = original.Help_text__c,
                                                    Sort_Index__c = original.Sort_Index__c,
                                                    Title__c = original.Title__c,
                                                    Type__c = original.Type__c,
                                                    isEdit__c = original.isEdit__c,
                                                    isRequired__c = original.isRequired__c);
    }
}