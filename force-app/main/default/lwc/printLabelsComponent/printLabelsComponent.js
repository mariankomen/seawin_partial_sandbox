import { LightningElement, api, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import pdflib from "@salesforce/resourceUrl/pdflib";

import getTemplateLabelsData from '@salesforce/apex/PrintLabelsController.getTemplateLabelsData'
import getRecordLines from '@salesforce/apex/PrintLabelsController.getRecordLines'

const DATATABLE_COLUMNS = [
    { label: 'Product Name', fieldName: 'productName', type: 'text' },
    { label: 'Product Code', fieldName: 'productCode', type: 'text' },
    { label: 'Item Description', fieldName: 'itemDescription', type: 'text' , wrapText: true, initialWidth: 400},
    { label: 'Size', fieldName: 'itemSize', type: 'text' },
    { label: 'Quantity', fieldName: 'quantity', type: 'number' },
    { label: 'Total', fieldName: 'total', type: 'currency'},
    {
        label: 'Template',
        type: 'picklistType',
        wrapText: true,
        typeAttributes: {
            label: {fieldName: ''},
            options: {fieldName: 'productTemplates'},
            value: {fieldName: 'selectedTemplate'},
            fieldapi: 'selectedTemplate',
            productId: {fieldName: 'lineId'}
        }
    },

    {
        label: 'Copies',
        type: 'inputType',
        typeAttributes: {
            value: {fieldName: 'copiesCount'},
            fieldapi: 'copiesCount',
            lineId: {fieldName: 'lineId'},
        }
    },



]
export default class PrintLabelsComponent extends LightningElement {

    columns = DATATABLE_COLUMNS;
    @api recordId = 'a1HEY000005fgrr';
    // @api recordId;
    @track linesData = []
    @api docData = [];

    _showCheckboxes = false;
    @track _showSpinner = false;

    renderedCallback(){
        loadScript(this, pdflib).then(() => {
            console.log('pdflib is connected.')
        }).catch(err => {
            console.error('Error during connecting pdflib: ',err)
        })

    }

    connectedCallback(){
        this.fetchLines();
    }

    handleCellChange(e){
        console.log(1111)
    }
    handlePicklistChange(e){
        let lineId = e.detail.rowId;
        let index = this.linesData.findIndex(el => el.lineId == lineId);
        this.linesData[index][e.detail.field] = e.detail.value;
    }
    handleInputChange(e){
        let lineId = e.detail.rowId;
        let index = this.linesData.findIndex(el => el.lineId == lineId);
        this.linesData[index][e.detail.field] = e.detail.value;
    }

    buildLabelsHandler(){
        const selectedRecords =  this.template.querySelector("c-salesforce-codex-data-table").getSelectedRows();
        if(selectedRecords.length == 0){
            this.showToast('Warning', 'Select at least one record.','WARNING')
        }else{
            console.log(JSON.stringify(selectedRecords))
            for(let item of selectedRecords){
                for(let field in item){
                    item[field] = typeof item[field] == 'string' ? item[field].replaceAll("'",'singleQuote').replaceAll('"','duobeQuote').replaceAll('#','{{{HASH}}}') : item[field];
                }
            }

            let hasTemplateError = false;
            selectedRecords.forEach(el => {
                if(el.selectedTemplate == null){
                    hasTemplateError = true;
                }
            })
            
            if(hasTemplateError){
                this.showToast('Warning', 'Some of your selected line(s), has no selected Label Template. Check it and click again.','WARNING')
            }else{
                this.getTemplateContentBlob(JSON.stringify(selectedRecords));
            }
        }
    }
    fetchLines(){
        getRecordLines({
            recordId: this.recordId
        }).then(res => {
            console.log(res)
            this.linesData = JSON.parse(res)
        }).catch(err => {
            console.error(err)
        })
    }


    getTemplateContentBlob(dataJson){
        this._showSpinner = true;
        this.showToast('Info', 'Compiling template pages. Label(s) pdf file will be automatically downloaded.','Info');
        getTemplateLabelsData({
            data: dataJson,
            recordId: this.recordId
        }).then(res => {
            console.log(res);

            this.docData = JSON.parse(JSON.stringify(res));
                    console.log('Size of File are ' + this.docData.length)
            this.error = undefined;
            this.createPdf()
        }).catch(err => {
            if(err.body.message.includes('Apex heap size too large')){
                this.showToast('Error', 'Total number of copies is too large, impossible to compile. Enter less numbers in Copies field.','ERROR')
            }
            console.error(err)
        }).finally(() => {
            this._showSpinner = false;
        })
    }








    async createPdf() {
        this.showToast('Info', 'Building pdf document.','Info');
        const pdfDoc = await PDFLib.PDFDocument.create();
        console.log('pdfDoc is ', pdfDoc)
        if (this.docData.length < 1)
            return
 
        var tempBytes = Uint8Array.from(atob(this.docData[0]), (c) => c.charCodeAt(0));
        console.log('tempBytes', tempBytes)
        const [firstPage] = await pdfDoc.embedPdf(tempBytes);
        // firstPage.width = '384'
        // firstPage.height = '284'
        const americanFlagDims = firstPage.scale(0.99);
        var page = pdfDoc.addPage();
        page.setWidth(288)
        page.setHeight(216)
        console.log('page is ', page)
 
        page.drawPage(firstPage, {
            ...americanFlagDims,
            x: 0,
            y: 0
        });
 
 
        if (this.docData.length > 1) {
            for (let i = 1; i < this.docData.length; i++) {
                tempBytes = Uint8Array.from(atob(this.docData[i]), (c) => c.charCodeAt(0));
                console.log('tempBtes>> ', tempBytes)
                page = pdfDoc.addPage();
                page.setWidth(288)
                page.setHeight(216)
                const usConstitutionPdf = await PDFLib.PDFDocument.load(tempBytes);
                console.log('After ', usConstitutionPdf, usConstitutionPdf.getPages())
                const preamble = await pdfDoc.embedPage(usConstitutionPdf.getPages()[0]);
                console.log(' Inside page is ', page)
 
                const preambleDims = preamble.scale(0.95);
 
                page.drawPage(preamble, {
                    ...preambleDims,
                    x: 0,
                    y: 0
                });
                
            }
 
        }
        const pdfBytes = await pdfDoc.save();
        this.saveByteArray("Labels", pdfBytes);

        this._showSpinner = false;
    }

    saveByteArray(pdfName, byte) {
        var blob = new Blob([byte], { type: "application/pdf" });
        var link = document.createElement("a");
        link.href = window.URL.createObjectURL(blob);
        link.target = '_blank'
        var fileName = pdfName;
        link.download = fileName;
        link.click();

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