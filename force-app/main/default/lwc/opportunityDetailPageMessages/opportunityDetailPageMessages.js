import { LightningElement, api, track } from 'lwc';
import getOpportunityDetailPageMessages from '@salesforce/apex/OpportunityDetailPageController.getOpportunityDetailPageMessages'
import getSobjectType from '@salesforce/apex/OpportunityDetailPageController.getSobjectType'

export default class OpportunityDetailPageMessages extends LightningElement {
    @api recordId;

    @track isOpportunityOpened = false;
    @track messages = [];

    connectedCallback(){
        if(!this.recordId){
            this.isOpportunityOpened = false;
        }else{
            getSobjectType({
                recordId: this.recordId
            }).then(type => {
                if(type == 'Opportunity'){
                    this.getMessages();

                    this.isOpportunityOpened = true;
                }else{
                    this.isOpportunityOpened = false;
                }
            })
        }


        
    }

    getMessages(){
        getOpportunityDetailPageMessages({
            opportunityId: this.recordId
        }).then(res => {
            let messagesOptional = JSON.parse(res);
            let idCounter = 1;
            messagesOptional.forEach(el => {
                el.Id = idCounter;
                idCounter += 1;
                el.iconProperties = this.findMessageIcon(el);
                console.log(this.findMessageIcon(el))
            })
            console.log(messagesOptional)
            this.messages = messagesOptional;
        })
    }

    findMessageIcon(message){
        let iconProperties = {
            name: 'utility:ad_set', //Default
            size: 'medium',
            variant: 'warning'
        };

        if(message.messageType == 'SUCCESS'){
            iconProperties['name'] = 'utility:success';
            iconProperties['variant'] = 'success';
        }else if(message.messageType == 'INFO'){
            iconProperties['name'] = 'utility:info_alt';
            iconProperties['variant'] = 'warning';
        }else if(message.messageType == 'WARNING'){
            iconProperties['name'] = 'utility:warning';
            iconProperties['variant'] = 'warning';
        }

        return iconProperties;
    }
}