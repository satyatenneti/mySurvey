public with sharing class EmailServiceBase implements EmailService {
	public void sendEmailNotifications (List<String> idList, Id surveyId) {
    	List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    	List<Trifecta_Survey_Submission__c> submissionList = new List<Trifecta_Survey_Submission__c>();

    	EmailTemplate contactTemplate = [select Id from EmailTemplate where name ='Survey Template Contact'];
        EmailTemplate userTemplate = [select Id from EmailTemplate where name ='Survey Template User'];

    	for(String eachId : idList) {
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (eachId.substring(0,3) == schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
	    	  mail.setTemplateId(userTemplate.Id);
            }
            if (eachId.substring(0,3) == schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
               	mail.setTemplateId(contactTemplate.Id);
            }
            mail.setTargetObjectId(eachId);
	    	Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});	
    		if(result[0].success) {
    			submissionList.add(new Trifecta_Survey_Submission__c(Survey__c = surveyId, Submitted_To__c = eachId, Completed__c = false ));
    		}
    	}
    	insert submissionList;
    }
}