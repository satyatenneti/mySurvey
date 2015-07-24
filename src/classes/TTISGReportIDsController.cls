public class TTISGReportIDsController { 
    public TTISGReportIDsController (ApexPages.StandardController controller) {

    }

    public List<Report> reportIds { 
    	get{
    		return new TTISGSurveyService().getReportsForDisplay();  
    	}
    	set; 
    }     
}