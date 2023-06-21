import { LightningElement, api, track } from 'lwc';
import saveProposalPDF from '@salesforce/apex/CreateProposalExtensionNew.saveProposalPDF'

import getFrontPageStatic from '@salesforce/apex/CreateProposalExtensionNew.getFrontPageStatic'
import getProposalTemplateContent from '@salesforce/apex/CreateProposalExtensionNew.getProposalTemplateContent'
import getQuoteDocumentContent from '@salesforce/apex/CreateProposalExtensionNew.getQuoteDocumentContent'
import checkDoesQuoteHasProposal from '@salesforce/apex/CreateProposalExtensionNew.checkDoesQuoteHasProposal'

import getQuoteAndQuoteLines from '@salesforce/apex/CreateProposalExtensionNew.getQuoteAndQuoteLines'
import fetchQuoteProposalTemplates from '@salesforce/apex/CreateProposalExtensionNew.fetchQuoteProposalTemplates'
import getProductSpecRepParsedURL from '@salesforce/apex/CreateProposalExtensionNew.getProductSpecRepParsedURL'


import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

import jquery from '@salesforce/resourceUrl/jQueryV331';

export default class CreateProposalCmp extends LightningElement {
    @api quoteId = ''

    @track b64dataObj = {}
    @track b64data = []

    @track _QuoteRecord;
    @track _QuoteLineItems = []

    @track hasError = false;
    @track quoteTemplatesOptions = []
    @track quoteTemplates = []
    @track _selectedTemplate;
    @track withTechnicalSpecs = false;

    @track createAnyway = false;
    //ERRORS

    @track FRONT_PAGE_ERROR = false;
    @track PROPOSAL_PAGE_ERROR = false;
    @track QUOTE_DOCUMENT_PAGE_ERROR = false;
    @track ANOTHER_ERROR = false;
    @track ERROR_MESSAGE = ''
    @track INFO_MESSAGE = ''
    @track SHOW_MESSAGE = false
    @track SHOW_CREATED = false

    @track showProposalPDF = false


    @track PDF_BODY = ''
    @track previewAvailable = true;
    connectedCallback(){
        this.initial();
    }

    renderedCallback(){
        loadScript(this, jquery)
        .then(() => {
            console.log('JQuery loaded.');
        })
        .catch(error=>{
            console.log('Failed to load the JQuery : ' +error);
        });
    }

    initial(){
        this.doesQuoteHasProposalAlready();
        this.getQuoteInfo();
        this.getProposalTemplates();

        
    }
    doesQuoteHasProposalAlready(){
        checkDoesQuoteHasProposal({
            quoteId: this.quoteId
        }).then(res => {
            console.log('STATUS: ',res)
            if(res == true){
                this.hasError = true;
                alert("A proposal already exists in Notes & Attachments for this quote.")
            }
        }).catch(err => {
            alert(err.body.message)
        })
    }
    getQuoteInfo(){
        getQuoteAndQuoteLines({
            quoteId: this.quoteId
        }).then(res => {
            const resp = JSON.parse(res);
            this._QuoteRecord = resp.quote;
            this._QuoteLineItems = resp.quoteLineItems;

            if(this._QuoteRecord.Opportunity_in_Approval__c){
                alert('Locked Opportunity, pending Approval.')
                this.hasError = true;
            }
            this.fetchProposalPageContent();
        }).catch(err => {
            alert(err.body.message);
        })
    }
    getProposalTemplates(){
        fetchQuoteProposalTemplates({
            quoteId: this.quoteId
        }).then(res => {
            const response = JSON.parse(res)
            if(!response.length) return;
            const options = []
            response.forEach(el => {
                if(el.Template_Name__c){
                    options.push({
                        label: el.Name,
                        value:  el.Template_Name__c
                    })
                }
                
            })

            this.quoteTemplatesOptions = options;
            this.quoteTemplates = response;
        })
    }

    fetchProposalPageContent(){
        (async () => {
            this.getFrontPageStaticCall();
            this.getQuoteDocumentContentCall();
        })();
    }

    getFrontPageStaticCall(){
        getFrontPageStatic({
            quoteId: this.quoteId
        }).then(res => {
            this.b64dataObj["1"] = res
        }).catch(err => {
            this.FRONT_PAGE_ERROR = true;
            alert(err)
        })
    }

    getProposalTemplateContentCall(parentId){
        getProposalTemplateContent({
            parentId: parentId,
            name: this._selectedTemplate
        }).then(res => {
            this.b64dataObj["2"] = res
        }).catch(err => {
            this.hasError = true;
            this._selectedTemplate = ""
            console.log(err)
            alert(err.body.message)
        })
    }
    getQuoteDocumentContentCall(){
        getQuoteDocumentContent({
            quoteId: this.quoteId
        }).then(res => {
            this.b64dataObj["3"] = res
        }).catch(err => {
            this.QUOTE_DOCUMENT_PAGE_ERROR = true;
            console.error(err)
        })
    }


    handleTestClick(){
        console.log(JSON.stringify(this.b64dataObj))
        console.log(this.FRONT_PAGE_ERROR)
        console.log(this.PROPOSAL_PAGE_ERROR)
        console.log(this.QUOTE_DOCUMENT_PAGE_ERROR)
    }

    handleTemplateChange(event) {
        this._selectedTemplate = event.detail.value;

        let proposalTemplate = this.quoteTemplates.find(el => el.Template_Name__c == this._selectedTemplate)
        this.getProposalTemplateContentCall(proposalTemplate.Id);
    }
    handleToggleChange(e){
        if(this._QuoteLineItems.length > 0){
            this.withTechnicalSpecs = !this.withTechnicalSpecs
        }else{
            this.ERROR_MESSAGE = '<b>Can not create Proposal with technical specs, because quote has not line items</b><br/>'
            this.addCustomError(this.ERROR_MESSAGE)
        }
    }

    handleStartProcessing(){
        if(!this._selectedTemplate){
            this.ANOTHER_ERROR = true;
            this.ERROR_MESSAGE = '<b>Select Proposal Template from dropdown below. <br/>1. If dropdown has no active options, create it: <a href="/a2V/e?retURL=%2Fa2V%2Fo" target="_blank">Create Proposal Template</a><br/>'
            this.ERROR_MESSAGE += '2. Attach template pdf to Attachments related list.<br/>'
            this.ERROR_MESSAGE += '3. Update "Template Name" field with attached file fullname with extension. Example: Hospitality_Template.pdf</b>'
            this.addCustomError(this.ERROR_MESSAGE)
            return;
        }else{
            this.ANOTHER_ERROR = false;
            this.ERROR_MESSAGE = ""
            this.addCustomError(this.ERROR_MESSAGE)
        }

        
        if(this.withTechnicalSpecs){
            let HasProductsWithoutTechSpec = false;
            let productsWithoutTechSpec = {}

            this._QuoteLineItems.forEach(el => {
                if(!el.Product2.Technical_Specs_Id__c){
                    HasProductsWithoutTechSpec = true;
                    productsWithoutTechSpec[el.Product2.Name] = el.Product2.Id
                }
            })

            if(HasProductsWithoutTechSpec){
                this.ANOTHER_ERROR = true;
                this.ERROR_MESSAGE = '<b>The following Product(s) are missing their Techincal Specs PDF:<br/>'
                for(let product in productsWithoutTechSpec){
                    this.ERROR_MESSAGE += '<a href="/'+productsWithoutTechSpec[product]+'" target="_blank">'+product+'<a><br/>'
                }
                this.ERROR_MESSAGE += '</b>'

                this.createAnyway = true;
                this.addCustomError(this.ERROR_MESSAGE)
                return;
            }
        }else{
            this.handleSendRequestForCombining();
        }
    }

    handleCreateAnyway(){
        try{
            if(this.withTechnicalSpecs){
                const setTechnicalSpecs = [];
    
                this._QuoteLineItems.forEach(el => {
                    if(el.Product2.Technical_Specs_Id__c){
                        if(!setTechnicalSpecs.includes(el.Product2.Technical_Specs_Id__c)){
                            setTechnicalSpecs.push(el.Product2.Technical_Specs_Id__c)
                        }
                    }
                })
    
                if(setTechnicalSpecs.length > 0){
                    this.SHOW_MESSAGE = true;
                    this.INFO_MESSAGE = '<b>Fetching lines technical specs...</b>'
                    this.addCustomInfoMessage(this.INFO_MESSAGE)
                    getProductSpecRepParsedURL({
                        qouteLinesSpecURLJSON: JSON.stringify(setTechnicalSpecs)
                    }).then(res => {
                        let iterator = 4
                        res.forEach(el => {
                            this.b64dataObj[iterator.toString()] = el;
                            iterator++;
                        })

                        this.INFO_MESSAGE = '<b>Technical Specs Received!</b>'
                        this.addCustomInfoMessage(this.INFO_MESSAGE)

                        this.handleSendRequestForCombining();
                    }).catch(err => {
                        console.error(err)
                    })
    
                }
            }else{
                this.handleSendRequestForCombining();
            }
        }catch(err){
            console.error(err)
        }
        
        
    }

    handleSendRequestForCombining(){
        this.SHOW_MESSAGE = true;
        this.INFO_MESSAGE = '<b>Waiting for Quote Proposal Pdf...</b>'
        this.addCustomInfoMessage(this.INFO_MESSAGE)

        this.apiRequest();
    }
    addCustomError(inner){
        setTimeout(() => {
            let Element = this.template.querySelector('div[data-custom-error="true"]');
            Element.innerHTML = inner
        },500)
        
    }
    addCustomInfoMessage(inner){
        setTimeout(() => {
            let Element = this.template.querySelector('div[data-custom-info="true"]');
            Element.innerHTML = inner
        },500)
        
    }



    b64toBlob = (b64Data, contentType='', sliceSize=512) => {
        const byteCharacters = atob(b64Data);
        const byteArrays = [];
        
        for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        const slice = byteCharacters.slice(offset, offset + sliceSize);
        
        const byteNumbers = new Array(slice.length);
        for (let i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
        }
    
        const byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
        }
        
        const blob = new Blob(byteArrays, {type: contentType});
        return blob;
    }

    sortObject = o => Object.keys(o).sort().reduce((r, k) => (r[k] = o[k], r), {})

    apiRequest(){
        var uploadFormData = new FormData();
        uploadFormData.append("user","9c1ca8fb-813e-4ed7-970f-42188962713f");
        uploadFormData.append("password","4RKxwJo4QB1YnyjN");
        uploadFormData.append("test","true");

        let i = 1;
        this.b64data = Object.values(this.sortObject(this.b64dataObj))
        this.b64data.forEach(el => {
            let blob1 = this.b64toBlob(el, "application/pdf")
            uploadFormData.append("file_"+i, blob1)

            console.log(blob1)
            i++;
        })
        
        console.log('PDF_BODY: '+this.PDF_BODY)
        
        let obj = {
            setPDFBody: (content) => {
                try{
                    console.log('inited')
                    console.log('inited content: ',content)
                    this.handleSetBodyPdf(content)
                    console.log('inited after')
                    console.log(this.PDF_BODY)
                }catch(err){
                    console.error(err)
                }
            }
        }

        
        let TEMPLATE = this.template
        $.ajax({
            async: true,
            url : "https://www.hypdf.com/pdfunite",
            type : "POST",
            data : uploadFormData,
            cache : false,
            contentType : false,
            processData : false,
            xhr:function(){// Seems like the only way to get access to the xhr object
                var xhr = new XMLHttpRequest();
                xhr.responseType= 'blob'
                return xhr;
            },
            error: function(xhr, status, error) {
                if(error == 'Payment Required'){
                    // QuotaExceeded('payment');
                }else{
                    // QuotaExceeded('other');
                }

                console.error('error: ',error)
            },
            success : function(response, status, xhr) {
                console.log(55555)
                var reader = new FileReader();
                reader.readAsDataURL(response); 
                reader.onloadend = function() {
                    let base64data = reader.result; 
                    if(base64data.indexOf(",") > -1){
                        console.log('JQUERY SUCCESS')
                        // var sendData = new wrapper();
                        // console.log('base64data: ',base64data)
                        // saveProposalPDF({
                        //     qId: '0Q0Ei0000001MPtKAM',
                        //     str: base64data.split(',')[1]
                        // }).then(res => {
                        //     console.log(res)
                        // }).catch(err => {
                        //     console.log(err)
                        // })

                        obj.setPDFBody(base64data)
                        
                    }else{

                    }
                }
            }
        });

        

    }

    handleSetBodyPdf(content){
        this.showProposalPDF = false;
        this.PDF_BODY = content
        this.showProposalPDF = true;

        const stringLength = content.length 
        const sizeInBytes = 4 * Math.ceil(stringLength / 3) * 0.5624896334383812;
        const sizeInKb = sizeInBytes / 1000;
        const sizeInMb = sizeInKb / 1000;
        console.log('sizeInMb: ',sizeInMb)
        if(sizeInMb > 2){
            this.previewAvailable = false;
        }
        this.SHOW_CREATED = true;
        this.FRONT_PAGE_ERROR = false;
        this.PROPOSAL_PAGE_ERROR = false;
        this.QUOTE_DOCUMENT_PAGE_ERROR = false;
        this.ANOTHER_ERROR = false;
        this.SHOW_MESSAGE = false;
    }   

    handleGoBack(){
        console.log('BACK BACK BACK')
        // window.location.replace = '/'+this._QuoteRecord.Id
        var url = 'https://seawin--peeklpart.sandbox.my.salesforce.com/0Q0Ei0000001MPt'
        window.location.href = url
        
    }

    savePdfAction(){
        

        saveProposalPDF({
            qId: this.quoteId,
            str: this.PDF_BODY.split(',')[1]
        }).then(res => {
            alert("Proposal PDF has been saved.")
        }).catch(err => {
            console.log(err)
        })
    }
}