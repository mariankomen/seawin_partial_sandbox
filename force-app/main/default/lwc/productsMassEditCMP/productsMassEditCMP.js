import { LightningElement, track, api } from 'lwc';

export default class ProductsMassEditCMP extends LightningElement {
    @track isModalOpen = false;


    @api initial(){
        this.openModal();
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