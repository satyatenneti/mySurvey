public class TTISGReportIDsController { 
    public TTISGReportIDsController (ApexPages.StandardController controller) {

    }

    public List<Report> surveyReportList { get;set; }
     
    public TTISGReportIDsController () {
    }

    public List<Report> getReportIds() { 
      
        List<Report> ReportList = [SELECT Id,Name,Description FROM Report WHERE Name like '%Avg Rating For This Survey%' OR Name like '%Survey Completion For This Survey%' limit 1000];  

        return ReportList;   
    }     
}