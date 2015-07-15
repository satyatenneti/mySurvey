public with sharing class TTISGEmailServiceBase implements TTISGEmailService {
    
    public EmailTemplate EMAIL_TEMPLATE_FOR_USER {
        get {
            if(EMAIL_TEMPLATE_FOR_USER == null) {
                EMAIL_TEMPLATE_FOR_USER = [select Id from EmailTemplate where name = :TTISGSurveyUtils.EMAIL_TEMPLATE_FOR_USER];

            }
            return EMAIL_TEMPLATE_FOR_USER;
        }
        set;
    }

    public EmailTemplate EMAIL_TEMPLATE_FOR_CONTACT {
        get {
            if(EMAIL_TEMPLATE_FOR_CONTACT == null) {
                EMAIL_TEMPLATE_FOR_CONTACT = [select Id from EmailTemplate where name = :TTISGSurveyUtils.EMAIL_TEMPLATE_FOR_CONTACT];
            }
            return EMAIL_TEMPLATE_FOR_CONTACT;
        }
        set;
    }

    public void sendInternalEmailNotifications (List<Trifecta_Survey_Submission__c> submissions, Id surveyId) {
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        for(Trifecta_Survey_Submission__c submission : submissions) {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (TTISGSurveyUtils.isValidId(submission.Submitted_To__c, 'User')) {
                mail.setTemplateId(EMAIL_TEMPLATE_FOR_USER.Id);
                mail.setSaveAsActivity(false);
            }
            else if (TTISGSurveyUtils.isValidId(submission.Submitted_To__c, 'Contact')) {
                mail.setTemplateId(EMAIL_TEMPLATE_FOR_CONTACT.Id);
                mail.setSaveAsActivity(true);
            }
            mail.setSenderDisplayName(TTISGSurveyUtils.SENDER_NAME);
            mail.setTargetObjectId(submission.Submitted_To__c);
            mail.setWhatId(submission.Id);
            mails.add(mail);
        }
        Messaging.sendEmail(mails,false);
    }
    public void sendExternalEmailNotifications (List<Trifecta_Survey_Submission__c> submissions, Id surveyId) {
      String surveyName =[SELECT Name from Trifecta_Survey__c WHERE Id = :surveyId].name;
      Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
      String siteURL = Survey_Global_Settings__c.getOrgDefaults().Site_Address__c;
      for(Trifecta_Survey_Submission__c submission : submissions) {
            String SurveyURL = siteURL+'TTISGDisplayForm?Id='+submission.Id+'&Survey='+TTISGSurveyService.getSurveyId(submission.Id);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSenderDisplayName(TTISGSurveyUtils.SENDER_NAME);
            mail.setSubject('Feedback form for '+surveyName);
            mail.setUseSignature(false);
            mail.setBccSender(false);
            mail.setSaveAsActivity(false);
            String body = 'Hi ' + TTISGSurveyUtils.stripDomainFromEmail(String.valueOf(submission.Submitted_To__c)) + ',<br /><br /> ';
            body += 'Please submit your feedback <a href ="'+SurveyURL+'" >here</a>. <br /> <br />';
            body += 'Thank You <br />'+UserInfo.getFirstName() + ' ' +UserInfo.getLastName();
            mail.setHtmlBody(body);
            mail.setToAddresses(new String[]{submission.Submitted_To__c});
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
   
}