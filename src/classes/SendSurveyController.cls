public with sharing class SendSurveyController {
    public List<SelectOption> usersList {get;set;}
   // public List<String> selectedUsersList {get;set;}
    public List<SelectOption> contactsList {get;set;}
    public List<SelectOption> groupsList {get;set;}

    public List<TestUser> userDetailsList{get;set;}
    public String selectedUsers {get; set;}
    public String selectedContacts {get; set;}
    public String selectedGroups {get; set;}
    public String externalContacts {get; set;}
    public Id surveyId;
    public EmailServiceBase emailService;
    public SendSurveyController() {
        surveyId = ApexPages.currentPage().getParameters().get('id');
        init();
    }
    private void init() {
        emailService = new EmailServiceBase();
        usersList = getActiveUsers();
        contactsList = getContacts();
        groupsList = getGroups();
        userDetailsList = getActiveUserList();
    }
    private List<SelectOption> getActiveUsers() {
        List<SelectOption> usersList = new List<SelectOption>();
        for (User eachActiveUser :[SELECT Id,Name FROM User WHERE IsActive = true]) {
            usersList.add(new SelectOption(eachActiveUser.Id, eachActiveUser.Name));
        }
        return usersList;
    }
    private List<TestUser> getActiveUserList() {
        List<TestUser> userDetailsList = new List<TestUser>();
        for (User eachActiveUser :[SELECT Id,Name,FirstName,LastName,Smallphotourl FROM User WHERE IsActive = true]) {
            userDetailsList.add(new TestUser(eachActiveUser));
        }
        return userDetailsList;
    }
    private List<SelectOption> getContacts() {
        contactsList = new List<SelectOption>();
        for (Contact eachContact :[SELECT Id,Name FROM Contact]) {
            contactsList.add(new SelectOption(eachContact.Id, eachContact.Name));
        }
        return contactsList;
    }
    private List<SelectOption> getGroups() {
        groupsList = new List<SelectOption>();
        for (Group eachGroup :[SELECT Id,Name FROM Group WHERE Type = 'Regular']) {
            groupsList.add(new SelectOption(eachGroup.Id, eachGroup.Name));
        }
        return groupsList;
    }
    public void sendForm() {

        for(TestUser selectedUsers : userDetailsList) {
            if(selectedUsers.selected)
            System.debug('name-'+selectedUsers.user.FirstName);
        }
        List<String> submittedList = new List<String>();
        
        //When no users are selected this will get an empty square branckets. Remove them before validation.
        selectedUsers = (selectedUsers != null ) ? selectedUsers.remove('[]') : null;
        selectedContacts = (selectedContacts != null ) ? selectedContacts.remove('[]') : null;
        selectedGroups = (selectedGroups != null ) ? selectedGroups.remove('[]') : null;
        
        if (! String.isEmpty(externalContacts)){
            submittedList = externalContacts.split(',');
            sendExternalEmails (submittedList);
        } else {
            if (!String.isEmpty(selectedUsers)) {
                submittedList = selectedUsers.substring(1,selectedUsers.length()-1).split(',');
            } else if (! String.isEmpty(selectedContacts)) {
                submittedList = selectedContacts.substring(1,selectedContacts.length()-1).split(',');
            } else if (! String.isEmpty(selectedGroups)) {
                List<Id> submittedGroups =new List<Id>();
                submittedGroups = selectedGroups.substring(1,selectedGroups.length()-1).split(',');
                List<GroupMember> memberList =[select UserOrGroupId from GroupMember where GroupId in :submittedGroups];
                for (GroupMember eachMember : memberList) {
                    submittedList.add(String.valueOf(eachMember.UserOrGroupId));
                }
            }
            sendInternalEmails(submittedList);
        }
    }
    private void sendInternalEmails(List<String> submittedList) {
        if(!submittedList.isEmpty()){
            List<Trifecta_Survey_Submission__c> submissionList = new List<Trifecta_Survey_Submission__c>();
            //create the submission records for every user/contact/group member selected
            for(String eachId : submittedList) {
                submissionList.add(new Trifecta_Survey_Submission__c(Survey__c = surveyId, Submitted_To__c = eachId.trim(), Completed__c = false ));
            }
            insert submissionList;
            emailService.sendInternalEmailNotifications(submissionList, surveyId);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your Survey form has been successfully submitted.'));     
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You should select atleast one recipent (or) group.'));
        }
    }
    private void sendExternalEmails(List<String> submittedList) {
        Integer emailFlag = 0;
        Integer count = [select count() from Trifecta_Email_Sent__c where Email_Sent_Date__c =:System.today()];
        Integer maximumEmails = (Integer)[select EmailsMaximumLimit__c from EmailsSentPerDay__c][0].EmailsMaximumLimit__c;
        if(!submittedList.isEmpty()){
            if (count == maximumEmails ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Number of Emails sent per day Exceeds Maximum Limit'));
            } else if ((count + submittedList.size()) > maximumEmails) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have only '+ (maximumEmails - count) +' more Email(s) left to sent'));
            } else {
                List<Trifecta_Survey_Submission__c> submissionList = new List<Trifecta_Survey_Submission__c>();
                List<Trifecta_Email_Sent__c> sentMails = new List<Trifecta_Email_Sent__c>();
                for(String eachId : submittedList) {
                    submissionList.add(new Trifecta_Survey_Submission__c(Survey__c = surveyId, Submitted_To__c = eachId.trim(), Completed__c = false ));
                    sentMails.add(new Trifecta_Email_Sent__c(Email_Sent_Date__c = System.today(), Email_Sent_Address__c = eachId.trim()));
                }
                insert submissionList;
                insert sentMails;
                externalContacts = '';
                emailService.sendExternalEmailNotifications(submissionList, surveyId);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your Survey form has been successfully submitted.'));     
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You should select atleast one recipent (or) group.'));
        }
    }
    public Trifecta_Survey__c getSurvey() {
        return [select Name from Trifecta_Survey__c where Id =:surveyId];
    }

    public class TestUser {

        public TestUser(User u) {
            user = u;
            selected = false;
        }
        public User user {get;set;}
        public Boolean selected{get;set;}
    }
}