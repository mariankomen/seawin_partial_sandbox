declare module "@salesforce/apex/SalesOrderDetailPageController.getLogginedUserProfile" {
  export default function getLogginedUserProfile(): Promise<any>;
}
declare module "@salesforce/apex/SalesOrderDetailPageController.getSalesOrderLines" {
  export default function getSalesOrderLines(param: {salesOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/SalesOrderDetailPageController.getSalesOrder" {
  export default function getSalesOrder(param: {salesOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/SalesOrderDetailPageController.createBilling" {
  export default function createBilling(param: {linesWrapperJson: any}): Promise<any>;
}
