import { LightningElement, api, track, wire } from 'lwc';
import getPredefinedSalesOrderData from '@salesforce/apex/OpportunityDetailPageController.getPredefinedSalesOrderData'
import createSalesOrder from '@salesforce/apex/OpportunityDetailPageController.createSalesOrder'
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateSalesOrderCMP extends NavigationMixin(LightningElement)  {

    @api recordId; 
    @track predefinedData = {}
    @track _ledgers = []
    _selectedLedger;

    _GLVariable_1;

    activeSections = ['A','B'];

    _masterCheck = true;

    connectedCallback(){
        this.fetchPredefinedData();
    }


    fetchPredefinedData(){
        getPredefinedSalesOrderData({
            opportunityId: this.recordId
        }).then(res => {
            console.log(res)
            const data = JSON.parse(res)
            let _id = 0;
            data.lines.forEach(el => {
                el.selected = true;
                el.total = el.quantity * el.salesPrice
                el.kitChildrens.forEach(children => {
                    children['id'] = _id;
                    _id += 1;
                })
                _id = 0;
            })
            this.predefinedData = data;
            console.log(1)
            this._GLVariable_1 = data.glVariable.Id;

            const ledgers = [];

            data?.ledgers.forEach(el => {
                ledgers.push({
                    label: el.Name,
                    value: el.Id
                })
            })

            console.log('sdasd:  ',JSON.stringify(this.predefinedData.lines))
            this._ledgers = ledgers;
            this._selectedLedger = this._ledgers[0].value;

            this.predefinedData['selectedLedgerId'] = this._selectedLedger;
            this.predefinedData['selectedGlVarId'] = this._GLVariable_1;
            let cmp = this.template.querySelector('c-reusable-lookup')
            cmp.fetchDefaultRecord(this._GLVariable_1);

            console.log(2)
        }).catch(err => {
            console.error(err)
            if(err.body.message.includes('Opportunity can not have more than 1 Sales Order')){
                this.redirectToOpportunity();
                this.showToast('Warning',err.body.message, 'Info')
            }else{
                this.showToast('Error',err.body.message,'Error')
            }
        })
    }

    redirectToOpportunity(){
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
    handleSelectedValue(e){
        console.log(JSON.stringify(e.detail))
        this._GLVariable_1 = e.detail.id
        this.predefinedData['selectedGlVarId'] = this._GLVariable_1;

    }

    handleChange(e){
        this._selectedLedger = e.detail.value;
        this.predefinedData['selectedLedgerId'] = e.detail.value;
        
    }
    onRemoveHandler(e){
        this._GLVariable_1 = '';
    }

    handleChildrenFieldChange(e){
        const field = e.target.dataset.field;
        const childrendId = e.target.dataset.id;
        const parent = e.target.dataset.parent;
        const value = e.target.value;

        const parentIndex = this.predefinedData.lines.findIndex(el => el.opportunityLineId == parent);
        console.log('parentIndex: ',parentIndex)
        const childrenIndex = this.predefinedData.lines[parentIndex]?.kitChildrens.findIndex(el => el.id == childrendId);
        console.log('childrenIndex: ',childrenIndex)
        this.predefinedData.lines[parentIndex].kitChildrens[childrenIndex][field] = value;

        console.log('success')
    }
    handleFieldChange(e){
        const field = e.target.dataset.field;
        const lineid = e.target.dataset.lineid;
        const value = e.target.value;
        const index = this.predefinedData.lines.findIndex(el => el.opportunityLineId == lineid);

        if(field != 'quantity'){
            this.predefinedData.lines[index][field] = value;
        }else{
            this.predefinedData.lines[index][field] = value;

            if(this.predefinedData.lines[index]?.isKit){
                this.predefinedData.lines[index]?.kitChildrens.forEach(el => {
                    el['quantity'] = el['kitQuantity'] * value;
                })
            }

            this.recalculateTotalSalesPrice();
        }
        console.log('index: ',index)
        console.log(field)
        console.log(lineid)
        console.log(value)
        console.table(this.predefinedData.lines[index])
    }

    handleMasterCheck(e){
        this._masterCheck = !this._masterCheck;

        this.predefinedData.lines.forEach(el => {
            el.selected = this._masterCheck;
        })
    }
    handleCheckboxSelectChange(e){
        const lineid = e.target.dataset.lineid;
        const index = this.predefinedData.lines.findIndex(el => el.opportunityLineId == lineid);

        this.predefinedData.lines[index].selected = e.target.checked;

        this.handleCheckMasterCheckboxValue();
    }

    handleCheckMasterCheckboxValue(){
        this._masterCheck = [...this.predefinedData.lines].every(el => el.selected == true);

        console.log(this._masterCheck)
    }

    recalculateTotalSalesPrice(){
        this.predefinedData.lines.forEach(el => {
            el.total = el.quantity * el.salesPrice
        })
    }

    handleSave(){
        const dataToCreate = [...this.predefinedData.lines].filter(el => el.selected);

        if(!dataToCreate.length){
            this.showToast('Warning','Select at least one product to continue.','Warning')
            return;
        }
        // this.showToast('Info','Working...','Info')


        console.log(dataToCreate.length)
        console.table(dataToCreate)

        createSalesOrder({
            payload: JSON.stringify(this.predefinedData),
            opportunityId: this.recordId
        }).then(salesOrderId => {
            console.log(4)
            this.showToast('Success','Sales Order was created.','Success')
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: salesOrderId,
                    actionName: 'view'
                }
            });
        }).catch(err => {
            console.error(err)
            this.showToast('Error',err.body.message,'Error')
        })
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