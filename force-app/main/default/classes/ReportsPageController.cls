public class ReportsPageController {
    
    public boolean getIsSandbox(){
        
        return [SELECT IsSandbox FROM Organization LIMIT 1][0].IsSandbox;
    }
    
    public string getcommunityUrl() {
        
        return UserInfo.getUserType() == 'PowerPartner' ? '/sales' : '';
    }
    
    public User usr {
        get{
            if(usr == null) usr = [select Id, name from user where id =: userinfo.getUserId() limit 1];    
            return usr;
        }
        set;}
    
    public List<Wrapper> wrap {get; set;}
    
    public integer sizeOfTable {get; set;}
    
    public ReportsPageController(){
        
        wrap = new List<Wrapper>();
        
        sizeOfTable = 150;
        
    }
    
    public PageReference PageAction(){
        
        wrap = new List<Wrapper>();
        
        List<AcctSeedERP__Sales_Order__c> Orders = [Select Id, Name, OwnerId, 
                                                    CreatedDate,
                                                    Commission_Rate_Sales_Rep__c,
                                                    (SELECT Id, AcctSeedERP__Sales_Order__c,
                                                     AcctSeedERP__Product__c, 
                                                     AcctSeedERP__Product__r.Commissionable_Product__c, 
                                                     AcctSeedERP__Total__c, 
                                                     AcctSeedERP__Unit_Price__c FROM 
                                                     AcctSeedERP__Sales_Order_Line__r where 
                                                     AcctSeedERP__Product__r.Commissionable_Product__c = true) FROM 
                                                    AcctSeedERP__Sales_Order__c where (OwnerId =:usr.id
                                                    OR Referral_Sales_Rep__c =:usr.id) AND 
                                                    AcctSeedERP__Total__c > 0
                                                    and Commission_Rate_Sales_Rep__c != null
                                                    order by Name desc];
        
        map<id, AcctSeedERP__Sales_Order__c> soMap = new map<id, AcctSeedERP__Sales_Order__c>(orders);
        
        // Keep only the sales order which do not have billings or billings have not been paid
        
        for(AcctSeed__Billing__c billing : [Select Id, AcctSeedERP__Sales_Order__c,
                                            AcctSeed__Received_Amount__c from 
                                            AcctSeed__Billing__c where 
                                            AcctSeedERP__Sales_Order__c in:soMap.keyset()]){
                                                
                                                if(soMap.containsKey(billing.AcctSeedERP__Sales_Order__c)){
                                                    // remove if payment is there
                                                    if(billing.AcctSeed__Received_Amount__c > 0){
                                                        soMap.remove(billing.AcctSeedERP__Sales_Order__c);
                                                    } 
                                                }
                                            }
        
        if(soMap.size() > 0){
            
            for(AcctSeedERP__Sales_Order__c o : soMap.values()){
                
                Decimal commissionDue = 0.00;
                
                List<AcctSeedERP__Sales_Order_Line__c> lines = o.AcctSeedERP__Sales_Order_Line__r;
                
                if(lines != null && !lines.isEmpty()){
                    
                    for(AcctSeedERP__Sales_Order_Line__c line : lines){
                        
                        commissionDue += line.AcctSeedERP__Total__c * (o.Commission_Rate_Sales_Rep__c / 100);
                    }
                    
                    if(commissionDue > 0) wrap.add(new Wrapper(o, commissionDue));
                }
            }
            
            if(!wrap.isEmpty()){
                
                sizeOfTable = (wrap.size() + 7) * 23;
                
            }
        }
        
        return null;
    }
    
    public class Wrapper{
        
        public AcctSeedERP__Sales_Order__c so {get; set;}
        public Decimal due {get; set;}
        
        public Wrapper(AcctSeedERP__Sales_Order__c s, decimal d){
            
            so = s;
            due = d;
            
        }
    }
}