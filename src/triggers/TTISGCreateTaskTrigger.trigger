trigger TTISGCreateTaskTrigger on Trifecta_Survey_Submission__c (after insert,before delete) {
    
    if(Trigger.isInsert && Trigger.isAfter) {
        List<Task> taskList = new List<Task>();
        Set<Id> surveyIds = new Set<Id>();
        String urlLoad = Survey_Global_Settings__c.getOrgDefaults().Login_URL__c;
        List<Trifecta_Survey__c> currentSurvey = new List<Trifecta_Survey__c>();
        for (Trifecta_Survey_Submission__c eachSub : trigger.new) {
            surveyIds.add(eachSub.Survey__c);
        }
        if (!surveyIds.isEmpty()) {
            currentSurvey = [SELECT Id, Name FROM Trifecta_Survey__c WHERE Id IN :surveyIds];
        }

        for (Trifecta_Survey_Submission__c eachSubmission : trigger.new) {
            if (TTISGSurveyUtils.isValidId(eachSubmission.Submitted_To__c, 'User')) {
                Task task = new Task();
                task.Subject = 'Awaiting feedback for '+currentSurvey[0].Name;
                task.Priority = 'Normal';
                task.OwnerId = eachSubmission.Submitted_To__c;
                task.WhatId = eachSubmission.Id;
                task.Description = urlLoad+'apex/TTISGDisplayForm?Id='+eachSubmission.Id+'&Survey='+eachSubmission.Survey__c;
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

    Trifecta_Survey_Submission__c surveySubmission;
    Trifecta_Survey__c surveyForTheSubmission;
    String userMessage;

    if(Trigger.isBefore && Trigger.isDelete) {
        surveySubmission = Trigger.old[0];
        surveyForTheSubmission = new TTISGSurveyService().getSurveyById(surveySubmission.Survey__c);
        
        userMessage = TTISGSurveyUtils.checkForRecordOwnership(surveyForTheSubmission.OwnerId,UserInfo.getUserId(),'Delete');
        
        if(userMessage != null) {
            surveySubmission.addError(userMessage);
        }       
    }
}