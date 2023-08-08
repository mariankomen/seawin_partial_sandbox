import { LightningElement, api, track } from 'lwc';
import getLogginedUserProfile from '@salesforce/apex/SalesOrderDetailPageController.getLogginedUserProfile'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import { publish,subscribe,unsubscribe,createMessageContext,releaseMessageContext } from 'lightning/messageService';


export default class CreatePurchaseOrderCMP extends LightningElement {

    @api recordId;

    @track iframeUrl = '/apex/CreatePurchaseOrderPage?scontrolCaching=1&id=';

    connectedCallback(){
        this.iframeUrl += this.recordId
        getLogginedUserProfile().then(res => {
            if(res.includes('(Partner)')){
                this.showToast('Insuffient Access','You dont have access for that action.', 'Warning')
                


                const closeQA = new CustomEvent('close');
                // Dispatches the event.
                this.dispatchEvent(closeQA);
            }
        }).catch(err => {
            this.showToast('Error during loading component', err.body.message, 'ERROR')
        })
    }


    showToast(t,m,v){
        const evt = new ShowToastEvent({
            title: t,
            message: m,
            variant: v,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}