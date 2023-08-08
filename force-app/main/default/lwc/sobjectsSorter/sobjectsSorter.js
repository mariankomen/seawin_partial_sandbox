import { LightningElement, api, track } from 'lwc';
import getLinesForSorting from '@salesforce/apex/SObjectSortController.getLinesForSorting'
import handleSaveSorting from '@salesforce/apex/SObjectSortController.handleSaveSorting'

export default class SobjectsSorter extends LightningElement {
    _sobjectName = '';
    _parentSObjectName = '';
    _parentRecordId = '';
    _parentSObjectFieldApi = '';
    _datatableFields = 'Name';
    _sortOrderFieldApi = '';

    @track users = {}
    @api userMap = {}
    @api dragMap;

    @track isModalOpen = false;

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }

    @api initial(sobjectName, parentSObjectName, parentRecordId, parentSObjectFieldApi, datatableFields, sortOrderFieldApi){
        this._sobjectName = sobjectName;
        this._parentSObjectName = parentSObjectName;
        this._parentRecordId = parentRecordId;
        this._parentSObjectFieldApi = parentSObjectFieldApi;
        this._datatableFields = datatableFields;
        this._sortOrderFieldApi = sortOrderFieldApi;

        this.getDatatableRecords();
        this.openModal();
    }

    getDatatableRecords(){
        const _payload = {
            sobjectName: this._sobjectName,
            parentSObjectName: this._parentSObjectName,
            parentSObjectFieldApi: this._parentSObjectFieldApi,
            parentRecordId: this._parentRecordId,
            datatableFields: this._datatableFields,
            sortOrderFieldApi: this._sortOrderFieldApi
        }

        console.log(JSON.stringify(_payload))
        getLinesForSorting({
            payload: JSON.stringify(_payload)
        }).then(res => {
            console.log(res)
            this.users.data = JSON.parse(res)

            if (!!this.users && !!this.users.data) {
                let tempArray = JSON.parse(JSON.stringify(this.users.data));
                tempArray.forEach((arrayElement, index) => {
                    arrayElement.index = index;
                    this.userMap[arrayElement.lineId] = arrayElement;
                });

                this.users.data = JSON.parse(JSON.stringify(tempArray));

            }
        })

        
    }

    handleSubmit() {
        console.log("in submit method");
        let sortedData = this.users.data.map(el => {
            return {
                lineId: el.lineId,
                sortOrder: el.index
            }
        });

        const _payload = {
            sobjectName: this._sobjectName,
            parentSObjectName: this._parentSObjectName,
            parentSObjectFieldApi: this._parentSObjectFieldApi,
            parentRecordId: this._parentRecordId,
            datatableFields: this._datatableFields,
            sortOrderFieldApi: this._sortOrderFieldApi
        }

        console.log('1: ',JSON.stringify(sortedData))
        console.log('1: ',JSON.stringify(_payload))
        handleSaveSorting({
            linesJson: JSON.stringify(sortedData),
            payload: JSON.stringify(_payload)
        }).then(res => {
            const closeQA = new CustomEvent('sortend');
            this.dispatchEvent(closeQA);

            this.closeModal()
        }).catch(err => {
            console.error(err)
        })
      }
    
      processRowNumbers() {
        const trs = this.template.querySelectorAll(".myIndex");
        const ids = this.template.querySelectorAll(".myId");
        for (let i = 0; i < trs.length; i++) {
          let currentRowId = ids[i].innerText;
          let currentRowRef = this.userMap[currentRowId];
          currentRowRef.index = i;
          this.userMap[currentRowId] = currentRowRef;
          trs[i].innerText = i;
        }
        this.users.data = Object.values(this.userMap);
      }
    
      onDragStart(evt) {
        const inputs = this.template.querySelectorAll(".mychkbox");
        this.dragMap = new Map();
    
        if (inputs) {
          for (let i = 0; i < inputs.length; i++) {
            if (inputs[i].checked) {
              let currentRow = inputs[i].parentNode.parentNode;
              let currentDragId = currentRow.dataset.dragId;
              this.dragMap.set(currentDragId, currentRow);
              //currentRow.classList.add("grabbed");
            }
          }
        }
    
        let eventRowDataId = evt.currentTarget.dataset.dragId;
        evt.dataTransfer.setData("dragId", eventRowDataId);
        evt.dataTransfer.setData("sy", evt.pageY);
        evt.dataTransfer.effectAllowed = "move";
        evt.currentTarget.classList.add("grabbed");
    
        if (this.dragMap.has(eventRowDataId)) {
          this.dragMap.forEach((value) => value.classList.add("grabbed"));
        }
      }
    
      onDragOver(evt) {
        evt.preventDefault();
        evt.dataTransfer.dropEffect = "move";
      }
      handleDragEnter(e){
        const trs = this.template.querySelectorAll(".myIndex");
        const ids = this.template.querySelectorAll(".myId");
        for (let i = 0; i < trs.length; i++) {
          let currentRowId = ids[i].innerText;
          let currentRowRef = this.userMap[currentRowId];
          currentRowRef.index = i;
          this.userMap[currentRowId] = currentRowRef;
          trs[i].innerText = i;
        }
        this.users.data = Object.values(this.userMap);
      }
      onDrop(evt) {
        evt.preventDefault();
        let sourceId = evt.dataTransfer.getData("dragId");
    
        const sy = evt.dataTransfer.getData("sy");
        const cy = evt.pageY;
    
        if (sy > cy) {
          if (this.dragMap.has(sourceId)) {
    
            Array.from(this.dragMap).reverse().forEach( element => {
              let key = element[0];
              const elm = this.template.querySelector(`[data-drag-id="${key}"]`);
              if (!!elm) {
                elm.classList.remove("grabbed");
              }
              evt.currentTarget.parentElement.insertBefore(elm, evt.currentTarget);
            });
          } else {
            const elm = this.template.querySelector(`[data-drag-id="${sourceId}"]`);
            if (!!elm) {
              elm.classList.remove("grabbed");
            }
            evt.currentTarget.parentElement.insertBefore(elm, evt.currentTarget);
          }
        } else {
          if (this.dragMap.has(sourceId)) {
            this.dragMap.forEach((value, key, map) => {
              const elm = this.template.querySelector(`[data-drag-id="${key}"]`);
              if (!!elm) {
                elm.classList.remove("grabbed");
              }
              evt.currentTarget.parentElement.insertBefore(
                elm,
                evt.currentTarget.nextElementSibling
              );
            });
          } else {
            const elm = this.template.querySelector(`[data-drag-id="${sourceId}"]`);
            if (!!elm) {
              elm.classList.remove("grabbed");
            }
            evt.currentTarget.parentElement.insertBefore(
              elm,
              evt.currentTarget.nextElementSibling
            );
          }
        }
        this.processRowNumbers();
      }
}