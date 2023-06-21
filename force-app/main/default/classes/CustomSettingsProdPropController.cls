public with sharing class CustomSettingsProdPropController {

    public List<SelectOption> picklist_fields {get; set;}
    public List<SelectOption> selected_value {get; set;}
    public Master_Product_Properties__c primary_properties {get;set;}
    public List<String> declared_values {get;set;}
    public static final List<String> exclude_fields = new List<String>{'LastReferencedDate',

                                                                        'LastViewedDate',
                                                                        'IsDeleted',
                                                                        'ExternalDataSourceId',
                                                                        'RecordTypeId',
                                                                        'SystemModstamp',
                                                                        'LastModifiedById',
                                                                        'LastModifiedDate',
                                                                        'CreatedById',
                                                                        'CreatedDate',
                                                                        'IsArchived'};
    public CustomSettingsProdPropController() {
        picklist_fields = new List<SelectOption>();
        selected_value = new List<SelectOption>();
        primary_properties = Master_Product_Properties__c.getInstance('Primary');
        getAlreadyDeclaredValues();
        makeSelectListOfAllPicklistFields();

    }


    public void getAlreadyDeclaredValues(){
        if(primary_properties != null && primary_properties.Picklist_Properties__c != null){
            declared_values = primary_properties.Picklist_Properties__c.split(';');
            Map<String,String> picklist_fields = getPicklistTypeFieldsByLabel('Product2');
            for(String value: declared_values){
                selected_value.add(new SelectOption(value, picklist_fields.get(value)));
            }
        }
    }
   
    public void makeSelectListOfAllPicklistFields(){
        Map<String,String> all_picklist_fields = getPicklistTypeFields('Product2');
        for(String field: all_picklist_fields.keySet()){
            if((declared_values != null && !declared_values.contains(all_picklist_fields.get(field))) || declared_values == null){
                picklist_fields.add(new SelectOption(all_picklist_fields.get(field), field));
            }
        }
    }


    public void saveConfiguration(){
        String separatedValues = '';
        for(SelectOption option: selected_value){
            separatedValues += (String)option.getValue() + ';';
        }
        system.debug('primary_properties: '+primary_properties);
        Master_Product_Properties__c property;
        if(primary_properties != null){
            property = primary_properties;
        }else{
            property = new Master_Product_Properties__c();
            property.Name = 'Primary';
        }
        property.Picklist_Properties__c = separatedValues;

        try{
            if(primary_properties != null){
                update property;
                
            }else{
                insert property;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 
                                                           'Configurations has been updated successfully!'));
        }catch(Exception e){
            system.debug(e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                           'Error during saving configurations. '+e.getMessage()));
        }

        // system.debug(selected_value[0].getValue());
    }

    public static Map<String,String> getPicklistTypeFields(String strObjectName) {
        Set<String> k = new Set<String>();
        Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe();
        Map<String,String> mapOfPicklistTypeFields = new  Map<String,String>();
        for(Schema.SObjectField fields :detail.get(strObjectName).getDescribe().fields.getMap().Values()) {
            if(!exclude_fields.contains(fields.getDescribe().getName())
            && String.valueOf(fields.getDescribe().getType()) != 'ID'
            && String.valueOf(fields.getDescribe().getType()) != 'REFERENCE'
            ) { 
                mapOfPicklistTypeFields.put(fields.getDescribe().getLabel() , fields.getDescribe().getName());
                k.add(String.valueOf(fields.getDescribe().getType()));
            }
        }
        system.debug(JSON.serialize(k));
        return mapOfPicklistTypeFields;
    }
    
    public static Map<String,String> getPicklistTypeFieldsByLabel(String strObjectName) {
        Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe();
        Map<String,String> mapOfPicklistTypeFields = new  Map<String,String>();
        for(Schema.SObjectField fields :detail.get(strObjectName).getDescribe().fields.getMap().Values()) {
            //if(fields.getDescribe().getType() == Schema.DisplayType.PICKLIST) { 
                mapOfPicklistTypeFields.put(fields.getDescribe().getName() , fields.getDescribe().getLabel());
            //}
        }
        return mapOfPicklistTypeFields;
    }
}