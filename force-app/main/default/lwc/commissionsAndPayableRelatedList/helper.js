import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSalesOrderLines from '@salesforce/apex/SalesOrderDetailPageController.getSalesOrderLines';
import deleteSObjectList from '@salesforce/apex/OpportunityDetailPageController.deleteSObjectList'
import getSalesOrder from '@salesforce/apex/SalesOrderDetailPageController.getSalesOrder'

import getAvailableCommissions from '@salesforce/apex/CommissionRelatedListsController.getAvailableCommissions'
import updateExistingCommissions from '@salesforce/apex/CommissionRelatedListsController.updateExistingCommissions'
import getAvailablePayables from '@salesforce/apex/CommissionRelatedListsController.getAvailablePayables'

const handleGetAvailablePayables = (controller) => {
    getAvailablePayables({
        recordId: controller.recordId
    }).then(res => {
        controller.setSpinnersVisibility('AcctSeed__Account_Payable__c', true);

        let data = JSON.parse(res);

        data.sobjectList.forEach(el => {
            el['recordURL'] = `/detail/${el.Id}`;
            el['commissionURL'] = `/detail/${el.Sales_Order_Commissions__c}`
            el['commissionName'] = `/detail/${el.Sales_Order_Commissions__r?.Name}`
            el['commissionHolder'] = el.Sales_Order_Commissions__r?.Holder_Name_System__c
        })

        const sobjectListData = {
            totalRecords: data.totalRecords,
            dataInitial: data.sobjectList,
            data: data.totalRecords > 3 ? [...data.sobjectList].splice(0, 3) : data.sobjectList
        }

        controller.setDatatableDataKey('AcctSeed__Account_Payable__c', sobjectListData);
        controller.handleReviewAllRelatedListsViewAll();
    }).catch(err => {
        console.error('Error during fetch payable: ', err)
        showToastFunc(controller, 'Error occured', 'Error during fetch payables : '+err.body.message,'ERROR')
    }).finally(() => {
        controller.setSpinnersVisibility('AcctSeed__Account_Payable__c', false);
    })
}
const handleRecalculateCommissions = (controller) => {
    updateExistingCommissions({
        recordId: controller.recordId
    }).then(res => {
        controller.refreshAllRelatedLists();
        showToastFunc(controller, 'Success', 'Commissions were updated successfully.','SUCCESS')
    }).catch(err => {
        console.error('Error recalculate commissions: ', err)
        showToastFunc(controller, 'Error occured', 'Error during updating commissions : '+err.body.message,'ERROR')
    }).finally(() => {
        controller.setSpinnersVisibility('Sales_Order_Commissions__c', false);
    })
}
const handleGetSalesOrder = (controller) => {
    getSalesOrder({
        salesOrderId: controller.recordId
    }).then(res => {
        controller._salesOrderRecord = JSON.parse(res);
    }).catch(err => {
        showToastFunc(controller, 'Error', 'Error during getting Sales Order record : '+err.body.message,'ERROR')
    })
}

const handleGetCommissions = (controller) => {
    getAvailableCommissions({
        recordId: controller.recordId
    }).then(res => {
        controller.setSpinnersVisibility('Sales_Order_Commissions__c', true);

        let data = JSON.parse(res);

        data.sobjectList.forEach(el => {
            el['recordURL'] = `/detail/${el.Id}`
            el['invoiceMemoLabel'] = el['Billing_Credit_Memo__c'] != null ? el.Billing_Credit_Memo__r.Name : el['Billing_Cash_Receipt__c'] != null ? el.Billing_Cash_Receipt__r.Name : '';
            el['invoiceMemoLink'] = el['Billing_Credit_Memo__c'] != null ? 
                `/detail/${el['Billing_Credit_Memo__c']}` : el['Billing_Cash_Receipt__c'] != null ? `/detail/${el['Billing_Cash_Receipt__c']}` : '';
        })

        const sobjectListData = {
            totalRecords: data.totalRecords,
            dataInitial: data.sobjectList,
            data: data.totalRecords > 3 ? [...data.sobjectList].splice(0, 3) : data.sobjectList
        }

        controller.setDatatableDataKey('Sales_Order_Commissions__c', sobjectListData);
        controller.handleReviewAllRelatedListsViewAll();
    }).catch(err => {
        console.error(err)
    }).finally(() => {
        controller.setSpinnersVisibility('Sales_Order_Commissions__c', false);
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
    handleRecalculateCommissions: (controller) => handleRecalculateCommissions(controller),
    handleGetCommissions: (controller) => handleGetCommissions(controller),
    handleGetAvailablePayables: (controller) => handleGetAvailablePayables(controller),
    handleGetSalesOrder: (controller) => handleGetSalesOrder(controller),
    delete: (controller, linesId) => deleteSObjectListHelper(controller, linesId),

}