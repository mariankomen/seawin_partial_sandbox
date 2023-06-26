import { LightningElement, api, track } from 'lwc';

export default class PicklistCustomTypeCMP extends LightningElement {


    @api label = '';
    @api value = '';
    @api placeholder = '';
    @api options = [];


    handleChange(e){
        const selectEvent = new CustomEvent('picklistselect', {
            composed: true,
            bubbles: true,
            detail: {
                value: e.detail.value,
                field: 'test'
            }
        });
        this.dispatchEvent(selectEvent);
    }
}