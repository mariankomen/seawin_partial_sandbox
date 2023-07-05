/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 06-27-2023
 * @last modified by  : Marian Lyzhychka
**/
public class PicklistValuesController {
 
  public class MyPickListInfo {
    public String validFor;
  }

  public static Map<String, List<String>> getFieldDependencies(
    String objectName,
    String controllingField,
    String dependentField
  ) {
    Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

    Schema.DescribeSObjectResult describeResult = objType.getDescribe();
    Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap()
      .get(controllingField)
      .getDescribe();
    Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap()
      .get(dependentField)
      .getDescribe();

    List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
    List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

    for (Schema.PicklistEntry currControllingValue : controllingValues) {
      
      controllingInfo.put(currControllingValue.getLabel(), new List<String>());
    }

    for (Schema.PicklistEntry currDependentValue : dependentValues) {
      String jsonString = JSON.serialize(currDependentValue);

      MyPickListInfo info = (MyPickListInfo) JSON.deserialize(
        jsonString,
        MyPickListInfo.class
      );

      String hexString = EncodingUtil.convertToHex(
          EncodingUtil.base64Decode(info.validFor)
        )
        .toUpperCase();

      

      Integer baseCount = 0;

      for (Integer curr : hexString.getChars()) {
        Integer val = 0;

        if (curr >= 65) {
          val = curr - 65 + 10;
        } else {
          val = curr - 48;
        }

        if ((val & 8) == 8) {

          controllingInfo.get(controllingValues[baseCount + 0].getLabel())
            .add(currDependentValue.getLabel());
        }
        if ((val & 4) == 4) {

          controllingInfo.get(controllingValues[baseCount + 1].getLabel())
            .add(currDependentValue.getLabel());
        }
        if ((val & 2) == 2) {

          controllingInfo.get(controllingValues[baseCount + 2].getLabel())
            .add(currDependentValue.getLabel());
        }
        if ((val & 1) == 1) {
  
          controllingInfo.get(controllingValues[baseCount + 3].getLabel())
            .add(currDependentValue.getLabel());
        }

        baseCount += 4;
      }
    }


    return controllingInfo;
  }

  public static Map<String, List<DependentPicklistOptionWrapper>> getFieldDependenciesWrap(
    String objectName,
    String controllingField,
    String dependentField
  ) {
      Map<String, List<DependentPicklistOptionWrapper>> controllingInfo = new Map<String, List<DependentPicklistOptionWrapper>>();

      Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

      Schema.DescribeSObjectResult describeResult = objType.getDescribe();
      Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap()
        .get(controllingField)
        .getDescribe();
      Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap()
        .get(dependentField)
        .getDescribe();

      List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
      List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

      for (Schema.PicklistEntry currControllingValue : controllingValues) {
        
        controllingInfo.put(currControllingValue.getValue(), new List<DependentPicklistOptionWrapper>());
      }

      for (Schema.PicklistEntry currDependentValue : dependentValues) {
        String jsonString = JSON.serialize(currDependentValue);

        MyPickListInfo info = (MyPickListInfo) JSON.deserialize(
          jsonString,
          MyPickListInfo.class
        );

        String hexString = EncodingUtil.convertToHex(
            EncodingUtil.base64Decode(info.validFor)
          )
          .toUpperCase();

        

        Integer baseCount = 0;

        for (Integer curr : hexString.getChars()) {
          Integer val = 0;

          if (curr >= 65) {
            val = curr - 65 + 10;
          } else {
            val = curr - 48;
          }

          if ((val & 8) == 8) {

            controllingInfo.get(controllingValues[baseCount + 0].getValue())
              .add(new DependentPicklistOptionWrapper(currDependentValue.getLabel(), currDependentValue.getValue()));
          }
          if ((val & 4) == 4) {

            controllingInfo.get(controllingValues[baseCount + 1].getValue())
            .add(new DependentPicklistOptionWrapper(currDependentValue.getLabel(), currDependentValue.getValue()));
          }
          if ((val & 2) == 2) {

            controllingInfo.get(controllingValues[baseCount + 2].getValue())
            .add(new DependentPicklistOptionWrapper(currDependentValue.getLabel(), currDependentValue.getValue()));
          }
          if ((val & 1) == 1) {
    
            controllingInfo.get(controllingValues[baseCount + 3].getValue())
            .add(new DependentPicklistOptionWrapper(currDependentValue.getLabel(), currDependentValue.getValue()));
          }

          baseCount += 4;
        }
      }


      return controllingInfo;
  }


  public class DependentPicklistOptionWrapper{
    public String label {get;set;}
    public String apiname {get;set;}

    public DependentPicklistOptionWrapper(String label, String apiname){
      this.label = label;
      this.apiname = apiname;
    }
  }
}