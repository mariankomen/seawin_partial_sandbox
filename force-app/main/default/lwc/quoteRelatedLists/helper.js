import getQuoteLineItems from '@salesforce/apex/QuoteDetailPageController.getQuoteLineItems'
import getOptionalQuoteLineItems from '@salesforce/apex/QuoteDetailPageController.getOptionalQuoteLineItems'
import getLogginedUserInfo from '@salesforce/apex/QuoteDetailPageController.getLogginedUserInfo'
import deleteSObjectList from '@salesforce/apex/OpportunityDetailPageController.deleteSObjectList'
import getOpportunity from '@salesforce/apex/OpportunityDetailPageController.getOpportunity'

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const getLogginedUserInfoFunction = (controller) => {
    getLogginedUserInfo().then(res => {
        controller._UserInfo = JSON.parse(res);
        console.log(res)
    }).catch(err => {
        showToastFunc(controller, 'Error', err.body.message)
    })
}
const getOptionalLines = (controller) => {
    getOptionalQuoteLineItems({
        quoteId: controller.recordId
    }).then(res => {
        let data = JSON.parse(res);
        console.log(44);
        data.sobjectList.forEach(el => {
            el['product_url'] = '/detail/'+el.Product__c;
            el['product_code_url'] = '/detail/'+el.Product__c;
            el['product_name'] = el.Product__r.Name;
            el['product_code'] = el.Product__r.ProductCode;
            el['imageUrl'] = '/partner'+el.Product__r['Product_Image_Short_URL__c'];
        })

        console.log(45)
        const sobjectListData = {
            totalRecords: data.totalRecords,
            dataInitial: data.sobjectList,
            data: data.totalRecords > 3 ? [...data.sobjectList].splice(0, 3) : data.sobjectList
        }

        controller.setDatatableDataKey('Optional_Products_Quote__c', sobjectListData);
        controller.handleReviewAllRelatedListsViewAll();
        console.log(46)
    }).catch(err => {
        showToastFunc(controller, 'Error', err.body.message)
    })
}
const getLines = (controller) => {
    getQuoteLineItems({
        quoteId: controller.recordId
    }).then(res => {
        console.log('skava')
        let data = JSON.parse(res);
        // this.totalRecords = data.totalRecords;
        data.sobjectList.forEach(el => {
            el['product_url'] = '/detail/'+el.Product2Id;
            el['product_code_url'] = '/detail/'+el.Product2Id;
            el['product_name'] = el.Product2.Name;
            el['product_code'] = el.Product2.ProductCode;
            el['imageUrl'] = '/partner'+el.Product2['Product_Image_Short_URL__c'];
        })
        const sobjectListData = {
            totalRecords: data.totalRecords,
            dataInitial: data.sobjectList,
            data: data.totalRecords > 3 ? [...data.sobjectList].splice(0, 3) : data.sobjectList
        }
        controller.setDatatableDataKey('QuoteLineItem', sobjectListData);
        controller.handleReviewAllRelatedListsViewAll();
        console.log('end')
    }).catch(err => {
        showToastFunc(controller, 'Error', err.body.message)
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
    getQuoteLinesItemsService: (controller) => getLines(controller),
    getOptionalLinesService: (controller) => getOptionalLines(controller),
    getLogginedUserInfoService: (controller) => getLogginedUserInfoFunction(controller),
    showToast: (controller, t, m, v) => showToastFunc(controller, t, m, v),

}