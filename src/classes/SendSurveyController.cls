public with sharing class SendSurveyController {
    public List<SelectOption> usersList {get;set;}
    public List<SelectOption> contactsList {get;set;}
    public List<SelectOption> groupsList {get;set;}
    public String selectedUsers {get; set;}
    public String selectedContacts {get; set;}
    public String selectedGroups {get; set;}
    public String selectedType {get; set;}
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
        //When no users are selected this will get an empty square branckets. Remove them before validation.
        selectedUsers = (selectedUsers != null ) ? selectedUsers.remove('[]') : null;
        selectedContacts = (selectedContacts != null ) ? selectedContacts.remove('[]') : null;
        selectedGroups = (selectedGroups != null ) ? selectedGroups.remove('[]') : null;

        if (!String.isEmpty(selectedUsers)) {
            submittedList = selectedUsers.substring(1,selectedUsers.length()-1).split(',');
        }
        else if (! String.isEmpty(selectedContacts)) {
            submittedList = selectedContacts.substring(1,selectedContacts.length()-1).split(',');
        }
        else if (! String.isEmpty(selectedGroups)) {
            List<Id> submittedGroups =new List<Id>();
            submittedGroups = selectedGroups.substring(1,selectedGroups.length()-1).split(',');
            List<GroupMember> memberList =[select UserOrGroupId from GroupMember where GroupId in :submittedGroups];
            for (GroupMember eachMember : memberList) {
                submittedList.add(String.valueOf(eachMember.UserOrGroupId));
            }
        }

        if(!submittedList.isEmpty()){
			List<Trifecta_Survey_Submission__c> submissionList = new List<Trifecta_Survey_Submission__c>();
            //create the submission records for every user/contact/group member selected
            for(String eachId : submittedList) {
                submissionList.add(new Trifecta_Survey_Submission__c(Survey__c = surveyId, Submitted_To__c = eachId.trim(), Completed__c = false ));
            }
            insert submissionList;

            emailService.sendEmailNotifications(submissionList, surveyId);      
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You should select atleast one recipent (or) group.'));
        }
        
    }
    public Trifecta_Survey__c getSurvey() {
        return [select Name from Trifecta_Survey__c where Id =:surveyId];
    }
}