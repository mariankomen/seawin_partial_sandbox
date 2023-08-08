import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getSobjectType from '@salesforce/apex/OpportunityDetailPageController.getSobjectType'

import {helper} from './helper.js'
import {config} from './datatableConfigs.js'

export default class SalesOrderRelatedLists extends NavigationMixin(LightningElement) {
    @api recordId;

    @track isSalesOrderOpened = false;
    @track _salesOrderRecord = {};
    @track _datatableData = {};
    @track relatedListsViewAll = {};
    @track _datatableColumns = {};

    connectedCallback(){
        if(!this.recordId){
            this.isSalesOrderOpened = false;
        }else{
            getSobjectType({
                recordId: this.recordId
            }).then(type => {
                if(type == 'AcctSeedERP__Sales_Order__c'){
                    this.matchDatatableColumnsConfig();
                    // this.getOpportunityRecord()
                    this.refreshAllRelatedLists();
                    helper.handleGetSalesOrder(this);
                    this.isSalesOrderOpened = true;
                }else{
                    this.isSalesOrderOpened = false;
                }
            })
        }
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

    
    matchDatatableColumnsConfig(){
        this._datatableColumns['AcctSeedERP__Sales_Order_Line__c'] = config?.AcctSeedERP__Sales_Order_Line__c;
    }

    setDatatableDataKey(key, data){
        if(!key) return;
        this._datatableData[key] = data ? data : [];
        this._datatableData = Object.assign({}, this._datatableData);
    }

    refreshAllRelatedLists(){
        helper.handleGetSalesOrderLines(this)
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
        window.location.href = `/partner/s/product-page?sobject=so&recordId=${this.recordId}`
    }
    handleNavigateToViewAllScreen(e){
        window.location.href = `/partner/apex/OpportunityProductsViewAll?recordId=${this.recordId}&optional=false`
    }
    handleNavigateToAllocatedScreen(e){
        window.location.href = `/partner/apex/AcctSeedERP__SalesOrderAllocate?scontrolCaching=1&id=${this.recordId}`
        
    }

    handleNavigateToDeAllocateScreen(e){
        const sobjectDatatable = `[data-id="${e.target.dataset.sobject}"]`;
        let selectedRecords =  this.template.querySelector(sobjectDatatable).getSelectedRows();

        if(selectedRecords.length == 0){
            helper.showToast(this, 'Warning', 'No records have been selected for deallocating!','WARNING')
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
        console.log(JSON.stringify(this._salesOrderRecord))
        let url = `/partner/apex/DeAllocateSOLinesPage?id=${this.recordId}&name=${this._salesOrderRecord.Name}&count=${total}&${linesId}`;
        
        window.location.href = url;
        this.refreshAllRelatedLists();

    }

    handleOpenSorting(e){
        const sobjectName = e.target.dataset.sobject;

        const sortCmp = this.template.querySelector('c-sobjects-sorter')
        sortCmp.initial(sobjectName, 'Sales Order', this.recordId, 'AcctSeedERP__Sales_Order__c', 'Quantity', 'SortOrder__c');
    }

    handleOnSortEnd(){
        this.refreshAllRelatedLists()
    }
}