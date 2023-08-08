import getOpportunity from '@salesforce/apex/OpportunityDetailPageController.getOpportunity'
import getOpportunityLineItems from '@salesforce/apex/OpportunityDetailPageController.getOpportunityLineItems'
import getOptionalOpportunityLines from '@salesforce/apex/OpportunityDetailPageController.getOptionalOpportunityLines'
import getOpportunityAttachments from '@salesforce/apex/OpportunityDetailPageController.getOpportunityAttachments'
import deleteSObjectList from '@salesforce/apex/OpportunityDetailPageController.deleteSObjectList'

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const getOpportunityAttachmentsService = (controller) => {
    getOpportunityAttachments({
        opportunityId: controller.recordId
    }).then(res => {
        const data = JSON.parse(res)

        const executedAttachmentsListData = {
            totalRecords: data.executedDocuments.length,
            dataInitial: data.executedDocuments,
            data: data.executedDocuments.length > 3 ? [...data.executedDocuments].splice(0, 3) : data.executedDocuments
        }
        const defaultAttachmentsListData = {
            totalRecords: data.defaultAttachments.length,
            dataInitial: data.defaultAttachments,
            data: data.defaultAttachments.length > 3 ? [...data.defaultAttachments].splice(0, 3) : data.defaultAttachments
        }

        controller.setDatatableDataKey('defaultAttachments', defaultAttachmentsListData);
        controller.setDatatableDataKey('executedDocuments', executedAttachmentsListData);

        controller.handleReviewAllRelatedListsViewAll();
    })
}
const getOpportunityService = (opportunityId) =>{
    return getOpportunity({
        opportunityId
    }).then(res => {
        return res;
    })
}
const getOpportunityLineItemsData = (controller) => {
    getOpportunityLineItems({
        opportunityId: controller.recordId
    }).then(res => {
        let data = JSON.parse(res);
        // this.totalRecords = data.totalRecords;
        data.sobjectList.forEach(el => {
            el['product_url'] = '/detail/'+el.Product2Id;
            el['product_code_url'] = '/detail/'+el.Product2Id;
            el['product_name'] = el.Product2.Name;
            el['product_code'] = el.Product2.ProductCode;
            el['imageUrl'] = '/partner'+el.Product2['Product_Image_Short_URL__c'];

            if(el.Product2.RecordType.DeveloperName == 'Part' || el.Product2.RecordType.DeveloperName == 'Product'){
                el['availableQuantity'] = el.Product2.Available_Quantity__c ? el.Product2.Available_Quantity__c : 0;
            }else{
                el['availableQuantity'] = el.Product2.Kit_Available_Quantity__c ? el.Product2.Kit_Available_Quantity__c : 0;
            }

            el['inventoryUrl'] = '/partner/apex/InventoryInformationPage?id='+el.Product2.Id

        })
        const sobjectListData = {
            totalRecords: data.totalRecords,
            dataInitial: data.sobjectList,
            data: data.totalRecords > 3 ? [...data.sobjectList].splice(0, 3) : data.sobjectList
        }
        controller.setDatatableDataKey('OpportunityLineItem', sobjectListData);
        controller.handleReviewAllRelatedListsViewAll();

        console.log('i have finishede')
    })
}


const getOptionalOpportunityLinesData = (controller) => {
    getOptionalOpportunityLines({
        opportunityId: controller.recordId
    }).then(res => {
        let data = JSON.parse(res)
        data.sobjectList.forEach(el => {
            el['product_url'] = '/detail/'+el.Product__c;
            el['product_code_url'] = '/detail/'+el.Product__c;
            el['product_name'] = el.Product__r.Name;
            el['product_code'] = el.Product__r.ProductCode;
            el['imageUrl'] = '/partner'+el.Product__r['Product_Image_Short_URL__c'];

            if(el.Product__r.RecordType.DeveloperName == 'Part' || el.Product__r.RecordType.DeveloperName == 'Product'){
                el['availableQuantity'] = el.Product__r.Available_Quantity__c ? el.Product__r.Available_Quantity__c : 0
            }else{
                el['availableQuantity'] = el.Product__r.Kit_Available_Quantity__c ? el.Product__r.Kit_Available_Quantity__c : 0
            }

            el['inventoryUrl'] = '/partner/apex/InventoryInformationPage?id='+el.Product__r.Id

        })
        const sobjectListData = {
            totalRecords: data.totalRecords,
            dataInitial: data.sobjectList,
            data: data.totalRecords > 3 ? [...data.sobjectList].splice(0, 3) : data.sobjectList
        }
        controller.setDatatableDataKey('Optional_Products_Opportunity__c', sobjectListData);
        controller.handleReviewAllRelatedListsViewAll();
    })
}
const deleteSObjectListHelper = (linesId) => {
    return deleteSObjectList({
        idList: JSON.stringify(linesId)
    }).then(res => {
    }).catch(err => {
        console.error(err)
    })
}

const opportunityButtons = (controller) => {
    return {
        'AddProduct': (controller) => {
            console.log(44)
            window.location.href = '/partner/s/product-page?sobject=opp&recordId='+controller.recordId
        },
        'View All': (controller) => {
            window.location.href = '/partner/apex/OpportunityProductsViewAll?recordId='+controller.recordId+'&optional=false'
        }
    }
}

const showToastFunc = (controller, t, m, v) => {
    const evt = new ShowToastEvent({
        title: t,
        message: m,
        variant: v,
        mode: 'dismissable'
    });
    controller.dispatchEvent(evt);
}
export const helper = {

    getOpportunityAttachmentsService: (recordId) => getOpportunityAttachmentsService(recordId),
    getOpportunityService: (recordId) => getOpportunityService(recordId),
    getOpportunityLineItemsData: (controller) => getOpportunityLineItemsData(controller),
    getOptionalOpportunityLinesData: (controller) => getOptionalOpportunityLinesData(controller),
    buttons: {
        'OpportunityLineItem': opportunityButtons
    },
    delete: (controller, linesId) => deleteSObjectListHelper(controller, linesId),
    showToast: (controller, t, m, v) => showToastFunc(controller, t, m, v),

}