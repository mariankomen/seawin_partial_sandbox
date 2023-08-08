import { LightningElement, api, track } from 'lwc';
import insertLinesController from '@salesforce/apex/ProductListViewController.insertLinesController'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const TOAST_SUCCESS_TYPE = 'success';
const TOAST_WARNING_TYPE = 'warning';
const TOAST_ERROR_TYPE = 'error';

export default class AddProductCMP extends NavigationMixin(LightningElement) {

    @track selectedProducts = [];
    @track isModalOpen = false;
    @track _isDataReady = false;
    @track _sObjectCode;
    @track recordId;

    _linesWrapperList = [];

    @track headerLabel = '';

    @api setSelectedProducts(data, sObjectCode, targetRecordId){
        try{
            this.resetAllTemporaryVariables();
            let parsedData = JSON.parse(data)
            this.selectedProducts = parsedData;
            this._sObjectCode = sObjectCode;
            this.recordId = targetRecordId;
            this.openModal();
            this.compileDefaultLineRecords();
            this.compileHeaderLabel();
            this._isDataReady = true;
        }catch(err){
            console.error(err)
        }
        
    }

    resetAllTemporaryVariables(){
        this.selectedProducts = [];

        this.isModalOpen = false;
        this._isDataReady = false;
        this._sObjectCode;
        this.recordId;

        this._linesWrapperList = [];

        this.headerLabel = '';
    }

    compileDefaultLineRecords(){
        this.selectedProducts.forEach(product => {
            this._linesWrapperList.push({
                productId: product.Id,
                quantity: 0,
                salesPrice: null,
                description: product.Description,
                size: product.Size__c,
                allowDescriptionChange: product.Allow_Product_Description_Change__c
            })
        })
    }
    compileHeaderLabel(){
        if(this._linesWrapperList.length > 1){
            this.headerLabel += 's';
        }

        switch (this._sObjectCode) {
            case 'so':
              this.headerLabel += ' to Sales Order';
              break;
            case 'opp':
                this.headerLabel += ' to Opportunity';
                break;
            default:
        }
    }

    handleQuantity(e){
        let productId = e.target.dataset.id;
        let quantity = e.target.value;

        this.handleObjectFieldByKey(productId, 'quantity', +quantity);
    }
    handleSalesPrice(e){
        let productId = e.target.dataset.id;
        let salesPrice = e.target.value;
        this.handleObjectFieldByKey(productId, 'salesPrice', +salesPrice);

    }
    
    handleDescriptionChange(e){
        let productId = e.target.dataset.id;
        let description = e.target.value;

        this.handleObjectFieldByKey(productId, 'description', description);

    }

    handleSizeChange(e){
        let productId = e.target.dataset.id;
        let size = e.target.value;

        this.handleObjectFieldByKey(productId, 'size', size);

    }


    removeLineHandler(e){
        let productId = e.target.dataset.id;

        let productsCopy = [...this.selectedProducts];
        productsCopy = this.removeObjectWithId(productsCopy, productId, 'Id');

        this.selectedProducts = productsCopy;


        let linesWrapperListCopy = [...this._linesWrapperList];
        linesWrapperListCopy = this.removeObjectWithId(linesWrapperListCopy, productId, 'productId');

        this._linesWrapperList = linesWrapperListCopy;

        if(this.selectedProducts.length == 0){
            this.closeModal();
        }


    }

    removeObjectWithId(arr, id, idKey) {
        const objWithIdIndex = arr.findIndex((obj) => obj[idKey] === id);
      
        if (objWithIdIndex > -1) {
          arr.splice(objWithIdIndex, 1);
        }
      
        return arr;
    }
    handleObjectFieldByKey(id, fieldKey, value){
        const index = this._linesWrapperList.findIndex((obj) => obj['productId'] === id);
        if (index > -1) {
            this._linesWrapperList[index][fieldKey] = value;
        }
    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        let allQuantitiesValid = true;
        let allSalesPricesValid = true;

        this._linesWrapperList.forEach(line => {
            if(line.quantity <= 0){
                allQuantitiesValid = false;
            }
            if(line.salesPrice == null || !line.salesPrice){
                allSalesPricesValid = false;
            }
        })

        if(!allQuantitiesValid){
            this.showToast('Warning', 'Quantity must be more than 0.', TOAST_WARNING_TYPE);
            return;
        }

        if(!allSalesPricesValid){
            this.showToast('Warning', 'Enter Sales Price for each line.', TOAST_WARNING_TYPE);
            return;
        }


        insertLinesController({
            sobjectType: this._sObjectCode,
            recordId: this.recordId,
            linesWrapper: JSON.stringify(this._linesWrapperList)
        }).then(res => {
            console.log('lines were inserted');
            this.showToast('Success', 'Products were added succesfully.',TOAST_SUCCESS_TYPE)

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                }
            });

        }).catch(err => {
            this.showToast('Error during inserting lines', err.body.message, TOAST_ERROR_TYPE);
        })
        console.log(JSON.stringify(this._linesWrapperList));
        // this.isModalOpen = false;
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