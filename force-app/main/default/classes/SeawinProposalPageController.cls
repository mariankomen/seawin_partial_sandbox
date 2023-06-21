public class SeawinProposalPageController {
    private string quoteId {get; set;}
    
    public string OpptyName {get; set;}
    public set<string> Categories {get; set;}
    
    // Sales rep information
    public string Name {get; set;}
    public string UserName {get; set;}
    public string Email {get; set;} 
    public string Phone {get; set;}
    public string MobilePhone {get; set;}
    public string Website {get; set;}
    
    public boolean isTeam {get; set;}
    public boolean ShowerDoorChecked {get; set;}
    public boolean WallSurroundsChecked {get; set;}
    
    public boolean LEDMirrorsChecked {get; set;}
    public boolean ShowerPansChecked {get; set;}
    
    public boolean BarnDoorsChecked {get; set;}
    public boolean VanitiesChecked {get; set;}
    
    public map<string, boolean> CheckboxMap {get; set;}
    
    public SeawinProposalPageController(){

        IsTeam = false;
        
        UserName = UserInfo.getName();
        
        ShowerDoorChecked = false;
        WallSurroundsChecked = false;
        
        LEDMirrorsChecked = false;
        ShowerPansChecked = false;
        
        BarnDoorsChecked = false;
        VanitiesChecked = false;
        
        CheckboxMap = new map<string, boolean>();
        
        // initialize the checkboxes
        CheckboxMap.put('Shower Doors', false);
        CheckboxMap.put('Wall Surrounds', false);
        CheckboxMap.put('Mirrors', false);
        CheckboxMap.put('Shower Pans', false);
        CheckboxMap.put('Barn Doors', false);
        CheckboxMap.put('Vanities', false);
        CheckboxMap.put('Interior Doors', false);
        CheckboxMap.put('Accessories', false);
        
        quoteId = ApexPages.currentPage().getParameters().get('quoteid');
        
        Categories = new set<string>();
        
        Categories.add('Shower Doors');
        Categories.add('Wall Surrounds');
        
        Categories.add('Mirrors');
        Categories.add('Shower Pans');
        
        Categories.add('Barn Doors');
        Categories.add('Vanities');

        Categories.add('Interior Doors');
        Categories.add('Accessories');
        
        List<Quote> quote = [select opportunity.sales_rep_o__r.name,
        opportunity.Owner.name,
        opportunity.Owner.MobilePhone,
        opportunity.Owner.Phone,
        opportunity.Owner.Email,
        opportunity.Owner.Website__c,
                             opportunity.sales_rep_o__r.IsTeam__c, 
                             opportunity.sales_rep_o__r.email__c,
                             opportunity.sales_rep_o__r.phone__c,
                             opportunity.sales_rep_o__r.mobile__c,
                             opportunity.sales_rep_o__r.website__c,
                             opportunity.name from quote where id =:quoteId limit 1];
        
        if(!quote.isEmpty()){
            
            List<AggregateResult> lines = [select product2.category__c category from quotelineitem where quoteid =:quoteId
                                          group by product2.category__c];

            for(AggregateResult a : lines){
                
                string category = (String)a.get('category');
                
                if(category.contains('Shower Door') || category.contains('Shower Enclosure') 
                   || category.contains('Bath Tub Door')){
   
                    CheckboxMap.put('Shower Doors', true);
                    
                }else if(category.contains('Wall Surround') || category.contains('Wall Surround Accessories')){
                    CheckboxMap.put('Wall Surrounds', true);
                    
                }else if(category.contains('Mirror')){
                    CheckboxMap.put('Mirrors', true);
                    
                }else if(category.contains('Shower Pans')){
                    CheckboxMap.put('Shower Pans', true);
                    
                }else if(category.contains('Barn Door')){
                    CheckboxMap.put('Barn Doors', true);
                    
                }else if(category.contains('Vanities')){
                    CheckboxMap.put('Vanities', true);
                }else if(category.contains('Interior Doors')){
                    CheckboxMap.put('Interior Doors', true);
                }else if(category.contains('Bathroom Accessories')){
                    CheckboxMap.put('Accessories', true);
                }                
            }

            IsTeam = quote[0].Opportunity.Sales_rep_o__r.IsTeam__c;
            
            opptyname = quote[0].opportunity.name;
            
            string m = IsTeam ? quote[0].opportunity.Owner.Phone : quote[0].Opportunity.Sales_rep_o__r.phone__c;
            string mp = IsTeam ? quote[0].opportunity.Owner.MobilePhone : quote[0].Opportunity.Sales_rep_o__r.mobile__c;
            
            Name = IsTeam ? quote[0].Opportunity.Sales_rep_o__r.name + ' (' + quote[0].opportunity.Owner.name + ')' : 
            quote[0].Opportunity.Sales_rep_o__r.name;
            Email = IsTeam ? quote[0].opportunity.Owner.Email : quote[0].Opportunity.Sales_rep_o__r.email__c;
            Phone = m == null ? null : this.FormatPhone(m);
            MobilePhone = mp == null ? null : this.FormatPhone(mp);
            Website = IsTeam ? quote[0].opportunity.Owner.Website__c : quote[0].Opportunity.Sales_rep_o__r.website__c;
            
        }
    }
    private String FormatPhone(String Phone) {
        string nondigits = '[^0-9]';
        string PhoneDigits;
        
        // remove all non numeric
        PhoneDigits = Phone.replaceAll(nondigits,'');
        
        // 10 digit: reformat with dashes
        if (PhoneDigits.length() == 10) 
            return PhoneDigits.substring(0,3) + '-' +
            PhoneDigits.substring(3,6) + '-' +
            PhoneDigits.substring(6,10);
        // 11 digit: if starts with 1, format as 10 digit 
        if (PhoneDigits.length() == 11) {
            if (PhoneDigits.substring(0,1) == '1') {
                return  PhoneDigits.substring(1,4) + '-' +
                    PhoneDigits.substring(4,7) + '-' +
                    PhoneDigits.substring(7,11);
            }
        }
        
        // if it isn't a 10 or 11 digit number, return the original because
        // it may contain an extension or special information
        return( Phone );
    }
}