trigger TTISurveyQuestionLockStatus on Trifecta_Survey_Question__c (before insert, before update) {
    for(Trifecta_Survey_Question__c question : trigger.new) {
        
        Integer count = [SELECT count() FROM Trifecta_Survey_Submission__c where Survey__c  = :question.Survey__c and Completed__c = false];
        if(count>0) {
            question.addError('This Survey has been locked for responses. You cannot make any changes.');
        }
    }
}