import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getProductFieldsDependencies from '@salesforce/apex/ProductListViewController.getProductFieldsDependencies'

const TOAST_SUCCESS_TYPE = 'success';
const TOAST_WARNING_TYPE = 'warning';
const TOAST_ERROR_TYPE = 'error';

export default class ProductListViewLeftBarCMP extends LightningElement {


    familyToCategoryDependencies;
    categoryToSubCategoryDependencies;

    /* Start Main Picklist */
    @track familyOptions = [];
    @track categoryOptions = [];
    @track subCategoryOptions = [];
    /* End Picklist */

    /* Start Selected Picklist Values */
    selectedFamilyValue;
    selectedCategoryValue;
    selectedSubCategoryValue;
    /* End Selected Picklist Values */

    /* Start Disable Picklist Properties */
    @track _disableFamilyPicklist = false;
    @track _disableCategoryPicklist = true;
    @track _disableSubCategoryPicklist = true;
    /* End Disable Picklist Properties */

    @track isOnlyActiveToggle = true;
    @track isSpinnerShowing = true;




    connectedCallback(){
        this.showSpinner();
        this.getFieldDependencies();
    }

    
    getFieldDependencies(){
        getProductFieldsDependencies().then(res => {
            const dependencies = JSON.parse(res);
            this.familyToCategoryDependencies = dependencies.familyToCategory;
            this.categoryToSubCategoryDependencies = dependencies.categoryToSubCategory;

            this.buildDependencyPicklists();

        }).catch(err => {
            console.log(err);
            this.showToast('Error occured during fetching field dependencies', err.body.message, TOAST_ERROR_TYPE);
        })
    }

    buildDependencyPicklists(){
        console.log(1)
        const options = [
            {label: '-None-', value: 'None'}
        ];
        for(let family in this.familyToCategoryDependencies){
            options.push({
                label: family,
                value: family
            })
        }

        this.familyOptions = options.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
        this.checkPicklistDisability();
        this.hideSpinner();

    }


    /* Start Picklist Handlers */
    handleFamilyChange(e){
        this.selectedFamilyValue = e.detail.value;

        const options = [
            {label: '-None-', value: 'None'}
        ];
        if(this.selectedFamilyValue == 'None'){
            this.categoryOptions = [];
        }else{
            this.familyToCategoryDependencies[this.selectedFamilyValue].forEach(category => {
                options.push({
                    label: category.label,
                    value: category.apiname
                })
            })
    
            this.categoryOptions = options.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
        }
        
        this.checkPicklistDisability();

        const eventPayload = {
            type: 'family',
            family: this.selectedFamilyValue,
            category: this.selectedCategoryValue,
            subcategory: this.selectedSubCategoryValue,
            allActive: this.isOnlyActiveToggle
        }

        const selectedEvent = new CustomEvent('familychange', { detail: eventPayload });
        this.dispatchEvent(selectedEvent);

    }

    handleCategoryChange(e){
        this.selectedCategoryValue = e.detail.value;

        const options = [
            {label: '-None-', value: 'None'}
        ];
        if(this.selectedCategoryValue == 'None'){
            this.subCategoryOptions = [];
        }else{
            this.categoryToSubCategoryDependencies[this.selectedCategoryValue].forEach(subcategory => {
                options.push({
                    label: subcategory.label,
                    value: subcategory.apiname
                })
            })
    
            this.subCategoryOptions = options.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
        }
        
        this.checkPicklistDisability();

        const eventPayload = {
            type: 'category',
            family: this.selectedFamilyValue,
            category: this.selectedCategoryValue,
            subcategory: this.selectedSubCategoryValue,
            allActive: this.isOnlyActiveToggle
        }

        const selectedEvent = new CustomEvent('categorychange', { detail: eventPayload });
        this.dispatchEvent(selectedEvent);
    }
    handleSubCategoryChange(e){
        this.selectedSubCategoryValue = e.detail.value;

        const eventPayload = {
            type: 'subcategory',
            family: this.selectedFamilyValue,
            category: this.selectedCategoryValue,
            subcategory: this.selectedSubCategoryValue,
            allActive: this.isOnlyActiveToggle
        }

        const selectedEvent = new CustomEvent('subcategorychange', { detail: eventPayload });
        this.dispatchEvent(selectedEvent);
    }
    /* End Picklist Handlers */

    /* Helper Methods */
    checkPicklistDisability(){
        this._disableFamilyPicklist = this.familyOptions.length == 0;
        this._disableCategoryPicklist = this.categoryOptions.length == 0;
        this._disableSubCategoryPicklist = this.subCategoryOptions.length == 0;
    }

    toggleChangeHandler(){
        this.isOnlyActiveToggle = !this.isOnlyActiveToggle;
    }

    showSpinner(){
        this.isSpinnerShowing = true;
    }
    hideSpinner(){
        this.isSpinnerShowing = false;
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