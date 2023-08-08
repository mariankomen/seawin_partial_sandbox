import { LightningElement, api, track } from 'lwc';
import getSobjectType from '@salesforce/apex/OpportunityDetailPageController.getSobjectType'
import { NavigationMixin } from 'lightning/navigation';

import {helper} from './helper.js'
const actions = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const QUOTE_LINE_ITEMS = [
    
    {
        label: 'Product Name', fieldName: 'product_url', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'product_name'
            },
            sortable: true
        }
    },

    { label: 'Product Image', fieldName: 'imageUrl', type: 'image' },
    
    {
        label: 'Product Code', fieldName: 'product_code_url', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'product_code'
            },
            sortable: true
        }
    },
    { label: 'Item Description', fieldName: 'ITEM_DESCRIPTION__c', type: 'text' , wrapText: true, initialWidth: 400},
    { label: 'Size', fieldName: 'Size__c', type: 'text' , wrapText: true},
    { label: 'Quantity', fieldName: 'Quantity', type: 'number'},
    { label: 'Sales Price', fieldName: 'UnitPrice', type: 'currency'},
    { label: 'Total Price', fieldName: 'TotalPrice', type: 'currency'},
    {   label: '',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: actions },
    }
];
const QUOTE_OPTIONAL_LINE_ITEMS = [
    
    {
        label: 'Product Name', fieldName: 'product_url', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'product_name'
            },
            sortable: true
        }
    },

    { label: 'Product Image', fieldName: 'imageUrl', type: 'image' },
    
    {
        label: 'Product Code', fieldName: 'product_code_url', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'product_code'
            },
            sortable: true
        }
    },
    { label: 'Item Description', fieldName: 'Item_Description__c', type: 'text' , wrapText: true, initialWidth: 400},
    { label: 'Size', fieldName: 'Size__c', type: 'text' , wrapText: true},
    { label: 'Quantity', fieldName: 'Quantity__c', type: 'number'},
    { label: 'Sales Price', fieldName: 'UnitPrice__c', type: 'currency'},
    { label: 'Total Price', fieldName: 'TotalPrice__c', type: 'currency'},
    {   label: '',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: actions },
    }
];


export default class QuoteRelatedLists extends NavigationMixin(LightningElement) {
    @api recordId;

    _datatableColumns = {}
    @track _datatableData = {}; //Current object has data for all related lists, filtered by key
    @track relatedListsViewAll = {};
    _OpportunityRecord = {};
    _UserInfo = {}

    @track isQuoteOpened = false;
    connectedCallback(){
        if(!this.recordId){
            this.isQuoteOpened = false;
        }else{
            getSobjectType({
                recordId: this.recordId
            }).then(type => {
                if(type == 'Quote'){
                    this.matchDatatableColumnsConfig();
                    this.refreshAllRelatedLists();
                    helper.getLogginedUserInfoService(this);
                    this.isQuoteOpened = true;
                }else{
                    this.isQuoteOpened = false;
                }
            })
        }
    }
    handleReviewAllRelatedListsViewAll(){
        const relatedListsViewAllObj = {};
        for(const sObject in this._datatableData){
            relatedListsViewAllObj[sObject] = this._datatableData[sObject].totalRecords > 3;
        }
        this.relatedListsViewAll = relatedListsViewAllObj;
    }
    matchDatatableColumnsConfig(){
        this._datatableColumns['QuoteLineItem'] = QUOTE_LINE_ITEMS;
        this._datatableColumns['Optional_Products_Quote__c'] = QUOTE_OPTIONAL_LINE_ITEMS;
    }

    setDatatableDataKey(key, data){
        if(!key) return;
        this._datatableData[key] = data ? data : [];
        this._datatableData = Object.assign({}, this._datatableData);
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

    refreshAllRelatedLists(){
        helper.getQuoteLinesItemsService(this)
        helper.getOptionalLinesService(this)
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


    handleNavigateToProductScreen(e){
        const sobject = e.target.dataset.sobject;
        let paramSobject = '';
        if(sobject == 'QuoteLineItem'){
            paramSobject = 'QuoteLineItem';
        }else if(sobject == 'Optional_Products_Quote__c'){
            paramSobject = 'OptionalProductQuote';
        }
        window.location.href = `/partner/s/product-page?sobject=${paramSobject}&recordId=${this.recordId}`
    }

    handleNavigateToEditAll(e){
        window.location.href = `/apex/EditAllQuoteLineItemPage?quoteId=${this.recordId}&retURL=${this.recordId}`
    }

    handleNavigateToEditAllOptional(e){
        window.location.href = `/apex/EditAllOptionalProductQuotePage?quoteId=${this.recordId}&retURL=${this.recordId}`
    }

    handleNavigateToTransferToOptional(e){
        const sobjectDatatable = `[data-id="${e.target.dataset.sobject}"]`;
        let selectedRecords =  this.template.querySelector(sobjectDatatable).getSelectedRows();
        if(selectedRecords.length == 0){
            helper.showToast(this, 'Warning', 'No records have been selected to transfer!', 'Warning')
        }else if(!this._UserInfo.Transfer_to_Optional__c){
            helper.showToast(this, 'Insufficient Privileges', 'You are not allowed to make these changes. Please contact your administrator.', 'Warning')
        }else{
            let linesId = '';
            for(let i = 0; i < selectedRecords.length; i++){
                if(i == 0){
                    linesId += 'id' + i + '=' + selectedRecords[i].Id;
                }else{
                    linesId += '&id' + i + '=' + selectedRecords[i].Id;
                }
            }
            let total = selectedRecords.length;
            let url = '/partner/apex/TransferRelatedListProductsQLI?id='+this.recordId+'&count=' +total+ '&'+ linesId;
            window.location.href = url;
            this.refreshAllRelatedLists();
        }
    }

    handleOpenSorting(e){
        const sobjectName = e.target.dataset.sobject;

        const sortCmp = this.template.querySelector('c-sobjects-sorter')
        sortCmp.initial(sobjectName, 'Quote', this.recordId, 'QuoteId', 'Quantity', 'SortOrder');
    }

    handleOpenOptionalSorting(e){
        const sobjectName = e.target.dataset.sobject;

        const sortCmp = this.template.querySelector('c-sobjects-sorter')
        sortCmp.initial(sobjectName, 'Quote', this.recordId, 'Quote__c', 'Quantity__c', 'SortOrder__c');
    }

    handleOnSortEnd(){
        this.refreshAllRelatedLists()
    }
}