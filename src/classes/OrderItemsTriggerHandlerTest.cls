@IsTest
public class OrderItemsTriggerHandlerTest {
    @IsTest
    public static void updateOrderTest() {
        List<OrderItem__c> orderItems = new List<OrderItem__c>();
        Order__c order                = new Order__c(Name = 'TestOrder');

        insert order;

        for (Integer i = 0; i < 5; i++) {
            orderItems.add(new OrderItem__c(Name = 'TestOrderItem' + i, Price__c = 1, Quantity__c = 1,
                    OrderId__c = order.Id));
        }

        insert orderItems;

        System.assertEquals([SELECT TotalPrice__c FROM Order__c].TotalPrice__c, 5);
        System.assertEquals([SELECT TotalProductCount__c FROM Order__c].TotalProductCount__c, 5);
    }
}