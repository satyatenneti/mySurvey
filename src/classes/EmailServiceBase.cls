public with sharing class EmailServiceBase implements EmailService {
    
	public void sendEmailNotifications (List<Trifecta_Survey_Submission__c> submissions, Id surveyId) {
    	List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    	
    	Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        
        
    	for(Trifecta_Survey_Submission__c submission : submissions) {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (isValidId(submission.Submitted_To__c, 'User')) {
                EmailTemplate userTemplate = [select Id from EmailTemplate where name ='Survey Template User'];
                mail.setTemplateId(userTemplate.Id);
                mail.setSaveAsActivity(false);
            }
            else if (isValidId(submission.Submitted_To__c, 'Contact')) {
                EmailTemplate contactTemplate = [select Id from EmailTemplate where name ='Survey Template Contact'];
                mail.setTemplateId(contactTemplate.Id);
                mail.setSaveAsActivity(true);
            }
            mail.setTargetObjectId(submission.Submitted_To__c);
            mail.setWhatId(submission.Id);
            mails.add(mail);
        }
        Messaging.sendEmail(mails,false);
    }

    private Boolean isValidId(String idString, String type) {
        //Validates depending on the Key Prefix for the Id
       return (idString.substring(0,3) == schema.getGlobalDescribe().get(type).getDescribe().getKeyPrefix()) ? true : false;
    }
}