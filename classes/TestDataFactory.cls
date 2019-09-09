/**
* @name TestDataFactory
* @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {
    /**
    * @name ConstructCollaborationGroup
    * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup cg = new CollaborationGroup(Name = 'Test' + Constants.INVENTORY_ANNOUNCEMENTS,
                                                       CollaborationType = 'Public',
                                                       CanHaveGuests = false,
                                                       IsArchived = false,
                                                       IsAutoArchiveDisabled = true);
        return cg;
    }
    
    /**
    * @name CreateProducts
    * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Product2> productList = new List<Product2>();
        List<String> pFamilyList = new List<String>();
        for(Schema.PicklistEntry ple : Constants.PRODUCT_FAMILY){
            pFamilyList.add(ple.getLabel());
        }
        Integer pFamilyIndex = 0;
        
        for(Integer i = 0; cnt > i; i++){
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
            productList.add(p);
        }
        
        return productList;
    }
    
    /**
    * @name CreatePricebookEntries
    * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PricebookEntry> pb = new List<PricebookEntry>();
        for(Product2 p : prods){
            PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id,
                                                    UnitPrice = 1,
                                                    IsActive = true,
                                                    Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID);
            pb.add(pbe);
        }
        return pb;
    }
    
    /**
    * @name CreateAccounts
    * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accountList = new List<Account>();
        
        for(Integer i = 0; cnt > i; i++){
            Account a = new Account(Name = 'Test' + i);
            accountList.add(a);
        }
        
        return accountList;
    }
    
    /**
    * @name CreateContacts
    * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> contactList = new List<Contact>();
        
        for(Integer i = 0; cnt > i; i++){
            Contact c = new Contact(AccountId = accts[i].Id,
                                    FirstName = 'Test' + i,
                                    LastName = 'Test' + i);
            contactList.add(c);
        }
        
        return contactList;
    }
    
    /**
    * @name CreateOrders
    * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> orderList = new List<Order>();
        for(Integer i = 0; cnt > i; i++){
            Order o = new Order(AccountId = accts[i].Id,
                                EffectiveDate = System.today().addDays(10 + i),
                                Status = Constants.DRAFT_ORDER_STATUS,
                                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID);
            orderList.add(o);
        }
        return orderList;
    }
    
    /**
    * @name CreateOrderItems
    * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> orderItemList = new List<OrderItem>();
        for(Integer i = 0; cnt > i; i++){
            OrderItem oi = new OrderItem(OrderId = ords[i].Id,
                                         Quantity = Constants.DEFAULT_ROWS,
                                         PricebookEntryId = pbes[i].Id,
                                         UnitPrice = 10 + i);
            orderItemList.add(oi);
        }
        return orderItemList;
    }
    
    /**
    * @name SetupTestData
    * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        insert ConstructCollaborationGroup();
        
        List<Account> accts = ConstructAccounts(cnt);
        insert accts;
        
        List<Contact> conts = ConstructContacts(cnt, accts);
        insert conts;
        
        List<Product2> prods = ConstructProducts(cnt);
        insert prods;
        
        List<PricebookEntry> pbes = ConstructPricebookEntries(prods);
        insert pbes;
        
        List<Order> ords = ConstructOrders(cnt, accts);
        insert ords;
        
        List<OrderItem> ordIts = ConstructOrderItems(cnt, pbes, ords);
        insert ordIts;
    }
    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        System.assertEquals(originalProduct.Quantity_Ordered__c + qtyOrdered, updatedProduct.Quantity_Ordered__c);
    }
}