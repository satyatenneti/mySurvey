public with sharing class TTISGSendEmailComponentController {
    public String submissionId { get; set; }
    public String senderId { get; set; }
    public String SurveyURL {get; set;}
    public Decimal avgWeightage {get; set;}
    public String submittedToName {
        get {
            Trifecta_Survey_Submission__c submission = [select Submitted_To__c, Submitted_To_Name__c,Avg_Weightage__c from Trifecta_Survey_Submission__c where id =:submissionId];
            avgWeightage = submission.Avg_Weightage__c;
            Survey_Global_Settings__c settings = [select Site_Address__c,Login_URL__c from Survey_Global_Settings__c][0];
            String siteURL = settings.Site_Address__c;
            String loginURL = settings.Login_URL__c;
            if (submission.Submitted_To__c != null) {
                if (submission.Submitted_To__c.subString(0,3) == schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
                    SurveyURL = loginURL+'apex/TTISGDisplayForm?Id='+submissionId+'&Survey='+getSurveyId(submissionId);
                } else if (submission.Submitted_To__c.subString(0,3) == schema.getGlobalDescribe().get('Contact').getDescribe().getKeyPrefix()) {
                    SurveyURL = siteURL+'TTISGDisplayForm?Id='+submissionId+'&Survey='+getSurveyId(submissionId);
                }
                return submission.Submitted_To_Name__c;
            }
            return null;
        }
        set;
    }
    public String getDetailUrl(){
        String loginURL = [select Login_URL__c from Survey_Global_Settings__c][0].Login_URL__c;
        return loginURL+submissionId;
    }
    public String getSurveyName() {
        Trifecta_Survey__c currentSurvey = [Select Name, Avg_Weightage__c from Trifecta_Survey__c where Id =:getSurveyId(submissionId)];
        return currentSurvey.Name;
    }
    private Id getSurveyId(Id submissionId) {
        return [Select Survey__c from Trifecta_Survey_Submission__c Where Id =:submissionId][0].Survey__c;
    }
}