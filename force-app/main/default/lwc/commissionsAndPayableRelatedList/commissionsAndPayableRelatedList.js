import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getSobjectType from '@salesforce/apex/OpportunityDetailPageController.getSobjectType'
import getLogginedUserProfileService from '@salesforce/apex/SalesOrderDetailPageController.getLogginedUserProfile'

import {helper} from './helper.js'
import {config} from './datatableConfigs.js'

export default class CommissionsAndPayableRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;

    @track isSalesOrderOpened = false;
    @track _salesOrderRecord = {};
    @track _datatableData = {};
    @track relatedListsViewAll = {};
    @track _datatableColumns = {};

    @track _isCommunityOpened = true;
    _loginedUserProfile = '';

    @track _spinnersVisibility = {};

    setDefaultSpinnersVisibility(){
        this._spinnersVisibility['Sales_Order_Commissions__c'] = false;
    }
    setSpinnersVisibility(sObject, value){
        this._spinnersVisibility[sObject] = value;
    }

    connectedCallback(){
        let url = window.location.href;
        console.log('url: ',url)
        this._isCommunityOpened = url.includes('/partner/');

        if(!this.recordId){
            this.isSalesOrderOpened = false;
        }else{
            getSobjectType({
                recordId: this.recordId
            }).then(type => {
                if(type == 'AcctSeedERP__Sales_Order__c' || type == 'Opportunity'){
                    this.matchDatatableColumnsConfig();
                    // this.getOpportunityRecord()
                    this.refreshAllRelatedLists();
                    if(type == 'AcctSeedERP__Sales_Order__c'){
                        helper.handleGetSalesOrder(this);
                    }
                    this.isSalesOrderOpened = true;
                }else{
                    this.isSalesOrderOpened = false;
                }
            })

            this.setSpinnersVisibility();
            this.setDefaultSpinnersVisibility();
            // getUserProfile();
        }


    }

    async getUserProfile(){
        getLogginedUserProfileService().then(res => {
            this._loginedUserProfile = res;
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

    
    matchDatatableColumnsConfig(){
        this._datatableColumns['Sales_Order_Commissions__c'] = config?.Sales_Order_Commissions__c;
        this._datatableColumns['AcctSeed__Account_Payable__c'] = config?.AcctSeed__Account_Payable__c;
    }

    setDatatableDataKey(key, data){
        if(!key) return;
        this._datatableData[key] = data ? data : [];
        this._datatableData = Object.assign({}, this._datatableData);
    }

    refreshAllRelatedLists(){
        helper.handleGetCommissions(this)
        helper.handleGetAvailablePayables(this)
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

    handleRedirectToCreatePayable(e){
        const sobjectDatatable = `[data-id="${e.target.dataset.sobject}"]`;
        let selectedRecords =  this.template.querySelector(sobjectDatatable).getSelectedRows();

        if(selectedRecords.length == 0){
            helper.showToast(this, 'Warning', 'No commissions have been selected.','WARNING')
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
        let url = this._isCommunityOpened ? '/partner' : ''
        url += `/apex/CommissionsPayablePage?id=${this.recordId}&count=${total}&${linesId}`;
        
        window.location.href = url;
        this.refreshAllRelatedLists();
    }

    handleRecalculateCommissions(){
        this.setSpinnersVisibility('Sales_Order_Commissions__c', true);

        helper.handleRecalculateCommissions(this);
    }

    handleCreateCommissionManually(){
        let cmp = this.template.querySelector('c-create-commission-manually-c-m-p')

        cmp.initial();
    }
}