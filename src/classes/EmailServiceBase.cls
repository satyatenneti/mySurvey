public with sharing class EmailServiceBase implements EmailService {
    
    public void sendInternalEmailNotifications (List<Trifecta_Survey_Submission__c> submissions, Id surveyId) {
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
    public void sendExternalEmailNotifications (List<Trifecta_Survey_Submission__c> submissions, Id surveyId) {
      List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
      
      Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        
      for(Trifecta_Survey_Submission__c submission : submissions) {
            String siteURL = [select Site_Address__c from Survey_Global_Settings__c][0].Site_Address__c;
            String SurveyURL = siteURL+'displayForm?Id='+submission.Id+'&Survey='+getSurveyId(submission.Id);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String> {'pavanmudiganti@gmail.com'});
            mail.setReplyTo('pavanmudiganti@gmail.com');
            mail.setSenderDisplayName('Trifecta Technologies');
            mail.setSubject('Trifecta Survey');
            mail.setUseSignature(false);
            mail.setBccSender(false);
            mail.setSaveAsActivity(false);
            String body = 'Hi ' + submission.Submitted_To__c.substring(0,submission.Submitted_To__c.indexOf('@')) + ',<br /><br /> ';
            body += 'Please submit your feedback <a href ="'+SurveyURL+'" >here</a>. <br /> <br />';
            body += 'Thanking You <br />'+UserInfo.getFirstName() + '  ' +UserInfo.getLastName();
            mail.setHtmlBody(body);
            mail.setToAddresses(new String[]{submission.Submitted_To__c});
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
    private Id getSurveyId(Id submissionId) {
      return [Select Survey__c from Trifecta_Survey_Submission__c Where Id =:submissionId][0].Survey__c;
    }
    private Boolean isValidId(String idString, String type) {
        //Validates depending on the Key Prefix for the Id
       return (idString.substring(0,3) == schema.getGlobalDescribe().get(type).getDescribe().getKeyPrefix()) ? true : false;
    }
}