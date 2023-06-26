/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 06-24-2023
 * @last modified by  : Marian Lyzhychka
**/
import { LightningElement, track } from 'lwc';
import getSalesRepTeamMembers from '@salesforce/apex/SalesRepTeamController.getSalesRepTeamMembers'

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const TOAST_SUCCESS_TYPE = 'success';
const TOAST_WARNING_TYPE = 'warning';
const TOAST_ERROR_TYPE = 'error';

export default class SelectSalesRepCMP extends LightningElement {

    selectedSalesRep;
    @track selectedSalesRepMembers = []
    selectedOwner;
    @track isSpinnerShowing = false;
    
    get _isMembersReady(){
        return !!this.selectedSalesRepMembers.length;
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
        }).catch(err => {
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