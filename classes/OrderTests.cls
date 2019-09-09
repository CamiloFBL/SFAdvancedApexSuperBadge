@isTest (seeAllData=false)
private class OrderTests {
    @testSetup
    private static void SetupTestData(){
        TestDataFactory.InsertTestData(20);
    }
    
    @isTest
    private static void OrderUpdate_UnitTest(){
        Test.startTest();
        List<Product2> originalProduct = [SELECT Id, Quantity_Ordered__c FROM Product2];
        List<Order> ords = new List<Order>();
        
        for(Order o : [SELECT Id, AccountId, EffectiveDate, Status, Pricebook2Id FROM Order WHERE Status = :Constants.DRAFT_ORDER_STATUS]){
            o.Status = Constants.ACTIVATED_ORDER_STATUS;
            ords.add(o);
        }
        update ords;
        
        List<Product2> updatedProduct = [SELECT Id, Quantity_Ordered__c FROM Product2];
        for(Product2 op : originalProduct){
            for(Product2 up : updatedProduct){
                if(op.Id == up.Id){
                    TestDataFactory.VerifyQuantityOrdered(op, up, Constants.DEFAULT_ROWS);
                }
            }
        }
        Test.stopTest();
    }
    
    @isTest
    private static void OrderExtension_UnitTest(){
        PageReference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        
        Order tOrd = [SELECT Id FROM Order LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(tOrd);
        OrderExtension ext = new OrderExtension(sc);
        
        ext.selectedFamily = Constants.PRODUCT_FAMILY[0].getValue();
        ext.SelectFamily();
        ext.OnFieldChange();
        ext.Save();
        ext.First();
        ext.Next();
        ext.Previous();
        Boolean getPrev = ext.GetHasPrevious();
        Boolean getNext = ext.GetHasNext();
        Integer pages = ext.GetTotalPages();
        Integer currentPage = ext.GetPageNumber();
        List<SelectOption> familyOptions = ext.GetFamilyOptions();
        ChartHelper.GetInventory();
    }
}