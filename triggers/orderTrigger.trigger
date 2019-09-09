trigger orderTrigger on Order (after update){
    try{
        if(Trigger.New != null){
            if(Trigger.new != null){
                OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
            }
        }
    }
    catch(Exception e){
        
    }
}