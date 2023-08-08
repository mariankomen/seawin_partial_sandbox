import { LightningElement, api, track } from 'lwc';

export default class InputCustomType extends LightningElement {
    @api value;
    @api fieldapi;
    @api lineId;

    handleInputChange(e){
        console.log(e.target.value)
        let row = this.lineId;
        const selectEvent = new CustomEvent('inputchange', {
            composed: true,
            bubbles: true,
            detail: {
                value: e.target.value,
                field: e.target.dataset.field,
                rowId: row
            }
        });
        this.dispatchEvent(selectEvent);
    }
}