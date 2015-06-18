public with sharing class EmailServiceBase implements EmailService {
	public void sendEmailNotifications (List<String> idList, Id surveyId) {
    	List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    	List<Trifecta_Survey_Submission__c> submissionList = new List<Trifecta_Survey_Submission__c>();
        
    	EmailTemplate contactTemplate = [select Id from EmailTemplate where name ='Survey Template Contact'];
        EmailTemplate userTemplate = [select Id from EmailTemplate where name ='Survey Template User'];
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        for(String eachId : idList) {
            submissionList.add(new Trifecta_Survey_Submission__c(Survey__c = surveyId, Submitted_To__c = eachId.trim(), Completed__c = false ));
        
        }
        insert submissionList;
        
    	for(Trifecta_Survey_Submission__c submission : submissionList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (submission.Submitted_To__c.substring(0,3) == schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
	    	  mail.setTemplateId(userTemplate.Id);
              mail.setSaveAsActivity(false);
            }
            else if (submission.Submitted_To__c.substring(0,3) == schema.getGlobalDescribe().get('Contact').getDescribe().getKeyPrefix()) {
               	mail.setTemplateId(contactTemplate.Id);
                mail.setSaveAsActivity(true);
            }
            mail.setTargetObjectId(submission.Submitted_To__c);
            mail.setWhatId(submission.Id);
            mails.add(mail);
        }
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails,false);
    }
}