public with sharing class TrifectaSurveyController {
	public Trifecta_Survey__c surveyObj{get;set;}
	public List<Trifecta_Survey_Question__c> surveyQuestionsList{get;set;}
	public String loadIdToDelete{get;set;}
	
	public TrifectaSurveyController(ApexPages.StandardController controllerInstance) {
		surveyObj = (Trifecta_Survey__c) controllerInstance.getRecord();
		surveyQuestionsList = new List<Trifecta_Survey_Question__c>();
		Trifecta_Survey_Question__c newQuestion = new Trifecta_Survey_Question__c(Type__c='Multi Choice',Choices__c='Option 1');
		surveyObj = verifyAndPutLoadIdForSurvey(surveyObj);
		newQuestion = verifyAndPutLoadIdForSurveyQuestion(newQuestion);
		surveyQuestionsList.add(newQuestion);
		loadIdToDelete = '';
	}

	public void addNewSurveyQuestion() {
		Trifecta_Survey_Question__c newSurveyObjQuestion = new Trifecta_Survey_Question__c(Type__c='Multi Choice',Choices__c='Option 1');
		newSurveyObjQuestion = verifyAndPutLoadIdForSurveyQuestion(newSurveyObjQuestion);
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

////////////////////////////////////////////////////////Helper Methods/////////////////////////////////////////////////////////////////

	private Trifecta_Survey__c verifyAndPutLoadIdForSurvey(Trifecta_Survey__c surveyObj) {
		Object surveyAggregateResult = [SELECT Max(Load_Id__c)maxSurveryCount FROM Trifecta_Survey__c ALL ROWS][0].get('maxSurveryCount');
		surveyObj.Load_Id__c = surveyAggregateResult == null ? 'SURVEY-0000000' : createLoadId(surveyAggregateResult,'Trifecta_Survey__c',null);
		return surveyObj;
	}

	private Trifecta_Survey_Question__c verifyAndPutLoadIdForSurveyQuestion(Trifecta_Survey_Question__c surveyQuestion) {
		Object surveryQuestionAggrResult = [SELECT Max(Load_Id__c)maxSurveryQuestionCount FROM Trifecta_Survey_Question__c ALL ROWS][0].get('maxSurveryQuestionCount');
		
		if(surveryQuestionAggrResult == null ) {

			if(surveyQuestionsList.size() < 1) {
				surveyQuestion.Load_Id__c = 'SQ-0000000';
			}
			else {
				surveyQuestion.Load_Id__c = createLoadId(surveryQuestionAggrResult,'Trifecta_Survey_Question__c',surveyQuestionsList.size());
			}
		}
		else {
			surveyQuestion.Load_Id__c = createLoadId(surveryQuestionAggrResult,'Trifecta_Survey_Question__c',null);	
		}
		return surveyQuestion;
	}

	private String createLoadId(Object pAggregateResult,String objName,Integer optionalSize) {
		String resultantString;
		String seedText;
		Integer nextRecordNumber;
		
		if(objName == 'Trifecta_Survey_Question__c'){
			seedText = 'SQ-';	
			nextRecordNumber = (optionalSize != null && pAggregateResult ==null) ? optionalSize : Integer.valueOf(pAggregateResult)+1;
			resultantString = seedText+String.valueOf(nextRecordNumber).leftPad(7).replaceAll(' ','0');
		}
		else {
			seedText = 'SURVEY-';
			nextRecordNumber = Integer.valueOf(pAggregateResult)+1 ;
			resultantString = seedText+String.valueOf(nextRecordNumber).leftPad(7).replaceAll(' ','0');
		}
		
		return resultantString;
	}
}