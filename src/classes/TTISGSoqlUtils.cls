public with sharing class TTISGSoqlUtils{

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
     * Provides methods to generate dynamic SOQL queries using an object-oriented Builder pattern
     * inspired by the Hibernate criteria API. A SoqlQuery can't be instantiated directly, but can
     * be created using the factory method <code>TTISGSoqlUtils.getSelect(...)</code>.
     * @author brendan.conniff
     * @see TTISGSoqlUtils.getSelect
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

        public virtual override String toString() {
            String soql = q;
            soql += (whereClause == null ? '' : ' WHERE '+whereClause.toString());
            soql += (orderClause == null ? '' : ' ORDER BY '+orderClause.toString());
            soql += (limitValue == null ? '' : ' LIMIT '+limitValue);
            soql += (offsetValue == null ? '' : ' OFFSET '+offsetValue);
            return soql;
        }
    }
    
    /**
     * Represents an ordering which may be used as part of a SOQL ORDER BY clause. A SoqlOrder can't be
     * instantiated directly, but can be created using the factory method <code>TTISGSoqlUtils.getOrder(...)</code>.
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
    
    /**
     * Creates an order clause. By default the order applied to the field is ascending, with nulls first.
     * @param field  field to order the results by
     * @return  an order clause
     */
    public static SoqlOrder getOrder(String field) {
        return new SoqlOrder(field);
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
     * Creates an equality condition.
     * @param field  field name to test in the comparison
     * @param value  value to compare the field to
     * @return  an equality condition
     */
    public static SoqlCondition getEq(String field, String value) {
        return new SoqlCondition(field + ' = \'' + String.escapeSingleQuotes(value) + '\'');
    }
    
    /**
     * Represents a condition which may be used as part of a SOQL WHERE clause. A SoqlCondition can't be
     * instantiated directly, but can be created using any of the factory methods in TTISGSoqlUtils with a return
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
    
    private static List<String> lcList(List<String> inputList) {
        List<String> outputList = new List<String>();
        for (String inputStr: inputList) {
            outputList.add(inputStr.toLowerCase());
        }
        return outputList;
    }
}