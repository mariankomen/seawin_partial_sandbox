const actions = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const OPPORTUNITY_LINE_ITEMS = [
    {   label: 'Action',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: actions },
    },
    {
        label: 'Product Name', fieldName: 'product_url', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'product_name'
            },
            sortable: true
        }
    },

    { label: 'Product Image', fieldName: 'imageUrl', type: 'image' },
    
    {
        label: 'Product Code', fieldName: 'product_code_url', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'product_code'
            },
            sortable: true
        }
    },
    { label: 'Item Description', fieldName: 'Item_Description__c', type: 'text' , wrapText: true, initialWidth: 400},
    { label: 'Size', fieldName: 'Size__c', type: 'text' , wrapText: true},
    {
        label: 'Available Quantity', fieldName: 'inventoryUrl', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'availableQuantity'
            },
            sortable: true
        }
    },
    { label: 'Quantity', fieldName: 'Quantity', type: 'number'},
    { label: 'Sales Price', fieldName: 'UnitPrice', type: 'currency'},
    { label: 'Total Price', fieldName: 'TotalPrice', type: 'currency'},
];

const OPTIONAL_OPPORTUNITY_LINE_ITEMS = [
    {   label: 'Action',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: actions },
    },
    {
        label: 'Product Name', fieldName: 'product_url', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'product_name'
            },
            sortable: true
        }
    },

    { label: 'Product Image', fieldName: 'imageUrl', type: 'image' },
    
    {
        label: 'Product Code', fieldName: 'product_code_url', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'product_code'
            },
            sortable: true
        }
    },
    { label: 'Item Description', fieldName: 'Item_Description__c', type: 'text' , wrapText: true, initialWidth: 400},
    { label: 'Size', fieldName: 'Size__c', type: 'text' , wrapText: true},
    {
        label: 'Available Quantity', fieldName: 'inventoryUrl', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'availableQuantity'
            },
            sortable: true
        }
    },
    { label: 'Quantity', fieldName: 'Quantity__c', type: 'number'},
    { label: 'Sales Price', fieldName: 'UnitPrice__c', type: 'currency'},
    { label: 'Total Price', fieldName: 'TotalPrice__c', type: 'currency'},

]

const ATTACHMENTS_ACTIONS = [
    { label: 'Edit', name: 'editAttachment' },
    { label: 'View', name: 'view' },
    { label: 'Delete', name: 'delete' },
]
const DEFAULT_ATTACHMENTS_COLUMNS = [
    {   label: 'Action',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: ATTACHMENTS_ACTIONS },
    },
    { label: 'Name', fieldName: 'Name', type: 'text'},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date'},
    { label: 'Last Modified', fieldName: 'LastModifiedDate', type: 'date'},
    { label: 'Created By', fieldName: 'CreatedById', type: 'text'},
]
const DEFAULT_EXECUTED_ATTACHMENTS_COLUMNS = [
    {   label: 'Action',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: ATTACHMENTS_ACTIONS },
    },
    { label: 'Name', fieldName: 'Name', type: 'text'},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date'},
    { label: 'Last Modified', fieldName: 'LastModifiedDate', type: 'date'},
    { label: 'Created By', fieldName: 'CreatedById', type: 'text'},
]
export const config = {
    OpportunityLineItem: OPPORTUNITY_LINE_ITEMS,
    Optional_Products_Opportunity__c: OPTIONAL_OPPORTUNITY_LINE_ITEMS,
    defaultAttachments: DEFAULT_ATTACHMENTS_COLUMNS,
    executedDocuments: DEFAULT_EXECUTED_ATTACHMENTS_COLUMNS,
}