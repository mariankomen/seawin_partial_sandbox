public class BookKeeperDashboardController {
    
    Public List<MainWrapper> SOPieData {get; set;}
    Public List<MainWrapper> BillingPieData {get; set;}
    
    public BookKeeperDashboardController(){
        
        List<ValuesWrapper> ValuesList = null;
        
        List<AcctSeed__Billing__c> Billings = [SELECT Name, AcctSeed__Age__c, AcctSeed__Total__c FROM AcctSeed__Billing__c where
                                    AcctSeed__Age__c != 'Closed' and OwnerId  =: UserInfo.getUserId() and 
                                               AcctSeed__Status__c = 'Posted' and 
                                              AcctSeed__Type__c != 'Credit Memo'];
        
        Decimal BillingTotal = 0.00;
        
        if(!Billings.IsEmpty()){
            BillingPieData = new List<MainWrapper>();
            ValuesList =  new List<ValuesWrapper>();
            
            for(AcctSeed__Billing__c b : Billings){
                
                BillingTotal += b.AcctSeed__Total__c;
                
                 
                ValuesList.add(new ValuesWrapper(b.Name, b.AcctSeed__Total__c, b.AcctSeed__Age__c));

            }
            BillingPieData.add(new MainWrapper(ValuesList, BillingTotal));
        }
        
        List<AggregateResult> agrSO = [Select AcctSeedERP__Customer__r.Name customer, Sum(AcctSeedERP__Total__c) total from
                                    AcctSeedERP__Sales_Order__c group by AcctSeedERP__Customer__r.Name order by 
                                    Sum(AcctSeedERP__Total__c) Desc Limit 10];
        
        if(!agrSO.IsEmpty()){
            SOPieData = new List<MainWrapper>();
            ValuesList =  new List<ValuesWrapper>(); 
            
            for(AggregateResult a : agrSO){
                
                
                ValuesList.add(new ValuesWrapper((String)a.get('customer'), (Decimal)a.get('total'), ''));

            }
            SOPieData.add(new MainWrapper(ValuesList, 0.00));
        }
    }
    
    public class MainWrapper{
        
        public List<ValuesWrapper> Data {get; set;}
        public Decimal Total {get; set;} 
            
        public MainWrapper(List<ValuesWrapper> d, decimal t){
            this.Data = d;
            this.Total = t;
        }
    }
    public class ValuesWrapper{
        
        public string Name {get; set;}
        public Decimal Amount {get; set;}
        public String Age {get; set;}
            
        public ValuesWrapper(string n, Decimal a, String g){
            this.Name = n;
            this.Amount = a;
            this.Age = g;
        }
    }
}