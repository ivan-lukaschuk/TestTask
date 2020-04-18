public with sharing class OrderManagement {
    public class ProductWrapper {
        public Id id;
        public String name;
        public String description;
        public String type;
        public String family;
        public String image;
        public Decimal price;

        public ProductWrapper(Id id, String name, String description, String type, String family, String image,
                Decimal price) {
            this.id          = id;
            this.name        = name;
            this.description = description;
            this.type        = type;
            this.family      = family;
            this.image       = image;
            this.price       = price;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getProducts() {
        List<ProductWrapper> productWrappers = new List<OrderManagement.ProductWrapper>();
        List<Product__c> products            = [
                SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c
                FROM Product__c
                ORDER BY Name ASC
                LIMIT 50000
        ];

        for (Product__c item : products) {
            productWrappers.add(new ProductWrapper(item.Id, item.Name, item.Description__c, item.Type__c, item.Family__c,
                    item.Image__c, item.Price__c));
        }

        return JSON.serialize(productWrappers);
    }

    @AuraEnabled(cacheable=true)
    public static String getProductsByFilter(String families, String types, String searchKey) {
        List<ProductWrapper> productWrappers = new List<OrderManagement.ProductWrapper>();
        List<Product__c> products            = new List<Product__c>();
        String key                           = '\'' + searchKey + '%\'';

        if (!families.equals('') && !types.equals('')) {
            products = Database.query(
                            'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c ' +
                            'FROM Product__c ' +
                            'WHERE (Family__c = ' + families + ') AND ( Type__c = ' + types + ') AND Name LIKE ' + key +
                            ' ORDER BY Name ASC ' +
                            'LIMIT 50000'
            );
        }

        if (families.equals('') && !types.equals('')) {
            products = Database.query(
                            'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c ' +
                            'FROM Product__c ' +
                            'WHERE (Type__c = ' + types + ' ' + ') AND Name LIKE ' + key +
                            ' ORDER BY Name ASC ' +
                            'LIMIT 50000'
            );
        }

        if (!families.equals('') && types.equals('')) {
            products = Database.query(
                            'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c ' +
                            'FROM Product__c ' +
                            'WHERE (Family__c = ' + families + ' ' + ') AND Name LIKE ' + key +
                            ' ORDER BY Name ASC ' +
                            'LIMIT 50000'
            );
        }

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
            productWrappers.add(new ProductWrapper(item.Id, item.Name, item.Description__c, item.Type__c, item.Family__c,
                    item.Image__c, item.Price__c));
        }

        return JSON.serialize(productWrappers);
    }

    @AuraEnabled
    public static void createOrderItems(String orderItemsString) {
        List<OrderItem__c> orderItems = (List<OrderItem__c>) JSON.deserialize(orderItemsString,
                List<OrderItem__c>.class);

        try {
            insert orderItems;
        } catch (DmlException ex) {
            System.debug(ex.getMessage());
        }
    }
}