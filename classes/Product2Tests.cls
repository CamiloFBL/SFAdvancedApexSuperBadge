@isTest (seeAllData=false)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    private static TestMethod void Product2Extension_UnitTest(){
        PageReference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        
        Product2 tp = new Product2(Name = 'Test', IsActive = true);
        ApexPages.StandardController sc = new ApexPages.StandardController(tp);
        Product2Extension ext = new Product2Extension(sc);
        
        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
        
        ext.AddRows();
        System.assertEquals(Constants.DEFAULT_ROWS * 2, ext.productsToInsert.size());
        
        List<String> pFamilyList = new List<String>();
        for(Schema.PicklistEntry ple : Constants.PRODUCT_FAMILY){
            pFamilyList.add(ple.getLabel());
        }
        Integer pFamilyIndex = 0;
        
        for(Integer i = 0; i < 5; i++){
            Product2Extension.ProductWrapper pw = ext.productsToInsert[i];
            
            String pFamily;
            if(pFamilyList.size() > pFamilyIndex){
                pFamily = pFamilyList[pFamilyIndex];
                pFamilyIndex++;
            }
            else{
                pFamilyIndex = 0;
                pFamily = pFamilyList[pFamilyIndex];
            }
            
            Product2 p = new Product2(Name = 'Test' + i,
                                      isActive = true,
                                      Initial_Inventory__c = 10,
                                      Family = pFamily);
            pw.productRecord = p;
            
            PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id,
                                                    UnitPrice = 1,
                                                    IsActive = true,
                                                    Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID);
            pw.pricebookEntryRecord = pbe;
        }
        
        Test.startTest();
        ext.Save();
        Test.stopTest();
        
        List<Product2> newProducts = [SELECT Id FROM Product2];
        System.assertEquals(5, newProducts.size());
    }
    
    private static TestMethod void Product2Trigger_UnitTest(){
        Test.startTest();
        Product2 tp = new Product2(Name = 'TEST',
                                   IsActive = true,
                                   Family = Constants.PRODUCT_FAMILY[0].getValue(),
                                   Initial_Inventory__c = 10);
        insert tp;
        
        CollaborationGroup cg = new CollaborationGroup(Name = 'Test' + Constants.INVENTORY_ANNOUNCEMENTS,
                                                       CollaborationType = 'Public',
                                                       CanHaveGuests = false,
                                                       IsArchived = false,
                                                       IsAutoArchiveDisabled = true);
        insert cg;
        
        tp.Quantity_Ordered__c = 10;
        update tp;
        Test.stopTest();
    }
}