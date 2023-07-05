import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

import getPreparedLineForBilling from '@salesforce/apex/OpportunityDetailPageController.getPreparedLineForBilling'
import createBilling from '@salesforce/apex/OpportunityDetailPageController.createBilling'

const PICKLIST_BILL_OPTIONS = [
    {label: 'All', value: 'All'},
    {label: 'Deposit', value: 'Deposit'}
]

export default class CreateBillingCMP extends NavigationMixin(LightningElement) {

    @api recordId;
    billPicklistOptions = PICKLIST_BILL_OPTIONS;
    @track billPicklistSelected = 'All';
    @track selectedBillingType = 'Percent';
    @track initialData = {}
    @track accountInfo = {};
    @track ledgerInfo = {}
    @track isFirstBilling = false;
    @track selectedBillingFormat;
    @track billingDate;
    @track dueDate;
    @track deposit = 100;
    @track linesData = []
    @track totalAmountToBill = 0;

    @track dataIsReady = false;

    connectedCallback(){
        console.log('recordId: ',JSON.stringify(this.recordId))
        this.getInitialBillingData();
    }

    getInitialBillingData(){
        getPreparedLineForBilling({
            type: 'Opportunity',
            recordId: this.recordId
        }).then(res => {
            const data = JSON.parse(res);
            console.log(res)
            this.initialData = data;
            this.accountInfo = {
                name: data.accountName,
                id: data.accountId
            }
            this.isFirstBilling = data.isFirstBilling;
            this.deposit = data.deposit;
            this.ledgerInfo = data.ledger;
            this.selectedBillingFormat = data.billingFormatId;
            this.billingDate = data.billingDate;
            this.dueDate = data.dueDate;
            this.linesData = data.billingLines.map(el => {
                return {
                    ...el,
                    toBillNumber: el.isLineFullyBilled ? null : 100,
                    quantityToBill: el.quantityUnBilled
                }
            });
            this.recalculateCurrencyFields();
            this.recalculateTotalAmountToBill();

            this.dataIsReady = true;
        }).catch(err => {
            console.error(err)
        })
    }

    recalculateCurrencyFields(){
        let linesDataCopy = [...this.linesData];

        linesDataCopy.forEach(el => {
            el['totalPrice'] = el['unitPrice'] * el['quantityOrdered']
            el['unbilledAmount'] = el['totalPrice'] - el['billedAmount'];
            el['amountToBill'] = el['quantityUnBilled'] * el['unitPrice'];
        })

        this.linesData = linesDataCopy;
    }
    
    recalculateTotalAmountToBill(){
        this.totalAmountToBill = [...this.linesData].reduce((acc, cur) => {
            return acc + cur['amountToBill'];
        }, 0)
    }
    handleSelectedValue(e){
        console.log(JSON.stringify(e.detail))
        this.selectedBillingFormat = e.detail.id
    }

    onRemoveHandler(e){
        this.selectedBillingFormat = '';
    }


    handleChangeBillOption(e){
        this.billPicklistSelected = e.detail.value;
        console.log(e.detail.value)
        let dataCopy = [...this.linesData];
        this.selectedBillingType = 'Percent';

        if(this.billPicklistSelected == 'All'){
            dataCopy.forEach(el => {
                el.toBillNumber = el.isLineFullyBilled ? null : 100;
                el.quantityToBill = el.quantityUnBilled;
                el.amountToBill = el.quantityToBill * el.unitPrice;
            })
            this.linesData = dataCopy;
            this.recalculateTotalAmountToBill();
        }else if(this.billPicklistSelected == 'Deposit'){
            dataCopy.forEach(el => {
                el.toBillNumber = el.isLineFullyBilled ? null : this.deposit;
                el.quantityToBill = (el.quantityUnBilled * this.deposit)/100;
                el.amountToBill = el.quantityToBill * el.unitPrice;
            })
            this.linesData = dataCopy;
            this.recalculateTotalAmountToBill();
        }
    }

    handleBillQuantityChange(e){
        this.dataIsReady = false;
        const enteredValue = e.target.value;
        const lineId = e.target.dataset.lineid;
        const lineItem = this.linesData.find(el => el.lineId == lineId);
        console.log('lineItem: ',JSON.stringify(lineItem));
        if(enteredValue < 0){
            this.showToast('Warning', 'Can not enter value less than 0.','WARNING');
            this.recalculateCurrencyFields();
            this.recalculateTotalAmountToBill();
        }else if(this.selectedBillingType == 'Percent' && enteredValue > 100){
            this.showToast('Warning', 'Can not enter percent more than 100.','WARNING');
            this.updateDataLine(lineId, 'toBillNumber', 100);
            this.recalculateCurrencyFields();
            this.recalculateTotalAmountToBill();
        }else if(this.selectedBillingType == 'Quantity' && enteredValue > lineItem.quantityUnBilled){
            this.showToast('Warning', 'Can not enter percent more than ' + lineItem.quantityUnBilled,'WARNING');
            this.updateDataLine(lineId, 'toBillNumber', lineItem.quantityUnBilled);
            this.recalculateCurrencyFields();
            this.recalculateTotalAmountToBill();
        }else if(this.selectedBillingType == 'Amount' && enteredValue > lineItem.unbilledAmount){
            this.showToast('Warning', 'Can not enter percent more than unbilled amount.','WARNING');
            this.updateDataLine(lineId, 'toBillNumber', lineItem.unbilledAmount);
            this.recalculateCurrencyFields();
            this.recalculateTotalAmountToBill();
        }else{
            this.updateDataLine(lineId, 'toBillNumber', enteredValue);
            let quantityToBill = lineItem.quantityToBill;

            if(this.selectedBillingType == 'Percent'){
                quantityToBill = (lineItem.quantityUnBilled * enteredValue)/100;
            }else if(this.selectedBillingType == 'Quantity'){
                quantityToBill = enteredValue;
            }else if(this.selectedBillingType == 'Amount'){
                quantityToBill = enteredValue / lineItem.unitPrice;
            }

            let amountToBill = quantityToBill * lineItem.unitPrice;
            this.updateDataLine(lineId, 'quantityToBill', quantityToBill);
            this.updateDataLine(lineId, 'amountToBill', amountToBill);

        }

        // this.recalculateCurrencyFields();
        this.recalculateTotalAmountToBill();
        this.dataIsReady = true;
    }
    updateDataLine(lineId, key, value){
        let linesDataCopy = [...this.linesData];
        let index = linesDataCopy.findIndex(el => el.lineId == lineId);
        linesDataCopy[index][key] = value;

        this.linesData = linesDataCopy;
        console.log('this.linesData: ',JSON.stringify(this.linesData))
    }

    handleBillTypeChange(e){
        const BILL_TYPE = e.target.value;
        this.selectedBillingType = BILL_TYPE;
        if(BILL_TYPE == 'Quantity'){
            this.linesData.forEach(el => {
                el.toBillNumber = el.isLineFullyBilled ? null : el.quantityUnBilled;
            })
            
        }else if(BILL_TYPE == 'Amount'){
            this.linesData.forEach(el => {
                el.toBillNumber = el.isLineFullyBilled ? null : el.unbilledAmount;
            })
        }else if(BILL_TYPE == 'Percent'){
            this.linesData.forEach(el => {
                el.toBillNumber = el.isLineFullyBilled ? null : 100;
            })
        }


        this.recalculateCurrencyFields();
        this.recalculateTotalAmountToBill();
    }

    handleBillingDateChange(e){
        this.billingDate = e.target.value;
    }

    handleDueDateChange(e){
        this.dueDate = e.target.value; 
    }

    handleCreateBilling(){
        let properties = this.getPreparedCreateBillingData();
        createBilling({
            linesWrapperJson: properties
        }).then(res => {
            const billingId = res;

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: billingId,
                    actionName: 'view'
                }
            });
        }).catch(err => {
            console.error(err)
            this.showToast('Error', err.body.message, 'ERROR')
        })
    }
    getPreparedCreateBillingData(){
        const body = {}
        body['recordId'] = this.recordId;
        body['billingDate'] = this.billingDate;
        body['dueDate'] = this.dueDate;
        body['accountId'] = this.accountInfo.Id;
        body['ledger'] = this.ledgerInfo.Id;
        body['billingFormatId'] = this.selectedBillingFormat;

        let linesToCreate = this.linesData.filter(el => el.quantityToBill > 0).filter(el => el.isLineFullyBilled == false).map(el => {
            return {
                lineId: el.lineId,
                quantity: el.quantityToBill
            }
        })

        body['lines'] = linesToCreate;

        console.log(JSON.stringify(body))
        return JSON.stringify(body)
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