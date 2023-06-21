public class CalculateTaxController {
    
    public String opId {get; set;}
    public Boolean showDetails {get; set;}
    public Boolean HideAll {get; set;}
    public Opportunity opp {get; set;}
    
    public String selectedTaxValue {get; set;}
    public string selectedTaxId {get; set;}
    
    public map<id, id> ProdstoPbeIdsMap {get; set;}
    public map<id, string> prodstoNameMap {get; set;}
    
    public List<SelectOption> TaxRates {get; set;}
    public List<Wrapper> w {get; set;}
    
    public CalculateTaxController(){
        
        opId = ApexPages.currentPage().getParameters().get('id');
        opp = new Opportunity();
        ProdstoPbeIdsMap = new map<id, id>();
        prodstoNameMap = new map<id, string>();
        
        TaxRates = new List<SelectOption>();
        w = new List<Wrapper>();
        
        showDetails = false;
        HideAll = false;
        
        opp = [select Id, Name, AccountId, Account.Name, 
               Gl_Account_Variable_1__c from Opportunity where id =:opId limit 1];
        
        findAccountTaxes();
        CreateWrapper();
    }
    
    public void findAccountTaxes(){
        
        list<AcctSeed__Account_Tax__c> taxes = [SELECT Id, Name, AcctSeed__Account__c, AcctSeed__Rate__c,
                                                AcctSeed__Tax_Rate__r.Name, AcctSeed__Tax_Rate__r.Id,
                                                AcctSeed__Tax_Rate__r.AcctSeed__Tax_Rate__c, AcctSeed__Tax_Type__c FROM 
                                                AcctSeed__Account_Tax__c where 
                                                AcctSeed__Account__c =: opp.AccountId AND (AcctSeed__Tax_Type__c = 'Sales' OR 
                                                                                           AcctSeed__Tax_Type__c = 'Sales & Purchase')];
        set<id> prodIds = new set<id>(); 
        
        if(taxes.isEmpty()){
            hideAll = true;
            apexpages.addMessage(new ApexPages.message(apexpages.Severity.Error, 
                                                       'There is no Tax record available for the <a href="/'+opp.AccountId+'" style="font-size: 96%; margin: 0px;">'+opp.Account.Name+'</a> Account with Tax Type "Sales" or "Sales & Purchase".'));
        }else{
            
            for(AcctSeed__Account_Tax__c aat : taxes){
                prodIds.add(aat.AcctSeed__Tax_Rate__r.id); 
                prodstoNameMap.put(aat.AcctSeed__Tax_Rate__r.Id, aat.AcctSeed__Tax_Rate__r.Name);
            }
            
            if(prodIds.size() > 0){
                
                list<pricebookentry> pbeIds = [select id, product2id, product2.name from pricebookentry 
                                               where product2id in:prodIds];
                
                if(!pbeIds.isEmpty()){
                    for(pricebookentry pbe : pbeIds){
                        ProdstoPbeIdsMap.put(pbe.Product2Id, pbe.id);
                    }
                }
                
                if(pbeIds.size() == prodIds.size()){
                    
                    showDetails = true;
                    
                    for(AcctSeed__Account_Tax__c tx : taxes){
                        
                        TaxRates.add(new SelectOption(tx.AcctSeed__Tax_Rate__r.id + '-' + 
                                                      String.ValueOf(tx.AcctSeed__Tax_Rate__r.AcctSeed__Tax_Rate__c.setScale(2)), 
                                                      tx.AcctSeed__Tax_Rate__r.Name + ' (' + 
                                                      String.ValueOf(tx.AcctSeed__Tax_Rate__r.AcctSeed__Tax_Rate__c.setScale(2)) 
                                                      + '%)'));
                        
                    }   
                    
                    selectedTaxId = TaxRates[0].getValue().split('-')[0];
                    selectedTaxValue = TaxRates[0].getValue().split('-')[1];
                    
                }else{
                    
                    string errorStr = '';
                    
                    for(id i : prodIds){
                        if(ProdstoPbeIdsMap.size() > 0){
                            
                            Id pbeId = ProdstoPbeIdsMap.get(i);
                            
                            if(pbeId == null){
                                errorStr += '<br/>Tax product <a href="/'+ i +'" style="font-size: 96%; margin: 0px;">'+prodstoNameMap.get(i)+'</a> has not been added to the current PriceBook.';                        
                            }
                        }else{
                            errorStr += '<br/>Tax product <a href="/'+ i +'" style="font-size: 96%; margin: 0px;">'+prodstoNameMap.get(i)+'</a> has not been added to the current PriceBook.'; 
                        }
                    }
                    
                    apexpages.addMessage(new ApexPages.message(apexpages.Severity.Error, errorStr));
                }
            }
        }
    }
    
    public void CreateWrapper(){
        
        map<id, opportunitylineitem> oliMap = new map<id, opportunitylineitem>();
        
        list<opportunitylineitem> lines = [select id, name, product2id, totalprice,
                                           product2.AcctSeed__Accounting_Type__c from opportunitylineitem where 
                                           opportunityid =:opId and (not name like '%tax%')];
        
        if(!lines.isEmpty()){
            
            oliMap = new map<id, opportunitylineitem>(lines);
            set<id> prodIds = new set<id>();
            
            Boolean HasTaxableProduct = true;
            Integer TaxableCount = 0;
            
            for(opportunitylineitem ol : lines){
                if(ol.product2.AcctSeed__Accounting_Type__c != 'Taxable Product' || 
                   ol.product2.AcctSeed__Accounting_Type__c == null){
                       hasTaxableProduct = false;
                       TaxableCount++;
                   }else{
                       prodIds.add(ol.product2id);
                   }
            }
            
            if(!hasTaxableProduct && TaxableCount == lines.size()){
                showDetails = false;
                Apexpages.addMessage(new ApexPages.message(ApexPages.Severity.Info, 
                                                           'There is no taxable product associated with a opportunity product line.'));
            }else{
                if(!hasTaxableProduct && !HideAll){
                    
                    Apexpages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 
                                                               'Some products were not added because they are not Taxable Products. To make a Product taxable, go to the Product and choose the option Taxable Product in the Tax Type field.'));
                }
                
                list<pricebookentry> pbes = [select id, product2id, product2.Name, Product2.ProductCode,
                                             unitprice, product2.AcctSeed__Unit_Cost__c from 
                                             pricebookentry where product2id in:prodIds];
                
                if(!pbes.IsEmpty()){
                    
                    map<id, pricebookentry> pbeMap = new map<id, pricebookentry>();
                    
                    for(pricebookentry p : pbes){
                        
                        pbeMap.put(p.product2id, p);
                        
                    }
                    
                    if(selectedTaxId != null && selectedTaxValue != null){
                        
                        for(opportunitylineitem li : lines){
                            if(li.product2.AcctSeed__Accounting_Type__c == 'Taxable Product'){
                                pricebookentry pb = pbeMap.get(li.Product2Id);
                                w.add(new wrapper(selectedTaxId, selectedTaxValue, pb, li, 
                                                  li.TotalPrice * Decimal.ValueOf(selectedTaxValue) / 100));
                            }
                        }
                    }
                }
            }
        }else{
            
            showDetails = false;
            Apexpages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 
                                                       'No Opportunity Products found.'));
        }
    }
    
    public PageReference Back(){
        
        PageReference page = new PageReference('/'+ opp.id);
        page.setRedirect(true);
        
        return page;
        
    }
    
    public PageReference CalculateTax(){
        
        list<OpportunityLineItem> oppList = new list<OpportunityLineItem>();
        
        for(Wrapper wl : w){
            
            oppList.add(new OpportunityLineItem(OpportunityId = Opp.Id,
                                                UnitPrice = wl.taxAmount,
                                                Product2Id = wl.selectedTaxId,
                                                PricebookEntryId = ProdstoPbeIdsMap.get(wl.selectedTaxId),
                                                item_description__c = wl.pbe.Product2.Name + ' Tax',
                                                Quantity = 1,
                                                AcctSeed__GL_Account_Variable_1__c = Opp.Gl_Account_Variable_1__c));
        }
        
        if(!oppList.IsEmpty()){
            
            system.debug(oppList);
            
            insert oppList;
            
            Pagereference page = new PageReference('/' + opp.id);
            page.setRedirect(true);
            
            return page;
            
        }
        return null;
    }
    
    public class Wrapper {
        
        public string selectedTaxId {get; set;}
        public string selectedTax {get; set;}
        public pricebookentry pbe {get; set;}
        public opportunitylineitem oli {get; set;}
        public decimal taxAmount {get; set;}
        public string taxPbeId {get; set;}
        
        public Wrapper(string i, string st, pricebookentry p, opportunitylineitem o, decimal t){
            selectedTaxId = i;
            selectedTax = st;
            pbe = p;
            oli = o;
            taxAmount = t;
        }
    }
}