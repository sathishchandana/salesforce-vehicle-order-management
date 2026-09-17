public with sharing class VehicleOrderTriggerHandler {
    
    public static void handleBeforeInsert(List<Vehicle_Order__c> newOrders) {
        // 1. Collect all related Vehicle IDs from incoming orders
        Set<Id> vehicleIds = new Set<Id>();
        for (Vehicle_Order__c orderRecord : newOrders) {
            if (orderRecord.Vehicle__c != null) {
                vehicleIds.add(orderRecord.Vehicle__c);
            }
        }
        
        if (vehicleIds.isEmpty()) {
            return;
        }
        
        // 2. Query stock levels for the referenced Vehicles
        Map<Id, Vehicle__c> vehicleMap = new Map<Id, Vehicle__c>(
            [SELECT Id, Stock_Quantity__c FROM Vehicle__c WHERE Id IN :vehicleIds]
        );
        
        // 3. Evaluate stock levels and set Order Status accordingly
        for (Vehicle_Order__c orderRecord : newOrders) {
            if (orderRecord.Vehicle__c != null && vehicleMap.containsKey(orderRecord.Vehicle__c)) {
                Vehicle__c parentVehicle = vehicleMap.get(orderRecord.Vehicle__c);
                
                if (parentVehicle.Stock_Quantity__c != null && parentVehicle.Stock_Quantity__c > 0) {
                    orderRecord.Status__c = 'Confirmed';
                } else {
                    orderRecord.Status__c = 'Pending';
                }
            }
        }
    }
}