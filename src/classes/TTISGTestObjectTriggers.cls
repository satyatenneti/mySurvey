@isTest(seeAllData=false)
public with sharing class TTISGTestObjectTriggers {
    @testSetup
    static void createTestData() {
        // Creating Test Survey , Survey Questions , Survey Question Choices
        Trifecta_Survey__c survey = TTISGTestUtils.createSurvey('Sample Survey');
        List<Trifecta_Survey_Question__c> surveyQuestions = TTISGTestUtils.createSurveyQuestions(survey.Id);
        List<Id> surveyQuestionIds = TTISGSObjectUtils.pluckIds(surveyQuestions,'Id');
        TTISGTestUtils.createSurveyChoices(surveyQuestionIds);
    }

    @isTest    // Verifying the Updation of submitted response stopped by the non-eligible user
    static void testRecordUpdations() {
        // Querying up profiles required for the users below
        Profile platformprofile = [SELECT Id FROM Profile WHERE Name='Standard Platform User'];
        Profile systemadminprofile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        // Constructing required test users
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = systemadminprofile.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='surveymakeradminuser@testorg.com');  
        User u1;

        // Querying required permission which is to be assigned to non admin user
        PermissionSet pset = [Select Id,Name from PermissionSet Where Name = 'Survey_Maker_Permissions'];

        System.runAs(u2) {
            // Inserting PermissionSetAssignment and Non Admin user record as co-admin User to avoid Mixed DML Error
            u1 = new User(Alias = 'standt', Email='standarduser@testorg.com',FirstName='Admin', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = platformprofile.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='surveymakertestuser@testorg.com');
            insert u1;
            
            PermissionSetAssignment passign = new PermissionSetAssignment();
            passign.AssigneeId = u1.Id;
            passign.PermissionSetId = pset.Id;
            insert passign;
        }
        
        // Coming back to current user content , creating a Submission for the Survey
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c LIMIT 1];
        Trifecta_Survey_Submission__c submission =  TTISGTestUtils.createSubmission(survey.Id, u1.Id,'Admin Testing',false);

        

        System.runAs(u1) {  
            Trifecta_Survey_Question_Response__c response1,response2,response3;
            
            List<Trifecta_Survey_Question__c> qList = [Select Id,Name from Trifecta_Survey_Question__c ORDER BY Type__c];

            // Creating responses as Non Admin User but not current User
            response1 = TTISGTestUtils.createResponseForQuestion(submission.Id,qList[1].Id,'RadioButtonOption1');
            response2 = TTISGTestUtils.createResponseForQuestion(submission.Id,qList[0].Id,'CheckBoxOption1;CheckBoxOption2');
            response3 = TTISGTestUtils.createResponseForQuestion(submission.Id,qList[2].Id,'Sample Answert');
            
            List<Trifecta_Survey_Question_Response__c> responsesList = new List<Trifecta_Survey_Question_Response__c>{response1,response2,response3};
            insert responsesList;

            Boolean cameToException=false;
            String exceptionMessage;
            try{
                response1.Answer__c = 'RadioButtonOption2'; // If Response giving user try to edit the Response
                update response1;
            } 
            catch(Exception e) {
                cameToException = true;
                exceptionMessage = e.getMessage();
            }
            System.assertEquals(true,cameToException,'Failed Asserting that the unintended User Got Error Message , Updating His Reponse');
            System.assertEquals(true,exceptionMessage.contains('You Do Not Have Permissions to Modify the Record'),'Failed Asserting Error Message');
        } 
    }   

    @isTest    // Verifying the Deletions (Question , Choice , Submission , Survey) are working stopped by the non-eligible user
    static void testRecordDeletions() {
        // Querying up profiles required for the users below
        Profile platformprofile = [SELECT Id FROM Profile WHERE Name='Standard Platform User'];
        Profile systemadminprofile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        // Constructing required test users
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = systemadminprofile.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='surveymakeradminuser@testorg.com');  
        User u1;

        // Querying required permission which is to be assigned to non admin user
        PermissionSet pset = [Select Id,Name from PermissionSet Where Name = 'Survey_Maker_Permissions'];

        System.runAs(u2) {
            // Inserting PermissionSetAssignment and Non Admin user record as co-admin User to avoid Mixed DML Error
            u1 = new User(Alias = 'standt', Email='standarduser@testorg.com',FirstName='Admin', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = platformprofile.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='surveymakertestuser@testorg.com');
            insert u1;
            
            PermissionSetAssignment passign = new PermissionSetAssignment();
            passign.AssigneeId = u1.Id;
            passign.PermissionSetId = pset.Id;
            insert passign;
        }
        
        // Coming back to current user content , creating a Submission for the Survey
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c LIMIT 1];
        Trifecta_Survey_Submission__c submission =  TTISGTestUtils.createSubmission(survey.Id, u1.Id,'Admin Testing',false);

        Boolean cameToException=false;
        String exceptionMessage;
        
        System.runAs(u1) {  
            Trifecta_Survey_Question_Response__c response1,response2,response3;
            
            List<Trifecta_Survey_Question__c> qList = [Select Id,Name from Trifecta_Survey_Question__c ORDER BY Type__c];

            // Creating responses as Non Admin User but not current User
            response1 = TTISGTestUtils.createResponseForQuestion(submission.Id,qList[1].Id,'RadioButtonOption1');
            response2 = TTISGTestUtils.createResponseForQuestion(submission.Id,qList[0].Id,'CheckBoxOption1;CheckBoxOption2');
            response3 = TTISGTestUtils.createResponseForQuestion(submission.Id,qList[2].Id,'Sample Answert');
            
            List<Trifecta_Survey_Question_Response__c> responsesList = new List<Trifecta_Survey_Question_Response__c>{response1,response2,response3};
            insert responsesList;

            try {
                delete submission;     // Trying to delete the Submission which the user is not intended to be doing so
            }
            catch(Exception e){
                cameToException = true;
                exceptionMessage = e.getMessage();
            }
            System.assertEquals(true,cameToException,'Failed Asserting that the unintended User Got Error Message, Deleting Submission created by Submitter');
            System.assertEquals(true,exceptionMessage.contains('You Do Not Have Permissions to Delete the Record'),'Failed Asserting Error Message');

            try {
                delete qList;       // Trying to delete the Questions which the user is not intended to be doing so
            }
            catch(Exception e){
                cameToException = true;
                exceptionMessage = e.getMessage();
            }
            System.assertEquals(true,cameToException,'Failed Asserting that the unintended User Got Error Message , Deleting Questions created by Submitter');
            System.assertEquals(true,exceptionMessage.contains('You Do Not Have Permissions to Delete the Record'),'Failed Asserting Error Message');

            List<Trifecta_Survey_Question_Choice__c> questionChoices = [Select Id,Name,Value__c from Trifecta_Survey_Question_Choice__c Where Survey_Question__r.Type__c = 'Radio Button'];

            try {
                delete questionChoices;       // Trying to delete the Radio Button Question Choices which the user is not intended to be doing so
            }
            catch(Exception e){
                cameToException = true;
                exceptionMessage = e.getMessage();
            }
            System.assertEquals(true,cameToException,'Failed Asserting that the unintended User Got Error Message , Deleting the Question Choices created by Submitter');
            System.assertEquals(true,exceptionMessage.contains('You Do Not Have Permissions to Delete the Record'),'Failed Asserting Error Message');


            try {
                delete survey;       // Trying to delete the Survey which the user is not intended to be doing so
            }
            catch(Exception e){
                cameToException = true;
                exceptionMessage = e.getMessage();
            }
            System.assertEquals(true,cameToException,'Failed Asserting that the unintended User Got Error Message , Deleting the Survey itself');
            // Asserting that error message because trying to delete a master record to which he is not the owner nor on top of main user in role hierarchy
            System.assertEquals(true,exceptionMessage.contains('INSUFFICIENT_ACCESS_OR_READONLY'),'Failed Asserting Error Message');

        }

        // Running as Co Admin and trying to delet the Survey
        System.runAs(u2) {
            try {
                delete survey;       // Trying to delete the Survey which the Co Admin user is not intended to be doing so
            }
            catch(Exception e){
                cameToException = true;
                exceptionMessage = e.getMessage();
            }
            System.assertEquals(true,cameToException,'Failed Asserting that the Co Admin User Got Error Message , Deleting the Survey');
            System.assertEquals(true,exceptionMessage.contains('You Do Not Have Permissions to Delete the Record'),'Failed Asserting Error Message');
        }

    }

    @isTest // Verifying the Deletions (Question , Choice , Submission , Survey) are working good by the right eligible user
    static void testDeletionByRightUser() {
        List<Trifecta_Survey_Question_Choice__c> questionChoices = [Select Id,Name,Value__c from Trifecta_Survey_Question_Choice__c Where Survey_Question__r.Type__c = 'Radio Button'];

        Boolean cameToException=false;
        String exceptionMessage;

        try {
            delete questionChoices;       // Trying to delete the Radio Button Question Choices 
        }
        catch(Exception e){
            cameToException = true;
            exceptionMessage = e.getMessage();
        }
        System.assertEquals(false,cameToException,'Failed Asserting that the unintended User Got Error Message , Deleting the Question Choices created by Submitter');
        System.assertEquals(null,exceptionMessage,'Failed Asserting Error Message');
        System.assertEquals(0,[Select Count() from Trifecta_Survey_Question_Choice__c Where Survey_Question__r.Type__c = 'Radio Button']);
        // Successfull deletion of Survey Radio Button Question Choices

        // Preparing the Submission Object
        Profile platformprofile = [SELECT Id FROM Profile WHERE Name='Standard Platform User'];
        Profile systemadminprofile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        // Constructing required test users
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = systemadminprofile.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='surveymakeradminuser@testorg.com');  
        User u1;

        // Querying required permission which is to be assigned to non admin user
        PermissionSet pset = [Select Id,Name from PermissionSet Where Name = 'Survey_Maker_Permissions'];

        System.runAs(u2) {
            // Inserting PermissionSetAssignment and Non Admin user record as co-admin User to avoid Mixed DML Error
            u1 = new User(Alias = 'standt', Email='standarduser@testorg.com',FirstName='Admin', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = platformprofile.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='surveymakertestuser@testorg.com');
            insert u1;
            
            PermissionSetAssignment passign = new PermissionSetAssignment();
            passign.AssigneeId = u1.Id;
            passign.PermissionSetId = pset.Id;
            insert passign;
        }
        
        // Coming back to current user content , creating a Submission for the Survey
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c LIMIT 1];
        Trifecta_Survey_Submission__c submission =  TTISGTestUtils.createSubmission(survey.Id, u1.Id,'Admin Testing',false);
        
        try {
            delete submission;     // Trying to delete the Submission 
        }
        catch(Exception e){
            cameToException = true;
            exceptionMessage = e.getMessage(); 
        }
        System.assertEquals(false,cameToException,'Failed Asserting that the unintended User Got Error Message , Deleting the Survey Submission');
        System.assertEquals(null,exceptionMessage,'Failed Asserting Error Message');
        System.assertEquals(0,[Select Count() from Trifecta_Survey_Submission__c]);

        List<Trifecta_Survey_Question__c> qList = [Select Id,Name from Trifecta_Survey_Question__c ORDER BY Type__c];

        try {
            delete qList;       // Trying to delete the Questions
        }
        catch(Exception e){
            cameToException = true;
            exceptionMessage = e.getMessage();
        }
        System.assertEquals(false,cameToException,'Failed Asserting that the unintended User Got Error Message , Deleting Questions created by Submitter');
        System.assertEquals(null,exceptionMessage,'Failed Asserting Error Message');
        System.assertEquals(0,[Select Count() from Trifecta_Survey_Question__c]);

        try {
            delete survey;       // Trying to delete the Survey
        }
        catch(Exception e){
            cameToException = true;
            exceptionMessage = e.getMessage();
        }
        System.assertEquals(false,cameToException,'Failed Asserting that the Co Admin User Got Error Message , Deleting the Survey');
        System.assertEquals(null,exceptionMessage,'Failed Asserting Error Message');
        System.assertEquals(0,[Select Count() from Trifecta_Survey__c]);
    }
}