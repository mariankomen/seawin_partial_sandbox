import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const TOAST_SUCCESS_TYPE = 'success';
const TOAST_WARNING_TYPE = 'warning';
const TOAST_ERROR_TYPE = 'error';

export default class CreateAccountCMP extends NavigationMixin(LightningElement) {

    isSalesRepSelected = false;

    openedSections = ['A','B','C','D','E','F','G','H']
    /*
        Sales Rep & Owner values from child component;
    */
    _salesRepAndOwner = {}

    handleSalesRepSelection(e){
        console.log(JSON.stringify(e.detail))
        this._salesRepAndOwner = e.detail;
        this.isSalesRepSelected = true;

        // this.runCreateRecordForm();
    }

    handleSuccess(e){
        let accountId = e.detail.id
        console.log(accountId);
        this.showToast('Success', 'Account has been created.',TOAST_SUCCESS_TYPE)

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });

    }
    closeModal(){
        this.isSalesRepSelected = false;
    }
    predefineValues(){
        const defaultValues = encodeDefaultFieldValues({
            Sales_Rep_O__c: this._salesRepAndOwner.sales_rep_id,
            OwnerId: this._salesRepAndOwner.owner_id
        });

        return defaultValues;
    }

    runCreateRecordForm(){
        const defaultValues = this.predefineValues();
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    handleAccountCreated(e){
        alert('created')
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