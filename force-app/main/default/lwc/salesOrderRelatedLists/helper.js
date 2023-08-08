import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSalesOrderLines from '@salesforce/apex/SalesOrderDetailPageController.getSalesOrderLines';
import deleteSObjectList from '@salesforce/apex/OpportunityDetailPageController.deleteSObjectList'
import getSalesOrder from '@salesforce/apex/SalesOrderDetailPageController.getSalesOrder'


const handleGetSalesOrder = (controller) => {
    getSalesOrder({
        salesOrderId: controller.recordId
    }).then(res => {
        controller._salesOrderRecord = JSON.parse(res);
    }).catch(err => {
        showToastFunc(controller, 'Error', 'Error during getting Sales Order record : '+err.message.body,'ERROR')
    })
}
const handleGetSalesOrderLines = (controller) => {
    getSalesOrderLines({
        salesOrderId: controller.recordId
    }).then(res => {
        let data = JSON.parse(res);

        data.sobjectList.forEach(el => {
            el['product_url'] = '/detail/'+el.AcctSeedERP__Product__c;
            el['product_code_url'] = '/detail/'+el.AcctSeedERP__Product__c;
            el['product_name'] = el.AcctSeedERP__Product__r.Name;
            el['product_code'] = el.AcctSeedERP__Product__r.ProductCode;
            el['imageUrl'] = '/partner'+el.AcctSeedERP__Product__r['Product_Image_Short_URL__c'];

            if(el.AcctSeedERP__Product__r.RecordType.DeveloperName == 'Part' || el.AcctSeedERP__Product__r.RecordType.DeveloperName == 'Product'){
                el['availableQuantity'] = el.AcctSeedERP__Product__r.Available_Quantity__c ? el.AcctSeedERP__Product__r.Available_Quantity__c : 0;
            }else{
                el['availableQuantity'] = el.AcctSeedERP__Product__r.Kit_Available_Quantity__c ? el.AcctSeedERP__Product__r.Kit_Available_Quantity__c : 0;
            }

            el['inventoryUrl'] = '/partner/apex/InventoryInformationPage?id='+el.AcctSeedERP__Product__r.Id
        })

        const sobjectListData = {
            totalRecords: data.totalRecords,
            dataInitial: data.sobjectList,
            data: data.totalRecords > 3 ? [...data.sobjectList].splice(0, 3) : data.sobjectList
        }

        controller.setDatatableDataKey('AcctSeedERP__Sales_Order_Line__c', sobjectListData);
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
    showToast: (controller, t, m, v) => showToastFunc(controller, t, m, v),
    handleGetSalesOrderLines: (controller) => handleGetSalesOrderLines(controller),
    handleGetSalesOrder: (controller) => handleGetSalesOrder(controller),
    delete: (controller, linesId) => deleteSObjectListHelper(controller, linesId),

}