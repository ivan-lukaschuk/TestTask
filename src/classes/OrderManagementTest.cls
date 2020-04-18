@IsTest
public class OrderManagementTest {
    @TestSetup
    public static void createRecords() {
        List<Product__c> products = new List<Product__c>();

        for (Integer i = 0; i < 10; i++) {
            products.add(new Product__c(Name = 'Product' + i, Description__c = 'Product description', Type__c = 'Type 1',
                    Family__c = 'Family 1', Image__c = 'https://www.shopolog.ru/s/img/services/de/2b/800x400_de2bf5f75bc0b74cf094e70e1ad6121e___png____4_ae854789.png',
                    Price__c = 1));
        }

        insert products;
    }

    @IsTest
    public static void getProductsTest() {
        List<OrderManagement.ProductWrapper> productWrappers = new List<OrderManagement.ProductWrapper>();
        List<Product__c> products                            = [
                SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c
                FROM Product__c
                ORDER BY Name ASC
                LIMIT 50000
        ];

        for (Product__c item : products) {
            productWrappers.add(new OrderManagement.ProductWrapper(item.Id, item.Name, item.Description__c, item.Type__c,
                    item.Family__c, item.Image__c, item.Price__c));
        }

        System.assertEquals(OrderManagement.getProducts(), JSON.serialize(productWrappers));
    }

    @IsTest
    public static void getProductsByFilterTest() {
        List<OrderManagement.ProductWrapper> productWrappers = new List<OrderManagement.ProductWrapper>();
        List<Product__c> products                            = new List<Product__c>();
        String families                                      = '\'Family 1\' OR Family__c = \'Family 2\'';
        String types                                         = '\'Type 1\' OR Type__c = \'Type 2\'';
        String searchKey                                     = 'Pr';
        String key                                           = '\'' + searchKey + '%\'';

        if (!families.equals('') && !types.equals('')) {
            products = Database.query(
                    'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c ' +
                            'FROM Product__c ' +
                            'WHERE (Family__c = ' + families + ') AND ( Type__c = ' + types + ') AND Name LIKE ' + key +
                            ' ORDER BY Name ASC ' +
                            'LIMIT 50000'
            );
        }

        for (Product__c item : products) {
            productWrappers.add(new OrderManagement.ProductWrapper(item.Id, item.Name, item.Description__c, item.Type__c,
                    item.Family__c, item.Image__c, item.Price__c));
        }

        System.assertEquals(OrderManagement.getProductsByFilter('\'Family 1\' OR Family__c = \'Family 2\'',
                '\'Type 1\' OR Type__c = \'Type 2\'', 'Pr'), JSON.serialize(productWrappers));

        productWrappers = new List<OrderManagement.ProductWrapper>();
        families        = '';
        types           = '\'Type 1\' OR Type__c = \'Type 2\'';

        if (families.equals('') && !types.equals('')) {
            products = Database.query(
                    'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c ' +
                            'FROM Product__c ' +
                            'WHERE (Type__c = ' + types + ' ' + ') AND Name LIKE ' + key +
                            ' ORDER BY Name ASC ' +
                            'LIMIT 50000'
            );
        }

        for (Product__c item : products) {
            productWrappers.add(new OrderManagement.ProductWrapper(item.Id, item.Name, item.Description__c, item.Type__c,
                    item.Family__c, item.Image__c, item.Price__c));
        }

        System.assertEquals(OrderManagement.getProductsByFilter('', '\'Type 1\' OR Type__c = \'Type 2\'',
                'Pr'), JSON.serialize(productWrappers));

        productWrappers = new List<OrderManagement.ProductWrapper>();
        families        = '\'Family 1\' OR Family__c = \'Family 2\'';
        types           = '';

        if (!families.equals('') && types.equals('')) {
            products = Database.query(
                    'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c ' +
                            'FROM Product__c ' +
                            'WHERE (Family__c = ' + families + ' ' + ') AND Name LIKE ' + key +
                            ' ORDER BY Name ASC ' +
                            'LIMIT 50000'
            );
        }

        for (Product__c item : products) {
            productWrappers.add(new OrderManagement.ProductWrapper(item.Id, item.Name, item.Description__c, item.Type__c,
                    item.Family__c, item.Image__c, item.Price__c));
        }

        System.assertEquals(OrderManagement.getProductsByFilter('\'Family 1\' OR Family__c = \'Family 2\'',
                '', 'Pr'), JSON.serialize(productWrappers));

        productWrappers = new List<OrderManagement.ProductWrapper>();
        families        = '';
        types           = '';

        if (families.equals('') && types.equals('')) {
            products = Database.query(
                    'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c ' +
                            'FROM Product__c ' +
                            'WHERE Name LIKE ' + key +
                            ' ORDER BY Name ASC ' +
                            'LIMIT 50000'
            );
        }

        for (Product__c item : products) {
            productWrappers.add(new OrderManagement.ProductWrapper(item.Id, item.Name, item.Description__c, item.Type__c,
                    item.Family__c, item.Image__c, item.Price__c));
        }

        System.assertEquals(OrderManagement.getProductsByFilter('', '', 'Pr'),
                JSON.serialize(productWrappers));
    }

    @IsTest
    public static void createOrderItemsTest() {
        OrderManagement.createOrderItems('[{"Name":"Order Item","Quantity__c":1,"Price__c":32,"ProductId__c":"a032w000002Z2H6AAK"},{"Name":"Order Item","Quantity__c":1,"Price__c":3423,"ProductId__c":"a032w000002Z2HBAA0"}]');
        System.assertEquals([SELECT COUNT() FROM OrderItem__c], 2);
    }
}