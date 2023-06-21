@isTest
public class OpportunityLineItemAlternateImgExtTest {

    @testSetup static void createData(){  
        
        Document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        //document.ContentType = 'application/pdf';
        //document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'ajmal testDoc';
        //document.FolderId = [select id from folder where name = 'My Test Docs'].id;
        document.FolderId =UserInfo.getUserId();
        insert document;

    }
    
    @isTest static void StartProcess(){
        
        Document doc = [select id from Document where Name = 'ajmal testDoc' limit 1];
        OpportunityLineItemAlternateImgExtension obj = new OpportunityLineItemAlternateImgExtension();
        obj.contentName = 'test contentname';
        obj.contentType = 'image/jpeg';
        obj.content = blob.valueOf('test blob');
        obj.upload();        
    }
    
}