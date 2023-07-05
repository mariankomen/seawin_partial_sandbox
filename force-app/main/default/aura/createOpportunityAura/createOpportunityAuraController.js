({
    doInit: function(component, event, helper) {
         
        //get record type Id
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        component.set("v.selectedRecordId", recordTypeId);
         
        //get action name edit/new
        var actionName = component.get("v.pageReference").attributes.actionName;
        console.log('actionName-' + actionName);
         
        //get object API name
        var objectApiName = component.get("v.pageReference").attributes.objectApiName;
        console.log('objectApiName-' + objectApiName);
    },
})
