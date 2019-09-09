/**
* @name OrderExtension
* @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {
    
    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}
    
    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;
    
    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        
        resetSsc();
        total = 0;
        
        for (OrderItem oi : orderRecord.OrderItems) {
            orderItemMap.put(oi.Product2Id, oi);
            if (oi.Quantity > 0) {
                if (null == pieData) {
                    pieData = new List<ChartHelper.ChartData>();
                }
                pieData.add(new chartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice));
                total = total + oi.UnitPrice * oi.Quantity;
            }
        }
        populateOrderItemList();
    }
    
    public void resetSsc() {
        String query;
        
        if (selectedFamily != null && selectedFamily != Constants.SELECT_ONE) {
            query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c '
                  + 'FROM PricebookEntry WHERE IsActive = TRUE AND Product2.Family = \'' + selectedFamily + '\' ORDER BY Name';
        }
        else{
            query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c '
                  + 'FROM PricebookEntry WHERE IsActive = TRUE ORDER BY Name';
        }
        
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }
    
    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    public void populateOrderItemList(){
        orderItemList = new List<OrderItem>();
        for(SObject obj : standardSetController.getRecords()){
            PricebookEntry pbe = (PricebookEntry)obj;
            
            if(orderItemMap.containsKey(pbe.Product2Id)){
                orderItemList.add(orderItemMap.get(pbe.Product2Id));
            }
            else{
                OrderItem oi = new OrderItem(PricebookEntryId = pbe.Id,
                                                Product2Id = pbe.Product2Id,
                                                UnitPrice = pbe.UnitPrice,
                                                Quantity = 0,
                                                Product2 = pbe.Product2);
                orderItemList.add(oi);
                orderItemMap.put(pbe.Product2Id, oi);
                
            }
        }
    }
    
    /**
    * @name OnFieldChange
    * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        for(OrderItem oi : orderItemList){
            orderItemMap.put(oi.Id, oi);
        }
        
        pieData = new List<chartHelper.chartData>();
        total = 0;
        for(OrderItem oi : orderItemList){
            if(oi.Quantity > 0){
                pieData.add(new ChartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice));
                total = total + oi.Quantity * oi.UnitPrice;
            }
        }
    }
    
    /**
    * @name SelectFamily
    * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        resetSsc();
        populateOrderItemList();
    }
    
    /**
    * @name Save
    * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        Savepoint sp = Database.setSavepoint();
        try{
            if(orderRecord.Pricebook2Id == null){
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord;
            
            List<OrderItem> ordersItemsToUpsert = new List<OrderItem>();
            List<OrderItem> ordersItemsToDelete = new List<OrderItem>();
            for(OrderItem oi : orderItemList){
                if(oi.Quantity > 0){
                    if(oi.OrderId == null){
                        oi.OrderId = orderRecord.Id;
                    }
                    ordersItemsToUpsert.add(oi);
                }
                else{
                    if(oi.Id != null){
                        ordersItemsToDelete.add(oi);
                    }
                }
            }
            
            if(ordersItemsToUpsert.size() > 0){
                Upsert ordersItemsToUpsert;
            }
            if(ordersItemsToDelete.size() > 0){
                delete ordersItemsToDelete; 
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
    }
        
    /**
    * @name First
    * @description
    **/
    public void First(){
        standardSetController.first();
        populateOrderItemList();
    }
    
    
    /**
    * @name Next
    * @description
    **/
    public void Next(){
        standardSetController.next();
        populateOrderItemList();
    }
    
    /**
    * @name Previous
    * @description
    **/
    public void Previous(){
        standardSetController.previous();
        populateOrderItemList();
    }
    
    /**
    * @name Last
    * @description
    **/
    public void Last(){
        standardSetController.last();
        populateOrderItemList();
    }
    
    /**
    * @name GetHasPrevious
    * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }
    
    /**
    * @name GetHasNext
    * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }
    
    /**
    * @name GetTotalPages
    * @description
    **/
    public Integer GetTotalPages(){
        Integer pageNumber = standardSetController.getResultSize() / (Integer)Constants.DEFAULT_ROWS;
        if(Math.mod(standardSetController.getResultSize(), (Integer)Constants.DEFAULT_ROWS) > 0){
            pageNumber++;
        }
        return pageNumber;
    }
    
    /**
    * @name GetPageNumber
    * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }
    
    /**
    * @name GetFamilyOptions
    * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> entries = new List<SelectOption>();
        entries.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for(Schema.PicklistEntry ple : Constants.PRODUCT_FAMILY){
            entries.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return entries;
    }
    
    /**
    * @name QueryOrderRecord
    * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
            (
                SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                FROM OrderItems
            )
            FROM Order
            WHERE Id = :orderId
        ];
    }
}