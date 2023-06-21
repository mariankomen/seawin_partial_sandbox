public class OpportunityHandler {
    
    public static void checkDuplicate(List<Opportunity> opportunityData){
        
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Boolean counter = false;
        String accountId = null;
        String shippingCity = null;
        String shippingPostalCode = null;

        String queryString = 'Select AccountId, Name, Shipping_City__c, Shipping_PostalCode__c ';
        queryString += ' From Opportunity WHERE ( ';
                      
        for(Opportunity opp: opportunityData){

            opportunityIds.add(opp.Id);
            accountId = opp.accountId;
            shippingCity = opp.Shipping_City__c;
            shippingPostalCode = opp.Shipping_PostalCode__c;
            queryString += (counter) ? ' AND ' : '';
            queryString += ' (Shipping_City__c =:shippingCity AND Shipping_PostalCode__c =:shippingPostalCode) ';
            counter = true;
        }
        queryString += ') AND ID NOT IN :opportunityIds';
        List<Opportunity> matchedOpportunituesData = Database.query(queryString);
        
        for(Opportunity opp: opportunityData){
            for(Opportunity matchedOpp: matchedOpportunituesData){
                if((opp.Shipping_City__c == matchedOpp.Shipping_City__c) && 
                   (opp.Shipping_PostalCode__c == matchedOpp.Shipping_PostalCode__c)){
                	boolean matched = checkNamePartialMatch(opp.Name, matchedOpp.Name);
                    if(matched && !opp.Allow_Duplicate_Opportunity__c){
                        if(!Test.isRunningTest()){
                            opp.addError('Duplicate opportunity found. '+
                                         '<a style=\'color: blue;\' href=\'/'+matchedOpp.id+'\'> Go to Opportunity ('+matchedOpp.Name+')</a>'+
                                         '<br>To create this opportunity anyway, please mark the \'Allow Duplicate Opportunity\' checkbox <br>', False);
                        }
                    }    
                }
            }
        }
	}
    
    public static boolean checkNamePartialMatch(string nameOne, string nameTwo){
        
        nameOne = (nameOne == null) ? '' : nameOne;
        nameTwo = (nameTwo == null) ? '' : nameTwo;
        boolean matched = false;
        if(nameOne == nameTwo){
            matched = true;
        }
        else{
            List<String> nameOneList = nameOne.split(' ');
        	List<String> nameTwoList = nameTwo.split(' ');
            if((nameOneList.size() >=3) && (nameTwoList.size() >= 3)){
                if((nameOneList[0] == nameTwoList[0]) && 
                   (nameOneList[1] == nameTwoList[1]) && 
                   (nameOneList[2] == nameTwoList[2])){
                    matched = true;
                }
            }
        }
        
        return matched;
    }
}