public class UserInfoController {
    
    public List<String> ids{ get; set; }
    
    public String type { get; set; }
    
    public List<User> users {
        get {
            if(ids == null || ids.size() == 0) {
                return null;
            }
            return getUserData(ids);
        }
        
        set;
    }
    
    private List<User> getUserData(List<String> ids) {
        return new List<User>([SELECT Id, FirstName, LastName, smallphotourl FROM User where Id in :ids]);
    }
    
}