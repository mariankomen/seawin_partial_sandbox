global class  ListOfRecordsIterator implements Iterator<list<sObject>>
{ 
   list<sObject> InnerList{get; set;}
   list<sObject> ListRequested{get; set;}

   Integer i {get; set;} 
   public Integer setPageSize {get; set;} 

   public ListOfRecordsIterator(List<sObject> lstAccWr)
   {
       InnerList = new list<sObject>(); 
       ListRequested = new list<sObject>();     
       InnerList = lstAccWr;
       setPageSize = 100;
       i = 0; 
   }   

   global boolean hasNext(){ 
       if(i >= InnerList.size()) {
           return false; 
       } else {
           return true; 
       }
   } 
   
   global boolean hasPrevious(){ 
       if(i <= setPageSize) {
           return false; 
       } else {
           return true; 
       }
   }  

   global list<sObject > next(){       
       ListRequested = new list<sObject >(); 
       integer startNumber;
       integer size = InnerList.size();
       if(hasNext())
       {  
           if(size <= (i + setPageSize))
           {
               startNumber = i;
               i = size;
           }
           else
           {
               i = (i + setPageSize);
               startNumber = (i - setPageSize);
           }
           
           for(integer start = startNumber; start < i; start++)
           {
               ListRequested.add(InnerList[start]);
           }
       } 
       return ListRequested;
   } 
   
   global list<sObject > previous(){      
       ListRequested = new list<sObject >(); 
       integer size = InnerList.size(); 
       if(i == size)
       {
           if(math.mod(size, setPageSize) > 0)
           {    
               i = size - math.mod(size, setPageSize);
           }
           else
           {
               i = (size - setPageSize);
           } 
       }
       else
       {
           i = (i - setPageSize);
       }
       
       for(integer start = (i - setPageSize); start < i; ++start)
       {
           ListRequested.add(InnerList[start]);
       } 
       return ListRequested;
   }   
}