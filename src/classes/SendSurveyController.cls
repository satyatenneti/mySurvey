public with sharing class SendSurveyController {
    public List<UserDetail> userDetailsList{get;set;}
    public List<ContactDetail> contactDetailsList {get;set;}
    public List<SelectOption> groupsList {get;set;}

    public String sendTo {get;set;}
    public String selectedUsers {get; set;}
    public String selectedContacts {get; set;}
    public String selectedGroups {get; set;}
    public String externalContacts {get; set;}
    public Id surveyId;
    public Integer balanceEmails {get; set;}
    public EmailServiceBase emailService;
    public Integer count;
    public Integer maximumEmails;


    public SendSurveyController() {
        surveyId = ApexPages.currentPage().getParameters().get('id');
        count = [select count() from Trifecta_Email_Sent__c where Email_Sent_Date__c =:System.today()];
        maximumEmails = (Integer)[select EmailsMaximumLimit__c from EmailsSentPerDay__c][0].EmailsMaximumLimit__c;
        init();
    }

    private void init() {
        emailService = new EmailServiceBase();
        userDetailsList = getUserDetails();
        contactDetailsList = getContactDetails();
        groupsList = getGroups();
        balanceEmails = getBalance();
    }
   
    private List<UserDetail> getUserDetails() {
        List<UserDetail> userDetailsList = new List<UserDetail>();
        for (User user :[SELECT Id,Name,FirstName,LastName,Smallphotourl FROM User WHERE IsActive = true]) {
            userDetailsList.add(new UserDetail(user));
        }
        return userDetailsList;
    }

    private List<ContactDetail> getContactDetails() {
        
        List<ContactDetail> contactDetailsList = new List<ContactDetail>();
        for (Contact contact :[SELECT Id,Name,FirstName,LastName FROM Contact]) {
            contactDetailsList.add(new ContactDetail(contact));
        }
        return contactDetailsList;
    }

    private List<SelectOption> getGroups() {
        groupsList = new List<SelectOption>();
        for (Group eachGroup :[SELECT Id,Name FROM Group WHERE Type = 'Regular']) {
            groupsList.add(new SelectOption(eachGroup.Id, eachGroup.Name));
        }
        return groupsList;
    }
    private Integer getBalance() {
        return maximumEmails - count ;
    }
    private List<String> getSelectedUserIds() {
        List<String> selectedUsersList = new List<String>();
        for(UserDetail userDetail : userDetailsList) {
            if(userDetail.selected)
                selectedUsersList.add(userDetail.user.Id);            
        }
        return selectedUsersList;
    }

    private List<String> getSelectedContactIds() {
        List<String> selectedContactList = new List<String>();
        for(ContactDetail contactDetail : contactDetailsList) {
            if(contactDetail.selected)
                selectedContactList.add(contactDetail.contact.Id);            
        }
        return selectedContactList;
    }

    public void sendForm() {
        
        //When no users are selected this will get an empty square branckets. Remove them before validation.
        selectedGroups = (selectedGroups != null ) ? selectedGroups.remove('[]') : null;
        
        List<String> submittedList = new List<String>();        

        if (sendTo.equals('others')) {
            submittedList = externalContacts.split(',');
            sendExternalEmails (submittedList);
        } else {
            if (sendTo.equals('users')) {
                submittedList = getSelectedUserIds();
            } else if (sendTo.equals('contacts')) {
                submittedList = getSelectedContactIds();
            } else if (sendTo.equals('groups')) {
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

    public class UserDetail {

        public UserDetail(User user) {
            this.user = user;
        }
        public User user {get;set;}
        public Boolean selected{get;set;}
    }

    public class ContactDetail {

        public ContactDetail(Contact contact) {
            this.contact = contact;
        }
        public Contact contact {get;set;}
        public Boolean selected{get;set;}
    }
}