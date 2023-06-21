public class OverrideProductPageExtension {
  public String Kit_Parents_Products_Id { get; set; }
  public String Kit_Children_Products_Id { get; set; }
  public String Parts_Products_Id { get; set; }
  public String Parts_Parent_Products_Id { get; set; }

  public OverrideProductPageExtension(ApexPages.StandardController std) {
    // For Kit Product Part
    List<EntityDefinition> kitproductpart = [
      SELECT DurableId
      FROM EntityDefinition
      WHERE DeveloperName = 'Kit_Product_Part'
      LIMIT 1
    ];

    if (!kitproductpart.isEmpty()) {
      List<FieldDefinition> kppfield = [
        SELECT DurableId, DeveloperName
        FROM FieldDefinition
        WHERE
          EntityDefinitionId = :kitproductpart[0].DurableId
          AND (DeveloperName = 'Kit_Children'
          OR DeveloperName = 'Kit_Product_Part')
      ];
      
      if (!kppfield.isEmpty()) {
        for (FieldDefinition fd : kppfield) {
          if (fd.DeveloperName == 'Kit_Children') {
            Parts_Products_Id = extractId((String)fd.DurableId);
          } else if (fd.DeveloperName == 'Kit_Product_Part') {
            Parts_Parent_Products_Id = extractId((String)fd.DurableId);
          }
        }
      }
      
    }
    // For Kit/Product Part
    List<EntityDefinition> productpart = [
      SELECT DurableId
      FROM EntityDefinition
      WHERE DeveloperName = 'Product_Part'
      LIMIT 1
    ];

    if (!productpart.isEmpty()) {
      List<FieldDefinition> ppfield = [
        SELECT DurableId, DeveloperName
        FROM FieldDefinition
        WHERE
          EntityDefinitionId = :productpart[0].DurableId
          AND (DeveloperName = 'Kit_Children'
          OR DeveloperName = 'Kit_Product')
      ];
      
      if (!ppfield.isEmpty()) {
        for (FieldDefinition fd : ppfield) {
          if (fd.DeveloperName == 'Kit_Children') {
            Kit_Parents_Products_Id = extractId((String)fd.DurableId);
          } else if (fd.DeveloperName == 'Kit_Product') {
            Kit_Children_Products_Id = extractId((String)fd.DurableId);
          }
        }
      }
      
    }
  }
  public String extractId(String DurableId) {
    String fieldId = '';

    if (DurableId.indexOf('.') > -1) {
      fieldId = DurableId.split('\\.')[1];
    } else {
      fieldId = DurableId;
    }

    return fieldId;
  }
}