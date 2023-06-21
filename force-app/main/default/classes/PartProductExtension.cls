public class PartProductExtension {
    
    Public string Subtitle {get; set;}
    Public AcctSeed__Product_Part__c Part {get; set;}
    Public String retURL {get; set;}
    Public String URL {get; set;}
    
    public PartProductExtension(ApexPages.StandardController std){
        
        Id EditId = (Id)std.getId();
        
        Part = new AcctSeed__Product_Part__c();
        
        String parentId = ApexPages.currentPage().getParameters().get('parentId');
        String childId = ApexPages.currentPage().getParameters().get('childId');
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        URL = '/apex/PartProductPage?parentId='+parentId+'&childId='+childId+'&retURL='+retURL;
        
        if(EditId != null){

        	Part = [select id,name,Kit_Product__c,Kit_Children__c,ownerId,AcctSeed__Quantity__c
                   from AcctSeed__Product_Part__c where id=:EditId limit 1]; 
            
            URL = '/apex/PartProductPage?parentId='+Part.Kit_Product__c+'&childId=&retURL='+retURL;
        }
        
        Part.OwnerId = UserInfo.getUserId();
        
        if(!String.isEmpty(parentId)){
           Part.Kit_Product__c = parentId;
        }
        
        if(!String.isEmpty(childId)){
           Part.Kit_Children__c = childId;
        }
        Subtitle = EditId != null ? 'Edit Kit' : !String.isEmpty(parentId) && EditId == null ? 
            'Add Product': 'Add to Kit';
        
        
    }
    
    public PageReference SavePart(){
        
        try{
            upsert part;
    	}catch(Exception ex){
            system.debug('Exception has occured.');
            system.debug(ex.getMessage());
        }
        
        PageReference page = new PageReference(retURL);
        
        page.setRedirect(true);
        
        return page;
        
    }
    
    public PageReference Back(){
        
        PageReference page = new PageReference(retURL);
        
        page.setRedirect(true);
        
        return page;
        
    }
    public PageReference SaveAndMore(){
        
        try{
        	upsert Part;
    	}catch(Exception ex){
            system.debug('Exception has occured.');
            system.debug(ex.getMessage());
        }
        
        PageReference page = new PageReference(URL);
        
        page.setRedirect(true);
        
        return page;
        
    }
}