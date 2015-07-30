trigger TSQResponseTrigger on Trifecta_Survey_Question_Response__c (before insert) {
    List<String> questionIds = new List<String>();
    for (Trifecta_Survey_Question_Response__c eachAnswer : Trigger.new) {
        questionIds.add(eachanswer.Survey_Question__c);
    }
    Map<Id,Trifecta_Survey_Question__c> questionsMap = new Map<Id,Trifecta_Survey_Question__c>([select Id, Type__c, (select Id, Value__c, Weightage__c from Trifecta_Survey_Question_Choices__r) from Trifecta_Survey_Question__c where id in :questionIds and Type__c ='Radio Button' ]);
    for (Trifecta_Survey_Question_Response__c eachAnswer : Trigger.new) {
        if (questionsMap.containsKey(eachAnswer.Survey_Question__c)) {
            List<Trifecta_Survey_Question_Choice__c> choiceList = questionsMap.get(eachAnswer.Survey_Question__c).Trifecta_Survey_Question_Choices__r;
            Integer weight = 0;
            for (Trifecta_Survey_Question_Choice__c eachChoice : choiceList ) {
                if(eachAnswer.Answer__c == eachChoice.Value__c) {
                    weight = (Integer)eachChoice.Weightage__c;
                }
            }
            eachAnswer.weitage__c = weight;
        }
    }    
}