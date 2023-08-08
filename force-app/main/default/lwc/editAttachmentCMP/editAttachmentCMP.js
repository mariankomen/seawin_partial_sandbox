import { LightningElement, api, track, wire } from 'lwc';
import getAttachmentRecord from '@salesforce/apex/OpportunityDetailPageController.getAttachmentRecord'
import updateAttachmentRecord from '@salesforce/apex/OpportunityDetailPageController.updateAttachmentRecord'

const fields = ['Attachment.Name', 'Attachment.Description'];

export default class EditAttachmentCMP extends LightningElement {

    @track attachmentId;
    @track attachment = {};

    @track isModalOpen = false;

    @api initial(recordId){
        this.attachmentId = recordId;
        this.getAttachment();
        this.openModal();
        console.log(this.attachment)
    }


    getAttachment(){
        getAttachmentRecord({
            recordId: this.attachmentId
        }).then(res => {
            this.attachment = JSON.parse(res)
        }).catch(err => {
            console.error(err)
        })
    }

    handleAttachmentChange(e){
        const field = e.target.dataset.field;
        this.attachment[field] = e.target.value;
    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        updateAttachmentRecord({
            record: JSON.stringify(this.attachment)
        }).then(res => {
            this.dispatchEvent(new CustomEvent('savesuccess'));
            this.isModalOpen = false;
        })
    }
}