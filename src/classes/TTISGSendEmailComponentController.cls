public with sharing class TTISGSendEmailComponentController {
    public String submissionId { get; set; }
    public String senderId { get; set; }
    public String SurveyURL {get; set;}
    public Decimal avgWeightage {get; set;}
    public String submittedToName {
        get {
            Trifecta_Survey_Submission__c submission = [select Submitted_To__c, Submitted_To_Name__c, Avg_Weightage__c from Trifecta_Survey_Submission__c where id =:submissionId];
            avgWeightage = submission.Avg_Weightage__c;
            Survey_Global_Settings__c settings = Survey_Global_Settings__c.getOrgDefaults();
            String siteURL = settings.Site_Address__c;
            String loginURL = settings.Login_URL__c;
            Trifecta_Survey__c survey = [Select Name, Is_Anonymous__c from Trifecta_Survey__c where Id =:TTISGSurveyService.getSurveyId(submissionId)];
            if (survey.Is_Anonymous__c || TTISGSurveyUtils.isValidId(submission.Submitted_To__c, 'Contact')) {
                SurveyURL = siteURL+'TTISGDisplayForm?Id='+submissionId+'&Survey='+TTISGSurveyService.getSurveyId(submissionId);
            } else if (TTISGSurveyUtils.isValidId(submission.Submitted_To__c, 'User')) {
                SurveyURL = loginURL+'apex/TTISGDisplayForm?Id='+submissionId+'&Survey='+TTISGSurveyService.getSurveyId(submissionId);
            }
            return submission.Submitted_To_Name__c;
        }
        set;
    }
    public String getDetailUrl(){
        return Survey_Global_Settings__c.getOrgDefaults().Login_URL__c+submissionId;
    }
    public String getSurveyName() {
        Trifecta_Survey__c currentSurvey = [Select Name from Trifecta_Survey__c where Id =:TTISGSurveyService.getSurveyId(submissionId)];
        return currentSurvey.Name;
    }

    public String getUserName(){
        Trifecta_Survey__c currentSurvey = [select id, OwnerId from Trifecta_Survey__c where id =:TTISGSurveyService.getSurveyId(submissionId)];
        User info =[Select FirstName, LastName from User where id= :currentSurvey.OwnerId];
        return info.FirstName+' '+info.LastName;
    }
}