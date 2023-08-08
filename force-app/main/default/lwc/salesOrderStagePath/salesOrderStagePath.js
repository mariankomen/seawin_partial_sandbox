import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import SALES_ORDER_OBJECT from '@salesforce/schema/AcctSeedERP__Sales_Order__c';
import PICKLIST_FIELD from '@salesforce/schema/AcctSeedERP__Sales_Order__c.Stage__c';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';


const FIELDS = [
    'AcctSeedERP__Sales_Order__c.Id',
    'AcctSeedERP__Sales_Order__c.Name',
    'AcctSeedERP__Sales_Order__c.AcctSeedERP__Status__c',
    'AcctSeedERP__Sales_Order__c.Stage__c',
    'AcctSeedERP__Sales_Order__c.RecordTypeId',
    'AcctSeedERP__Sales_Order__c.Billed_Amount__c',
    'AcctSeedERP__Sales_Order__c.Total_Actual__c',
    'AcctSeedERP__Sales_Order__c.Not_Posted_Billing_Count__c',
    'AcctSeedERP__Sales_Order__c.Total_Products_Quantity__c',
    'AcctSeedERP__Sales_Order__c.Total_Quantity_Shipped__c',
]
export default class SalesOrderStagePath extends LightningElement {
    @track selectedValue;
    @api recordId;
    @track showSpinner = false;

    @wire(getObjectInfo, { objectApiName: SALES_ORDER_OBJECT })
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record;

    @wire(getPicklistValues, { recordTypeId: '$record.data.fields.RecordTypeId.value', fieldApiName: PICKLIST_FIELD })
    picklistFieldValues;


    get picklistValues() {
        try{
            console.log(11);
            let itemsList = [];
            if (this.record.data) {
                console.log(JSON.stringify(this.record.data))
                if (!this.selectedValue && this.record.data.fields.Stage__c.value) {
                    this.selectedValue = this.record.data.fields.Stage__c.value + '';
                }
                if (this.picklistFieldValues && this.picklistFieldValues.data && this.picklistFieldValues.data.values) {
                    let selectedUpTo = 0;
                    
                    let iterator = 0;
                    let iteratorLast = 0;
                    for(let char in this.picklistFieldValues.data.values){
                        
                        let classList;
                        if(this.picklistFieldValues.data.values[char].value == this.selectedValue){
                            if(this.selectedValue == 'Received'){
                                classList = 'slds-path__item slds-is-current slds-is-won';
                            }else{
                                classList = 'slds-path__item slds-is-current slds-is-active';
                            }
                            iteratorLast = iterator;
                        }else{
                            classList = 'slds-path__item slds-is-incomplete';
    
                        }
                        iterator += 1;
    
                        itemsList.push({
                            pItem: this.picklistFieldValues.data.values[char],
                            classList: classList,
                            showSubStage: false,
                            subStages: []
                        })
                    }
    
                    if (iteratorLast > 0) {
                        // itemsList[iteratorLast].subStages = this.compileSubStagesList();
                        // itemsList[iteratorLast].showSubStage = itemsList[iteratorLast].subStages.length > 0;
    
                        for (let item = 0; item < iteratorLast; item++) {
                            if(this.selectedValue == 'Received'){
    
                            }else{
                                itemsList[item].classList = 'slds-path__item slds-is-complete';
                            }
                        }
                    }
                    console.log(12)
                    return itemsList;
                }
            }
            return null;
        }catch(err){
            console.error(err)
        }
        
    }

    handleSelect(event) {

        let stageIsAvailableForUpdate = this.validateDoAvailableForUpdate(event.currentTarget.dataset.value);
        if(stageIsAvailableForUpdate){
            this.selectedValue = event.currentTarget.dataset.value;
            this.handleMarkAsSelected();
        }
    }

    validateDoAvailableForUpdate(selectedStage){
        if(this.record.data.fields.AcctSeedERP__Status__c.value == 'Hold'){
            this.showToast('Warning','Stage cannot be changed. Please change status to Open and then try again.', 'Warning');
            return false;
        }

        if(selectedStage == 'Received'){
            if(this.record.data.fields.Billed_Amount__c.value < this.record.data.fields.Total_Actual__c.value ){
                this.showToast('Warning','Stage cannot be changed. All items have not been billed.', 'Warning');
                return false;
            }else if(this.record.data.fields.Not_Posted_Billing_Count__c.value > 0){
                this.showToast('Warning','Stage cannot be changed. All bills have not been posted.', 'Warning');
                return false;
            }else if(this.record.data.fields.Total_Products_Quantity__c.value > this.record.data.fields.Total_Quantity_Shipped__c.value){
                this.showToast('Warning','Stage cannot be changed. All items have not been shipped.', 'Warning');
                return false;
            }else{
                return true;
            }
        }else{
            return true;
        }
    }


    handleMarkAsSelected() {
        this.showSpinner = true;
        const fields = {};
        fields.Id = this.recordId;
        fields.Stage__c = this.selectedValue;

        const recordInput = { fields };

        this.updateRecordHandler(recordInput);
    }

    updateRecordHandler(recordInput){
        updateRecord(recordInput)
        .then(() => {
            this.showToast('Success', 'Stage Updated!', 'success');
        })
        .catch(error => {
                this.showToast('Error during updating', error.body.message, 'error');
                console.log('failure => ' + error.body.message);
        });

        this.showSpinner = false;
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