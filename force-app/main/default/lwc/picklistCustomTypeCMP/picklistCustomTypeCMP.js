import { LightningElement, api, track } from 'lwc';

export default class PicklistCustomTypeCMP extends LightningElement {


    @api label = '';
    @api value = '';
    @api placeholder = '';
    @api options = [];
    @api fieldapi;
    @api productid;
    @api disable = false;

    handleChange(e){
        let row = this.productid
        console.log('hahaha')
        const selectEvent = new CustomEvent('picklistselect', {
            composed: true,
            bubbles: true,
            detail: {
                value: e.detail.value,
                field: e.target.dataset.field,
                rowId: row
            }
        });
        this.dispatchEvent(selectEvent);
    }
}