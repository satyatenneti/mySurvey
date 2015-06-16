public with sharing class SendSurveyController {
    public List<SelectOption> usersList {get;set;}
    public List<SelectOption> contactsList {get;set;}
    public List<SelectOption> groupsList {get;set;}
    public List<SelectOption> typeList {get;set;}
    public String selectedUsers;
    public String selectedContacts;
    public String selectedGroups;
    public String selectedType;
    public Id surveyId;
    public SendSurveyController() {
    	surveyId = ApexPages.currentPage().getParameters().get('id');
        usersList = new List<SelectOption>();
  		contactsList = new List<SelectOption>();
  		groupsList = new List<SelectOption>();
  		for (User eachActiveUser :[SELECT Id,Name FROM User WHERE IsActive = true]) {
  			usersList.add(new SelectOption(eachActiveUser.Name, eachActiveUser.Id));
  		}
  		for (Contact eachContact :[SELECT Id,Name FROM Contact]) {
  			contactsList.add(new SelectOption(eachContact.Name, eachContact.Id));
  		}
  		for (Group eachGroup :[SELECT Id,Name FROM Group WHERE Type = 'Regular']) {
  			groupsList.add(new SelectOption(eachGroup.Name, eachGroup.Id));
  		}
  		typeList.add(new SelectOption('Internal','I'));
  		typeList.add(new SelectOption('External','E'));
    }
    
    public void sendForm() {
    	List<String> submittedList = new List<String>();
    	String s1 = schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix();
    	if (selectedUsers != null) {
    		submittedList = selectedUsers.split(';');
    	}
    	if (selectedContacts != null) {
    		submittedList = selectedContacts.split(';');
    	}
    	if (selectedGroups != null) {
    		List<Id> submittedGroups =new List<Id>();
    		submittedGroups = selectedGroups.split(';');
    		List<GroupMember> memberList =[select UserOrGroupId from GroupMember where GroupId in :submittedGroups];
    		for (GroupMember eachMember : memberList) {
    			submittedList.add(String.valueOf(eachMember.UserOrGroupId));
    		}
    	}
    	sendEmailNotifications(submittedList);	
    }
    private void sendEmailNotifications (List<String> idList) {
    	List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    	List<Trifecta_Survey_Submission__c> submissionList = new List<Trifecta_Survey_Submission__c>();

    	EmailTemplate et = [select Id from EmailTemplate where name ='sample'];
    	for(String eachId : idList) {
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    	mail.setTemplateId(et.Id);
	    	mail.setTargetObjectId(eachId);
	    	Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});	
    		if(result[0].success) {
    			submissionList.add(new Trifecta_Survey_Submission__c(Survey__c = surveyId, Submitted_To__c = eachId, Completed__c = false ));
    		}
    	}
    	insert submissionList;
    }
}