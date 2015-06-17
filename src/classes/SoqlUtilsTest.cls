@isTest
private class SoqlUtilsTest {
	private static Integer idNum = 1;
	
	private static Id getFakeProductId() {
		String myIdNum = String.valueOf(idNum++);
		return Id.valueOf(Product2.SObjectType.getDescribe().getKeyPrefix() + '0'.repeat(12 - myIdNum.length()) + myIdNum);
	}

	@isTest static void testGetSelect() {
		String query = SoqlUtils.getSelect(new List<String> {
			'Id',
			'Name'
		}, 'Product2').toString();

		System.assertEquals('SELECT Id, Name FROM Product2', query);
	}
	
	@isTest static void testGetLike() {
		String likeClause = SoqlUtils.getLike('Name', '%Produc\'t%').toString();

		System.assertEquals(likeClause, 'Name LIKE \'%Produc\\\'t%\'');
	}

	@isTest static void testGetAndOr() {
		String andClause = SoqlUtils.getAnd(new List<SoqlUtils.SoqlCondition> {
			SoqlUtils.getEq('My_Field__c', '1'),
			SoqlUtils.getEq('Other_Field__c', '2'),
			SoqlUtils.getOr(new List<SoqlUtils.SoqlCondition> {
				SoqlUtils.getLike('Field__c', '3'),
				SoqlUtils.getLike('Last__c', '4')
			})
		}).toString();

		System.assertEquals(andClause, '(My_Field__c = \'1\' AND Other_Field__c = \'2\' AND (Field__c LIKE \'3\' OR Last__c LIKE \'4\'))');
	}

	@isTest static void testGetOrAnd() {
		String andClause = SoqlUtils.getOr(new List<SoqlUtils.SoqlCondition> {
			SoqlUtils.getEq('My_Field__c', '1'),
			SoqlUtils.getEq('Other_Field__c', '2'),
			SoqlUtils.getAnd(new List<SoqlUtils.SoqlCondition> {
				SoqlUtils.getLike('Field__c', '3'),
				SoqlUtils.getLike('Last__c', '4')
			})
		}).toString();

		System.assertEquals(andClause, '(My_Field__c = \'1\' OR Other_Field__c = \'2\' OR (Field__c LIKE \'3\' AND Last__c LIKE \'4\'))');
	}

	@isTest static void testGetEq() {
		String eqClause = SoqlUtils.getEq('My_Field__c', 'Test Val\'ue 123').toString();

		System.assertEquals(eqClause, 'My_Field__c = \'Test Val\\\'ue 123\'');
	}

	@isTest static void testGetNotEq() {
		String eqClause = SoqlUtils.getNotEq('My_Field__c', 'Test Val\'ue 123').toString();

		System.assertEquals(eqClause, 'My_Field__c != \'Test Val\\\'ue 123\'');
	}

	@isTest static void testGetOrderThenBy() {

		String orderClause = SoqlUtils.getOrder('My_Field__c')
			.thenBy('Other_Field__c').descending()
			.thenBy('Final_Field__c').descending().withNullsLast()
			.toString();

		System.assertEquals('My_Field__c ASC NULLS FIRST, Other_Field__c DESC NULLS FIRST, Final_Field__c DESC NULLS LAST', orderClause);
	}

	@isTest static void testGetOrder() {
		// order respects the builder pattern

		String orderClause = SoqlUtils.getOrder('My_Field__c').toString();
		String orderClauseWithNullsFirst = SoqlUtils.getOrder('My_Field__c').withNullsFirst().toString();
		String orderClauseWithNullsLast = SoqlUtils.getOrder('My_Field__c').withNullsLast().toString();
		String orderClauseAscending = SoqlUtils.getOrder('My_Field__c').ascending().toString();
		String orderClauseDescending = SoqlUtils.getOrder('My_Field__c').descending().toString();
		String orderClauseDescendingWithNullsLast = SoqlUtils.getOrder('My_Field__c').descending().withNullsLast().toString();

		System.assertEquals(orderClause, 'My_Field__c ASC NULLS FIRST');
		System.assertEquals(orderClauseWithNullsFirst, 'My_Field__c ASC NULLS FIRST');
		System.assertEquals(orderClauseWithNullsLast, 'My_Field__c ASC NULLS LAST');
		System.assertEquals(orderClauseAscending, 'My_Field__c ASC NULLS FIRST');
		System.assertEquals(orderClauseDescending, 'My_Field__c DESC NULLS FIRST');
		System.assertEquals(orderClauseDescendingWithNullsLast, 'My_Field__c DESC NULLS LAST');
	}

	@isTest static void testGetOrderMutability() {
		// order is mutable

		SoqlUtils.SoqlOrder order = SoqlUtils.getOrder('Field');

		System.assertEquals(order.toString(), 'Field ASC NULLS FIRST');
		order.descending();
		System.assertEquals(order.toString(), 'Field DESC NULLS FIRST');
		order.withNullsLast();
		System.assertEquals(order.toString(), 'Field DESC NULLS LAST');
		order.ascending();
		System.assertEquals(order.toString(), 'Field ASC NULLS LAST');
	}

	@isTest static void testGetNotInList() {
		String inClause = SoqlUtils.getNotIn('Something__c', new List<String> {
			'value 1',
			'value 2',
			'val\'ue 3'
		}).toString();

		System.assertEquals(inClause, 'Something__c NOT IN (\'value 1\', \'value 2\', \'val\\\'ue 3\')');
	}

	@isTest static void testGetNotInSet() {
		String inClause = SoqlUtils.getNotIn('Something__c', new Set<String> {
			'value 1',
			'value 2',
			'val\'ue 3'
		}).toString();

		System.assert(Pattern.compile('Something__c NOT IN \\((\'(value 1|value 2|val\\\\\'ue 3)\',?\\s*){3}\\)').matcher(inClause).matches());
		System.assert(inClause.contains('\'value 1\''));
		System.assert(inClause.contains('\'value 2\''));
		System.assert(inClause.contains('\'val\\\'ue 3\''));
	}

	@isTest static void testGetNotInIdList() {
		Id id1 = getFakeProductId();
		Id id2 = getFakeProductId();
		Id id3 = getFakeProductId();

		String inClause = SoqlUtils.getNotIn('Something__c', new List<Id> { id1, id2, id3 }).toString();

		System.assertEquals(inClause, 'Something__c NOT IN (\''+id1+'\', \''+id2+'\', \''+id3+'\')');
	}

	@isTest static void testGetNotInIdSet() {
		Id id1 = getFakeProductId();
		Id id2 = getFakeProductId();
		Id id3 = getFakeProductId();

		String inClause = SoqlUtils.getNotIn('Something__c', new Set<Id> { id1, id2, id3 }).toString();

		System.assert(Pattern.compile('Something__c NOT IN \\((\'('+id1+'|'+id2+'|'+id3+')\',?\\s*){3}\\)').matcher(inClause).matches());
		System.assert(inClause.contains(id1));
		System.assert(inClause.contains(id2));
		System.assert(inClause.contains(id3));
	}

	@isTest static void testGetNotInSubquery() {
		String inClause = SoqlUtils.getNotIn('Something__c', SoqlUtils.getSelect(new List<String> { 'Id' }, 'Product2')).toString();

		System.assertEquals(inClause, 'Something__c NOT IN (SELECT Id FROM Product2)');
	}

	@isTest static void testGetInList() {
		String inClause = SoqlUtils.getIn('Something__c', new List<String> {
			'value 1',
			'value 2',
			'val\'ue 3'
		}).toString();

		System.assertEquals(inClause, 'Something__c IN (\'value 1\', \'value 2\', \'val\\\'ue 3\')');
	}

	@isTest static void testGetInSet() {
		String inClause = SoqlUtils.getIn('Something__c', new Set<String> {
			'value 1',
			'value 2',
			'val\'ue 3'
		}).toString();

		System.assert(Pattern.compile('Something__c IN \\((\'(value 1|value 2|val\\\\\'ue 3)\',?\\s*){3}\\)').matcher(inClause).matches());
		System.assert(inClause.contains('\'value 1\''));
		System.assert(inClause.contains('\'value 2\''));
		System.assert(inClause.contains('\'val\\\'ue 3\''));
	}

	@isTest static void testGetInIdList() {
		Id id1 = getFakeProductId();
		Id id2 = getFakeProductId();
		Id id3 = getFakeProductId();

		String inClause = SoqlUtils.getIn('Something__c', new List<Id> { id1, id2, id3 }).toString();

		System.assertEquals(inClause, 'Something__c IN (\''+id1+'\', \''+id2+'\', \''+id3+'\')');
	}

	@isTest static void testGetInIdSet() {
		Id id1 = getFakeProductId();
		Id id2 = getFakeProductId();
		Id id3 = getFakeProductId();

		String inClause = SoqlUtils.getIn('Something__c', new Set<Id> { id1, id2, id3 }).toString();

		System.assert(Pattern.compile('Something__c IN \\((\'('+id1+'|'+id2+'|'+id3+')\',?\\s*){3}\\)').matcher(inClause).matches());
		System.assert(inClause.contains(id1));
		System.assert(inClause.contains(id2));
		System.assert(inClause.contains(id3));
	}
	@isTest static void testGetInSubquery() {
		String inClause = SoqlUtils.getIn('Something__c', SoqlUtils.getSelect(new List<String> { 'Id' }, 'Product2')).toString();

		System.assertEquals(inClause, 'Something__c IN (SELECT Id FROM Product2)');
	}
	
	@isTest static void testQuery() {
		String query = SoqlUtils.getSelect(new List<String> {
				'Id',
				'Name'
			}, 'Product2')
			.withLimit(10)
			.withCondition(SoqlUtils.getIn('Id', SoqlUtils.getSelect(new List<String> { 'Product__c' }, 'Product_Attribute__c')))
			.withOffset(20)
			.withOrder(SoqlUtils.getOrder('Sort_Order__c').descending().withNullsLast())
			.toString();


		System.assertEquals('SELECT Id, Name FROM Product2 WHERE Id IN (SELECT Product__c FROM Product_Attribute__c) ORDER BY Sort_Order__c DESC NULLS LAST LIMIT 10 OFFSET 20', query);
	}

	@isTest static void testBooleans() {
		System.assertEquals('a = true', SoqlUtils.getEq('a', true).toString());
		System.assertEquals('a = false', SoqlUtils.getEq('a', false).toString());
		System.assertEquals('a != true', SoqlUtils.getNotEq('a', true).toString());
		System.assertEquals('a != false', SoqlUtils.getNotEq('a', false).toString());
	}

	@isTest static void testDatetimes() {
		System.assertEquals('My_Field__c = 2009-11-13T08:10:49Z', SoqlUtils.getEq('My_Field__c', Datetime.newInstanceGmt(2009, 11, 13, 8, 10, 49)).toString());
		System.assertEquals('My_Field__c != 2009-11-13T08:10:49Z', SoqlUtils.getNotEq('My_Field__c', Datetime.newInstanceGmt(2009, 11, 13, 8, 10, 49)).toString());
		System.assertEquals('My_Field__c < 2014-01-03T21:00:00Z', SoqlUtils.getLt('My_Field__c', Datetime.newInstanceGmt(2014, 1, 3, 21, 0, 0)).toString());
		System.assertEquals('My_Field__c > 2011-09-27T00:00:00Z', SoqlUtils.getGt('My_Field__c', Datetime.newInstanceGmt(2011, 9, 27, 0, 0, 0)).toString());
		System.assertEquals('My_Field__c <= 2007-04-29T13:10:49Z', SoqlUtils.getLe('My_Field__c', Datetime.newInstanceGmt(2007, 4, 29, 13, 10, 49)).toString());
		System.assertEquals('My_Field__c >= 2018-12-01T23:59:59Z', SoqlUtils.getGe('My_Field__c', Datetime.newInstanceGmt(2018, 12, 1, 23, 59, 59)).toString());
	}

	@isTest static void testNulls() {
		System.assertEquals('My_Field__c = null', SoqlUtils.getNull('My_Field__c').toString());
		System.assertEquals('My_Field__c != null', SoqlUtils.getNotNull('My_Field__c').toString());
	}

	@isTest static void testBetweenTemplate() {
		Datetime dt = Datetime.newInstanceGmt(2014, 1, 3, 21, 0, 0);
		String validStart = '((Start != null AND Start <= 2014-01-03T21:00:00Z) OR (Start = null AND Tpl_Start != null AND Tpl_Start <= 2014-01-03T21:00:00Z))';
		String validEnd = '((End = null AND Tpl_End = null) OR (End != null AND End > 2014-01-03T21:00:00Z) OR (End = null AND Tpl_End != null AND Tpl_End > 2014-01-03T21:00:00Z))';
		System.assertEquals('('+validStart+' AND '+validEnd+')', SoqlUtils.getBetween(dt, 'Start', 'End', 'Tpl_Start', 'Tpl_End').toString());
	}

	@isTest static void testBetween() {
		Datetime dt = Datetime.newInstanceGmt(2014, 1, 3, 21, 0, 0);
		System.assertEquals('((Start_Date__c != null AND Start_Date__c <= 2014-01-03T21:00:00Z) AND (End_Date__c = null OR End_Date__c > 2014-01-03T21:00:00Z))', SoqlUtils.getBetween(dt, 'Start_Date__c', 'End_Date__c').toString());
	}

	@isTest static void testGetCreatableFields() {
		Set<String> c1 = new Set<String>(SoqlUtils.getCreatableFields(Product2.SObjectType));
		Set<String> c2 = new Set<String>(SoqlUtils.getCreatableFields('Product2'));

		// assert that both are the same
		System.assertEquals(c1.size(), c2.size());
		for (String fieldName: c1) {
			System.assert(c2.contains(fieldName));
		}

		// just assert some of the standard fields are returned. we'll get back custom fields too,
		// but asserting those would be inflexible
		System.assert(c1.contains('isactive'));
		System.assert(c1.contains('recordtypeid'));
		System.assert(c1.contains('productcode'));
		System.assert(c1.contains('description'));
		System.assert(c1.contains('family'));
		System.assert(c1.contains('name'));

		// these are NOT creatable
		System.assert(!c1.contains('createdbyid'));
		System.assert(!c1.contains('lastmodifiedbyid'));
		System.assert(!c1.contains('id'));
	}

	@isTest static void testStar() {
		Set<String> star1 = new Set<String>(SoqlUtils.star(Product2.SObjectType));
		Set<String> star2 = new Set<String>(SoqlUtils.star('Product2'));

		// assert that both stars are the same
		System.assertEquals(star1.size(), star2.size());
		for (String fieldName: star1) {
			System.assert(star2.contains(fieldName));
		}

		// just assert some of the standard fields are returned. we'll get back custom fields too,
		// but asserting those would be inflexible
		System.assert(star1.contains('isactive'));
		System.assert(star1.contains('createdbyid'));
		System.assert(star1.contains('recordtypeid'));
		System.assert(star1.contains('lastmodifiedbyid'));
		System.assert(star1.contains('productcode'));
		System.assert(star1.contains('description'));
		System.assert(star1.contains('family'));
		System.assert(star1.contains('name'));
		System.assert(star1.contains('id'));
	}
	static void insertAccountsAndContacts(){
		List<Sales_Channel__c> clist;
		List<Store_Front__c> sflist;
		Sales_Channel__c testschannel1 , testschannel2;
		testschannel1 = new Sales_Channel__c(Name='TestChannel1');
		testschannel2 = new Sales_Channel__c(Name='TestChannel2');
		clist= new List<Sales_Channel__c>{testschannel1,testschannel2};
		insert clist;
		Store_Front__c testsf1 = new Store_Front__c(Sales_Channel__c=testschannel1.Id,Name='JonesMart');
		Store_Front__c testsf2 = new Store_Front__c(Sales_Channel__c=testschannel2.Id,Name='MarkMart');
		sflist = new List<Store_Front__c>{testsf1,testsf2};
		insert sflist;
	}
    @isTest static void testgetChildSelect(){	
    	   insertAccountsAndContacts();
           Test.startTest();
	           for(Sales_Channel__c eachschannel:Database.query(SoqlUtils.getChildSelect('Store_Front__c','Store_Fronts__r','Sales_Channel__c').toString())){
	           	      system.assertEquals(eachschannel.Store_Fronts__r.size(),1);
	           }
	       Test.stopTest();
    }
    @isTest static void testgetChildSelectNegativeCondition(){	
    	   Test.startTest();
	           try{
	           	     Database.query(SoqlUtils.getChildSelect('','','').toString());
	           }
	           catch(Exception soqlException){
	           	
	           }
	       Test.stopTest();
    }
	
	@isTest static void testGetAnd() {
        Id id1 = getFakeProductId();
        Id id2 = getFakeProductId();
        Id id3 = getFakeProductId();
        
        String andClause = SoqlUtils.getAnd(new List<SoqlUtils.SoqlCondition> {         
            SoqlUtils.getOr(new List<SoqlUtils.SoqlCondition> {
                SoqlUtils.getNotEq('My_Field__c', 'Test Val\'ue 123')}),
            SoqlUtils.getAnd(new List<SoqlUtils.SoqlCondition> {
                SoqlUtils.getEq('My_Field__c', '1'),
                SoqlUtils.getEq('Other_Field__c', '2')          
            }),
            SoqlUtils.getIn('Something__c', new List<Id> { id1, id2, id3 })
        }).toString();
        System.assertEquals(andClause, '((My_Field__c != \'Test Val\\\'ue 123\') AND (My_Field__c = \'1\' AND Other_Field__c = \'2\') AND Something__c IN (\''+id1+'\', \''+id2+'\', \''+id3+'\'))');
    }

    @isTest static void testGetSOQLExcludeDataType() {
    	RecordType testRecordType = [Select id From RecordType Where Name = 'Frames' and SobjectType = 'Manufacturing_Agreement__c'];

    	Account acc = new Account(Name = 'Test Account');
    	insert acc;

    	Opportunity opp = new Opportunity(
    		AccountId = acc.Id,
    		Name = 'Test Opportunity',
    		CloseDate = Date.today().addDays(-4),
    		StageName = 'Stage');
    	insert opp;

    	Manufacturing_Agreement__c ma = new Manufacturing_Agreement__c(
    		RecordTypeId = testRecordType.Id,
    		Opportunity__c = opp.Id,
			Prices_Generated_Date__c = DateTime.Now(),
			School_Name__c = 'ABC School');
    	insert ma;

    	List<String> excludeDates = new List<String> {'DATE', 'DATETIME'};
		String queryString = SoqlUtils.getCreatableFieldsExcludeDataTypeSOQL('Manufacturing_Agreement__c', SoqlUtils.getEq('Id', ma.Id), null, excludeDates);
		for(Manufacturing_Agreement__c oppMa: (List<Manufacturing_Agreement__c>)Database.query(queryString))
		{
			
			System.AssertEquals('ABC School', oppMa.School_Name__c, 'School Name should have been retained');
			Boolean objectMissing = false;
			try{
				DateTime dt = oppMa.Prices_Generated_Date__c;
			} catch (SObjectException e) {
				objectMissing = true;
			}
			System.AssertEquals(true, objectMissing, 'Prices Generated Date should have been excluded');
		}
    }
}