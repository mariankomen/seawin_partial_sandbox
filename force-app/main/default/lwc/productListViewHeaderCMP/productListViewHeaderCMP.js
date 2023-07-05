import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_PROFILE from '@salesforce/schema/User.Profile.Name';
import USER_ID from '@salesforce/user/Id';

const SEARCH_BY_OPTIONS = [
    {label: 'None', value:'None'},
    {label: 'All', value:'All'},
    {label: 'Product Name', value:'Name'},
    {label: 'Product Code', value:'ProductCode'},
    {label: 'Product Description', value:'Description'},
    {label: 'Size', value:'Size__c'},
    {label: 'Type', value:'Type__c'},
    {label: 'UPC Code', value:'UPC_Code__c'},
    {label: 'Inventory Type', value:'AcctSeed__Inventory_Type__c'}
]

export default class ProductListViewHeaderCMP extends NavigationMixin(LightningElement) {

    @track isUserAdmin = false;


    selectedFilterBy = 'All';
    filterOptions = SEARCH_BY_OPTIONS;

    searchKey = '';

    @track massEditButtonVariant = 'Neutral';

    @wire(getRecord, { recordId: USER_ID, fields: [USER_PROFILE] })
    wireUser({ error, data }) {
        if (data) {
            let profileName = getFieldValue(data, USER_PROFILE);
            this.isUserAdmin = profileName == 'System Administrator';
        } else if (error) {
            console.error('Error fetching user profile', error);
        }
    }

    handleSearchBy(e){
        this.selectedFilterBy = e.detail.value;
    }

    handleChangeInput(e){
        this.searchKey = e.target.value;

        const isEnterKey = e.keyCode === 13;
        if (isEnterKey) {
            this.handleRunSearch();
        }

    }

    handleEnter(e){
        if(e.keyCode === 13){
            this.handleRunSearch();
        }
    }

    handleRunSearch(){
        const searchOptions = {
            filter_type: this.selectedFilterBy,
            filter_key: this.searchKey
        }
        const selectedEvent = new CustomEvent('selected', { detail: searchOptions });

        this.dispatchEvent(selectedEvent);
    }

    executeMassEditMode(){
        if(this.massEditButtonVariant == 'Neutral'){
            this.massEditButtonVariant = 'Brand'
        }else{
            this.massEditButtonVariant = 'Neutral'
        }
        this.dispatchEvent(new CustomEvent('massedit'));
    }

    redirectToMasterProduct(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
              url: '/master-product'
            }
          });
    }
    redirectToDefaultProduct(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
              url: '/recordlist/Product2/Default'
            }
          });
    }

    redirectToNewProduct(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Product2',
                actionName: 'new'
            }
        });
    }
}