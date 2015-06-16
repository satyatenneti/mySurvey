public with sharing class TrifectaSurveyController {
	public Trifecta_Survey__c surveyObj{get;set;}
	public List<Trifecta_Survey_Question__c> surveyQuestionsList{get;set;}
	public String loadIdToDelete{get;set;}
	
	public TrifectaSurveyController(ApexPages.StandardController controllerInstance) {
		surveyObj = (Trifecta_Survey__c) controllerInstance.getRecord();
		surveyQuestionsList = new List<Trifecta_Survey_Question__c>();
		Trifecta_Survey_Question__c newQuestion = new Trifecta_Survey_Question__c(Type__c='Multi Choice',Choices__c='Option 1');
		surveyObj.Load_Id__c = GuidUtil.NewGuid();
		newQuestion.Load_Id__c = GuidUtil.NewGuid();
		surveyQuestionsList.add(newQuestion);
		loadIdToDelete = '';
	}

	public void addNewSurveyQuestion() {
		Trifecta_Survey_Question__c newSurveyObjQuestion = new Trifecta_Survey_Question__c(Type__c='Multi Choice',Choices__c='Option 1');
		newSurveyObjQuestion.Load_Id__c = GuidUtil.NewGuid();
		surveyQuestionsList.add(newSurveyObjQuestion);
	}	

	public void deleteSurveyQuestion() {
		Integer rowIndex =0;
		for(Trifecta_Survey_Question__c eachQuestion : surveyQuestionsList) {
			if(eachQuestion.Load_Id__c != loadIdToDelete) {
				rowIndex++;
			}
			else {
				break; 
			}
		}
		surveyQuestionsList.remove(rowIndex);
	}

	public void saveSurvey(){
		for(Trifecta_Survey_Question__c eachQuestion : surveyQuestionsList) {
			eachQuestion.Survey__r = new Trifecta_Survey__c(Load_Id__c = surveyObj.Load_Id__c);
		}
		try {
			insert surveyObj;
			insert surveyQuestionsList;
		}
		catch (Exception dmlException) { 
			System.debug('An Exception Occured While DML'+dmlException.getMessage());
		}
	}

	public void copySurveyQuestion(){

	}

	public void addSurveyQuestionChoice() {

	}

	public void sendSurvey(){

	}
}