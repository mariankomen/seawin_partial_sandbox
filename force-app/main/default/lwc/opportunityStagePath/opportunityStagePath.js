/* eslint-disable no-console */
// Import LightningElement and api classes from lwc module
import { LightningElement, api, wire, track } from 'lwc';
// import getPicklistValues method from lightning/uiObjectInfoApi
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// import getObjectInfo method from lightning/uiObjectInfoApi
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// Import lead object APi from schema
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
// import Lead status field from schema
import PICKLIST_FIELD from '@salesforce/schema/Opportunity.StageName';
// import record ui service to use crud services
import { getRecord } from 'lightning/uiRecordApi';
// import show toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import update record api
import { updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

import getOpportunitySubStages from '@salesforce/apex/OpportunityDetailPageController.getOpportunitySubStages'


const FIELDS = [
    'Opportunity.Id',
    'Opportunity.StageName',
    'Opportunity.RecordTypeId',
    'Opportunity.Sent_for_Approval__c',
    'Opportunity.Type',
    'Opportunity.RecordType.Name',
    'Opportunity.Approval_Status__c',
    'Opportunity.TotalSalesOrderInOpp__c',
    'Opportunity.Loss_Reason__c',
    'Opportunity.Billing_Balances__c',
    'Opportunity.Sub_Stage__c',
    'Opportunity.Financial_Clearance__c',
    'Opportunity.Approval_Package__c',
    'Opportunity.Signed_Sales_Order__c',
    'Opportunity.Financial_Clearance_Date__c',
    'Opportunity.submittal_approval_date__c',
    'Opportunity.Contract_Date__c',
];

const USER_FIELDS = [
    'User.Check_Financial_Clearance__c',
    'User.Check_Approval_Package__c',
    'User.Check_Signed_Sales_Order__c'
]

export default class OpportunityStagePath extends LightningElement {
    @track userId = Id;
    @track selectedValue;
    @api recordId;
    @track showSpinner = false;

    @track _subStageMap = {}

    @track hasClearenceStage = false;
    @track showCheckboxesSection = false;


    @track _userCheckFinancialClearenceAvailable = false;
    @track _userCheckApprovalPackageAvailable = false;
    @track _userCheckSIgnedSalesOrderAvailable = false;




    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record;

    @wire(getPicklistValues, { recordTypeId: '$record.data.fields.RecordTypeId.value', fieldApiName: PICKLIST_FIELD })
    picklistFieldValues;

    @wire(getRecord, { recordId: '$userId', fields: USER_FIELDS}) 
    userDetails({error, data}) {
        if (data) {
            this._userCheckFinancialClearenceAvailable = data.fields.Check_Financial_Clearance__c.value;
            this._userCheckApprovalPackageAvailable = data.fields.Check_Approval_Package__c.value;
            this._userCheckSIgnedSalesOrderAvailable = data.fields.Check_Signed_Sales_Order__c.value;

        } else if (error) {
            console.error(error)
            // this.error = error ;
        }
    }

    connectedCallback(){
        this.getOpportunitySubStages();
    }

    getOpportunitySubStages(){
        getOpportunitySubStages().then(res => {
            const subStages = JSON.parse(res)
            this._subStageMap = subStages;
        })
    }
    get picklistValues() {
        
        let itemsList = [];
        if (this.record.data) {
            if (!this.selectedValue && this.record.data.fields.StageName.value) {
                this.selectedValue = this.record.data.fields.StageName.value + '';
            }
            if (this.picklistFieldValues && this.picklistFieldValues.data && this.picklistFieldValues.data.values) {
                let selectedUpTo = 0;
                
                let iterator = 0;
                let iteratorLast = 0;
                for(let char in this.picklistFieldValues.data.values){
                    if(this.picklistFieldValues.data.values[char].value == 'Pre-Order'){
                        this.hasClearenceStage = true;
                    }
                    let classList;
                    if(this.picklistFieldValues.data.values[char].value == this.selectedValue){
                        if(this.selectedValue == 'Not Qualified' || this.selectedValue == 'Closed Lost'){
                            classList = 'slds-path__item slds-is-current slds-is-lost';
                        }else if(this.selectedValue == 'Closed Lost'){
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
                    itemsList[iteratorLast].subStages = this.compileSubStagesList();
                    itemsList[iteratorLast].showSubStage = itemsList[iteratorLast].subStages.length > 0;

                    for (let item = 0; item < iteratorLast; item++) {
                        if(this.selectedValue == 'Not Qualified' || this.selectedValue == 'Closed Lost'){

                        }else{
                            itemsList[item].classList = 'slds-path__item slds-is-complete';
                        }
                    }
                }

                this.showCheckboxesSection = this.hasClearenceStage && this.record.data.fields.StageName.value == 'Pre-Order'
                return itemsList;
            }
        }
        return null;
    }
    compileSubStagesList(){
        let subStagesList = []
        const currentValue = this.record.data.fields.Sub_Stage__c.value

        if(this._subStageMap.hasOwnProperty(this.selectedValue)){
            subStagesList = this._subStageMap[this.selectedValue].map(el => {
                return {
                    label: el,
                    value: el,
                    selected: el == currentValue
                }
            })
        }
        return subStagesList;
    }
    handleCheckboxChange(e){
        this.showSpinner = true;
        const fields = {};
        fields.Id = this.recordId;


        let status = e.target.checked;
        let field_key = e.target.dataset.key;

        if(field_key == 'Financial Clearance'){
            if(status){
                if(this.record.data.fields.Financial_Clearance_Date__c.value == null){
                    fields.Financial_Clearance_Date__c = this.getTodaysDate();
                }
            }else{
                fields.Financial_Clearance_Date__c = null;
            }
        }else if(field_key == 'Submittal Package'){
            if(status){
                if(this.record.data.fields.submittal_approval_date__c.value == null){
                    fields.submittal_approval_date__c = this.getTodaysDate();
                }
            }else{
                fields.submittal_approval_date__c = null;
            }
        }else if(field_key == 'Signed Order'){
            if(status){
                if(this.record.data.fields.Contract_Date__c.value == null){
                    fields.Contract_Date__c = this.getTodaysDate();
                }
            }else{
                fields.Contract_Date__c = null;
            }
        }

        const recordInput = { fields };

        this.updateRecordHandler(recordInput);
    }
    handleSelect(event) {

        let stageIsAvailableForUpdate = this.validateDoAvailableForUpdate(event.currentTarget.dataset.value);
        if(stageIsAvailableForUpdate){
            this.selectedValue = event.currentTarget.dataset.value;
            this.handleMarkAsSelected();
        }
    }

    validateDoAvailableForUpdate(selectedStage){
        const NEGATIVE_STAGES = ['Closed Lost', 'Not Qualified', 'Sleep'];

        if(selectedStage != "Needs Analysis" && this.record.data.fields.Type.value == 'Template'){
            this.showToast('Warning', 'This is a template type Opportunity. Change type to Estimate or other to continue further.', 'WARNING');
            return false;
        }else if((selectedStage == 'Pre-Order' || selectedStage == 'Closed Won') && (this.record.data.fields.RecordType.value.fields.Name.value == 'Seawin USA Hospitality' ||
            this.record.data.fields.RecordType.value.fields.Name.value == 'Seawin China Hospitality' ||
            this.record.data.fields.RecordType.value.fields.Name.value == 'Seawin China OEM') 
            && this.record.data.fields.Approval_Status__c.value != 'Approved'){

            this.showToast('Warning', 'Cannot change stage, because the Opportunity is not Approved.', 'WARNING');
            return false;  
        }else if(selectedStage == 'Closed Won' && this.record.data.fields.Sent_for_Approval__c.value){
            this.showToast('Warning', 'Locked Opportunity, Approval pending.', 'WARNING');
            return false; 
        }else{
            if(this.record.data.fields.StageName.value == 'Closed Won' && this.record.data.fields.TotalSalesOrderInOpp__c.value > 0 ){
                this.showToast('Warning', 'Opportunity is Locked, because the Opportunity Stage is Closed Won and Opportunity has Sales Order(s).', 'WARNING');
                return false; 
            }else if(NEGATIVE_STAGES.includes(selectedStage) && this.record.data.fields.Billing_Balances__c.value > 0){
                if(selectedStage == 'Closed Lost'){
                    if(this.record.data.fields.Loss_Reason__c.value == null){
                        this.showToast('Warning', 'Loss Reason is required. Please first save the opportunity with Loss Reason and then change stage.', 'WARNING');
                        return false; 
                    }else if(this.record.data.fields.Billing_Balances__c.value > 0){
                        this.showToast('Warning', 'Can not change stage, associated billing has a balance', 'WARNING');
                        return false; 
                    }else{
                        return true;
                    }
                }else{
                    this.showToast('Warning', 'Can not change stage, associated billing has a balance.', 'WARNING');
                    return false; 
                }
            }else if(selectedStage == 'Closed Lost'){
                if(this.record.data.fields.Loss_Reason__c.value == null){
                    this.showToast('Warning', 'Loss Reason is required. Please first save the opportunity with Loss Reason and then change stage.', 'WARNING');
                    return false; 
                }else if(this.record.data.fields.Billing_Balances__c.value > 0){
                    this.showToast('Warning', 'Can not change stage, associated billing has a balance', 'WARNING');
                    return false; 
                }else{
                    return true;
                }
            }
            else{
                return true;
            }

        }
    }

    substageClick(e){
        e.stopPropagation();
    }
    handleMarkAsSelected() {
        this.showSpinner = true;
        const fields = {};
        fields.Id = this.recordId;
        fields.StageName = this.selectedValue;
        fields.Sub_Stage__c = null;

        const recordInput = { fields };

        this.updateRecordHandler(recordInput);
    }

    updateRecordHandler(recordInput){
        updateRecord(recordInput)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Status Updated!',
                    variant: 'success'
                })
            );
            this.showToast('Success', 'Status Updated!', 'success');
        })
        .catch(error => {
                this.showToast('Error during updating', 'error.body.message', 'error');
                console.log('failure => ' + error.body.message);
        });

        this.showSpinner = false;
    }

    substageHandler(e){
        let newSubStage = e.target.value;

        this.showSpinner = true;
        const fields = {};
        fields.Id = this.recordId;
        fields.Sub_Stage__c = newSubStage;

        const recordInput = { fields };

        this.updateRecordHandler(recordInput);

    }

    getTodaysDate(){
        let rightNow = new Date();

        // Adjust for the user's time zone
        rightNow.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );

        // Return the date in "YYYY-MM-DD" format
        let yyyyMmDd = rightNow.toISOString().slice(0,10);
        return yyyyMmDd;
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