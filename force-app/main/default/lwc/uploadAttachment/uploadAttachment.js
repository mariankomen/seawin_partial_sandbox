import { LightningElement, api, track } from 'lwc';
import handleSaveAttachment from '@salesforce/apex/OpportunityDetailPageController.handleSaveAttachment'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UploadAttachment extends LightningElement {
    @api recordId;
    fileData

    @track isModalOpen = false;
    @track withRenamingMode = false;
    _fileName = ''; //Use only when withRenamingMode = true


    @api initial(recId, renamingMode){
        this.withRenamingMode = renamingMode;
        this.recordId = recId;

        this._fileName = '';
        this.fileData = {}
        this.openModal();
    }

    handleFileNameChange(e){
        this._fileName = e.target.value;
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


    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }

            this._fileName = file.name;
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
    }

    handleClick(){
        const {base64, filename, recordId} = this.fileData
        let fileNameToBack = this.withRenamingMode ? this._fileName : filename;

        handleSaveAttachment({ base64: base64, filename: fileNameToBack, recordId: recordId }).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(title)

            this.dispatchEvent(new CustomEvent("filesave"));
            this.closeModal();
        }).catch(err => {
            console.error(err)
        })
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }
}