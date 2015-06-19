public with sharing class SendSurveyController {
    public List<SelectOption> usersList {get;set;}
    public List<SelectOption> contactsList {get;set;}
    public List<SelectOption> groupsList {get;set;}
    public String selectedUsers {get; set;}
    public String selectedContacts {get; set;}
    public String selectedGroups {get; set;}
    public String selectedType {get; set;}
    public Id surveyId;
    public SendSurveyController() {
        surveyId = ApexPages.currentPage().getParameters().get('id');
        init();
    }
    private void init() {
        usersList = getActiveUsers();
        contactsList = getContacts();
        groupsList = getGroups();
    }
    private List<SelectOption> getActiveUsers() {
        List<SelectOption> usersList = new List<SelectOption>();
        for (User eachActiveUser :[SELECT Id,Name FROM User WHERE IsActive = true]) {
            usersList.add(new SelectOption(eachActiveUser.Id, eachActiveUser.Name));
        }
        return usersList;
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
        List<String> submittedList = new List<String>();
        if (selectedUsers.length() > 3) {
            submittedList = selectedUsers.substring(1,selectedUsers.length()-1).split(',');
        }
        else if (selectedContacts.length() > 3) {
            submittedList = selectedContacts.substring(1,selectedContacts.length()-1).split(',');
        }
        else if (selectedGroups.length() > 3) {
            List<Id> submittedGroups =new List<Id>();
            submittedGroups = selectedGroups.substring(1,selectedGroups.length()-1).split(',');
            List<GroupMember> memberList =[select UserOrGroupId from GroupMember where GroupId in :submittedGroups];
            for (GroupMember eachMember : memberList) {
                submittedList.add(String.valueOf(eachMember.UserOrGroupId));
            }
        }
        new EmailServiceBase().sendEmailNotifications(submittedList,surveyId);  
    }
    public String getSurveyName() {
        return [select Name from Trifecta_Survey__c where Id =:surveyId].Name;
    }
}