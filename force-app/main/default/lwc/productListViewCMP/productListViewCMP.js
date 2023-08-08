import { LightningElement, api, track, wire } from 'lwc';
import fetchProducts from '@salesforce/apex/ProductListViewController.fetchProducts'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getProductFieldsDependencies from '@salesforce/apex/ProductListViewController.getProductFieldsDependencies'
import updateEditedProductFields from '@salesforce/apex/ProductListViewController.updateEditedProductFields'


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
    {
        label: 'Family',
        type: 'picklistType',
        wrapText: true,
        typeAttributes: {
            label: {fieldName: ''},
            options: {fieldName: 'familyOptions'},
            value: {fieldName: 'Category__c'},
            fieldapi: 'Category__c',
            productId: {fieldName: 'Id'},
            disabled: {fieldName: 'disableFamily'}
        }
    },
    {
        label: 'Category',
        type: 'picklistType',
        wrapText: true,
        typeAttributes: {
            label: {fieldName: ''},
            options: {fieldName: 'categoryOptions'},
            value: {fieldName: 'Sub_Category__c'},
            fieldapi: 'Sub_Category__c',
            productId: {fieldName: 'Id'},
            disabled: {fieldName: 'disableCategory'}
        }
    },

    {
        label: 'Sub Category',
        type: 'picklistType',
        wrapText: true,
        typeAttributes: {
            label: {fieldName: ''},
            options: {fieldName: 'subCategoryOptions'},
            value: {fieldName: 'Complementary_Category__c'},
            fieldapi: 'Complementary_Category__c',
            productId: {fieldName: 'Id'},
            disabled: {fieldName: 'disableSubCategory'}
        }
    },
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

    familyToCategoryDependencies;
    categoryToSubCategoryDependencies;

    draftValues = [];
    sobject; // If component use for adding lines to sobject, current param identificates to which sobject need to add products
    targetRecordId; //target sobject id. Identificates to which record need to add lines

    @track data = [];
    @track isAddingMode = false; // If False - Checkboxes Present || True - Hidden
    @track isEditMode = false;
    @track isMassEditMode = false;
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

        //   console.log('sobject: ',this.sobject)
          console.log('targetRecordId: ',this.targetRecordId)
       }
    }

    setParametersBasedOnUrl() {
        this.sobject = this.urlStateParameters.sobject || null;
        console.log('sobject is: ',JSON.stringify(this.sobject))
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
        this.fetchProductRecords();
        this.getFieldDependencies();
    }

    getFieldDependencies(){
        getProductFieldsDependencies().then(res => {
            const dependencies = JSON.parse(res);
            this.familyToCategoryDependencies = dependencies.familyToCategory;
            this.categoryToSubCategoryDependencies = dependencies.categoryToSubCategory;

        }).catch(err => {
            console.log(err);
            this.showToast('Error occured during fetching field dependencies', err.body.message, TOAST_ERROR_TYPE);
        })
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
        console.log('JSON.stringify(this.filterConfig): ',JSON.stringify(this.filterConfig))
        console.log('this.pageSize: ', JSON.stringify(this.pageSize))
        console.log('this.pageNumber: ', JSON.stringify(this.pageNumber))
        console.log('this.sortedBy: ', JSON.stringify(this.sortedBy))
        console.log('this.sortDirection: ', JSON.stringify(this.sortDirection))
        fetchProducts({
            filters: JSON.stringify(this.filterConfig),
            pageSize: this.pageSize,
            pageNumber: this.pageNumber, 
            sortField: this.sortedBy, 
            sortDirection: this.sortDirection
        }).then(res => {
            const result = JSON.parse(res);
            let parsedData = result.data.map(el => el.product)

            let familyOptions = []
            for(let family in this.familyToCategoryDependencies){
                familyOptions.push({
                    label: family,
                    value: family
                })
            }

            

            parsedData.forEach(product => {
                product.Product_Image_Short_URL__c = product.Product_Image_Short_URL__c ? product.Product_Image_Short_URL__c.replace('sales','partner') : '';
                product['product_url'] = '/detail/'+product.Id;
                product['familyOptions'] = familyOptions.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
                product['categoryOptions'] = this.compileDependentPicklistOptions(this.familyToCategoryDependencies, product.Category__c);
                product['subCategoryOptions'] = this.compileDependentPicklistOptions(this.categoryToSubCategoryDependencies, product.Sub_Category__c);
                

                product['disableFamily'] = product['familyOptions'].length == 0;
                product['disableCategory'] = product['categoryOptions'].length == 0;
                product['disableSubCategory'] = product['subCategoryOptions'].length == 0;
                product['edited'] = false;
            })

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

    compileDependentPicklistOptions(dependency, productDependencyFieldValue){
        let categoryValue = []
        if(dependency[productDependencyFieldValue]){
            dependency[productDependencyFieldValue].forEach(category => {
                categoryValue.push({
                    label: category.label,
                    value: category.apiname
                })
            })
        }
        return categoryValue.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
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
            if(this.isMassEditMode){
                const modal = this.template.querySelector("c-products-mass-edit-c-m-p");
                modal.initial();
            }else{
                const modal = this.template.querySelector("c-add-product-c-m-p");
                modal.setSelectedProducts(JSON.stringify(selectedRecords), this.sobject, this.targetRecordId);
            }
            
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
        let index = this.data.findIndex(product => product.Id == e.detail.rowId)
        console.log('index: ',index , ' === ', e.detail.rowId)
        console.log('this.data[index]: ',JSON.stringify(this.data[index]))
        console.log('JSON.s',JSON.stringify(this.data))
        if(index > -1){
            this.data[index][e.detail.field] = e.detail.value;

            this.data[index]['categoryOptions'] = this.compileDependentPicklistOptions(this.familyToCategoryDependencies, this.data[index].Category__c);
            this.data[index]['subCategoryOptions'] = this.compileDependentPicklistOptions(this.categoryToSubCategoryDependencies, this.data[index].Sub_Category__c);
            

            this.data[index]['disableFamily'] = this.data[index]['familyOptions'].length == 0;
            this.data[index]['disableCategory'] = this.data[index]['categoryOptions'].length == 0;
            this.data[index]['disableSubCategory'] = this.data[index]['subCategoryOptions'].length == 0;

            this.data[index]['edited'] = true;
        }

        this.data = [...this.data]
        console.log(JSON.stringify(e.detail))

        this.handleCheckIfProductsWereEdited();
    }

    saveUpdateChanges(){
        this.showSpinner();
        let editableData = []

        this.data.forEach(el => {
            if(el['edited'] == true){
                editableData.push({
                    productId: el.Id,
                    family: el['Category__c'],
                    category: el['Sub_Category__c'],
                    subcategory: el['Complementary_Category__c']
                })
            }
        })

        if(editableData.length > 0){
            console.log('JSON.stringify(editableData): ',JSON.stringify(editableData))
            updateEditedProductFields({
                updatedDataJson: JSON.stringify(editableData)
            }).then(res => {
                this.showToast('Success', 'Record were updated successfully.', TOAST_SUCCESS_TYPE);

                this.refresh();
                this.isEditMode = false;

            }).catch(err => {
                this.showToast('Error occured during updating fields.', err.body.message, TOAST_ERROR_TYPE);

            })
        }
    }
    handleCheckIfProductsWereEdited(){
        let dataCopy = [...this.data]
        let totalEdited = dataCopy.filter(el => el.edited == true).length
        this.isEditMode = totalEdited > 0;
    }
    handleSave(e){
        
        console.log(JSON.stringify(e.detail.draftValues))
    }

    handleMassEditMode(e){
        if(this.data.length > 0){
            if(this.isMassEditMode){ //If this.isMassEditMode = true, disable edit mode
                this.isAddingMode = true; //False means checkboxes present
                this.isMassEditMode = false;
            }else{
                this.isAddingMode = false; //False means checkboxes present
                this.isMassEditMode = true;
            }
        }else{
            this.showToast('Warning','List view has no displayed records. Please select some filters and click "Mass Edit" button again.', TOAST_WARNING_TYPE)
        }
        console.log('mass edit')
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