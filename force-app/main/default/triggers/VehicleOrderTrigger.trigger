trigger VehicleOrderTrigger on Vehicle_Order__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        VehicleOrderTriggerHandler.handleBeforeInsert(Trigger.new);
    }
}