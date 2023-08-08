const actions = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const COMMISSIONS_LINES = [
    
    {
        label: 'Commission Name', fieldName: 'recordURL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            sortable: true
        }
    },

    { label: 'Commission Holder', fieldName: 'Holder_Name_System__c', type: 'text' },
    
    { label: 'Role', fieldName: 'Role__c', type: 'text' },

    {
        label: 'Invoice/Memo', fieldName: 'invoiceMemoLink', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'invoiceMemoLabel'
            },
            sortable: true
        }
    },
    { label: 'Billing Payment', fieldName: 'Billing_Payment__c', type: 'currency' },
    
    { label: 'Billing Paid Date', fieldName: 'Billing_Paid_Date__c', type: 'date', 
        typeAttributes: {
            day: 'numeric',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        },
    },
    { label: 'Commission Amount', fieldName: 'Commission_Amount__c', type: 'currency' },
    { label: 'Discount', fieldName: 'Total_Discount__c', type: 'currency' },
    { label: 'Commission Paid', fieldName: 'Commission_Paid__c', type: 'currency' },
    { label: 'Balance', fieldName: 'Commission_Balance__c', type: 'currency' },

    {   label: '',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: actions },
    }
];

const PAYABLES = [
    
    {
        label: 'Payable Name', fieldName: 'recordURL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            sortable: true
        }
    },
    {
        label: 'Commission Name', fieldName: 'Sales_Order_Commissions__c', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'commissionName'
            },
            sortable: true
        }
    },
    { label: 'Commission Holder', fieldName: 'commissionHolder', type: 'text' },
    
    { label: 'Role', fieldName: 'Role__c', type: 'text' },

    { label: 'Due Date', fieldName: 'AcctSeed__Due_Date__c', type: 'date', 
        typeAttributes: {
            day: 'numeric',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        },
    },
    { label: 'Posting Status', fieldName: 'AcctSeed__Status__c', type: 'text' },
    { label: 'Payment Status', fieldName: 'AcctSeed__Payment_Status__c', type: 'text' },
    { label: 'Paid Date', fieldName: 'Paid_Date__c', type: 'date', 
        typeAttributes: {
            day: 'numeric',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        },
    },
    { label: 'Total', fieldName: 'AcctSeed__Total__c', type: 'currency' },
    { label: 'Balance', fieldName: 'AcctSeed__Balance__c', type: 'currency' },

    {   label: '',
        type: 'action',
        initialWidth:'50px',
        typeAttributes: { rowActions: actions },
    }
];
export const config = {
    Sales_Order_Commissions__c: COMMISSIONS_LINES,
    AcctSeed__Account_Payable__c: PAYABLES
}