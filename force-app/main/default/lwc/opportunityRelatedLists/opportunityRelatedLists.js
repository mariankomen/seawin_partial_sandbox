import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getSobjectType from '@salesforce/apex/OpportunityDetailPageController.getSobjectType'
import {config} from './datatableConfigs.js'
import {helper} from './opportunityRelatedListHelper.js'

export default class OpportunityRelatedLists extends NavigationMixin(LightningElement) {
    @api recordId;
    _OpportunityRecord = {};
    _datatableColumns = {}

    /* Opportunity Line Items */
    @track _datatableData = {}; //Current object has data for all related lists, filtered by key
    @track relatedListsViewAll = {};

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
    
                    this.refreshAllRelatedLists();
                    this.getOpportunityRecord();

                    this.isOpportunityOpened = true;
                }else{
                    this.isOpportunityOpened = false;
                }
            })
        }
        
        
    }

    getOpportunityRecord(){
        helper.getOpportunityService(this.recordId).then(res => {
            this._OpportunityRecord = JSON.parse(res)
        })
    }
    matchDatatableColumnsConfig(){
        this._datatableColumns['OpportunityLineItem'] = config?.OpportunityLineItem;
        this._datatableColumns['Optional_Products_Opportunity__c'] = config?.Optional_Products_Opportunity__c;
        this._datatableColumns['defaultAttachments'] = config?.defaultAttachments;
        this._datatableColumns['executedDocuments'] = config?.executedDocuments;
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

    handleNavigateToProductScreen(e){
        const sobject = e.target.dataset.sobject;
        let paramSobject = '';
        if(sobject == 'OpportunityLineItem'){
            paramSobject = 'opp';
        }else if(sobject == 'Optional_Products_Opportunity__c'){
            paramSobject = 'optionalopp';
        }
        window.location.href = `/partner/s/product-page?sobject=${paramSobject}&recordId=${this.recordId}`
    }
    handleNavigateToViewAllScreen(e){
        const sobject = e.target.dataset.sobject;
        let isOptional = sobject == 'Optional_Products_Opportunity__c';

        window.location.href = `/partner/apex/OpportunityProductsViewAll?recordId=${this.recordId}&optional=${isOptional}`
    }
    handleNavigateToEditAllScreen(e){
        const sobject = e.target.dataset.sobject;
        let sobjectShortName = sobject == 'OpportunityLineItem' ? 'oli' : 'opo'
        window.location.href = `/partner/apex/OpportunityEditAllPage?oppId=${this.recordId}&retURL=${this.recordId}&recordType=${sobjectShortName}`;
    }
    handleTransferToOptional(e){
        const sobjectDatatable = `[data-id="${e.target.dataset.sobject}"]`;
        let selectedRecords =  this.template.querySelector(sobjectDatatable).getSelectedRows();
        if(selectedRecords.length == 0){
            helper.showToast(this, 'Warning', 'No records have been selected to transfer!','WARNING')
            return;
        }
        if(this._OpportunityRecord.Sent_for_Approval__c){
            helper.showToast(this, 'Warning','Locked Opportunity, pending Approval.','Info')
            return;
        }

        if(this._OpportunityRecord.TotalSalesOrderInOpp__c > 0){
            helper.showToast(this, 'Warning','Won Opportunity with Sales Order cannot be edited.','Info')
            return;
        }

        let linesId = '';
        for(let i = 0; i < selectedRecords.length; i++){
            if(i == 0){
                linesId += 'id' + i + '=' + selectedRecords[i].Id;
            }else{
                linesId += '&id' + i + '=' + selectedRecords[i].Id;
            }
        }
        let total = selectedRecords.length;
        let url = '/partner/apex/TransferRelatedListProductsOLIVFPage?id='+this.recordId+'&count=' +total+ '&'+ linesId;
        window.location.href = url;
        this.refreshAllRelatedLists();
    }

    handleTransferToLineItems(e){
        const sobjectDatatable = `[data-id="${e.target.dataset.sobject}"]`;
        let selectedRecords =  this.template.querySelector(sobjectDatatable).getSelectedRows();
        if(selectedRecords.length == 0){
            helper.showToast(this, 'Warning', 'No records have been selected to transfer!','WARNING')
            return;
        }
        if(this._OpportunityRecord.Sent_for_Approval__c){
            helper.showToast(this, 'Warning','Locked Opportunity, pending Approval.','Info')
            return;
        }

        if(this._OpportunityRecord.TotalSalesOrderInOpp__c > 0){
            helper.showToast(this, 'Warning','Won Opportunity with Sales Order cannot be edited.','Info')
            return;
        }

        let linesId = '';
        for(let i = 0; i < selectedRecords.length; i++){
            if(i == 0){
                linesId += 'id' + i + '=' + selectedRecords[i].Id;
            }else{
                linesId += '&id' + i + '=' + selectedRecords[i].Id;
            }
        }
        let total = selectedRecords.length;
        let url = '/partner/apex/TransferRelatedListProductsQuoteVF?id='+this.recordId+'&count=' +total+ '&'+ linesId;
        window.location.href = url;
        this.refreshAllRelatedLists();
    }
    
    handleTransferToLineItems(e){
        const sobjectDatatable = `[data-id="${e.target.dataset.sobject}"]`;
        let selectedRecords =  this.template.querySelector(sobjectDatatable).getSelectedRows();

        if(selectedRecords.length == 0){
            helper.showToast(this, 'Warning', 'No records have been selected to transfer!','WARNING')
            return;
        }
        if(this._OpportunityRecord.Sent_for_Approval__c){
            helper.showToast(this, 'Warning','Locked Opportunity, pending Approval.','Info')
            return;
        }

        if(this._OpportunityRecord.TotalSalesOrderInOpp__c > 0){
            helper.showToast(this, 'Warning','Won Opportunity with Sales Order cannot be edited.','Info')
            return;
        }

        let linesId = '';
        for(let i = 0; i < selectedRecords.length; i++){
            if(i == 0){
                linesId += 'id' + i + '=' + selectedRecords[i].Id;
            }else{
                linesId += '&id' + i + '=' + selectedRecords[i].Id;
            }
        }
        let total = selectedRecords.length;
        let url = '/partner/apex/TransferRelatedListProductsVFPage?id='+this.recordId+'&count=' +total+ '&'+ linesId;
        window.location.href = url;
        this.refreshAllRelatedLists();
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
            default:
        }
    }

    handleOpenSorting(e){
        const sobjectName = e.target.dataset.sobject;

        const sortCmp = this.template.querySelector('c-sobjects-sorter')
        sortCmp.initial(sobjectName, 'Opportunity', this.recordId, 'OpportunityId', 'Quantity', 'SortOrder');
    }

    handleOpenOptionalSorting(e){
        const sobjectName = e.target.dataset.sobject;

        const sortCmp = this.template.querySelector('c-sobjects-sorter')
        sortCmp.initial(sobjectName, 'Opportunity', this.recordId, 'Opportunity__c', 'Quantity', 'SortOrder__c');
    }


    handleOnSortEnd(){
        this.refreshAllRelatedLists()
    }

    refreshAllRelatedLists(){
        helper.getOpportunityLineItemsData(this)
        helper.getOptionalOpportunityLinesData(this)
    }
}