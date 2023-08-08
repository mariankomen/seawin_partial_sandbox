declare module "@salesforce/apex/OpportunityDetailPageController.getSobjectType" {
  export default function getSobjectType(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getOpportunitySubStages" {
  export default function getOpportunitySubStages(): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getOpportunity" {
  export default function getOpportunity(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getAccount" {
  export default function getAccount(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.createBilling" {
  export default function createBilling(param: {linesWrapperJson: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getPreparedLineForBilling" {
  export default function getPreparedLineForBilling(param: {type: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getOpportunityStageValues" {
  export default function getOpportunityStageValues(): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getOpportunityRecordTypes" {
  export default function getOpportunityRecordTypes(): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getOpportunityLineItems" {
  export default function getOpportunityLineItems(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getOptionalOpportunityLines" {
  export default function getOptionalOpportunityLines(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.deleteSObjectList" {
  export default function deleteSObjectList(param: {idList: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getOpportunityAttachments" {
  export default function getOpportunityAttachments(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.transferExecutedDocumentsToAttachmets" {
  export default function transferExecutedDocumentsToAttachmets(param: {attachmentsJSON: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.transferAttachmentsToExecutedDocuments" {
  export default function transferAttachmentsToExecutedDocuments(param: {attachmentsJSON: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getAttachmentRecord" {
  export default function getAttachmentRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.updateAttachmentRecord" {
  export default function updateAttachmentRecord(param: {record: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.getPredefinedSalesOrderData" {
  export default function getPredefinedSalesOrderData(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityDetailPageController.createSalesOrder" {
  export default function createSalesOrder(param: {payload: any, opportunityId: any}): Promise<any>;
}
