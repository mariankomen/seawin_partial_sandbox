@isTest
public class MetaDataServiceUtilityTest {
    
    @isTest static void runTest(){

        set<string> urls = new set<string>();
		urls.add('http://PleaseDeleteOnlyForTest.com');
		MetadataServiceUtility.createRemoteSiteSettings(urls);
        
    }

}