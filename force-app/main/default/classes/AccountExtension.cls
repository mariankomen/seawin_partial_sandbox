public class AccountExtension {

    //This indicates if warning message exist or not. If not then hide the lockedAccountExtension page, so that spacing will not come
    public Boolean hasMessage {get; set;}
    Public AccountExtension(ApexPages.StandardController std){
        
        LockedAccountExtension obj = new LockedAccountExtension(std);
        hasMessage = obj.hasMessage;
        
    }
}