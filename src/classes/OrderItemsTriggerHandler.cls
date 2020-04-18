public with sharing class OrderItemsTriggerHandler {
    public static void updateOrder(List<OrderItem__c> orderItems) {
        List<Order__c> orders = [
                SELECT TotalPrice__c, TotalProductCount__c
                FROM Order__c
                WHERE Id IN (SELECT OrderId__c FROM OrderItem__c WHERE Id IN :orderItems)
        ];

        Decimal totalPrice        = 0;
        Decimal totalProductCount = 0;

        for (Order__c order : orders) {
            if (order.TotalPrice__c != null) {
                totalPrice = order.TotalPrice__c;
            }

            if (order.TotalProductCount__c != null) {
                totalProductCount = order.TotalProductCount__c;
            }

            for (OrderItem__c orderItem : orderItems) {
                totalPrice        += orderItem.Price__c;
                totalProductCount += orderItem.Quantity__c;
            }

            order.TotalPrice__c        = totalPrice;
            order.TotalProductCount__c = totalProductCount;
            totalPrice                 = 0;
            totalProductCount          = 0;
        }

        try {
            update orders;
        } catch (DmlException ex) {
            System.debug(ex.getMessage());
        }
    }
}