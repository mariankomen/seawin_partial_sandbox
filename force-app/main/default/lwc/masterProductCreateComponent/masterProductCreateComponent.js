import { LightningElement, track } from 'lwc';
import fetchPicklistsValues from '@salesforce/apex/MasterProductController.fetchPicklistsValues'
import fetchFieldsExceptSelectedProperties from '@salesforce/apex/MasterProductController.fetchFieldsExceptSelectedProperties'
import combineFieldWithType from '@salesforce/apex/MasterProductController.combineFieldWithType'
import createProductsFromMasterProduct from '@salesforce/apex/MasterProductController.createProductsFromMasterProduct'
import checkProductSKUAvailability from '@salesforce/apex/MasterProductController.checkProductSKUAvailability'
import getAllPicklistFieldsWithOptions from '@salesforce/apex/MasterProductController.getAllPicklistFieldsWithOptions'
import getMasterProduct from '@salesforce/apex/MasterProductController.getMasterProduct'
import getFieldsMap from '@salesforce/apex/MasterProductController.getFieldsMap'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from "lightning/confirm";

export default class MasterProductCreateComponent extends LightningElement {

    @track show_spinner = false;
    @track all_fields_map = {}
    @track all_picklist_map_values = {}
    @track property_fields = []
    @track fields = []
    @track show_form = false;
    @track master_product_created_id = ''
    @track predefined_table_columns = [];
    @track predefined_table_data = [];
    @track show_predefined_table = false;
    draftValues = [];
    @track show_modal_lead_edit = false;

    @track editable_row_id = ''
    @track editable_row_fields = [];
    @track editable_row_object = {}
    property_attribute_map = {}
    @track preselected_rows = []

    @track master_product_properties = {}
    @track show_properties = false;


    @track show_add_column_popup = false;
    @track available_additional_columns = []
    @track selected_new_column = ''

    showAddColumn(){
        this.show_add_column_popup = true;
        this.addColumnHandler()
    }
    hideAddColumn(){
        this.show_add_column_popup = false;
    }
    addColumnHandler(){
        const available_fields = []
        let single_record = this.property_fields[0]
        let already_selected_fields = []

        this.predefined_table_columns.forEach(el => {
            already_selected_fields.push(el.fieldName)
        })

        for(let char in single_record){
            if(char !== 'picklist_values'
                && char !== 'label'
                && char !== 'isText'
                && char !== 'isPicklist'
                && char !== 'isCheckbox'
                && char !== 'field_type'
                && char !== 'apiname'
                && char !== 'placeholder'
                && char !== 'placeholder_attr'
                && char !== 'placeholder_name'
                && char !== 'placeholder_desc'
                && char !== 'inputs'
                && !char.endsWith('__r')
                && !already_selected_fields.includes(char)
            ){
                available_fields.push({
                    label: this.all_fields_map[char],
                    value: char
                })
            }
        }
        
        this.available_additional_columns = available_fields.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0))
        

    }
    addNewColumn(){
        try{
            this.show_predefined_table = false;
            // selected_new_column
            console.log('predefined_table_data: '+JSON.stringify(this.predefined_table_data))
            let copy = [...this.predefined_table_data]
            copy.forEach(el => {
                el[this.selected_new_column] = this.property_fields[0][this.selected_new_column]
            })
    
            this.predefined_table_data = copy;
            let copy_columns = [...this.predefined_table_columns]
            
            copy_columns.push({
                label: this.all_fields_map[this.selected_new_column],
                fieldName: this.selected_new_column.toLowerCase(),
                sortable: "true"
            })
            this.predefined_table_columns = copy_columns
    
            this.show_predefined_table = true;
            this.hideAddColumn();
        }catch(err){
            console.error(err)
        }
        
    }

    async handleConfirm(mes, them, lab) {
        const result = await LightningConfirm.open({
          message: mes,
          theme: them,
          label: lab
        });
        return result;
    }

    connectedCallback(){
        
        fetchPicklistsValues().then(res => {
            const result = JSON.parse(res)
            result.forEach(el => {
                if(!el.isPicklist){
                    el.inputs = [{
                        value: el.isText ? '' : false,
                        attribute: '',
                        name_keyword: '',
                        description_keyword: '',
                        index: 0
                    }]
                }
                
                if(el.isCheckbox){
                    el.two_checkboxes = false;
                }
                el.placeholder = `Enter: ${el.label}`
                el.placeholder_attr = `Enter abbreviation for: ${el.label}`
                el.placeholder_name = `Enter Name keyword for: ${el.label}`
                el.placeholder_desc = `Enter Description keyword for: ${el.label}`
            })
            this.property_fields = result

        }).catch(err => {
            this.showToast('Error',err,'Error')
        })


        fetchFieldsExceptSelectedProperties().then(res => {
            const result = JSON.parse(res)
            console.log('res fields: '+res)
            // result.push('Product_Description__c')
            this.fields = result.sort((a,b) => a.label - b.label).map(el => el.value);
            this.show_form = true;
        }).catch(err => {
            console.error(err)
        })


        getFieldsMap({
            selectedSObject: 'Master_Product__c'
        }).then(res => {
            this.all_fields_map = JSON.parse(res)
        }).catch(err => {
            console.error(err)
        })


        getAllPicklistFieldsWithOptions({
            strObjectName: 'Master_Product__c'
        }).then(res => {
            console.log('JSON.parse(res): ',JSON.parse(res))
            let result = JSON.parse(res)

            let data = {}
            for(let char in result){
                let options = []
                for(let option in result[char]){
                    options.push({
                        label: option,
                        value: result[char][option]
                    })
                }
                data[char] = options
            }


            this.all_picklist_map_values = data
        }).catch(err => {
            console.error(err)
        })
    }


    addTextRow(e){
        const field = e.target.dataset.field;
        const property_fields_copy = [...this.property_fields]

        console.log('TEST: '+JSON.stringify(property_fields_copy))
        let field_object = property_fields_copy.find(el => el.apiname == field)
        let last_index = field_object.inputs[field_object.inputs.length-1].index
        console.log('last_index: ',last_index)
        field_object.inputs.push({
            value: '',
            attribute: '',
            name_keyword: '',
            description_keyword: '',
            index: last_index+1
        })
        this.property_fields = [...property_fields_copy]
    }

    addCheckboxRow(e){
        const field = e.target.dataset.field;
        const property_fields_copy = [...this.property_fields]

        let field_object = property_fields_copy.find(el => el.apiname == field)
        let last_index = field_object.inputs[field_object.inputs.length-1].index

        field_object.inputs.push({
            value: false,
            attribute: '',
            name_keyword: '',
            description_keyword: '',
            index: last_index+1

        })
        if(field_object.inputs.length >= 2){
            field_object.two_checkboxes = true;
        }
        this.property_fields = [...property_fields_copy]
    }
    handlCheckboxValue(e){
        let isChecked = e.target.checked;
        let fieldapi = e.target.dataset.fieldapi;
        let index = e.target.dataset.index;

        const property_fields_copy = [...this.property_fields]

        let field_object = property_fields_copy.find(el => el.apiname == fieldapi)
        field_object.inputs.find(el => el.index == index).value = isChecked
        this.property_fields = [...property_fields_copy]

    }
    handleTextValue(e){
        //Uses as handler on text fields
        const fieldapi = e.target.dataset.fieldapi
        const index = e.target.dataset.index

        const property_fields_copy = [...this.property_fields]
        let field_object = property_fields_copy.find(el => el.apiname == fieldapi)
        field_object.inputs.find(el => el.index == index).value = e.target.value

        this.property_fields = [...property_fields_copy]
    }

    handleTextAttribute(e){
        //Uses as handler on text fields
        const fieldapi = e.target.dataset.fieldapi
        const index = e.target.dataset.index

        const property_fields_copy = [...this.property_fields]
        let field_object = property_fields_copy.find(el => el.apiname == fieldapi)
        field_object.inputs.find(el => el.index == index).attribute = e.target.value

        this.property_fields = [...property_fields_copy]
    }

    handleNameKeywordAttribute(e){
        //Uses as handler on text fields
        const fieldapi = e.target.dataset.fieldapi
        const index = e.target.dataset.index

        const property_fields_copy = [...this.property_fields]
        let field_object = property_fields_copy.find(el => el.apiname == fieldapi)
        field_object.inputs.find(el => el.index == index).name_keyword = e.target.value

        this.property_fields = [...property_fields_copy]
    }
    handleDescriptionKeywordAttribute(e){
        //Uses as handler on text fields
        const fieldapi = e.target.dataset.fieldapi
        const index = e.target.dataset.index

        const property_fields_copy = [...this.property_fields]
        let field_object = property_fields_copy.find(el => el.apiname == fieldapi)
        field_object.inputs.find(el => el.index == index).description_keyword = e.target.value

        this.property_fields = [...property_fields_copy]
    }

    picklistAttributeHandler(e){
        const targetField = e.target.dataset.field
        const targetValue = e.target.dataset.pickvalue
        this.property_fields.find(el => el.apiname == targetField).inputs.find(el => el.value == targetValue).attribute = e.target.value
        const arr = [...this.property_fields]
        this.property_fields = JSON.parse(JSON.stringify(this.property_fields))
    }
    picklistNameKeywordHandler(e){
        const targetField = e.target.dataset.field
        const targetValue = e.target.dataset.pickvalue
        this.property_fields.find(el => el.apiname == targetField).inputs.find(el => el.value == targetValue).name_keyword = e.target.value
        const arr = [...this.property_fields]
        this.property_fields = JSON.parse(JSON.stringify(this.property_fields))
    }
    picklistDescriptionKeywordHandler(e){
        const targetField = e.target.dataset.field
        const targetValue = e.target.dataset.pickvalue
        this.property_fields.find(el => el.apiname == targetField).inputs.find(el => el.value == targetValue).description_keyword = e.target.value
        const arr = [...this.property_fields]
        this.property_fields = JSON.parse(JSON.stringify(this.property_fields))
    }




    handlePicklistChange(e){
        const picklistField = e.target.dataset.field
        const property_fields_copy = [...this.property_fields]

        this.handlePicklistCheckRemoving(picklistField, e.detail.value)

        console.log('property_fields_copy: '+JSON.stringify(property_fields_copy))
        console.log('e.detail.value: '+JSON.stringify(e.detail.value))
        e.detail.value.forEach(el => {
            try{
                let element;
                if(property_fields_copy.find(el => el.apiname == picklistField).inputs){
                    element = property_fields_copy.find(item => item.apiname == picklistField).inputs.find(item => item.value == el)
                }

                if(!element){
                    if(property_fields_copy.find(el => el.apiname == picklistField).inputs == undefined) property_fields_copy.find(el => el.apiname == picklistField).inputs = []

                    property_fields_copy.find(el => el.apiname == picklistField).inputs.push({
                        value: el,
                        attribute: '',
                        name_keyword: '',
                        description_keyword: '',
                        placeholder: `Enter attribute for ${el}:`
                    })
                } 
            }catch(err){

            }
        })

        this.property_fields = [...property_fields_copy]
    }

    handlePicklistCheckRemoving(picklistField, selectedValues){
        const property_fields_copy = [...this.property_fields]
        const selectedPicklistValues = []
        const valuesNeedToRemove = []
        let propertyObject = property_fields_copy.find(el => el.apiname == picklistField)
        if(propertyObject.inputs){
            propertyObject.inputs.forEach(el => {
                selectedPicklistValues.push(el.value)
            })

            selectedPicklistValues.forEach(value => {
                if(!selectedValues.includes(value)){
                    valuesNeedToRemove.push(value)
                }
            })

            if(valuesNeedToRemove.length > 0){
                valuesNeedToRemove.forEach(element => {
                    let removingIndex = property_fields_copy.find(el => el.apiname == picklistField).inputs.findIndex(el => el.value == element)
                    property_fields_copy.find(el => el.apiname == picklistField).inputs.splice(removingIndex, 1);
                })

                this.property_fields = [...property_fields_copy]
            }

        }
    }

    showToast(title, messag, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: messag,
            variant: variant
        });
        this.dispatchEvent(event);
    }



    previewInsetedFields(){
        this.show_spinner = true;
        this.show_predefined_table = false;
        let available_properties = {};
        console.log('this.property_fields: ',JSON.stringify(this.property_fields))
        const properties_map = {};

        try{
            this.property_fields.forEach(el => {

                if(el.inputs){
                    let iteratorAttr = 1;
                    let iteratorName = 1;
                    let iteratorDesc = 1;
                    el.inputs.forEach(item => {
                        
                        if(!properties_map.attribute){
                            let attr_obj = {}
                            attr_obj[item.value] = item.attribute
        
                            properties_map.attribute = attr_obj;
                        }else{
                            if(!properties_map.attribute.hasOwnProperty(item.value)){
                                properties_map.attribute[item.value] = item.attribute
                            }else{
                                properties_map.attribute[item.value+'__#$$$#'+iteratorAttr] = item.attribute
                                iteratorAttr++
                            }
                        }
        
                        if(!properties_map.nameAttribute){
                            let attr_obj = {}
                            attr_obj[item.value] = item.name_keyword
        
                            properties_map.nameAttribute = attr_obj;
                        }else{
                            
                            if(!properties_map.nameAttribute.hasOwnProperty(item.value)){
                                properties_map.nameAttribute[item.value] = item.name_keyword
                            }else{
                                properties_map.nameAttribute[item.value+'__#$$$#'+iteratorName] = item.name_keyword
                                iteratorName++
                            }

                            
                        }
        
                        if(!properties_map.descriptionAttribute){
                            let attr_obj = {}
                            attr_obj[item.value] = item.description_keyword
        
                            properties_map.descriptionAttribute = attr_obj;
                        }else{
                            properties_map.descriptionAttribute[item.value] = item.description_keyword

                            if(!properties_map.nameAttribute.hasOwnProperty(item.value)){
                                properties_map.descriptionAttribute[item.value] = item.description_keyword
                            }else{
                                properties_map.descriptionAttribute[item.value+'__#$$$#'+iteratorDesc] = item.description_keyword
                                iteratorDesc++
                            }
                        }
                    })
                }
            })
        
        
            console.log('properties_map: '+JSON.stringify(properties_map))



            let property_attribute_obj = {}

            this.property_fields.forEach(el => {
                let all_selected_values = [];
                let all_selected_namekeywords = [];
                let all_selected_desckeywords = [];

                if(el.inputs){
                    let iterator = 1;
                    el.inputs.forEach(field => {
                        if(!all_selected_values.includes(field.value)){
                            all_selected_values.push(field.value)
                        }else{
                            all_selected_values.push(field.value+'__#$$$#'+iterator)
                            iterator++
                        }
                        property_attribute_obj[field.value] = field.attribute
                    });
                    available_properties[el.apiname.toLowerCase()] = all_selected_values;
                }
                
            })
            this.property_attribute_map = property_attribute_obj
            console.log('JSON>::::::::',JSON.stringify(available_properties))
            let combined = this.allCombinations(available_properties);

            console.log('property_attribute_obj: '+JSON.stringify(property_attribute_obj))
            console.log('MARINA: '+JSON.stringify(combined))
            
            if(combined.length > 0){
                combined.forEach(el => {
                    el.name = this.master_product_properties['name'] !== null && this.master_product_properties['name'] !== undefined ? this.master_product_properties['name'] + ' ' : ''
                    el['product_description__c'] = this.master_product_properties['product_description__c'] !== null && this.master_product_properties['product_description__c'] !== undefined ? this.master_product_properties['product_description__c'] + ' ' : ''
                    el['product_code__c'] = this.master_product_properties['product_code__c'] !== null && this.master_product_properties['product_code__c'] !== undefined ? this.master_product_properties['product_code__c'] : ''
                    el['stockkeepingunit__c'] = this.master_product_properties['stockkeepingunit__c'] !== null && this.master_product_properties['stockkeepingunit__c'] !== undefined ? this.master_product_properties['stockkeepingunit__c'] : ''
                    for(let char in el){
                        el.name += properties_map['nameAttribute'][el[char]] ? properties_map['nameAttribute'][el[char]] + ' ' : ''
                        el['product_code__c'] += properties_map['attribute'][el[char]] ? properties_map['attribute'][el[char]] : ''
                        el['stockkeepingunit__c'] += properties_map['attribute'][el[char]] ? properties_map['attribute'][el[char]] : ''
                        el['product_description__c'] += properties_map['descriptionAttribute'][el[char]] != undefined && properties_map['descriptionAttribute'][el[char]] != null ? '\n' + properties_map['descriptionAttribute'][el[char]] : ''
                    }
                    
                })
                
                console.log('combined 380: '+JSON.stringify(combined))
                

                let item = combined[0]
                let column_objects = [
                    {
                        label: 'Edit',
                        type: 'button-icon',
                        initialWidth: 75,
                        typeAttributes: {
                            iconName: 'action:preview',
                            title: 'Edit',
                            variant: 'border-filled',
                            alternativeText: 'Edit',
                            menuAlignment: 'left'
                            
                        }
                    }
                ]

                column_objects.push({
                    initialWidth: 85,
                    fieldName: '',
                    label: 'Status',
                    cellAttributes: { iconName: { fieldName: 'dynamicIcon' } },
                    wrapText: true
                })
                for(let char in item){
                    if(char !== 'product_description__c'){
                        column_objects.push({
                            label: this.all_fields_map[char],
                            fieldName: char,
                            sortable: "true"
                        })
                    }else{
                        column_objects.push({
                            label: this.all_fields_map[char],
                            fieldName: char,
                            sortable: "true",
                            wrapText: true
                        })
                    }
                    
                }
                column_objects.push({
                    label: 'Unit Cost',
                    fieldName: 'selling_cost',
                    sortable: "true"
                })
                // column_objects.push({
                //     label: 'UPC Code',
                //     fieldName: 'upc_code__c',
                //     sortable: "true"
                // })


                let counter_id = 1;
                combined.forEach(el => {
                    el.Id = counter_id
                    //el.dynamicIcon = 'action:approval'
                    counter_id++;
                    for(let char in el){
                        char = char.toLowerCase()
                    }
                })
                // task2       OK
                // first_non_empty BAD

                

                let updated_selected_rows = []
                combined.forEach(el => {
                    let obj = {}
                    for(let char in el){
                        let key = char.replace('__c','')
                        obj[key] = el[char]
                    }
                    updated_selected_rows.push(obj)
                })

                console.log('updated_selected_rows 516: '+JSON.stringify(updated_selected_rows))
                checkProductSKUAvailability({
                    predefined: JSON.stringify(updated_selected_rows)
                }).then(res => {
                    const result = JSON.parse(res)

                    console.log('result 522: ',result)
                    let copy_arr = [...combined]
                    if(result.length > 0){
                        
                        console.log('DATA 526: '+JSON.stringify(copy_arr))
                        copy_arr.forEach(el => {
                            if(result.includes(el.stockkeepingunit__c)){
                                el.dynamicIcon = 'action:close'
                            }else{
                                el.dynamicIcon = 'action:approval'
                            }
                        })
                    }else{
                        copy_arr.forEach(el => {
                            el.dynamicIcon = 'action:approval'
                        })
                    }

                    this.predefined_table_columns = column_objects;
                    let counter = 1

                    copy_arr.forEach(el => {
                        el.rowId = counter
                        el.selling_cost = 0;
                        // el.upc_code__c = this.master_product_properties['upc_code__c']
                        counter++

                    })
                    this.predefined_table_data = this.decrypCodedData(copy_arr);

                    console.log('copy_arr: 553: '+JSON.stringify(copy_arr))
                    this.preselected_rows = copy_arr.filter(el => el.dynamicIcon == 'action:approval').map(record => record.rowId)
                    this.show_predefined_table = true;
                    
                    console.log('this.predefined_table_data: '+JSON.stringify(this.predefined_table_data))
                }).catch(err => {
                    this.handleConfirm(err, 'error' , 'Error occurred')
                })
            }
        }catch(err){
            console.error(err)
        }
        
        this.show_spinner = false;
    }

    decrypCodedData(data){
        data.forEach(el => {
            for(let char in el){
                if(el[char].toString().includes('__#$$$#')){
                    let index = el[char].toString().indexOf('__#$$$')
                    el[char] = el[char].slice(0, index)
                }
            }
        })
        let parsed = [...data]
        return parsed;
    }
    allCombinations(obj) {
        let combos = [{}];
        Object.entries(obj).forEach(([key, values]) => {
            let all = [];
            values.forEach((value) => {
                combos.forEach((combo) => {
                    all.push({ ...combo, [key]: value });
                });
            });
            combos = all;
        });
        return combos;
    }

    handleRowAction(event){
        this.show_modal_spinner = true;
        const dataRow = event.detail.row;
        this.editable_row_id = dataRow.Id

        this.editable_row_object = dataRow;
        this.editable_row_fields = []
        console.log('dataRow::::=====> ',JSON.stringify(dataRow))
        try{
            console.log('this.property_fields: '+JSON.stringify(this.property_fields))

            console.log('ASKJDGKASHGKDAHJSDGAJHSDGKJHASGDKJH: this.all_picklist_map_values::::::::: ',JSON.stringify(this.all_picklist_map_values))
            combineFieldWithType({
                sobject_api: 'Master_Product__c'
            }).then(res => {
                const fields_map = JSON.parse(res)

                for(let row in dataRow){
                    if(row != 'id' && row !== 'Id' && row != 'selling_cost'){
                        let obj = {
                            isText: fields_map[row] == 'TEXT',
                            isPicklist: fields_map[row] == 'PICKLIST',
                            isCheckbox: fields_map[row] == 'CHECKBOX',
                            label: this.all_fields_map[row],
                            value: dataRow[row],
                            apiname: row,
                            picklist_values: this.all_picklist_map_values[row]
                        }
                        this.editable_row_fields.push(obj)
                    }else if(row == 'selling_cost'){
                        let obj = {
                            isText: true,
                            isPicklist: false,
                            isCheckbox: false,
                            label: 'Standart Price',
                            value: 0,
                            apiname: row,
                            picklist_values: null
                        }
                        this.editable_row_fields.push(obj)
                    }

                }
            })
            this.showModalEditLeadAction()
        }catch(err){
            console.error(err)
        }
        


    }

    handleEditChange(e){
        const field = e.target.dataset.field
        this.editable_row_object[field] = e.target.value
    }
    handleEditPicklistChange(e){
        const field = e.target.dataset.field
        this.editable_row_object[field] = e.detail.value
    }

    handleAdditionalColumnPicklistChange(e){
        this.selected_new_column = e.detail.value
    }
    
    saveModalEdit(){
        let editableId = this.editable_row_object.Id
        let copy_column_data = [...this.predefined_table_data]
        let index = copy_column_data.findIndex(el => el.Id == editableId)

        let removed = copy_column_data.splice(index,1,this.editable_row_object)
        this.predefined_table_data = copy_column_data

        this.closeModalEditLeadAction()
    }
    showModalEditLeadAction(){
        this.show_modal_lead_edit = true;
    }
    closeModalEditLeadAction(){
        this.show_modal_lead_edit = false;
    }

    previewExecute(){
        console.log(JSON.stringify(this.property_fields))

        this.previewInsetedFields()
    }

    handleRecordCreated(e){
        console.log(JSON.stringify(e.detail))
        try{
            const created_id = e.detail.id;
            this.master_product_created_id = e.detail.id;
            console.log(JSON.stringify(e.detail.fields))
            const fields = e.detail.fields

            // this.master_product_properties['upd_code'] = fields['UPC_Code__c'].value
            // this.master_product_properties['Name'] = fields['Name'].value
            // this.master_product_properties['upd_code'] = fields['Product_Description__c'].value
            this.master_product_properties['Id'] = created_id

            getMasterProduct({
                masterId: created_id
            }).then(res => {
                const record = JSON.parse(res)
                console.log('MASTER BACE: '+res)

                for(let field in record){
                    this.master_product_properties[field.toLowerCase()] = record[field]
                }

                this.property_fields.forEach(el => {
                    for(let char in record){
                        el[char.toLowerCase()] = record[char]
                    }
                })
            })
            
            

            console.log('this.master_product_properties: '+JSON.stringify(this.master_product_properties))
            this.show_properties = true;
        }catch(err){
            console.error(err)
        }
        
    }


    async insertSelectedRows(){
        try{
            
            let selected_rows = this.template.querySelector('lightning-datatable').getSelectedRows(); 
            let updated_selected_rows = []
            selected_rows.forEach(el => {
                let obj = {}
                for(let char in el){
                    let key = char.replace('__c','')
                    obj[key] = el[char]
                }
                updated_selected_rows.push(obj)
            })
            console.log('TO BAKCEND:',JSON.stringify(updated_selected_rows));
            console.log('record id:',this.master_product_created_id)
            console.log('updated_selected_rows.length: ',updated_selected_rows.length)

            let master_prod_id = this.master_product_created_id.slice(0,15)
            if(updated_selected_rows.length == 0){
                let check_alert = await this.handleConfirm('You did not check any product from table, are you sure that you want to create only Master Product without Products?', 'warning' , 'Warning')
                console.log('check_alert: ',check_alert)
                if(check_alert){
                    checkProductSKUAvailability({
                        predefined: JSON.stringify(updated_selected_rows)
                    }).then(res => {
                        const result = JSON.parse(res)
                        if(result.length > 0){
                            let copy_arr = [...this.predefined_table_data]
        
                            copy_arr.forEach(el => {
                                if(result.includes(el.stockkeepingunit__c)){
                                    el.dynamicIcon = 'action:close'
                                }else{
                                    el.dynamicIcon = 'action:approval'
                                }
                            })
        
                            this.predefined_table_data = copy_arr;
                        }else{
                            let copy_arr = [...this.predefined_table_data]
                            copy_arr.forEach(el => {
                                el.dynamicIcon = 'action:approval'
                            })
                            this.predefined_table_data = copy_arr;
                            this.show_spinner = true;
                            createProductsFromMasterProduct({
                                masterId: master_prod_id,
                                predefined: JSON.stringify(updated_selected_rows)
                            }).then(res => {
                                console.log(1)
                                this.show_spinner = false;
                                window.location.href='/'+master_prod_id
                            }).catch(err => {
                                this.show_spinner = false;
                                this.handleConfirm(err, 'error' , 'Error occurred')
                                console.error(err)
                            })
                        }
                    }).catch(err => {
                        console.error(err)
                        this.show_spinner = false;
                        this.handleConfirm(err, 'error' , 'Error occurred')
                    })
                }
            }else{
                checkProductSKUAvailability({
                    predefined: JSON.stringify(updated_selected_rows)
                }).then(res => {
                    const result = JSON.parse(res)
                    console.log('check result: ',result)
                    if(result.length > 0){
                        let copy_arr = [...this.predefined_table_data]
                        console.log('copyarr: ',JSON.stringify(copy_arr))
                        copy_arr.forEach(el => {
                            if(result.includes(el.stockkeepingunit__c)){
                                el.dynamicIcon = 'action:close'
                            }else{
                                el.dynamicIcon = 'action:approval'
                            }
                        })
    
                        this.predefined_table_data = copy_arr;
                    }else{
                        let copy_arr = [...this.predefined_table_data]
                        copy_arr.forEach(el => {
                            el.dynamicIcon = 'action:approval'
                        })
                        this.predefined_table_data = copy_arr;
                        this.show_spinner = true;
                        createProductsFromMasterProduct({
                            masterId: master_prod_id,
                            predefined: JSON.stringify(updated_selected_rows)
                        }).then(res => {
                            console.log(1)
                            this.show_spinner = false;
                            window.location.href='/'+master_prod_id
                        }).catch(err => {
                            this.show_spinner = false;
                            this.handleConfirm(err.body.message, 'error' , 'Error occurred')
                            console.error(err)
                        })
                    }
                }).catch(err => {
                    console.error(err)
                    this.show_spinner = false;
                    this.handleConfirm(err, 'error' , 'Error occurred')
                })
            }

           

        }catch(err){
            console.error(err)
        }
        

    }
    
}