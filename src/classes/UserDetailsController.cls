public class UserDetailsController {
	public String userIds{get;set;}
	public List<User> userDetails{get;set;}
	public List<String> ids{get;set;}

    public void loadUserDetails() {

    	ids = new List<Id>();
    	for(Id userid : userIds.split(',')) {
    		System.debug('listed ids ------- '+userid);
    		ids.add(userid);

    	}
    	userDetails = getUserData(ids);
    	System.debug('userdata  ------- '+userDetails.size());
    }

    private List<User> getUserData(List<String> ids) {
        return new List<User>([SELECT Id, FirstName, LastName, smallphotourl FROM User where Id in :ids]);
    }
}