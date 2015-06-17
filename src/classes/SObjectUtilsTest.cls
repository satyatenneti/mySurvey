@isTest
private class SObjectUtilsTest {

	private static void assertCmpLt(Object a, Object b) {
		System.assert(SObjectUtils.comparePrimitives(a, b) < 0);
		System.assert(SObjectUtils.comparePrimitives(b, a) > 0);
		System.assert(SObjectUtils.comparePrimitives(a, a) == 0);
		System.assert(SObjectUtils.comparePrimitives(b, b) == 0);
	}

	private static void assertCmpEq(Object a, Object b) {
		System.assert(SObjectUtils.comparePrimitives(a, b) == 0);
		System.assert(SObjectUtils.comparePrimitives(b, a) == 0);
		System.assert(SObjectUtils.comparePrimitives(a, a) == 0);
		System.assert(SObjectUtils.comparePrimitives(b, b) == 0);
	}

	private static Product_Category__c getProductCategory(Product_Category__c pc) {
		return [ SELECT Category__r.Name, Product__r.Name FROM Product_Category__c WHERE Id = :pc.Id ];
	}

	@isTest static void testGetNull() {
		User u = new User();

		System.assertEquals(null, SObjectUtils.getField(u, 'Contact.Account.Name'));
		System.assertEquals(null, SObjectUtils.getField(null, 'Contact.Account.Name'));

		System.assertEquals(null, SObjectUtils.getSObject(u, 'Contact.Account'));
		System.assertEquals(null, SObjectUtils.getSObject(null, 'Contact.Account'));

		System.assertEquals(null, SObjectUtils.getSObject(u, 'Contact'));
		System.assertEquals(null, SObjectUtils.getSObject(null, 'Contact'));
	}
	
	@isTest static void testGetField() {
		Date today = Date.today();

		User u = new User();
		Contact c = new Contact();
		Account a = new Account();

		u.Contact = c;
		c.Account = a;
		c.Birthdate = today;
		a.Name = 'Hello World';

		System.assertEquals('Hello World', SObjectUtils.getField(u, 'Contact.Account.Name'));
		System.assertEquals('Hello World', SObjectUtils.getField(a, 'Name'));
		System.assertEquals(today, SObjectUtils.getField(c, 'Birthdate'));

		Boolean hadError = false;
		try {
			SObjectUtils.getField(u, 'Contact.Account');
		} catch (Exception e) {
			hadError = true;
		}
		System.assert(hadError);
	}
	
	@isTest static void testGetSObject() {
		Date today = Date.today();

		User u = new User();
		Contact c = new Contact();
		Account a = new Account();

		u.Contact = c;
		c.Account = a;
		c.Birthdate = today;
		a.Name = 'Hello World';

		System.assertEquals(a, SObjectUtils.getSObject(u, 'Contact.Account'));
		System.assertEquals(c, SObjectUtils.getSObject(u, 'Contact'));

		Boolean hadError = false;
		try {
			SObjectUtils.getSObject(u, 'Contact.Account.Name');
		} catch (Exception e) {
			hadError = true;
		}
		System.assert(hadError);
	}

	@isTest static void testAccumulate() {
		CatalogTestUtils util = new CatalogTestUtils();

		Product2 p1 = util.getProduct('Product 1');
		Product2 p2 = util.getProduct('Product 2');
		Product2 p3 = util.getProduct('Product 3');
		Product2 p4 = util.getProduct('Product 4');

		Category__c c1 = util.getCategory('Category 1');
		Category__c c2 = util.getCategory('Category 2');

		util.getProductCategory(p1, c1);
		util.getProductCategory(p2, c1);
		util.getProductCategory(p3, c1);
		util.getProductCategory(p1, c2);
		util.getProductCategory(p4, c2);
		util.getProductCategory(p4, c2);

		util.upsertData();

		List<Product_Category__c> productCategories = [ SELECT
				Category__c,
				Product__c,
				Category__r.Name,
				Product__r.Name
			FROM Product_Category__c
			ORDER BY Product__r.Name, Category__r.Name ];

		Map<Id,List<Product_Category__c>> productCategoriesByCategoryId = SObjectUtils.accumulate(productCategories, 'Category__c');

		System.assertEquals(2, productCategoriesByCategoryId.size());

		System.assertEquals(3, productCategoriesByCategoryId.get(c1.Id).size());
		System.assertEquals('Product 1', productCategoriesByCategoryId.get(c1.Id).get(0).Product__r.Name);
		System.assertEquals('Product 2', productCategoriesByCategoryId.get(c1.Id).get(1).Product__r.Name);
		System.assertEquals('Product 3', productCategoriesByCategoryId.get(c1.Id).get(2).Product__r.Name);

		System.assertEquals(3, productCategoriesByCategoryId.get(c2.Id).size());
		System.assertEquals('Product 1', productCategoriesByCategoryId.get(c2.Id).get(0).Product__r.Name);
		System.assertEquals('Product 4', productCategoriesByCategoryId.get(c2.Id).get(1).Product__r.Name);
		System.assertEquals('Product 4', productCategoriesByCategoryId.get(c2.Id).get(2).Product__r.Name);

		Map<Id,List<Product_Category__c>> productCategoriesByProductId = SObjectUtils.accumulate(productCategories, 'Product__c');

		System.assertEquals(4, productCategoriesByProductId.size());

		System.assertEquals(2, productCategoriesByProductId.get(p1.Id).size());
		System.assertEquals('Category 1', productCategoriesByProductId.get(p1.Id).get(0).Category__r.Name);
		System.assertEquals('Category 2', productCategoriesByProductId.get(p1.Id).get(1).Category__r.Name);

		System.assertEquals(1, productCategoriesByProductId.get(p2.Id).size());
		System.assertEquals('Category 1', productCategoriesByProductId.get(p2.Id).get(0).Category__r.Name);

		System.assertEquals(1, productCategoriesByProductId.get(p3.Id).size());
		System.assertEquals('Category 1', productCategoriesByProductId.get(p3.Id).get(0).Category__r.Name);

		System.assertEquals(2, productCategoriesByProductId.get(p4.Id).size());
		System.assertEquals('Category 2', productCategoriesByProductId.get(p4.Id).get(0).Category__r.Name);
		System.assertEquals('Category 2', productCategoriesByProductId.get(p4.Id).get(1).Category__r.Name);
	}
	
	@isTest static void testAccumulateAllowsPath() {
		CatalogTestUtils util = new CatalogTestUtils();

		Product2 p1 = util.getProduct('Product 1');
		Product2 p2 = util.getProduct('Product 2');
		Product2 p3 = util.getProduct('Product 3');
		Product2 p4 = util.getProduct('Product 4');

		Category__c c1 = util.getCategory('Category 1');
		Category__c c2 = util.getCategory('Category 2');

		util.getProductCategory(p1, c1);
		util.getProductCategory(p2, c1);
		util.getProductCategory(p3, c1);
		util.getProductCategory(p4, c2);

		util.upsertData();

		List<Product_Category__c> productCategories = [ SELECT
				Category__r.Id,
				Product__r.Name
			FROM Product_Category__c
			ORDER BY Product__r.Name, Category__r.Name ];

		Map<Id,List<Product_Category__c>> productCategoriesByCategoryId = SObjectUtils.accumulate(productCategories, 'Category__r.Id');

		System.assertEquals(2, productCategoriesByCategoryId.size());

		System.assertEquals(3, productCategoriesByCategoryId.get(c1.Id).size());
		System.assertEquals('Product 1', productCategoriesByCategoryId.get(c1.Id).get(0).Product__r.Name);
		System.assertEquals('Product 2', productCategoriesByCategoryId.get(c1.Id).get(1).Product__r.Name);
		System.assertEquals('Product 3', productCategoriesByCategoryId.get(c1.Id).get(2).Product__r.Name);

		System.assertEquals(1, productCategoriesByCategoryId.get(c2.Id).size());
		System.assertEquals('Product 4', productCategoriesByCategoryId.get(c2.Id).get(0).Product__r.Name);
	}


	@isTest static void testPluck() {
		CatalogTestUtils util = new CatalogTestUtils();

		Product2 p1 = util.getProduct('Product 1');
		Product2 p2 = util.getProduct('Product 2');
		Product2 p3 = util.getProduct('Product 3');
		Product2 p4 = util.getProduct('Product 4');

		Category__c c1 = util.getCategory('Category 1');
		Category__c c2 = util.getCategory('Category 2');

		util.getProductCategory(p1, c1);
		util.getProductCategory(p2, c1);
		util.getProductCategory(p3, c1);
		util.getProductCategory(p4, c2);

		util.upsertData();

		List<Product_Category__c> productCategories = [ SELECT
				Product__r.Id,
				Category__r.Name
			FROM Product_Category__c
			ORDER BY Category__r.Name DESC, Product__r.Name ];

		List<Id> productIds = SObjectUtils.pluckIds(productCategories, 'Product__r.Id');
		System.assertEquals(4, productIds.size());
		System.assertEquals(p4.Id, productIds.get(0));
		System.assertEquals(p1.Id, productIds.get(1));
		System.assertEquals(p2.Id, productIds.get(2));
		System.assertEquals(p3.Id, productIds.get(3));

		List<Category__c> categories = SObjectUtils.pluckSObjects(productCategories, 'Category__r');
		System.assertEquals(4, categories.size());
		System.assertEquals('Category 2', categories.get(0).Name);
		System.assertEquals('Category 1', categories.get(1).Name);
		System.assertEquals('Category 1', categories.get(2).Name);
		System.assertEquals('Category 1', categories.get(3).Name);
	}

	@isTest static void testCompareByStrings() {
		CatalogTestUtils util = new CatalogTestUtils();

		Product2 p1 = util.getProduct('Product 1');
		Product2 p2 = util.getProduct('Product 2');
		Product2 p3 = util.getProduct('Product 3');
		Product2 p4 = util.getProduct('Product 4');

		Category__c c1 = util.getCategory('Category 1');
		Category__c c2 = util.getCategory('Category 2');

		Product_Category__c pc1 = util.getProductCategory(p1, c2);
		Product_Category__c pc2 = util.getProductCategory(p2, c1);
		Product_Category__c pc3 = util.getProductCategory(p3, c1);
		Product_Category__c pc4 = util.getProductCategory(p4, c2);
		Product_Category__c pc5 = util.getProductCategory(p1, c1);

		util.upsertData();

		pc1 = getProductCategory(pc1);
		pc2 = getProductCategory(pc2);
		pc3 = getProductCategory(pc3);
		pc4 = getProductCategory(pc4);
		pc5 = getProductCategory(pc5);

		System.assert(SObjectUtils.compare(pc1, pc1, new List<String> { 'Category__r.Name', 'Product__r.Name' }) == 0);
		System.assert(SObjectUtils.compare(pc2, pc2, new List<String> { 'Category__r.Name', 'Product__r.Name' }) == 0);
		System.assert(SObjectUtils.compare(pc3, pc3, new List<String> { 'Category__r.Name', 'Product__r.Name' }) == 0);
		System.assert(SObjectUtils.compare(pc4, pc4, new List<String> { 'Category__r.Name', 'Product__r.Name' }) == 0);
		System.assert(SObjectUtils.compare(pc5, pc5, new List<String> { 'Category__r.Name', 'Product__r.Name' }) == 0);

		System.assert(SObjectUtils.compare(pc1, pc2, new List<String> { 'Category__r.Name', 'Product__r.Name' }) > 0);
		System.assert(SObjectUtils.compare(pc1, pc2, new List<String> { 'Category__r.Name' }) > 0);
		System.assert(SObjectUtils.compare(pc1, pc2, new List<String> { 'Product__r.Name' }) < 0);

		System.assert(SObjectUtils.compare(pc1, pc4, new List<String> { 'Category__r.Name', 'Product__r.Name' }) < 0);
		System.assert(SObjectUtils.compare(pc1, pc4, new List<String> { 'Category__r.Name' }) == 0);
		System.assert(SObjectUtils.compare(pc1, pc4, new List<String> { 'Product__r.Name' }) < 0);

		System.assert(SObjectUtils.compare(pc3, pc4, new List<String> { 'Category__r.Name', 'Product__r.Name' }) < 0);
		System.assert(SObjectUtils.compare(pc3, pc4, new List<String> { 'Category__r.Name' }) < 0);
		System.assert(SObjectUtils.compare(pc3, pc4, new List<String> { 'Product__r.Name' }) < 0);

		System.assert(SObjectUtils.compare(pc2, pc1, new List<String> { 'Category__r.Name', 'Product__r.Name' }) < 0);
		System.assert(SObjectUtils.compare(pc2, pc1, new List<String> { 'Category__r.Name' }) < 0);
		System.assert(SObjectUtils.compare(pc2, pc1, new List<String> { 'Product__r.Name' }) > 0);

		System.assert(SObjectUtils.compare(pc4, pc1, new List<String> { 'Category__r.Name', 'Product__r.Name' }) > 0);
		System.assert(SObjectUtils.compare(pc4, pc1, new List<String> { 'Category__r.Name' }) == 0);
		System.assert(SObjectUtils.compare(pc4, pc1, new List<String> { 'Product__r.Name' }) > 0);

		System.assert(SObjectUtils.compare(pc4, pc3, new List<String> { 'Category__r.Name', 'Product__r.Name' }) > 0);
		System.assert(SObjectUtils.compare(pc4, pc3, new List<String> { 'Category__r.Name' }) > 0);
		System.assert(SObjectUtils.compare(pc4, pc3, new List<String> { 'Product__r.Name' }) > 0);

		System.assert(SObjectUtils.compare(pc1, pc5, new List<String> { 'Category__r.Name', 'Product__r.Name' }) > 0);
		System.assert(SObjectUtils.compare(pc1, pc5, new List<String> { 'Category__r.Name' }) > 0);
		System.assert(SObjectUtils.compare(pc1, pc5, new List<String> { 'Product__r.Name' }) == 0);

		System.assert(SObjectUtils.compare(pc5, pc1, new List<String> { 'Category__r.Name', 'Product__r.Name' }) < 0);
		System.assert(SObjectUtils.compare(pc5, pc1, new List<String> { 'Category__r.Name' }) < 0);
		System.assert(SObjectUtils.compare(pc5, pc1, new List<String> { 'Product__r.Name' }) == 0);

		Product_Category__c pc6 = new Product_Category__c(Product__r = new Product2(Name = null));

		System.assert(SObjectUtils.compare(pc6, pc1, new List<String> { 'Product__r.Name' }) < 0);
		System.assert(SObjectUtils.compare(pc1, pc6, new List<String> { 'Product__r.Name' }) > 0);
		System.assert(SObjectUtils.compare(pc6, pc6, new List<String> { 'Product__r.Name' }) == 0);
	}

	@isTest static void testCompareByDecimalAndDatetime() {
		Datetime now = Datetime.now();
		Datetime yesterday = now.addDays(-1);

		Product2 p1 = new Product2(
			Maximum_Order_Quantity__c = 3,
			Start_Date__c = yesterday);

		Product2 p2 = new Product2(
			Maximum_Order_Quantity__c = 4,
			Start_Date__c = now);

		Product2 p3 = new Product2(
			Maximum_Order_Quantity__c = 2,
			Start_Date__c = now);

		Product2 p4 = new Product2(
			Maximum_Order_Quantity__c = 4,
			Start_Date__c = yesterday);

		System.assert(SObjectUtils.compare(p1, p3, new List<String> { 'Start_Date__c' }) < 0);
		System.assert(SObjectUtils.compare(p1, p3, new List<String> { 'Maximum_Order_Quantity__c' }) > 0);
		System.assert(SObjectUtils.compare(p1, p3, new List<String> { 'Maximum_Order_Quantity__c', 'Start_Date__c' }) > 0);
		System.assert(SObjectUtils.compare(p1, p3, new List<String> { 'Start_Date__c', 'Maximum_Order_Quantity__c' }) < 0);
		System.assert(SObjectUtils.compare(p1, p3, new List<String> { }) == 0);

		System.assert(SObjectUtils.compare(p2, p3, new List<String> { 'Start_Date__c' }) == 0);
		System.assert(SObjectUtils.compare(p2, p3, new List<String> { 'Maximum_Order_Quantity__c' }) > 0);
		System.assert(SObjectUtils.compare(p2, p3, new List<String> { 'Maximum_Order_Quantity__c', 'Start_Date__c' }) > 0);
		System.assert(SObjectUtils.compare(p2, p3, new List<String> { 'Start_Date__c', 'Maximum_Order_Quantity__c' }) > 0);
		System.assert(SObjectUtils.compare(p2, p3, new List<String> { }) == 0);

		System.assert(SObjectUtils.compare(p2, p4, new List<String> { 'Start_Date__c' }) > 0);
		System.assert(SObjectUtils.compare(p2, p4, new List<String> { 'Maximum_Order_Quantity__c' }) == 0);
		System.assert(SObjectUtils.compare(p2, p4, new List<String> { 'Maximum_Order_Quantity__c', 'Start_Date__c' }) > 0);
		System.assert(SObjectUtils.compare(p2, p4, new List<String> { 'Start_Date__c', 'Maximum_Order_Quantity__c' }) > 0);
		System.assert(SObjectUtils.compare(p2, p4, new List<String> { }) == 0);
	}

	@isTest static void testCompareByBoolean() {
		Datetime now = Datetime.now();
		Datetime yesterday = now.addDays(-1);

		Product2 p1 = new Product2(IsActive = true);
		Product2 p2 = new Product2(IsActive = false);
		Product2 p3 = new Product2(IsActive = false);

		System.assert(SObjectUtils.compare(p1, p2, new List<String> { 'IsActive' }) > 0);
		System.assert(SObjectUtils.compare(p2, p1, new List<String> { 'IsActive' }) < 0);
		System.assert(SObjectUtils.compare(p2, p1, new List<String> { }) == 0);
		System.assert(SObjectUtils.compare(p2, p3, new List<String> { 'IsActive' }) == 0);
	}

	@isTest static void testComparePrimitives() {
		Datetime now = Datetime.now();
		Datetime yesterday = now.addDays(-1);

		assertCmpLt(Time.newInstance(8, 0, 0, 0), Time.newInstance(11, 0, 0, 0));
		assertCmpEq(Time.newInstance(11, 0, 0, 0), Time.newInstance(11, 0, 0, 0));
		assertCmpLt(8, 9);
		assertCmpEq(8, 8);
		assertCmpLt('a', 'b');
		assertCmpEq('a', 'a');
		assertCmpLt(null, 'a');
		assertCmpEq(null, null);
		assertCmpLt(yesterday, now);
		assertCmpEq(yesterday, yesterday);
		assertCmpLt(false, true);
		assertCmpEq(true, true);
		assertCmpEq(false, false);
	}

	@isTest static void testCompareNulls() {
		System.assert(SObjectUtils.compare(null, new Product2(), new List<String> {}) < 0);
		System.assert(SObjectUtils.compare(new Product2(), null, new List<String> {}) > 0);
		System.assert(SObjectUtils.compare(null, null, new List<String> {}) == 0);

		System.assert(SObjectUtils.compare(null, new Product2(), new List<String> {}, true, false) > 0);
		System.assert(SObjectUtils.compare(new Product2(), null, new List<String> {}, true, false) < 0);
		System.assert(SObjectUtils.compare(null, null, new List<String> {}, true, false) == 0);
	}

}