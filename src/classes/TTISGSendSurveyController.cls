public with sharing class TTISGSendSurveyController {
    public List<UserDetail> userDetailsList{get;set;}
    public List<ContactDetail> contactDetailsList {get;set;}
    public List<SelectOption> groupsList {get;set;}

    public String sendTo {get;set;}
    public String selectedIds{get;set;}
    public String selectedGroups {get; set;}
    public String externalContacts {get; set;}
    public Id surveyId;
    public Integer balanceEmails {get; set;}
    public TTISGEmailServiceBase emailService;
    public Integer count;
    public Integer maximumEmails;


    public TTISGSendSurveyController() {
        surveyId = ApexPages.currentPage().getParameters().get('id');
        count = [select count() from Trifecta_Email_Sent__c where Email_Sent_Date__c =:System.today()];
        maximumEmails = (Integer)[select EmailsMaximumLimit__c from EmailsSentPerDay__c][0].EmailsMaximumLimit__c;
        init();
    }

    private void init() {
        emailService = new TTISGEmailServiceBase();
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

    public void sendForm() {
        
        //When no users are selected this will get an empty square branckets. Remove them before validation.
        List<String> submittedList = new List<String>();        

        if (sendTo.equals('others')) {
            submittedList = externalContacts.split(',');
            sendExternalEmails (submittedList);
        } else {
            if (sendTo.equals('users') || sendTo.equals('contacts')) {
                submittedList = selectedIds.split(',');
                sendInternalEmails(submittedList);
            } else if (sendTo.equals('groups')) {
                List<GroupMember> memberList =[select UserOrGroupId from GroupMember where GroupId = :selectedGroups];
                Set<String> otherGroups = new Set<String>();
                for (GroupMember eachMember : memberList) {
                    if (TTISGSurveyUtils.isValidId(String.valueOf(eachMember.UserOrGroupId), 'User')) {
                        submittedList.add(String.valueOf(eachMember.UserOrGroupId));
                    } else {
                        otherGroups.add(String.valueOf(eachMember.UserOrGroupId));
                    }
                }
                if (otherGroups.size() > 0) {
                    submittedList.addAll(getGroupsForIds(otherGroups));
                }
                if (submittedList.isEmpty()) {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected group doesn`t contain any Users')); 
                } else {
                    sendInternalEmails(submittedList);
                }
            }
        }
    }

    private Set<String> getGroupsForIds (Set<String> userOrGroupIds) {

        Set<String> output = new Set<String>();

        Set<String> nestedGroupIds = new Set<String>();
        List<GroupMember> records = [ SELECT Id, GroupId, UserOrGroupId from GroupMember where GroupId in :userOrGroupIds];
        for (GroupMember record:records) {
            if (TTISGSurveyUtils.isValidId(String.valueOf(record.UserOrGroupId), 'User')) {
                nestedGroupIds.add(record.UserOrGroupId);   
            } else {
                nestedGroupIds.add(record.UserOrGroupId);
            }
        }
        if (nestedGroupIds.size() > 0) {
            output.addAll(getGroupsForIds(nestedGroupIds));
        }
        return output;
    }

    private void sendInternalEmails(List<String> submittedList) {
        if(!submittedList.isEmpty()){
            List<Trifecta_Survey_Submission__c> submissionList = new List<Trifecta_Survey_Submission__c>();
            //create the submission records for every user/contact/group member selected
            Map<Id, User> userList = new Map<Id, User>();
            Map<Id, Contact> contactList = new Map<Id, Contact>();
            if (TTISGSurveyUtils.isValidId(submittedList[0], 'User')) {
                userlist = new Map<Id, User>([SELECT Id, FirstName, LastName from User where id in :submittedList]);
            }
            else {
                contactList = new Map<Id, Contact>([SELECT Id, Name from Contact where id in :submittedList]);
            }
            for(String eachId : submittedList) {
                String name;
                if (userList.size() > 0) {
                    name = userlist.get(eachId).FirstName +' '+ userlist.get(eachId).LastName;
                }
                else {
                    name = contactList.get(eachId).Name;
                }
                submissionList.add(new Trifecta_Survey_Submission__c(Survey__c = surveyId, Submitted_To__c = eachId.trim(), Submitted_To_Name__c = name, Completed__c = false ));
            }
            insert submissionList;
            emailService.sendInternalEmailNotifications(submissionList, surveyId);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your Survey form has been sent successfully.'));     
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
                    String name = eachId.substring(0,eachId.indexOf('@'));
                    submissionList.add(new Trifecta_Survey_Submission__c(Survey__c = surveyId, Submitted_To__c = eachId.trim(), Submitted_To_Name__c = name, Completed__c = false ));
                    sentMails.add(new Trifecta_Email_Sent__c(Email_Sent_Date__c = System.today(), Email_Sent_Address__c = eachId.trim()));
                }
                insert submissionList;
                insert sentMails;
                externalContacts = '';
                emailService.sendExternalEmailNotifications(submissionList, surveyId);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your Survey form has been successfully sent.'));     
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You should select atleast one recipent.'));
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