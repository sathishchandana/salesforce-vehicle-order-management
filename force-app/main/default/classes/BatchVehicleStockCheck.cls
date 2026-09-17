public with sharing class BatchVehicleStockCheck implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query pending orders
        return Database.getQueryLocator([
            SELECT Id, Status__c, Vehicle__c 
            FROM Vehicle_Order__c 
            WHERE Status__c = 'Pending' AND Vehicle__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Vehicle_Order__c> scope) {
        Set<Id> vehicleIds = new Set<Id>();
        for (Vehicle_Order__c orderRec : scope) {
            vehicleIds.add(orderRec.Vehicle__c);
        }

        Map<Id, Vehicle__c> vehicleMap = new Map<Id, Vehicle__c>(
            [SELECT Id, Stock_Quantity__c FROM Vehicle__c WHERE Id IN :vehicleIds]
        );

        List<Vehicle_Order__c> ordersToUpdate = new List<Vehicle_Order__c>();
        List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();

        for (Vehicle_Order__c orderRec : scope) {
            Vehicle__c vehicleRec = vehicleMap.get(orderRec.Vehicle__c);
            if (vehicleRec != null && vehicleRec.Stock_Quantity__c > 0) {
                // Update order status
                orderRec.Status__c = 'Confirmed';
                ordersToUpdate.add(orderRec);
                
                // Decrement stock count
                vehicleRec.Stock_Quantity__c -= 1;
                vehiclesToUpdate.add(vehicleRec);
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
        if (!vehiclesToUpdate.isEmpty()) {
            update vehiclesToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch stock check process completed successfully.');
    }
}