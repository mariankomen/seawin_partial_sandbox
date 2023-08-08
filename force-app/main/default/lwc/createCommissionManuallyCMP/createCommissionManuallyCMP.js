import { LightningElement, api, track } from 'lwc';

export default class CreateCommissionManuallyCMP extends LightningElement {
    @api recordId;

    @track isModalOpen = false;
    @track initialData = {}

    

    @track iframeURL = '/apex/CreateManualCommissionPage'
    @api initial(){
        this.openModal();
        this.iframeURL += `?salesOrderId=${recordId}`
    }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }
}