public class MetadataServiceUtility {
    
  public static boolean createRemoteSiteSettings(set<String> urls){
      
      
      	boolean isSucessful = false;
      	Map<string,string> RemoteSiteMap = new Map<string,string>();
      
      	for(String u : urls){
          	System.Url setting = new System.Url(u);
      		String name = setting.getProtocol() + '_' + setting.getHost().replaceAll('[.-]', '_');
            string uri = setting.getProtocol() + '://' + setting.getHost();
            
            RemoteSiteMap.put(name,uri);
      	}

        List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>();
        for(string s: RemoteSiteMap.keyset()){
            MetadataService.RemoteSiteSetting remoteSiteDetails = new MetadataService.RemoteSiteSetting();
            remoteSiteDetails.fullName = s;
            remoteSiteDetails.disableProtocolSecurity  = false;
            remoteSiteDetails.isActive  = true;
            remoteSiteDetails.url=RemoteSiteMap.get(s);
            allMetadataList.add(remoteSiteDetails);
        }        
        if(allMetadataList.size()>0){
            // only run this code if its not testing because here its callout
            MetadataService.MetadataPort service = createService();
            
            List<MetadataService.UpsertResult> results = new List<MetadataService.UpsertResult>();
			
            if(!Test.isRunningTest()) results = service.upsertMetadata(allMetadataList); 
            
            for(MetadataService.UpsertResult result: results){
                    if(result.success){
                        isSucessful=true;
                    }else{
                        system.debug('****error while adding remote site settings:'+result.errors[0].message);
                    }

            }


        }
        return isSucessful;
    }  
  
    private static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    
}