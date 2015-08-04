public with sharing class TTISGSurveyUtils {

	public static final String EMAIL_TEMPLATE_FOR_USER = 'TTISGSurvey Template User';
	public static final String EMAIL_TEMPLATE_FOR_CONTACT = 'TTISGSurvey Template Contact';
    public static final String SENDER_NAME = 'SurveyMaker';
    public static final String QUESTION_TYPE_RADIO = 'Radio Button';
	public static final String QUESTION_TYPE_CHECKBOX = 'Checkbox';
    public static final String QUESTION_TYPE_TEXT = 'Text';
    public static final String SEND_SURVEY_PAGE_URL = '/apex/TTISGSendSurvey?id=';
    public static final String DEFAULT_QUESTION_TITLE = 'Untitled Question';
    public static final String DEFAULT_SURVEY_NAME = 'Untitled Survey';
    public static final String DEFAULT_AUTO_RESPONSE = 'Thank you for your time and feedback';
    
	private TTISGSurveyUtils() {
		
	}

	/*
	* Returns true if the given Id is valid for the given object. Verifies
	* the validity basing on the key prefix of the idvalue.
	* @param idAsString - Id to validated
	* @param objectName - Name of the object to validate against.
	*/
	public static Boolean isValidId(String idAsString, String objectName) {

		//idAsString should be minimum of 4 characters long to verify the validity.
		if(!String.isBlank(idAsString) && idAsString.length() > 4 
			&& !String.isBlank(objectName) 
			&& Schema.getGlobalDescribe().get(objectName) != null) {
			return (idAsString.substring(0,3) == Schema.getGlobalDescribe().get(objectName).getDescribe().getKeyPrefix());	
		}
	 return false;
	}

	public static String stripDomainFromEmail(String emailAddress) {
		return emailAddress.substring(0,emailAddress.indexOf('@'));
	}

	public static List<SelectOption> getAllQuestionTypes() {
		List<SelectOption> options = new list<SelectOption>();
		Map<String, Schema.SObjectField> fieldMap = Trifecta_Survey_Question__c.getSObjectType().getDescribe().fields.getMap(); 
		// Get the list of picklist values for this field.
		List<Schema.PicklistEntry> values = fieldMap.get('Type__c').getDescribe().getPickListValues();
		// Add these values to the selectoption list.
		for(Schema.PicklistEntry a : values) { 
			options.add(new SelectOption(a.getLabel(), a.getValue())); 
		}
		return options;
	} 
	
	public static List<Trifecta_Survey__c> getUserOwnedSurveys(Id userId) {
		return [Select Id,Name,Help_Text__c,CreatedDate,Avg_Weightage__c,Edit__c,Quick_Send_Link__c FROM Trifecta_Survey__c Where OwnerId =:userId AND CreatedById =:userId];
	}

	public static String getCreateSurveyPage() {
		return [Select Id,Name from ApexPage Where Name = 'TTISGCreateSurvey'].Name;
	}
}