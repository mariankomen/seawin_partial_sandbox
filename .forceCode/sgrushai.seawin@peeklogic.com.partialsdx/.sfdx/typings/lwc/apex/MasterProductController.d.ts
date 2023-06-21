declare module "@salesforce/apex/MasterProductController.fetchPicklistsValues" {
  export default function fetchPicklistsValues(): Promise<any>;
}
declare module "@salesforce/apex/MasterProductController.fetchFieldsExceptSelectedProperties" {
  export default function fetchFieldsExceptSelectedProperties(): Promise<any>;
}
declare module "@salesforce/apex/MasterProductController.combineFieldWithType" {
  export default function combineFieldWithType(param: {sobject_api: any}): Promise<any>;
}
declare module "@salesforce/apex/MasterProductController.getMasterProduct" {
  export default function getMasterProduct(param: {masterId: any}): Promise<any>;
}
declare module "@salesforce/apex/MasterProductController.getAllPicklistFieldsWithOptions" {
  export default function getAllPicklistFieldsWithOptions(param: {strObjectName: any}): Promise<any>;
}
declare module "@salesforce/apex/MasterProductController.checkProductSKUAvailability" {
  export default function checkProductSKUAvailability(param: {predefined: any}): Promise<any>;
}
declare module "@salesforce/apex/MasterProductController.createProductsFromMasterProduct" {
  export default function createProductsFromMasterProduct(param: {masterId: any, predefined: any}): Promise<any>;
}
declare module "@salesforce/apex/MasterProductController.getFieldsMap" {
  export default function getFieldsMap(param: {selectedSObject: any}): Promise<any>;
}
