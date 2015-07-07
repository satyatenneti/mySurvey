trigger CreateTaskTrigger on Trifecta_Survey_Submission__c (after insert) {
	public static final String SURVEYURL = 'https://login.salesforce.com/apex/displayForm?Id=';
	List<Task> taskList = new List<Task>();
	Set<Id> surveyIds = new Set<Id>();
	List<Trifecta_Survey__c> currentSurvey = new List<Trifecta_Survey__c>();
	for (Trifecta_Survey_Submission__c eachSub : trigger.new) {
		surveyIds.add(eachSub.Survey__c);
	}
	if (!surveyIds.isEmpty()) {
		currentSurvey = [SELECT Id, Name FROM Trifecta_Survey__c WHERE Id IN :surveyIds];
	}

	for (Trifecta_Survey_Submission__c eachSubmission : trigger.new) {
		if (eachSubmission.Submitted_To__c.substring(0,3) == Schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
			Task task = new Task();
			task.Subject = 'Awaiting feedback for '+currentSurvey[0].Name;
			task.Priority = 'Normal';
			task.OwnerId = eachSubmission.Submitted_To__c;
			task.WhatId = eachSubmission.Id;
			task.Description = SURVEYURL+eachSubmission.Id+'&Survey='+eachSubmission.Survey__c;
			taskList.add(task);
		}
	}
	if (!taskList.isEmpty()) {
		try {
			insert taskList;
		} catch (Exception e) {
			System.debug('Exception occured: '+e.getMessage());
		}
	}
}