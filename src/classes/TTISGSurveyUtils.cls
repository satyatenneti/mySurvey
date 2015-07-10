public with sharing class TTISGSurveyUtils {

	public static final String EMAIL_TEMPLATE_FOR_USER = 'TTISGSurvey Template User';
	public static final String EMAIL_TEMPLATE_FOR_CONTACT = 'TTISGSurvey Template Contact';
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
		List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Radio Button', 'Radio Button'));
        options.add(new SelectOption('Text', 'Text'));
        options.add(new SelectOption('Checkbox', 'Checkbox'));
        return options;
	}
}