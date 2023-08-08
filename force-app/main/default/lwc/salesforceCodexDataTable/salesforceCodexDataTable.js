import LightningDatatable from 'lightning/datatable';

import imageTableControl from './imageTableControl.html';
import picklistType from './picklistType.html';
import inputType from './inputType.html';

export default class SalesforceCodexDataTable extends LightningDatatable  {

    static customTypes = {
        image: {
            template: imageTableControl
        },
        picklistType: {
            template: picklistType,
            standardCellLayout: true,
            typeAttributes: ['label','value','placeholder','options','fieldapi', 'productId','disabled']
        },
        inputType: {
            template: inputType,
            standardCellLayout: true,
            typeAttributes: ['value', 'fieldapi','lineId']
        }
    };

}