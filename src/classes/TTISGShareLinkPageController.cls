public with sharing class TTISGShareLinkPageController {
	public String submissionId;
	public String surveyId;

	public TTISGShareLinkPageController() {
		submissionId = ApexPages.currentPage().getParameters().get('Id');
		surveyId = ApexPages.currentPage().getParameters().get('Survey');
	}
	public PageReference createChatterPostAndRedirect(){

	  PageReference pref = new PageReference('/apex/TTISGShareSubmissionToChatter');
	  pref.getParameters().put('Id',submissionId);
	  pref.getParameters().put('Survey',surveyId);

	  Trifecta_Survey__c survey = new TTISGSurveyService().getSurveyById(surveyId);

      Attachment a = new Attachment();
      a.Body = pref.getContentAsPDF();
      a.ParentID = submissionId;
      a.Name = survey.Name+'.pdf';
      insert a;
	  
	  FeedItem chatterItem = new FeedItem();
	  chatterItem.parentId = a.ParentId;
	  chatterItem.ContentData = a.body;
	  chatterItem.ContentFileName = a.Name;
	  chatterItem.ContentDescription = Default_Attachment_Description__c.getOrgDefaults().Description__c != null ? Default_Attachment_Description__c.getOrgDefaults().Description__c : 'Sample Description';
	  insert chatterItem;

	  return new PageReference('/_ui/core/userprofile/UserProfilePage?u='+UserInfo.getUserId());
	}
}