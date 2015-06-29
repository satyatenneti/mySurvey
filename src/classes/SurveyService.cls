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
    	surveyQuestionFields.add('('+SoqlUtils.getSelect(surveyQuestionChoiceFields, 'Trifecta_Survey_Question_Choices__r').toString()+')');
        SoqlUtils.Soqlquery soqlQuery = SoqlUtils.getSelect(surveyQuestionFields,'Trifecta_Survey_Question__c').withCondition(SoqlUtils.getIn('Id',questionIds));

        Map<String, List<Trifecta_Survey_Question_Choice__c>> choicesPerQuestion = new Map<String, List<Trifecta_Survey_Question_Choice__c>>();
        for(Trifecta_Survey_Question__c q: Database.query(soqlQuery.toString())) {
        	choicesPerQuestion.put(q.Load_Id__c, q.Trifecta_Survey_Question_Choices__r);
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
}