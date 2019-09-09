public class Product2Extension {
    
    public List<ProductWrapper> productsToInsert {get;set;}
    
    public List<SelectOption> getFamilyOptions(){
        List<SelectOption> entries = new List<SelectOption>();
        entries.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for(Schema.PicklistEntry ple : Constants.PRODUCT_FAMILY){
            entries.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return entries;
    }
    
    /*public Product2Extension(){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }*/
    
    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }
    
    public void AddRows(){
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++){
            productsToInsert.add(new ProductWrapper());
        }
    }
    
    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }
    
    public PageReference Save(){
        SavePoint sp = Database.setSavepoint();
        try {
            List<Product2> newProducts = new List<Product2>();
            List<PriceBookEntry> newPBE = new List<PriceBookEntry>();
            
            for(ProductWrapper pw : productsToInsert){
                if(pw.productRecord != null && pw.pricebookEntryRecord != null){
                    if(pw.productRecord.Name != null && pw.productRecord.Family != Constants.SELECT_ONE && pw.productRecord.Family != null && pw.pricebookEntryRecord.UnitPrice != null && pw.productRecord.Initial_Inventory__c != null){
                        newProducts.add(pw.productRecord);
                        PriceBookEntry pbe = pw.pricebookEntryRecord;
                        pbe.IsActive = true;
                        pbe.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                        newPBE.add(pbe);
                    }
                }
            }
            
            insert newProducts;
            
            for(Integer i = 0; newProducts.size() > i; i++){
                newPBE[i].Product2Id = newProducts[i].Id;
            }
            
            insert newPBE;
            
            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,newProducts.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            System.debug('Exception occured:'+e.getMessage());
            Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
        return null;
    }
    
    public class ProductWrapper{
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}
        
        public ProductWrapper(){
            productRecord = new Product2(Initial_Inventory__c = 0);
            pricebookEntryRecord = new PriceBookEntry(UnitPrice = 0.0);
        }
    }
}