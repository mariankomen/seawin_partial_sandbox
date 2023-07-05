import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getOpportunityStageValues from '@salesforce/apex/OpportunityDetailPageController.getOpportunityStageValues'
import getOpportunityRecordTypes from '@salesforce/apex/OpportunityDetailPageController.getOpportunityRecordTypes'

export default class CreateOpportunity extends NavigationMixin(LightningElement) {

    @api recordTypeId;
    @track salesRepAndOwnerObj = {}
    @track firstStepIsReady = true;
    @track secondStepIsReady = false;
    @track openedSections = ['A','B', 'C', 'D', 'E', 'F','G', 'H', 'I', 'J']


    @track isSeawinHospitalityRecordType = false;
    @track isChinaRecordType = false;
    @track isOtherRecordType = false;

    recordTypesMap = {};
    stageValuesMap = {};
    checkboxValue = false;
    opportunityType = null;
    opportunityProbability = null
    opportunityForecastCategory = null

    connectedCallback(){
        console.log('record type id LWC: ', JSON.stringify(this.recordTypeId))
        this.getStageValues();
        this.getOpportunityRecordTypesMap();
    }

    getStageValues(){
        getOpportunityStageValues().then(res => {
            this.stageValuesMap = JSON.parse(res)
        })
    }
    getOpportunityRecordTypesMap(){
        getOpportunityRecordTypes().then(res => {
            this.recordTypesMap = JSON.parse(res);
            console.log('JSON.parse(res): ',JSON.parse(res))
            let selectedRecordTypeName = this.recordTypesMap[this.recordTypeId].Name;

            if(selectedRecordTypeName == 'Seawin USA Hospitality'){
                this.isSeawinHospitalityRecordType = true;
            }else if(selectedRecordTypeName == 'Seawin China Hospitality' || selectedRecordTypeName == 'Seawin China OEM'){
                this.isChinaRecordType = true;
            }else if(selectedRecordTypeName == 'Seawin USA Online/Drop Shipment' || selectedRecordTypeName == 'Seawin USA Wholesale Distribution'){
                this.isOtherRecordType = true;
            }
        }).catch(err => {
            console.error(err)
        })
    }
    handleContinue(e){
        this.salesRepAndOwnerObj = e.detail;
        let recordType = this.recordTypeId
        console.log(JSON.stringify(e.detail))
        this.firstStepIsReady = false;
        this.secondStepIsReady = true;
    }

    handleStageChange(e){
        const selectedStageName = e.target.value
        if(this.stageValuesMap[selectedStageName]){
            this.opportunityProbability = this.stageValuesMap[selectedStageName].probability;
            this.opportunityForecastCategory = this.stageValuesMap[selectedStageName].forecastCategoryName;
        }
    }
    handleOpportunityNameChange(e){
        const name = e.target.value.toLowerCase();
        let typeHasBeenChanged = false;
        if(name.includes('case order') || name.includes('caseorder') || name.includes('issue')){
            this.opportunityType = 'Case Order';
            typeHasBeenChanged = true;
        }else if(name.includes('changed order') || name.includes('changedorder')){
            this.opportunityType = 'Change Order';
            typeHasBeenChanged = true;
        }else if(name.includes('claim order') || name.includes('claimorder')){
            this.opportunityType = 'Claim Order';
            typeHasBeenChanged = true;
        }else if(name.includes('marketing material') || name.includes('marketing materials') || name.includes('catalog') || name.includes('brochure')){
            this.opportunityType = 'Marketing Materials';
            typeHasBeenChanged = true;
        }else if(name.includes('mock-up samples') || name.includes('mock-up sample') || name.includes('mock-up') || name.includes('mockup') || name.includes('mock up')){
            this.opportunityType = 'Mock-Up Sample';
            typeHasBeenChanged = true;
        }else if(name.includes('parts order') || name.includes('partsorder') || name.includes('parts')){
            this.opportunityType = 'Parts Order';
            typeHasBeenChanged = true;
        }else if(name.includes('replacement') || name.includes('replacements')){
            this.opportunityType = 'Replacement';
            typeHasBeenChanged = true;
        }else if(name.includes('sales & marketing samples') || name.includes('sample') || name.includes('samples')){
            this.opportunityType = 'Sales & Marketing Samples';
            typeHasBeenChanged = true;
        }else if(name.includes('warranty related') || name.includes('warranty')){
            this.opportunityType = 'Warranty Related';
            typeHasBeenChanged = true;
        }

        if(typeHasBeenChanged){
            this.showToast('Info', 'Opportunity Type has been automatically changed to: '+this.opportunityType,'Info');
        }
    }
    handleSubmit(e){
        
    }

    handleSuccess(e){
        console.log(e.detail.id)
        console.log('RESPONSE: ', JSON.stringify(e.detail))
        this.showToast('Success', 'Opportunity has been created succesfully.','SUCCESS')

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: e.detail.id,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    handleError(e){

    }

    goBackHandler(){
        this.firstStepIsReady = true;
        this.secondStepIsReady = false;
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