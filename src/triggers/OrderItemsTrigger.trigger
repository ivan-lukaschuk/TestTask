trigger OrderItemsTrigger on OrderItem__c (after insert) {
    OrderItemsTriggerHandler.updateOrder(Trigger.new);
}