public with sharing class ScheduleVehicleBatch implements Schedulable {
    public void execute(SchedulableContext sc) {
        BatchVehicleStockCheck batchJob = new BatchVehicleStockCheck();
        Database.executeBatch(batchJob, 200);
    }
}