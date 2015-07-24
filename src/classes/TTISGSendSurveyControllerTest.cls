@isTest
private class TTISGSendSurveyControllerTest {
	@testSetup
    static void setData() {
        Trifecta_Survey__c survey = TTISGTestUtils.createSurvey('Sample Survey');
        List<Trifecta_Survey_Question__c> surveyQuestions = TTISGTestUtils.createSurveyQuestions(survey.Id);
        List<Id> surveyQuestionIds = TTISGSObjectUtils.pluckIds(surveyQuestions,'Id');
        TTISGTestUtils.createSurveyChoices(surveyQuestionIds);
    }

	@isTest static void sendSurveytoUser() {
		//Trifecta_Survey__c survey = setData();
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];

        EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 20);
        insert maxlimit;
        
        Test.setCurrentPage(Page.TTISGSendSurvey);
        ApexPages.currentPage().getParameters().put('Id',survey.Id);
        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
        sendSurvey.sendTo = 'users';
        sendSurvey.selectedIds= UserInfo.getUserId();
        sendSurvey.sendForm();
	}

	@isTest static void sendSurveytoContact() {
		//Trifecta_Survey__c survey = setData();
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];

        EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 20);
        insert maxlimit;

        Contact newContact = new Contact(LastName ='pavan kumar', Email ='test@test.com');
        insert newContact;

        Test.setCurrentPage(Page.TTISGSendSurvey);
        ApexPages.currentPage().getParameters().put('Id',survey.Id);
        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
        sendSurvey.sendTo = 'contacts';
        sendSurvey.selectedIds= newContact.Id;
        sendSurvey.sendForm();
	}

	@isTest static void sendSurveytoGroup() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = new User(Alias = 'standt', Email='corpuser2@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='abc2@testorg.com');
		insert u;
		System.runAs(u) {
			Group testGroup = new Group(Name = 'testGroup');
        	insert testGroup;
	        GroupMember gpm = new GroupMember(UserOrGroupId = u.id, GroupId = testGroup.Id);
    	    insert gpm;

			//Trifecta_Survey__c survey = setData();
            Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];

        	EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 20);
	        insert maxlimit;

        
    	    Test.setCurrentPage(Page.TTISGSendSurvey);
        	ApexPages.currentPage().getParameters().put('Id',survey.Id);
	        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
    	    sendSurvey.sendTo = 'groups';
        	sendSurvey.selectedGroups= testGroup.Id;
        	sendSurvey.sendForm();
        }
	}
	@isTest static void sendSurveytoGroupInGroup() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = new User(Alias = 'standt', Email='corpuser2@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='abc2@testorg.com');
		insert u;
		System.runAs(u) {
			Group testGroup = new Group(Name = 'testGroup');
        	insert testGroup;
        	Group childGroup = new Group(Name = 'testGroup');
        	insert childGroup;
        	
	        GroupMember gpm = new GroupMember(UserOrGroupId = u.id, GroupId = childGroup.Id);
    	    insert gpm;
    	    GroupMember gpm1 = new GroupMember(UserOrGroupId = childGroup.id, GroupId = testGroup.Id);
    	    insert gpm1;

			//Trifecta_Survey__c survey = setData();
            Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];

        	EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 20);
	        insert maxlimit;

        
    	    Test.setCurrentPage(Page.TTISGSendSurvey);
        	ApexPages.currentPage().getParameters().put('Id',survey.Id);
	        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
    	    sendSurvey.sendTo = 'groups';
        	sendSurvey.selectedGroups= testGroup.Id;
        	sendSurvey.sendForm();
        }
	}

	@isTest static void sendSurveytoNone() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = new User(Alias = 'standt', Email='corpuser2@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='abc2@testorg.com');
		insert u;
		System.runAs(u) {
			Group testGroup = new Group(Name = 'testGroup');
        	insert testGroup;
	        
			//Trifecta_Survey__c survey = setData();
            Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];

        	EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 20);
	        insert maxlimit;

        
    	    Test.setCurrentPage(Page.TTISGSendSurvey);
        	ApexPages.currentPage().getParameters().put('Id',survey.Id);
	        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
    	    sendSurvey.sendTo = 'groups';
        	sendSurvey.selectedGroups= testGroup.Id;
        	sendSurvey.sendForm();
        }
	}

	@isTest static void sendSurveytoExternal() {
		//Trifecta_Survey__c survey = setData();
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];

        EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 20);
        insert maxlimit;

        Test.setCurrentPage(Page.TTISGSendSurvey);
        ApexPages.currentPage().getParameters().put('Id',survey.Id);
        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
        sendSurvey.sendTo = 'others';
        sendSurvey.externalContacts= 'test@test.com';
        sendSurvey.sendForm();
	}

	@isTest static void getSurveyTest() {
		//Trifecta_Survey__c survey = setData();
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];

		EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 20);
        insert maxlimit;
		Test.setCurrentPage(Page.TTISGSendSurvey);
        ApexPages.currentPage().getParameters().put('Id',survey.Id);
        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
        sendSurvey.surveyId = survey.Id;
        Trifecta_Survey__c newSurvey = sendSurvey.getSurvey();
	}

	@isTest static void moreMailsTest() {
		
		//Trifecta_Survey__c survey = setData();
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];

        EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 0);
	    insert maxlimit;
     
   	    Test.setCurrentPage(Page.TTISGSendSurvey);
        ApexPages.currentPage().getParameters().put('Id',survey.Id);
        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
        sendSurvey.sendTo = 'others';
        sendSurvey.externalContacts= 'test@test.com';
        sendSurvey.sendForm();
	}

	@isTest static void mailsExceededTest() {
		
		//Trifecta_Survey__c survey = setData();
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];

        EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 1);
	    insert maxlimit;
     
   	    Test.setCurrentPage(Page.TTISGSendSurvey);
        ApexPages.currentPage().getParameters().put('Id',survey.Id);
        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
        sendSurvey.sendTo = 'others';
        sendSurvey.externalContacts= 'test@test.com,testing@test.com';
        sendSurvey.sendForm();
	}

    @isTest static void anonymousSurveyTest() {
        //Trifecta_Survey__c survey = setData();
        Trifecta_Survey__c survey = [Select Id,Name from Trifecta_Survey__c];
        survey.Is_Anonymous__c = true;
        update survey;
        
        EmailsSentPerDay__c maxlimit = new EmailsSentPerDay__c(EmailsMaximumLimit__c = 20);
        insert maxlimit;
        Test.setCurrentPage(Page.TTISGSendSurvey);
        ApexPages.currentPage().getParameters().put('Id',survey.Id);
        TTISGSendSurveyController sendSurvey = new TTISGSendSurveyController();
        sendSurvey.sendTo = 'users';
        sendSurvey.selectedIds= UserInfo.getUserId();
        sendSurvey.sendForm();
    }
}