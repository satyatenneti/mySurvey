public with sharing class TTISGSurveyMakerTabViewController {
	List<Trifecta_Survey__c> surveysToDisplay{get;set;}
	public TTISGSurveyMakerTabViewController(ApexPages.StandardSetController controller) {
		surveysToDisplay = TTISGSurveyUtils.getUserOwnedSurveys(UserInfo.getUserId()); 
	}

	public PageReference redirectToNewSurvey() {
		return new PageReference('/apex/'+TTISGSurveyUtils.getCreateSurveyPage()); 
	}
}