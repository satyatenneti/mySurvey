public with sharing class TTISGSendEmailComponentController {
    public static final String MYSURVEYURL = 'https://login.salesforce.com/apex/displayForm?Id=';
    public String submissionId { get; set; }
    public String senderId { get; set; }
    public String SurveyURL {get; set;}
    public Decimal avgWeightage {get; set;}
    public String submittedToName {
        get {
            Trifecta_Survey_Submission__c submission = [select Submitted_To__c, Submitted_To_Name__c,Avg_Weightage__c from Trifecta_Survey_Submission__c where id =:submissionId];
            avgWeightage = submission.Avg_Weightage__c;
            if (submission.Submitted_To__c != null) {
                if (submission.Submitted_To__c.subString(0,3) == schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix()) {
                    SurveyURL = MYSURVEYURL+submissionId+'&Survey='+getSurveyId(submissionId);
                } else if (submission.Submitted_To__c.subString(0,3) == schema.getGlobalDescribe().get('Contact').getDescribe().getKeyPrefix()) {
                    String siteURL = [select Site_Address__c from Survey_Global_Settings__c][0].Site_Address__c;
                    SurveyURL = siteURL+'displayForm?Id='+submissionId+'&Survey='+getSurveyId(submissionId);
                }
                return submission.Submitted_To_Name__c;
            }
            return null;
        }
        set;
    }
    public String getDetailUrl(){
        return 'http://login.salesforce.com/'+submissionId;
    }
    public String getSurveyName() {
        Trifecta_Survey__c currentSurvey = [Select Name, Avg_Weightage__c from Trifecta_Survey__c where Id =:getSurveyId(submissionId)];
        return currentSurvey.Name;
    }
    private Id getSurveyId(Id submissionId) {
        return [Select Survey__c from Trifecta_Survey_Submission__c Where Id =:submissionId][0].Survey__c;
    }
}