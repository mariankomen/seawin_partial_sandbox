import { LightningElement, api, track, wire } from 'lwc';
import deleteSObjectList from '@salesforce/apex/OpportunityDetailPageController.deleteSObjectList'
import transferExecutedDocumentsToAttachmets from '@salesforce/apex/OpportunityDetailPageController.transferExecutedDocumentsToAttachmets'
import transferAttachmentsToExecutedDocuments from '@salesforce/apex/OpportunityDetailPageController.transferAttachmentsToExecutedDocuments'
import {helper} from './executedDocumentsAndAttachmentsHelper.js'
import { NavigationMixin } from 'lightning/navigation';
import getSobjectType from '@salesforce/apex/OpportunityDetailPageController.getSobjectType'


const ATTACHMENTS_ACTIONS = [
    { label: 'Edit', name: 'editAttachment' },
    { label: 'View', name: 'view' },
    { label: 'Delete', name: 'delete' },
]
const DEFAULT_ATTACHMENTS_COLUMNS = [
    {   label: 'Action',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: ATTACHMENTS_ACTIONS },
    },
    { label: 'Name', fieldName: 'Name', type: 'text'},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date'},
    { label: 'Last Modified', fieldName: 'LastModifiedDate', type: 'date'},
    { label: 'Created By', fieldName: 'createdByName', type: 'text'},
]
const DEFAULT_EXECUTED_ATTACHMENTS_COLUMNS = [
    {   label: 'Action',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: ATTACHMENTS_ACTIONS },
    },
    { label: 'Name', fieldName: 'Name', type: 'text'},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date'},
    { label: 'Last Modified', fieldName: 'LastModifiedDate', type: 'date'},
    { label: 'Created By', fieldName: 'createdByName', type: 'text'},
]

export default class ExecutedDocumentsAndAttachments  extends NavigationMixin(LightningElement) {
    @api recordId;
    
    _datatableColumns = {}
    @track _datatableData = {}; //Current object has data for all related lists, filtered by key
    @track relatedListsViewAll = {};
    _OpportunityRecord = {};

    @track isOpportunityOpened = false;


    connectedCallback(){
        if(!this.recordId){
            this.isOpportunityOpened = false;
        }else{
            getSobjectType({
                recordId: this.recordId
            }).then(type => {
                if(type == 'Opportunity'){
                    this.matchDatatableColumnsConfig();
                    this.getOpportunityRecord()
                    this.refreshAllRelatedLists();

                    this.isOpportunityOpened = true;
                }else{
                    this.isOpportunityOpened = false;
                }
            })
        }
    }

    getOpportunityRecord(){
        helper.getOpportunityService(this.recordId).then(res => {
            console.log('res cntrl: ',res)
            this._OpportunityRecord = JSON.parse(res)
        })
    }
    matchDatatableColumnsConfig(){
        this._datatableColumns['defaultAttachments'] = DEFAULT_ATTACHMENTS_COLUMNS;
        this._datatableColumns['executedDocuments'] = DEFAULT_EXECUTED_ATTACHMENTS_COLUMNS;
    }

    setDatatableDataKey(key, data){
        if(!key) return;
        this._datatableData[key] = data ? data : [];
        this._datatableData = Object.assign({}, this._datatableData);
    }

    handleReviewAllRelatedListsViewAll(){
        const relatedListsViewAllObj = {};
        for(const sObject in this._datatableData){
            relatedListsViewAllObj[sObject] = this._datatableData[sObject].totalRecords > 3;
        }
        this.relatedListsViewAll = relatedListsViewAllObj;
    }

    handleShowMoreOLI(e){
        const sObjectName = e.target.dataset.sobject;
        this.relatedListsViewAll[sObjectName] = false;
        this._datatableData[sObjectName].data = this._datatableData[sObjectName].dataInitial;
    }
    handleShowLessOLI(e){
        const sObjectName = e.target.dataset.sobject;
        this.relatedListsViewAll[sObjectName] = true;
        this._datatableData[sObjectName].data = [...this._datatableData[sObjectName].dataInitial].splice(0,3);
    }

    handleTransferToAttachments(e){
        const sobjectDatatable = `[data-id="${e.target.dataset.sobject}"]`;
        let selectedRecords =  this.template.querySelector(sobjectDatatable).getSelectedRows();

        if(selectedRecords.length === 0){
            helper.showToast(this,'Warning', 'No documents selected. ','WARNING');
            return;
        }

        transferExecutedDocumentsToAttachmets({
            attachmentsJSON: JSON.stringify(selectedRecords)
        }).then(res => {
            helper.showToast(this, 'Success','Documents were successfully transfered.','SUCCESS')
            this.refreshAllRelatedLists();
        }).catch(err => {
            console.error(err)
            helper.showToast(this, 'Error','Error during transfer.','ERROR')
        })
    }

    handleTransferToExecutedDocuments(e){
        const sobjectDatatable = `[data-id="${e.target.dataset.sobject}"]`;
        let selectedRecords =  this.template.querySelector(sobjectDatatable).getSelectedRows();

        if(selectedRecords.length === 0){
            helper.showToast(this,'Warning', 'No documents selected. ','WARNING');
            return;
        }

        transferAttachmentsToExecutedDocuments({
            attachmentsJSON: JSON.stringify(selectedRecords)
        }).then(res => {
            helper.showToast(this, 'Success','Documents were successfully transfered.','SUCCESS')
            this.refreshAllRelatedLists();
        }).catch(err => {
            console.error(err)
            helper.showToast(this, 'Error','Error during transfer.','ERROR')
        })
    }

    handleNewAttachment(){
        window.location.href = `/p/attach/NoteAttach?pid=${this.recordId}&parentname=${this._OpportunityRecord.Name}&retURL=/partner/s/detail/${this.recordId}`
    }
    handleNewAttachmentWithRenaming(){
        window.location.href = `/partner/apex/OpportunityAttachmentPage?pid=${this.recordId}&id=${this.recordId}&parentname=${this._OpportunityRecord.Name}&retURL=/partner/s/detail/${this.recordId}`
    }

    handleDeleteSelected(e){
        const sobjectDatatable = `[data-id="${e.target.dataset.sobject}"]`;
        let selectedRecords =  this.template.querySelector(sobjectDatatable).getSelectedRows();
        console.log(selectedRecords)
        if(selectedRecords.length == 0){
            helper.showToast(this, 'Warning', 'Select at least one product for delete.','WARNING')

            return;
        }
        let linesId = [];

        selectedRecords.forEach(el => {
            linesId.push(el.Id);
        })

        helper.delete(linesId).then(() => {
            this.refreshAllRelatedLists();
            helper.showToast(this, 'Success','Record(s) has been deleted successfully','SUCCESS')
        }).catch(err => {
            helper.showToast(this, 'Error','Error during delete.','ERROR')
        })
        
    }
    handleRowAction( event ) {
 
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view'
                    }
                });
                break;
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'edit'
                    }
                });
                break;
            case 'delete':
                helper.delete([row.Id]).then(() => {
                    this.refreshAllRelatedLists();
                    helper.showToast(this, 'Success','Record(s) has been deleted successfully','SUCCESS')
                }).catch(err => {
                    helper.showToast(this, 'Error','Error during delete.','ERROR')
                })
            case 'editAttachment':
                let cmp = this.template.querySelector('c-edit-attachment-c-m-p');
                cmp.initial(row.Id);
            default:
        }
    }
    refreshAllRelatedLists(){
        helper.getOpportunityAttachmentsService(this)
    }
}