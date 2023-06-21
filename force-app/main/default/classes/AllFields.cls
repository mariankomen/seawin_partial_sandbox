public class AllFields {

    public static String Fields(string objName, List<String> fieldExceptions){

        List<string> fieldNames = new List<string>();
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = 
        schemaMap.get(objName).getDescribe().fields.getMap();

        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            if(!fieldExceptions.contains(dfield.getname())){

                fieldNames.add(dfield.getname());
            }
        }

        String fieldstring = String.join(fieldNames,',');

        return fieldstring;

    }
}