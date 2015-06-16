public class CreateSurveyController {
    
    ApexPages.StandardController controller;
    
    public Trifecta_Survey__c currentSurvey {get; set;}
    
    public CreateSurveyController(ApexPages.StandardController stdController) {
        this.controller = stdController;
        currentSurvey = new Trifecta_Survey__c();
        currentSurvey.Name = 'Untitle form';
    }
    
    public void saveSurvey() {
       System.debug(JSON.serialize(currentSurvey));
        upsert currentSurvey;
    }
    
    public List<Trifecta_Survey_Question__c> getQuestions() {
        Trifecta_Survey_Question__c question = new Trifecta_Survey_Question__c(Title__c='My First Question');
        List<Trifecta_Survey_Question__c> questions = new List<Trifecta_Survey_Question__c>();
        questions.add(question);
        //System.assert(false, json.serializePretty(questions));        
        return questions;
    }
    

}