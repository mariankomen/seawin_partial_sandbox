/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-06-2023
 * @last modified by  : Marian Lyzhychka
**/
import { LightningElement, track, api } from 'lwc';
import getSalesRepTeamMembers from '@salesforce/apex/SalesRepTeamController.getSalesRepTeamMembers'

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const TOAST_SUCCESS_TYPE = 'success';
const TOAST_WARNING_TYPE = 'warning';
const TOAST_ERROR_TYPE = 'error';

export default class SelectSalesRepCMP extends LightningElement {

    
    @api selectedSalesRep;
    @track selectedSalesRepMembers = []
    selectedOwner;
    @track isSpinnerShowing = false;
    
    @track _isMembersReady = false;
    get _isMembersReady(){
        return !!this.selectedSalesRepMembers.length;
    }
    @api reselectSalesRep(salRepId){
        let cmp = this.template.querySelector('c-reusable-lookup')
        cmp.fetchDefaultRecord(salRepId)
        this.selectedSalesRep = salRepId;
        this.getSalesRepMembers()
    }
    handleSelectedValue(e){
        console.log(JSON.stringify(e.detail))
        this.selectedSalesRep = e.detail.id

        this.getSalesRepMembers();
    }

    onRemoveHandler(e){
        this.selectedSalesRep = '';
        this.selectedOwner = '';
        this.selectedSalesRepMembers = [];
        
    }
    getSalesRepMembers(){
        getSalesRepTeamMembers({
            salesRepId: this.selectedSalesRep
        }).then(res => {
            console.log(res)
            const members = JSON.parse(res)
            const membersArr = []
            members.forEach(member => {
                membersArr.push({
                    label: member.userName,
                    value: member.userId
                })
            })

            this.selectedSalesRepMembers = membersArr;

            if(!!this.selectedSalesRepMembers.length){
                this._isMembersReady = true;
            }
        }).catch(err => {
            console.error(err)
            this.showToast('Error during fetching sales rep members.', err.message.body, TOAST_ERROR_TYPE)
        })
    }

    handleContinue(){
        if(this.selectedSalesRep == '' || !this.selectedSalesRep){
            this.showToast('Can not continue', 'Sales Rep/Team is required.', TOAST_WARNING_TYPE);
            return;
        }
        if(this.selectedOwner == '' || !this.selectedOwner){
            this.showToast('Can not continue', 'Owner is required.', TOAST_WARNING_TYPE);
            return;
        }
        const outputObject = {
            sales_rep_id: this.selectedSalesRep,
            owner_id: this.selectedOwner
        }
        const event = new CustomEvent('continue', { detail: outputObject });

        this.dispatchEvent(event);
    }
    
    handleOwnerChange(e){
        console.log(e.detail.value)
        this.selectedOwner = e.detail.value
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