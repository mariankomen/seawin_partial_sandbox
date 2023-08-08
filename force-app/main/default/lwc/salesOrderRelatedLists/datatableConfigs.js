const actions = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const SALES_ORDER_LINES = [
    {   label: 'Action',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: actions },
    },
    {
        label: 'Product Name', fieldName: 'product_url', type: 'url',wrapText: true,initialWidth: 150,
        typeAttributes: {
            label: {
                fieldName: 'product_name'
            },
            sortable: true
        }
    },

    { label: 'Product Image', fieldName: 'imageUrl', type: 'image' },
    
    { label: 'Item Description', fieldName: 'Item_Description__c', type: 'text' , wrapText: true, initialWidth: 350},
    { label: 'Size', fieldName: 'Size__c', type: 'text' , wrapText: true},

    { label: 'Quantity', fieldName: 'AcctSeedERP__Quantity_Ordered__c', type: 'number'},
    { label: 'Quantity Allocated', fieldName: 'AcctSeedERP__Quantity_Allocated__c', type: 'number'},

    {
        label: 'Available Quantity', fieldName: 'inventoryUrl', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'availableQuantity'
            },
            sortable: true
        }
    },
    { label: 'Quantity Shipped', fieldName: 'AcctSeedERP__Quantity_Shipped__c', type: 'number'},

    { label: 'Sales Price', fieldName: 'Sales_Price__c', type: 'currency'},
    { label: 'Total Price', fieldName: 'AcctSeedERP__Total__c', type: 'currency'},
];

export const config = {
    AcctSeedERP__Sales_Order_Line__c: SALES_ORDER_LINES
}