@isTest(seeAllData = true)
private class TTISGReportIDsControllerTest {
	
	@isTest 
	static void getReportIdsTest() {
		
		Trifecta_Survey__c survey = TTISGTestUtils.createSurvey('Trifecta Sample Survey');

		ApexPages.StandardController stdController = new ApexPages.StandardController(survey);

		TTISGReportIDsController extension = new TTISGReportIDsController(stdController);

		System.assertEquals(2,extension.reportIds.size(),'Failed Asserting Report Collection Size');
		
		Set<String> orgReportNames = new Set<String>();
		for(Report eachReport : extension.reportIds) {
			orgReportNames.add(eachReport.Name);
		}
		
		System.assertEquals(true,orgReportNames.contains('Survey Completion For This Survey'),'Failed Asserting for the Report Name 1');
		System.assertEquals(true,orgReportNames.contains('Avg Rating For This Survey'),'Failed Asserting for the Report Name 2');

	}
	
}