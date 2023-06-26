import { LightningElement, api, track, wire } from 'lwc';
import fetchProducts from '@salesforce/apex/ProductListViewController.fetchProducts'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';


const TOAST_SUCCESS_TYPE = 'success';
const TOAST_WARNING_TYPE = 'warning';
const TOAST_ERROR_TYPE = 'error';

const DEFAULT_PAGINATION_LIMIT = 15;

const columns = [
    {
        type: "button", label: 'Inventory',  typeAttributes: {
            label: '',
            name: 'inventory',
            title: 'Inventory',
            disabled: false,
            value: 'inventory',
            iconPosition: 'center',
            iconName:'utility:preview'
        }
    },
    {
        label: 'Product Name', fieldName: 'product_url', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            sortable: true
        }
    },

    { label: 'Product Image', fieldName: 'Product_Image_Short_URL__c', type: 'image' },
    { label: 'Product Code', fieldName: 'ProductCode', sortable: true },
    { label: 'Description', fieldName: 'Description' },
    { label: 'Size', fieldName: 'Size__c', sortable: true },
    { label: 'Family', fieldName: 'Category__c' },

    {
        label: 'Family',
        type: 'picklistType',
        wrapText: true,
        typeAttributes: {
            label: {fieldName: ''},
            options: {fieldName: 'picklistOptions'}
        }
    },
    { label: 'Category', fieldName: 'Sub_Category__c'},
    { label: 'Sub Category', fieldName: 'Complementary_Category__c' },
    { label: 'Hardware Finish', fieldName: 'Hardware_Finish__c' },
    { label: 'Glass', fieldName: 'Glass__c' },
    { label: 'Glass Thickness', fieldName: 'Glass_Thickness__c' }

];

const PAGE_SIZE_OPTIONS = [
    {label: '15', value: '15'},
    {label: '25', value: '25'},
    {label: '50', value: '50'},
    {label: '100', value: '100'},
    {label: '150', value: '150'},
    {label: '200', value: '200'}
]
export default class ProductListViewCMP extends NavigationMixin(LightningElement) {

    @api paginationLimit;
    @api createProductForSObject = '';
    
    draftValues = [];
    sobject; // If component use for adding lines to sobject, current param identificates to which sobject need to add products
    targetRecordId; //target sobject id. Identificates to which record need to add lines

    @track data = [];
    @track isAddingMode = false; // If False - Checkboxes Present || True - Hidden
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track sortDirection = 'asc';
    @track defaultSortDirection = 'asc';
    @track sortedBy = 'Name';
    @track isLoading = false;
    @track pageSize = DEFAULT_PAGINATION_LIMIT;
    @track pageSizePicklistValue = this.pageSize;
    @track columns = columns;
    pageSizePicklistOptions = PAGE_SIZE_OPTIONS;
    @track dataIsReady = false;

    @track isSpinnerShowing = false;

    
    filterConfig = {
        header_type: 'All', //Because All is default values in picklist
        header_key: null,
        family: null,
        category: null,
        subcategory: null,
        isAllActive: true
    }

    get displayedRecords(){
        let displayedTo = this.pageSize * this.pageNumber;
        return displayedTo >= this.totalRecords ? this.totalRecords : displayedTo;
    }
    get fromDisplayedRecords(){
        return (this.pageSize * this.pageNumber) - this.pageSize + 1;
    }

    currentPageReference = null; 
    urlStateParameters = null;

    

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();

          console.log('sobject: ',this.sobject)
          console.log('targetRecordId: ',this.targetRecordId)
       }
    }

    setParametersBasedOnUrl() {
        this.sobject = this.urlStateParameters.sobject || null;
        this.targetRecordId = this.urlStateParameters.recordId || null;

        this.checkIfComponentUseForAddingProducts();
    }

    checkIfComponentUseForAddingProducts(){
        if(this.sobject != null && this.targetRecordId){
            this.isAddingMode = false; //false - checkbox exist
        }else{
            this.isAddingMode = true;
        }
    }
    connectedCallback(){
        // this.fetchProductRecords();
    }

    /* Start Custom Event from child components Handlers */
    handleHeaderFilterEvent(e){
        this.filterConfig.header_type = e.detail.filter_type
        this.filterConfig.header_key = e.detail.filter_key

        this.fetchProductRecords();

    }

    handleRightBarFilterEvent(e){
        this.filterConfig.family = e.detail.family;
        this.filterConfig.category = e.detail.category;
        this.filterConfig.subcategory = e.detail.subcategory;
        this.filterConfig.isAllActive = e.detail.allActive;

        this.fetchProductRecords();

    }
    /* End Custom Event from child components Handlers */


    fetchProductRecords(){
        this.showSpinner();
        this.dataIsReady = false;
        fetchProducts({
            filters: JSON.stringify(this.filterConfig),
            pageSize: this.pageSize,
            pageNumber: this.pageNumber, 
            sortField: this.sortedBy, 
            sortDirection: this.sortDirection
        }).then(res => {
            const result = JSON.parse(res);
            let parsedData = result.data.map(el => el.product)
            parsedData.forEach(product => {
                product.Product_Image_Short_URL__c = product.Product_Image_Short_URL__c ? product.Product_Image_Short_URL__c.replace('sales','partner') : '';
                product['product_url'] = '/detail/'+product.Id;
            })

            let data11 = ['New','Open','Test']
            parsedData.forEach(el => {
                el['picklistOptions'] = data11.map(r => {
                    return {
                        label: r,
                        value: r
                    }
                })
            })
            console.log('kaka: ',JSON.stringify(parsedData));
            this.data = parsedData;
            this.totalRecords = result.totalRecords;
            this.dataIsReady = true;
            // setTimeout(() => {
                this.hideSpinner();
            // },1000)
        }).catch(err => {
            this.showToast('Error during fetching data.',err.body.message + ' \n Please select additional filters.', TOAST_ERROR_TYPE);
            console.error(err)
        })
    }


    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    callRowAction(event) {
        const recId = event.detail.row.Id;
        const actionName = event.detail.action.name;
        if (actionName === 'inventory') {
            console.log('Redirect to view')
        } 
    }

    showSpinner(){
        this.isSpinnerShowing = true;
    }
    hideSpinner(){
        this.isSpinnerShowing = false;
    }

    handlePageSizeChange(e){
        this.pageSize = Number(e.detail.value)
        this.pageSizePicklistValue = e.detail.value
        this.fetchProductRecords();
    }
    previousPage(event) {
        if (this.pageNumber === 1) {
            return;
        }
        this.pageNumber -= 1;
        this.fetchProductRecords();
    }

    firstPage(){
        this.pageNumber = 1;
        this.fetchProductRecords();
    }

    lastPage(){
        this.pageNumber = Math.ceil(this.totalRecords / this.pageSize);
        this.fetchProductRecords();
    }
    nextPage(event) {
        try{
            if ((this.pageNumber * this.pageSize) >= this.totalRecords) {
                return;
            }
            this.pageNumber += 1;
            this.fetchProductRecords();
        }catch(e){
            console.error(e)
        }
        
    }

    selectHandler(){
        const selectedRecords =  this.template.querySelector("c-salesforce-codex-data-table").getSelectedRows();
        if(selectedRecords.length > 0){
            const modal = this.template.querySelector("c-add-product-c-m-p");
            modal.setSelectedProducts(JSON.stringify(selectedRecords), this.sobject, this.targetRecordId);
        }else{
            this.showToast('Warning', 'No products selected.', TOAST_WARNING_TYPE);
        }
        

    }
    refresh(){
        this.fetchProductRecords();
    }

    redirectToMasterProduct(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
              url: '/master-product'
            }
          });
    }

    handlePicklistChange(e){
        console.log(JSON.stringify(this.data))
        console.log(JSON.stringify(e.detail))
    }
    handleSave(e){
        console.log(JSON.stringify(e.detail.draftValues))
    }

    showToast(t, m, v) {
        const evt = new ShowToastEvent({
            title: t,
            message: m,
            variant: v,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}