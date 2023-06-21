public with sharing class DependentPicklistExtension {

    /*****************************************************************************************************
    *   @method       : getDependentPicklistValues
    *   @description  : Current method returns map of dependent fields per object
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }

        /* Invoking
            Map<String,List<String>> dependentPicklistValuesMap = getDependentPicklistValues(Opportunity.Sub_Stage__c);
        */
        return dependentPicklistValues;
    }

    /*****************************************************************************************************
    *   @method       : getOpportunityStages
    *   @description  : Current method returns list of picklist values of Oppportunity Stages
    *   @return       : List<String>
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public static List<String> getOpportunityStages()
    {
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> picklist_values = new List<String>();
        for(Schema.PicklistEntry s:ple){
            picklist_values.add(s.getLabel());
        } 
        return picklist_values;
    }

    /*****************************************************************************************************
    *   @method       : getObjectPicklistMap
    *   @description  : Current method returns map of picklist label and value
    *   @return       : Map<String, String>
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public static Map<String, String> getObjectPicklistMap(Schema.sObjectField objectApiName)
    {
        Map<String, String> product_categories_map = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = objectApiName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:ple){
            product_categories_map.put(s.getLabel(), s.getValue());
        } 
        return product_categories_map;
    }
}