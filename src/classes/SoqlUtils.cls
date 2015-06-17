/**
 * Provides methods to generate dynamic SOQL using an object-oriented Builder pattern
 * inspired by the Hibernate criteria API.
 * @author brendan.conniff
 */
public with sharing class SoqlUtils {
    private static final Set<String> EXTRA_CALCULATED_FIELDS = new Set<String> {
        'Id',
        'CreatedDate',
        'CreatedById',
        'LastModifiedById',
        'LastModifiedDate',
        'LastReferencedDate',
        'LastViewedDate',
        'IsDeleted',
        'SystemModstamp' };

    private static final Map<Schema.SObjectType,Set<String>> EXTRA_CALCULATED_FIELDS_BY_SOBJECT_TYPE = new Map<Schema.SObjectType,Set<String>> {
        PricebookEntry.SObjectType => new Set<String> {
            'ProductCode' }
    };

    private static List<String> idsToStrings(List<Id> idList) {
        List<String> stringList = new List<String>();
        for (Id id: idList) {
            stringList.add(String.valueOf(id));
        }
        return stringList;
    }

    private static String fmtDatetime(Datetime dt) {
        return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

    private static String fmtDate(Datetime dt) {
        return dt.formatGmt('yyyy-MM-dd');
    }

    public static List<String> getCloneableFields(Schema.SObjectType type) {
        Map<String,Schema.SObjectField> fieldMap = type.getDescribe().fields.getMap();
        List<String> cloneableFields = new List<String>();

        Set<String> extraExcludes = new Set<String>();

        if (EXTRA_CALCULATED_FIELDS_BY_SOBJECT_TYPE.containsKey(type)) {
            extraExcludes.addAll(EXTRA_CALCULATED_FIELDS_BY_SOBJECT_TYPE.get(type));
        }
        extraExcludes.addAll(EXTRA_CALCULATED_FIELDS);
             
        for (Schema.SObjectField ft: fieldMap.values()) {
            Schema.DescribeFieldResult fd = ft.getDescribe();
            String fieldName = fd.getName();
            if (!fd.isAutoNumber() && !fd.isCalculated() && fd.isAccessible() && !extraExcludes.contains(fieldName)) {
                cloneableFields.add(fieldName.toLowerCase());
            }
        }
             
        return cloneableFields;
    }

    /**
     * Gets a list of field names in lowercase for the given type.
     * @param type  sObject type to find fields for
     * @return list of field names
     */
    public static List<String> star(Schema.SObjectType type) {
        return lcList(new List<String>(type.getDescribe().fields.getMap().keySet()));
    }

    /**
     * Gets a list of field names in lowercase for the given type.
     * Use the SObjectType version of this method where possible, since it does not
     * require a global describe.
     * @param typeName  name of sObject type to find fields for
     * @return list of field names
     */
    public static List<String> star(String typeName) {
        return star(Schema.getGlobalDescribe().get(typeName.toLowerCase()));
    }

    /**
     * Creates a new SELECT query.
     * @param fields  list of field names to query
     * @param table   sObject name to query from 
     * @return  a SELECT query
     */
    public static SoqlQuery getSelect(List<String> fields, String table) {
        String soql = 'SELECT ';
        String sep = '';
        for (String field: fields) {
            soql += sep + field;
            sep = ', ';
        }
        return new SoqlQuery(soql + ' FROM ' + table);
    }

    public static SoqlQuery getRelationshipSelect(List<String> fields, String relationship) {
        return new SoqlRelationshipQuery(getSelect(fields, relationship).toString());
    }

/**
     * Creates a new type of SELECT query. Here using this SoqlQuery Type we can get each of the Master Records with their own individual list of child records as per the relationship desired.
     * @param  Child Object Name which has the lookup/master detail field
     * @param  field in the Child Object particularly for which you wish to get the relationship query of
     * @param  Parent Object Name
     * @return   a SoqlQuery Object Type which we need to convert with toString() and perform Database.Query in calling method.
     */  
     public static SoqlQuery getChildSelect(String childObjName,String relationshipField,String parentObjectName){
     	   if(!(String.isBlank(childObjName) && String.isBlank(relationshipField) && String.isBlank(parentObjectName))){
	     	   List<String> parentSoqlList=SoqlUtils.star(parentObjectName);
               parentSoqlList.add('(' + SoqlUtils.getSelect(SoqlUtils.star(childObjName), relationshipField).toString() + ')');
               return SoqlUtils.getSelect(parentSoqlList,parentObjectName);
         }	   
         else
         return null;
    }
    
	/**
     * Creates a LIKE condition.
     * @param field  field name to test in the comparison
     * @param value  pattern to compare the field to
     * @return  a LIKE condition
     */
    public static SoqlCondition getLike(String field, String value) {
    	return new SoqlCondition(field + ' LIKE \'' + String.escapeSingleQuotes(value) + '\'');
    }

    /**
     * Creates an AND condition by combining a list of child conditions.
     * @param conditions  list of conditions to combine with AND
     * @return  an AND condition
     */
    public static SoqlCondition getAnd(List<SoqlCondition> conditions) {
        String soql = '(';
        String sep = '';
        for (SoqlCondition condition: conditions) {
            soql += sep + condition.toString();
            sep = ' AND ';
        }
        return new SoqlCondition(soql+')');
    }

    /**
     * Creates an OR condition by combining a list of child conditions.
     * @param conditions  list of conditions to combine with OR
     * @return  an OR condition
     */
    public static SoqlCondition getOr(List<SoqlCondition> conditions) {
        String soql = '(';
        String sep = '';
        for (SoqlCondition condition: conditions) {
            soql += sep + condition.toString();
            sep = ' OR ';
        }
        return new SoqlCondition(soql+')');
    }

    /**
     * Creates an AND condition by combining child conditions.
     * @param c1  a condition to include in the AND
     * @param c2  a condition to include in the AND
     * @return  an AND condition
     */
    public static SoqlCondition getAnd(SoqlCondition c1, SoqlCondition c2) {
        return getAnd(new List<SoqlCondition> { c1, c2 });
    }

    /**
     * Creates an AND condition by combining child conditions.
     * @param c1  a condition to include in the AND
     * @param c2  a condition to include in the AND
     * @param c3  a condition to include in the AND
     * @return  an AND condition
     */
    public static SoqlCondition getAnd(SoqlCondition c1, SoqlCondition c2, SoqlCondition c3) {
        return getAnd(new List<SoqlCondition> { c1, c2, c3 });
    }
	
	/**
     * Creates an AND condition by combining child conditions.
     * @param c1  a condition to include in the AND
     * @param c2  a condition to include in the AND
     * @param c3  a condition to include in the AND
	 * @param c4  a condition to include in the AND
     * @return  an AND condition
     */
    public static SoqlCondition getAnd(SoqlCondition c1, SoqlCondition c2, SoqlCondition c3, SoqlCondition c4) {
        return getAnd(new List<SoqlCondition> { c1, c2, c3, c4 });
    }

    /**
     * Creates an OR condition by combining child conditions.
     * @param c1  a condition to include in the OR
     * @param c2  a condition to include in the OR
     * @return  an OR condition
     */
    public static SoqlCondition getOr(SoqlCondition c1, SoqlCondition c2) {
        return getOr(new List<SoqlCondition> { c1, c2 });
    }

    /**
     * Creates an OR condition by combining child conditions.
     * @param c1  a condition to include in the OR
     * @param c2  a condition to include in the OR
     * @param c3  a condition to include in the OR
     * @return  an OR condition
     */
    public static SoqlCondition getOr(SoqlCondition c1, SoqlCondition c2, SoqlCondition c3) {
        return getOr(new List<SoqlCondition> { c1, c2, c3 });
    }

    /**
     * Creates a less-than condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  a less-than condition
     */
    public static SoqlCondition getLt(String field, Datetime dt) {
        return new SoqlCondition(field + ' < ' + fmtDatetime(dt));
    }

    /**
     * Creates a greater-than condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  a greater-than condition
     */
    public static SoqlCondition getGt(String field, Datetime dt) {
        return new SoqlCondition(field + ' > ' + fmtDatetime(dt));
    }

    /**
     * Creates a less-than or equal condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  a less-than or equal condition
     */
    public static SoqlCondition getLe(String field, Datetime dt) {
        return new SoqlCondition(field + ' <= ' + fmtDatetime(dt));
    }

    /**
     * Creates a greater-than or equal condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  a greater-than or equal condition
     */
    public static SoqlCondition getGe(String field, Datetime dt) {
        return new SoqlCondition(field + ' >= ' + fmtDatetime(dt));
    }

    /**
     * Creates a less-than or equal condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  a less-than or equal condition
     */
    public static SoqlCondition getDateLe(String field, DateTime dt) {
        return new SoqlCondition(field + ' <= ' + fmtDate(dt));
    }

    /**
     * Creates a greater-than or equal condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  a greater-than or equal condition
     */
    public static SoqlCondition getDateGt(String field, DateTime dt) {
        return new SoqlCondition(field + ' > ' + fmtDate(dt));
    }

    /**
     * Creates a greater-than or equal condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  a greater-than or equal condition
     */
    public static SoqlCondition getDateGe(String field, DateTime dt) {
        return new SoqlCondition(field + ' >= ' + fmtDate(dt));
    }

    /**
     * Creates an equality condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  an equality condition
     */
    public static SoqlCondition getEq(String field, Datetime dt) {
        return new SoqlCondition(field + ' = ' + fmtDatetime(dt));
    }

    /**
     * Creates an inequality condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  an inequality condition
     */
    public static SoqlCondition getNotEq(String field, Datetime dt) {
        return new SoqlCondition(field + ' != ' + fmtDatetime(dt));
    }

    /**
     * Creates an equality condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  an equality condition
     */
    public static SoqlCondition getEq(String field, Boolean value) {
        return new SoqlCondition(field + ' = ' + String.valueOf(value));
    }

    /**
     * Creates an equality condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  an equality condition
     */
    public static SoqlCondition getEq(String field, String value) {
        return new SoqlCondition(field + ' = \'' + String.escapeSingleQuotes(value) + '\'');
    }

    /**
     * Creates an inequality condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  an inequality condition
     */
    public static SoqlCondition getNotEq(String field, Boolean value) {
        return new SoqlCondition(field + ' != ' + String.valueOf(value));
    }

    /**
     * Creates an inequality condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  an inequality condition
     */
    public static SoqlCondition getNotEq(String field, String value) {
        return new SoqlCondition(field + ' != \'' + String.escapeSingleQuotes(value) + '\'');
    }

    /**
     * Creates an order clause. By default the order applied to the field is ascending, with nulls first.
     * @param field  field to order the results by
     * @return  an order clause
     */
    public static SoqlOrder getOrder(String field) {
        return new SoqlOrder(field);
    }

    /**
     * Creates an IN condition to test if a field's value is contained by a subquery. The subquery must
     * abide by Salesforce's usual rules for semi-join subqueries (for example, the subquery must be querying
     * a primary or foreign key field).
     * @param field     field name to test in the condition
     * @param subquery  subquery to match field values in
     * @return  an IN condition
     */
    public static SoqlCondition getIn(String field, SoqlQuery subquery) {
    	return new SoqlCondition(field + ' IN (' + subquery.toString() + ')');
    }

    /**
     * Creates an IN condition to test if a field's value is contained by a Set.
     * @param field   field name to test in the condition
     * @param values  set to match field values in
     * @return  an IN condition
     */
    public static SoqlCondition getIn(String field, Set<String> values) {
        return getIn(field, new List<String>(values));
    }

    /**
     * Creates an IN condition to test if a field's value is contained by a List.
     * @param field   field name to test in the condition
     * @param values  list to match field values in
     * @return  an IN condition
     */
    public static SoqlCondition getIn(String field, List<String> values) {
    	String sep = '';
    	String escaped = '';
    	for (String value: values) {
    		escaped += sep + '\'' + String.escapeSingleQuotes(value) + '\'';
    		sep = ', ';
    	}
    	return new SoqlCondition(field + ' IN (' + escaped + ')');
    }

    /**
     * Creates an IN condition to test if a field's value is contained by a Set.
     * @param field   field name to test in the condition
     * @param values  set to match field values in
     * @return  an IN condition
     */
    public static SoqlCondition getIn(String field, Set<Id> values) {
        return getIn(field, new List<Id>(values));
    }

    /**
     * Creates an IN condition to test if a field's value is contained by a List.
     * @param field   field name to test in the condition
     * @param values  list to match field values in
     * @return  an IN condition
     */
    public static SoqlCondition getIn(String field, List<Id> values) {
        return getIn(field, idsToStrings(values));
    }

    /**
     * Creates a NOT IN condition to test if a field's value is contained by a subquery. The subquery must
     * abide by Salesforce's usual rules for semi-join subqueries (for example, the subquery must be querying
     * a primary or foreign key field).
     * @param field     field name to test in the condition
     * @param subquery  subquery to exclude field values from
     * @return  an NOT IN condition
     */
    public static SoqlCondition getNotIn(String field, SoqlQuery subquery) {
        return new SoqlCondition(field + ' NOT IN (' + subquery.toString() + ')');
    }

    /**
     * Creates a NOT IN condition to test if a field's value is not contained by a List.
     * @param field   field name to test in the condition
     * @param values  list to exclude field values from
     * @return  an NOT IN condition
     */
    public static SoqlCondition getNotIn(String field, List<String> values) {
        String sep = '';
        String escaped = '';
        for (String value: values) {
            escaped += sep + '\'' + String.escapeSingleQuotes(value) + '\'';
            sep = ', ';
        }
        return new SoqlCondition(field + ' NOT IN (' + escaped + ')');
    }

    /**
     * Creates a NOT IN condition to test if a field's value is not contained by a Set.
     * @param field   field name to test in the condition
     * @param values  set to exclude field values from
     * @return  an NOT IN condition
     */
    public static SoqlCondition getNotIn(String field, Set<String> values) {
        return getNotIn(field, new List<String>(values));
    }

    /**
     * Creates a NOT IN condition to test if a field's value is not contained by a List.
     * @param field   field name to test in the condition
     * @param values  list to exclude field values from
     * @return  an NOT IN condition
     */
    public static SoqlCondition getNotIn(String field, List<Id> values) {
        return getNotIn(field, idsToStrings(values));
    }

    /**
     * Creates a NOT IN condition to test if a field's value is not contained by a Set.
     * @param field   field name to test in the condition
     * @param values  set to exclude field values from
     * @return  an NOT IN condition
     */
    public static SoqlCondition getNotIn(String field, Set<Id> values) {
        return getNotIn(field, new List<Id>(values));
    }

    /**
     * Creates a condition to test if a field's value is null
     * @param field   field name to test in the condition
     * @return  an "is null" condition
     */
    public static SoqlCondition getNull(String field) {
        return new SoqlCondition(field + ' = null');
    }

    /**
     * Creates a condition to test if a field's value is NOT null
     * @param field   field name to test in the condition
     * @return  an "is not null" condition
     */
    public static SoqlCondition getNotNull(String field) {
        return new SoqlCondition(field + ' != null');
    }

    /**
     * Creates a condition to test if a datetime is between the values of two fields.
     * @param dt          Datetime to test if between the fields
     * @param startField  field containing the start date for the range (inclusive)
     * @param endField    field containing the end date for the range (exclusive)
     * @return a condition to verify that dt is between startField and endField
     */
    public static SoqlCondition getBetween(Datetime dt, String startField, String endField) {
        SoqlCondition startIsNotNull = getNotNull(startField);
        SoqlCondition endIsNull = getNull(endField);
        SoqlCondition dateIsAfterStart = getLe(startField, dt);
        SoqlCondition dateIsBeforeEnd = getGt(endField, dt);

        SoqlCondition validStart = getAnd(startIsNotNull, dateIsAfterStart);
        SoqlCondition validEnd = getOr(endIsNull, dateIsBeforeEnd);

        return getAnd(validStart, validEnd);
    }

    /**
     * Creates a condition to test if a datetime is between the values of two fields.
     * @param dt          Date to test if between the fields
     * @param startField  field containing the start date for the range (inclusive)
     * @param endField    field containing the end date for the range (exclusive)
     * @return a condition to verify that dt is between startField and endField
     */
    public static SoqlCondition getDateBetween(DateTime dt, String startField, String endField) {
        SoqlCondition startIsNotNull = getNotNull(startField);
        SoqlCondition endIsNull = getNull(endField);
        SoqlCondition dateIsAfterStart = getDateLe(startField, dt);
        SoqlCondition dateIsBeforeEnd = getDateGt(endField, dt);


        SoqlCondition validStart = getAnd(startIsNotNull, dateIsAfterStart);
        SoqlCondition validEnd = getOr(endIsNull, dateIsBeforeEnd);

        return getAnd(validStart, validEnd);
    }

    /**
     * Creates a condition to test if a datetime is between the values of two fields.
     * @param dt          Date to test if between the fields
     * @param startField  field containing the start date for the range (inclusive)
     * @param endField    field containing the end date for the range (exclusive)
     * @return a condition to verify that dt is between startField and endField
     */
    public static SoqlCondition getDateBetweenInclusiveOnEnd(DateTime dt, String startField, String endField) {
        SoqlCondition startIsNotNull = getNotNull(startField);
        SoqlCondition endIsNull = getNull(endField);
        SoqlCondition dateIsAfterStart = getDateLe(startField, dt);
        SoqlCondition dateIsBeforeEnd = getDateGe(endField, dt);


        SoqlCondition validStart = getAnd(startIsNotNull, dateIsAfterStart);
        SoqlCondition validEnd = getOr(endIsNull, dateIsBeforeEnd);

        return getAnd(validStart, validEnd);
    }

    /**
     * Creates a condition to test if a datetime is between the values of two fields.
     * @param dt             Datetime to test if between the fields
     * @param productStart   field containing the start date for the range (inclusive)
     * @param productEnd     field containing the end date for the range (exclusive)
     * @param templateStart  field containing the start date to use if productStartField is empty
     * @param templateEnd    field containing the end date to use if productEndField is empty
     * @return a condition to verify that dt is between the start and end dates
     */
    public static SoqlCondition getBetween(Datetime dt, String productStart, String productEnd, String templateStart, String templateEnd) {
        SoqlCondition validStart = getOr(
                getAnd(
                    getNotNull(productStart),
                    getLe(productStart, dt)),
                getAnd(
                    getNull(productStart),
                    getNotNull(templateStart),
                    getLe(templateStart, dt)));

        SoqlCondition validEnd = getOr(
                getAnd(
                    getNull(productEnd),
                    getNull(templateEnd)),
                getAnd(
                    getNotNull(productEnd),
                    getGt(productEnd, dt)),
                getAnd(
                    getNull(productEnd),
                    getNotNull(templateEnd),
                    getGt(templateEnd, dt)));

        return getAnd(validStart, validEnd);
    }

    /**
     * Finds a list of all fields in lowercase for the given object that can be created.
     * Use the SObjectType version of this method where possible, since it does not
     * require a global describe.
     * @param objectName  name of SObject to find fields in
     * @return list of creatable fields in the object
     */
    public static List<String> getCreatableFields(String objectName) {
        return getCreatableFields(Schema.getGlobalDescribe().get(objectName.toLowerCase()));
    }

    public static List<String> getCloneableFields(String objectName) {
        return getCloneableFields(Schema.getGlobalDescribe().get(objectName.toLowerCase()));
    }

    /**
     * Finds a list of all fields in lowercase for the given object that can be created.
     * @param type  type of SObject to find fields in
     * @return list of creatable fields in the object
     */
    public static List<String> getCreatableFields(Schema.SObjectType type) {
        Map<String,Schema.SObjectField> fieldMap = type.getDescribe().fields.getMap();
        List<String> creatableFields = new List<String>();
             
        for (Schema.SObjectField ft: fieldMap.values()) {
            Schema.DescribeFieldResult fd = ft.getDescribe();
            if (fd.isCreateable()) {
                creatableFields.add(fd.getName().toLowerCase());
            }
        }
             
        return creatableFields;
    }

    public static List<String> excludeFields(List<String> fields, List<String> toExclude) {
        Set<String> fieldSet = new Set<String>(lcList(fields));
        fieldSet.removeAll(lcList(toExclude));
        return new List<String>(fieldSet);
    }

    /**
     * Converts this object to a dynamic SOQL statement for the whole object, includes only creatable fields
     * @param objectName    name of object to select from
     * @param whereClause   condition to restrict results to
     * @param excludeField  name of a field to exclude from the results
     * @return the SOQL String for selecting the object for clone
     */
    public static string getCreatableFieldsSOQL(String objectName, SoqlCondition whereClause, String excludeField){
        Set<String> fieldSet = new Set<String>(getCreatableFields(objectName));
        if (String.isNotBlank(excludeField)) {
            fieldSet.remove(excludeField.toLowerCase());
        }
        List<String> fields = new List<String>(fieldSet);
             
        return getSelect(fields, objectName).withCondition(whereClause).toString();
    }

    public static string getCloneableFieldsSOQL(String objectName, SoqlCondition whereClause, String excludeField){
        Set<String> fieldSet = new Set<String>(getCloneableFields(objectName));
        if (String.isNotBlank(excludeField)) {
            fieldSet.remove(excludeField.toLowerCase());
        }
        List<String> fields = new List<String>(fieldSet);
             
        return getSelect(fields, objectName).withCondition(whereClause).toString();
    }

    public static string getCloneableFieldsSOQL(String objectName, SoqlCondition whereClause, List<String> excludeFields){
        Set<String> fieldSet = new Set<String>(getCloneableFields(objectName));
        for (String excludeField: excludeFields) {
            fieldSet.remove(excludeField.toLowerCase());
        }
        List<String> fields = new List<String>(fieldSet);
             
        return getSelect(fields, objectName).withCondition(whereClause).toString();
    }

     /**
     * Finds a list of all fields in lowercase for the given object that can be created.
     * @param type  type of SObject to find fields in
     * @param dataTypes  array of datatypes for fields to exclude
     * @return list of creatable fields in the object that are not of the datatype specified
     */
    public static List<String> getCreatableFieldsMinusDataType(String ObjectName, List<String> exDataTypes) {
        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().fields.getMap();
        List<String> creatableFields = new List<String>();
        
        for (Schema.SObjectField ft: fieldMap.values()) {
            Schema.DescribeFieldResult fd = ft.getDescribe();
            if (fd.isCreateable()) {
                /** field is creatable - now see if it is a type we want to exclude */
                Boolean createfield = true;
                for (Integer i = 0; i < exDataTypes.size(); i++) {
                    if (fd.getType().Name() == exDataTypes[i])
                    {
                        createfield = false;
                        break;
                    }
                }
                if (createfield) {
                    creatableFields.add(fd.getName().toLowerCase());
                }
            }
        }
        return creatableFields;
    }

    /**
     * Converts this object to a dynamic SOQL statement for the whole object, includes only creatable fields that are not a specified data type
     * @param objectName    name of object to select from
     * @param whereClause   condition to restrict results to
     * @param excludeField  name of a field to exclude from the results
     * @param excludeDataTypes array of the data type fields to exclude (e.g. DATE, DATETIME, PICKLIST, etc)
     * @return the SOQL String for selecting the object for clone
     */
    public static string getCreatableFieldsExcludeDataTypeSOQL(String objectName, SoqlCondition whereClause, String excludeField, List<String> excludeDataTypes){
        //Set<String> fieldSet = new Set<String>(getCreatableFieldsMinusDataType(objectName, excludeDataTypes));
        Set<String> fieldSet = new Set<String>(getCreatableFieldsMinusDataType(objectName, excludeDataTypes));
        if (String.isNotBlank(excludeField)) {
            fieldSet.remove(excludeField.toLowerCase());
        }
        List<String> fields = new List<String>(fieldSet);
             
        return getSelect(fields, objectName).withCondition(whereClause).toString();
    }

    /**
     * Provides methods to generate dynamic SOQL queries using an object-oriented Builder pattern
     * inspired by the Hibernate criteria API. A SoqlQuery can't be instantiated directly, but can
     * be created using the factory method <code>SoqlUtils.getSelect(...)</code>.
     * @author brendan.conniff
     * @see SoqlUtils.getSelect
     */
    public virtual class SoqlQuery {
        private final String q;
        private SoqlCondition whereClause;
        private SoqlOrder orderClause;
        private Integer limitValue;
        private Integer offsetValue;

        private SoqlQuery(String q) {
            this.q = q;
        }

        /**
         * Sets the WHERE clause of this query to check for the given condition.
         * @param whereClause  condition to use in WHERE clause for this query
         * @return this SoqlQuery
         */
        public SoqlQuery withCondition(SoqlCondition whereClause) {
            this.whereClause = whereClause;
            return this;
        }

        /**
         * Sets the ORDER BY clause of this query to the given order.
         * @param orderClause  order to use in the ORDER BY clause for this query
         * @return this SoqlQuery
         */
        public SoqlQuery withOrder(SoqlOrder orderClause) {
            this.orderClause = orderClause;
            return this;
        }

        /**
         * Sets the LIMIT value of this query to the given number.
         * @param limitValue  value of the LIMIT clause to use for this query
         * @return this SoqlQuery
         */
        public SoqlQuery withLimit(Integer limitValue) {
            this.limitValue = limitValue;
            return this;
        }

        /**
         * Sets the OFFSET value of this query to the given number.
         * @param offsetValue  value of the OFFSET clause to use for this query
         * @return this SoqlQuery
         */
        public SoqlQuery withOffset(Integer offsetValue) {
            this.offsetValue = offsetValue;
            return this;
        }

        /**
         * Retrieves the SOQL for this query as a String, suitible for passing to <code>Database.query(...)</code>.
         * @return the SOQL String for this query.
         */
        public virtual override String toString() {
            String soql = q;
            soql += (whereClause == null ? '' : ' WHERE '+whereClause.toString());
            soql += (orderClause == null ? '' : ' ORDER BY '+orderClause.toString());
            soql += (limitValue == null ? '' : ' LIMIT '+limitValue);
            soql += (offsetValue == null ? '' : ' OFFSET '+offsetValue);
            return soql;
        }
    }

    public class SoqlRelationshipQuery extends SoqlQuery {
        public SoqlRelationshipQuery(String q) {
            super(q);
        }

        public override String toString() {
            return '(' + super.toString() + ')';
        }
    }
    
    /**
     * Represents a condition which may be used as part of a SOQL WHERE clause. A SoqlCondition can't be
     * instantiated directly, but can be created using any of the factory methods in SoqlUtils with a return
     * type of SoqlCondition.
     * @author brendan.conniff
     */
    public class SoqlCondition {
        private final String q;

        private SoqlCondition(String q) {
            this.q = q;
        }

        /**
         * Converts this condition to the SOQL String it represents.
         * This should not be used directly, as it will not generate a full, valid query.
         * @return the SOQL String for this condition
         */
        public override String toString() {
            return q;
        }
    }

    /**
     * Represents an ordering which may be used as part of a SOQL ORDER BY clause. A SoqlOrder can't be
     * instantiated directly, but can be created using the factory method <code>SoqlUtils.getOrder(...)</code>.
     * @author brendan.conniff
     */
    public class SoqlOrder {
        private final String q;
        private boolean isAsc = true;
        private boolean isNullsFirst = true;
        private SoqlOrder nextOrder;

        private SoqlOrder firstOrder {
            get {
                return firstOrder == null ? this : firstOrder;
            }
            set;
        }

        private SoqlOrder(String q) {
            this.q = q;
        }

        private SoqlOrder(SoqlOrder firstOrder, String q) {
            this.firstOrder = firstOrder;
            this.q = q;
        }

        /**
         * Sets this order to be ascending.
         * @return this SoqlOrder
         */
        public SoqlOrder ascending() {
            this.isAsc = true;
            return this;
        }

        /**
         * Sets this order to be descending.
         * @return this SoqlOrder
         */
        public SoqlOrder descending() {
            this.isAsc = false;
            return this;
        }

        /**
         * Sets this order to return null values first.
         * @return this SoqlOrder
         */
        public SoqlOrder withNullsFirst() {
            this.isNullsFirst = true;
            return this;
        }

        /**
         * Sets this order to return null values last.
         * @return this SoqlOrder
         */
        public SoqlOrder withNullsLast() {
            this.isNullsFirst = false;
            return this;
        }

        /**
         * Adds another field to order by after this.
         * @param next  name of next field to order by
         * @return next SoqlOrder
         */
        public SoqlOrder thenBy(String next) {
            SoqlOrder nextOrder = new SoqlOrder(firstOrder, next);
            this.nextOrder = nextOrder;
            return nextOrder;
        }

        private String chainToString() {
            String soql = q;
            soql += (isAsc ? ' ASC' : ' DESC');
            soql += (isNullsFirst ? ' NULLS FIRST' : ' NULLS LAST');

            if (nextOrder != null) {
                soql += ', ' + nextOrder.chainToString();
            }

            return soql;
        }

        /**
         * Converts this order to the SOQL String it represents.
         * This should not be used directly, as it will not generate a full, valid query.
         * @return the SOQL String for this order
         */
        public override String toString() {
            return this == firstOrder
                ? chainToString()
                : firstOrder.toString();
        }
    }

    private static List<String> lcList(List<String> inputList) {
        List<String> outputList = new List<String>();
        for (String inputStr: inputList) {
            outputList.add(inputStr.toLowerCase());
        }
        return outputList;
    }
}