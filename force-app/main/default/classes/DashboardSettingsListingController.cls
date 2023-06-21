public class DashboardSettingsListingController {

    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
         
    public DashboardSettingsListingController(){
        size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
    }
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {

                String fields = 'Id, Name, Default_GL_Account_Variable__c, Alias, Username, Profile.Name';

                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    'Select ' + fields + 
        ' from user where isactive=true and (usertype=\'Standard\' or usertype=\'PowerPartner\') order by name asc'));
            }
            setCon.setPageSize(size);  
            noOfRecords = setCon.getResultSize();
            return setCon;
        }
        set;
    }

    public List<User> getUserList() {
        return (List<User>) setCon.getRecords();
    }

    public PageReference refreshPageSize() {
        setCon.setPageSize(size);
        return null;
   }
}