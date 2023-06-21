@isTest(SeeAllData=true)
public class RHX_TEST_AcctSeedERP_Inventory_Balance {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM AcctSeedERP__Inventory_Balance__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AcctSeedERP__Inventory_Balance__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}