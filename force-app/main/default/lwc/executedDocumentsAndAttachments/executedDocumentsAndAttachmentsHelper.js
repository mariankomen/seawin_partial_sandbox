import getOpportunityAttachments from '@salesforce/apex/OpportunityDetailPageController.getOpportunityAttachments'
import deleteSObjectList from '@salesforce/apex/OpportunityDetailPageController.deleteSObjectList'
import getOpportunity from '@salesforce/apex/OpportunityDetailPageController.getOpportunity'

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const getOpportunityAttachmentsService = (controller) => {
    getOpportunityAttachments({
        opportunityId: controller.recordId
    }).then(res => {
        const data = JSON.parse(res)
        for(let char in data){
            data[char].forEach(el => {
                el['createdByName'] = el.CreatedBy.Name
            })
        }
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

const deleteSObjectListHelper = (linesId) => {
    return deleteSObjectList({
        idList: JSON.stringify(linesId)
    }).then(res => {
    }).catch(err => {
        console.error(err)
    })
}
const getOpportunityService = (opportunityId) =>{
    return getOpportunity({
        opportunityId
    }).then(res => {
        return res;
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
    getOpportunityService: (recordId) => getOpportunityService(recordId),
    getOpportunityAttachmentsService: (recordId) => getOpportunityAttachmentsService(recordId),
    delete: (controller, linesId) => deleteSObjectListHelper(controller, linesId),
    showToast: (controller, t, m, v) => showToastFunc(controller, t, m, v),
}