import {LightningElement, wire, track, api} from 'lwc';
import getProducts from '@salesforce/apex/OrderManagement.getProducts';
import getProductsByFilter from '@salesforce/apex/OrderManagement.getProductsByFilter';
import createOrderItems from '@salesforce/apex/OrderManagement.createOrderItems';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {createRecord} from 'lightning/uiRecordApi';
import ORDER_OBJECT from '@salesforce/schema/Order__c';
import ORDER_NAME_FIELD from '@salesforce/schema/Order__c.Name';
import ORDER_ACCOUNT_FIELD from '@salesforce/schema/Order__c.AccountId__c';
import PRODUCT_NAME_FIELD from '@salesforce/schema/Product__c.Name';
import PRODUCT_DESCRIPTION_FIELD from '@salesforce/schema/Product__c.Description__c';
import PRODUCT_TYPE_NAME_FIELD from '@salesforce/schema/Product__c.Type__c';
import PRODUCT_FAMILY_NAME_FIELD from '@salesforce/schema/Product__c.Family__c';
import PRODUCT_IMAGE_NAME_FIELD from '@salesforce/schema/Product__c.Image__c';
import PRODUCT_PRICE_NAME_FIELD from '@salesforce/schema/Product__c.Price__c';
import Id from '@salesforce/user/Id';

const columns = [
    {label: 'Label', fieldName: 'name'},
    {label: 'Description', fieldName: 'description'},
    {label: 'Type', fieldName: 'type'},
    {label: 'Family', fieldName: 'family'},
    {label: 'Image', fieldName: 'image', type: 'url'},
    {label: 'Price', fieldName: 'price', type: 'currency'},
];

export default class OrderManagement extends LightningElement {
    @api recordId;
    @track familyPicklistValues = [];
    @track typePicklistValues   = [];
    @track productsInCart       = [];
    @track data                 = [];
    @track columns              = columns;
    @track userId               = Id;
    @track products;
    selectedFamilies            = [];
    selectedTypes               = [];
    orderItems                  = [];
    searchKey                   = '';
    areDetailsVisible           = false;
    isCartVisible               = false;
    isCheckoutDisabled          = true;
    isCreateProductVisible      = false;
    orderNumber                 = 1;
    isManager;
    productDetails;

    fields = [PRODUCT_NAME_FIELD, PRODUCT_DESCRIPTION_FIELD, PRODUCT_TYPE_NAME_FIELD, PRODUCT_FAMILY_NAME_FIELD,
        PRODUCT_IMAGE_NAME_FIELD, PRODUCT_PRICE_NAME_FIELD];

    @wire(getRecord, {
        recordId: '$recordId',
        fields: ['Account.Name', 'Account.AccountNumber']
    })
    account;

    @wire(getRecord, {
        recordId: '$userId',
        fields: ['User.IsManager__c']
    })
    user;

    @wire(getObjectInfo, {objectApiName: 'Product__c'})
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: 'Product__c.Family__c'
    })
    wiredFamilyPicklist({data}) {
        if (data) {
            for (let i = 0; i < data.values.length; i++) {
                this.familyPicklistValues.push({id: i, label: data.values[i]['value']});
            }
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: 'Product__c.Type__c'
    })
    wiredTypePicklist({data}) {
        if (data) {
            for (let i = 0; i < data.values.length; i++) {
                this.typePicklistValues.push({id: i, label: data.values[i]['value']});
            }
        }
    }

    connectedCallback() {
        this.getProducts();
    }

    getProducts() {
        getProducts()
            .then(result => {
                this.products = JSON.parse(result);
            });
    }

    handleChangeFamily(event) {
        if (event.target.checked == true) {
            this.selectedFamilies.push('\'' + event.target.label + '\'');
        } else {
            this.selectedFamilies.splice(this.selectedFamilies.indexOf('\'' + event.target.label + '\''), 1);
        }
    }

    handleChangeType(event) {
        if (event.target.checked == true) {
            this.selectedTypes.push('\'' + event.target.label + '\'');
        } else {
            this.selectedTypes.splice(this.selectedTypes.indexOf('\'' + event.target.label + '\''), 1);
        }
    }

    getProductsByFilter() {
        getProductsByFilter({
            families: this.selectedFamilies.join(' OR Family__c = '),
            types: this.selectedTypes.join(' OR Type__c = '),
            searchKey: this.searchKey
        })
            .then(result => {
                this.products = JSON.parse(result);
            });
    }

    handleKeyChange(event) {
        this.searchKey = event.target.value;
        this.getProductsByFilter();
    }

    showHideDetails(event) {
        this.areDetailsVisible = !this.areDetailsVisible;
        this.productDetails    = this.products.find(item => item.id === event.target.value);
    }

    showHideCart() {
        this.data          = this.productsInCart;
        this.isCartVisible = !this.isCartVisible;

        if (this.data.length !== 0) {
            this.isCheckoutDisabled = false;
        }
    }

    addToCart(event) {
        this.productsInCart.push(this.products.find(item => item.id === event.target.value));
    }

    checkoutCart() {
        const fields                              = {};
        fields [ORDER_NAME_FIELD.fieldApiName]    = 'Order ' + this.orderNumber;
        fields [ORDER_ACCOUNT_FIELD.fieldApiName] = this.recordId;
        let orderInput                            = {apiName: ORDER_OBJECT.objectApiName, fields};

        createRecord(orderInput)
            .then(order => {
                this.productsInCart.forEach(item => {
                    this.orderItems.push({
                        Name: 'Order Item', Quantity__c: 1, Price__c: item.price, OrderId__c: order.id,
                        ProductId__c: item.id
                    });
                });

                createOrderItems({orderItemsString: JSON.stringify(this.orderItems)});
            });

        this.orderNumber++;
    }

    get isCreateProductDisabled() {
        this.isManager = getFieldValue(this.user.data, 'User.IsManager__c');
        return !this.isManager;
    }

    createProduct() {
        this.isCreateProductVisible = true;
    }

    hideProductCreationWindow() {
        this.isCreateProductVisible = false;
    }

    get accountName() {
        return getFieldValue(this.account.data, 'Account.Name');
    }

    get accountNumber() {
        return getFieldValue(this.account.data, 'Account.AccountNumber');
    }
}