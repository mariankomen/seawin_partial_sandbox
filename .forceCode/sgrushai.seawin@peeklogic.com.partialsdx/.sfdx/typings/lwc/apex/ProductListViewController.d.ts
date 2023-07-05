declare module "@salesforce/apex/ProductListViewController.fetchProducts" {
  export default function fetchProducts(param: {filters: any, pageSize: any, pageNumber: any, sortField: any, sortDirection: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListViewController.getProductFieldsDependencies" {
  export default function getProductFieldsDependencies(): Promise<any>;
}
declare module "@salesforce/apex/ProductListViewController.updateEditedProductFields" {
  export default function updateEditedProductFields(param: {updatedDataJson: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListViewController.insertLinesController" {
  export default function insertLinesController(param: {sobjectType: any, recordId: any, linesWrapper: any}): Promise<any>;
}
