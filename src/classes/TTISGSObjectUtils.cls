/**
 * Provides some convenience methods for working with SObjects.
 * @author brendan.conniff
 */
public with sharing class TTISGSObjectUtils {
    /**
     * Retrieves a primitive field from an object at a given path. This supports dot notation, for example:
     * <code>
     * Id productId = (Id)SObjectUtils.getField(mySObject, 'Product_Bundle__r.Product__r.Id')/;
     * </code>
     *
     * @param sob   SObject to get field from
     * @param path  path of the field, in dot notation
     * @return primitive value of the field
     */
    public static Object getField(SObject sob, String path) {
        Integer i;
        while ((i = path.indexOf('.')) != -1) {
            if (sob == null) {
                return null;
            }
            String fieldName = path.substring(0, i);
            path = path.substring(i + 1);
            sob = sob.getSObject(fieldName);
        }
        return sob == null ? null : sob.get(path);
    }

    /**
     * Retrieves a SObject lookup field from an object at a given path. This supports dot notation, for example:
     * <code>
     * Product2 product = (Product2)SObjectUtils.getSObject(mySObject, 'Product_Bundle__r.Product__r');
     * </code>
     *
     * @param sob   SObject to get field from
     * @param path  path of the field, in dot notation
     * @return SObject value of the field
     */
    public static SObject getSObject(SObject sob, String path) {
        Integer i;
        while ((i = path.indexOf('.')) != -1) {
            if (sob == null) {
                return null;
            }
            String fieldName = path.substring(0, i);
            path = path.substring(i + 1);
            sob = sob.getSObject(fieldName);
        }
        return sob == null ? null : sob.getSObject(path);
    }

    /**
     * Accumulates a list of SObjects by a given field, then plucks IDs from another.
     * @param sobs             SObjects to accumulate and pluck IDs from
     * @param accumulateField  field to accumulate by
     * @param pluckField       field to pluck IDs from
     * @return map of accumulated field values to a list of plucked IDs from the matching SObjects
     */
    public static Map<Id,List<Id>> accumulateAndPluckIds(List<SObject> sobs, String accumulateField, String pluckField) {
        Map<Id,List<SObject>> sobMap = accumulate(sobs, accumulateField);
        Map<Id,List<Id>> result = new Map<Id,List<Id>>();
        for (Id i: sobMap.keySet()) {
            result.put(i, TTISGSObjectUtils.pluckIds(sobMap.get(i), pluckField));
        }
        return result;
    }

    /**
     * Groups SObjects into a map keyed by a given ID field value.
     * @param sobs  List of SObjects to group into a map
     * @param path  path of the ID field to key the map on
     * @return Map of the ID keys to the list of SObjects with that field value
     */
    public static Map<Id,List<SObject>> accumulate(List<SObject> sobs, String field) {
        Map<Id,List<SObject>> result = new Map<Id,List<SObject>>();
        for (SObject sob: sobs) {
            Id accumulateId = (Id)getField(sob, field);
            if (accumulateId != null) {
                if (!result.containsKey(accumulateId)) {
                    result.put(accumulateId, new List<SObject>());
                }
                result.get(accumulateId).add(sob);
            }
        }
        return result;
    }

    /**
     * Retrieves a list of SObject field values from a list of SObjects.
     * @param sobs   SObjects to pluck fields from
     * @param field  field path to return values from
     * @return list of field values
     */
    public static List<SObject> pluckSObjects(List<SObject> sobs, String field) {
        List<SObject> result = new List<SObject>();
        for (SObject sob: sobs) {
            result.add(getSObject(sob, field));
        }
        return result;
    }

    /**
     * Retrieves a list of ID field values from a list of SObjects.
     * @param sobs   SObjects to pluck fields from
     * @param field  field path to return values from
     * @return list of field values
     */
    public static List<Id> pluckIds(List<SObject> sobs, String field) {
        List<Id> result = new List<Id>();
        for (SObject sob: sobs) {
            result.add((Id)getField(sob, field));
        }
        return result;
    }

    private static Integer compareDecimal(Decimal a, Decimal b) {
        if (a > b) {
            return 1;
        }
        if (a < b) {
            return -1;
        }
        return 0;
    }

    private static Integer comparePrimitivesNonNull(Object a, Object b, Boolean isAsc) {
        if (a instanceof Decimal) {
            return compareDecimal((Decimal)a, (Decimal)b);
        } else if (a instanceof Datetime) {
            return compareDecimal(((Datetime)a).getTime(), ((Datetime)b).getTime());
        } else if (a instanceof Time) {
            Date today = Date.today();
            Datetime dtA = Datetime.newInstance(today, ((Time)a));
            Datetime dtB = Datetime.newInstance(today, ((Time)b));
            return compareDecimal(dtA.getTime(), dtB.getTime());
        } else if (a instanceof Boolean) {
            return (((Boolean)a) ? 1 : 0) - (((Boolean)b) ? 1 : 0);
        }

        return (isAsc ? 1 : -1) * String.valueOf(a).compareTo(String.valueOf(b));
    }

    private static Integer compareNull(Object a, Object b, Boolean isNullsFirst) {
        if (a == null && b == null) {
            return 0;
        } else if (a == null) {
            return isNullsFirst ? -1 : 1;
        } else if (b == null) {
            return isNullsFirst ? 1 : -1;
        }

        return 0;
    }

    /**
     * Compares two primitive values of the same type.
     * @param a             first value to compare
     * @param b             second value to compare
     * @param isAsc         if true, sort ascending, otherwise sort descending
     * @param isNullsFirst  if true, sort nulls first, otherwise sort nulls last
     * @return greater than 0 if a is sorted after b, less than 0 if a is sorted before b, or 0 if a is sorted equal to to b
     */
    public static Integer comparePrimitives(Object a, Object b, Boolean isAsc, Boolean isNullsFirst) {
        if (a == null || b == null) {
            return compareNull(a, b, isNullsFirst);
        }

        return comparePrimitivesNonNull(a, b, isAsc);
    }

    /**
     * Compares two primitive values of the same type. Sorts nulls first and in ascending order.
     * @param a             first value to compare
     * @param b             second value to compare
     * @return greater than 0 if a is sorted after b, less than 0 if a is sorted before b, or 0 if a is sorted equal to to b
     */
    public static Integer comparePrimitives(Object a, Object b) {
        return comparePrimitives(a, b, true, true);
    }

    /**
     * Compares two SObjects based on the given list of field values. This attempts to
     * replicate the behavior of an ORDER BY clause to allow similar sorting within apex code.
     * @param a             first SObject to compare
     * @param b             second SObject to compare
     * @param fieldNames    list of field names in order to sort by
     * @param isAsc         if true, sort ascending, otherwise sort descending
     * @param isNullsFirst  if true, sort nulls first, otherwise sort nulls last
     * @return greater than 0 if a is sorted after b, less than 0 if a is sorted before b, or 0 if a is sorted equal to to b
     */
    public static Integer compare(SObject a, SObject b, List<String> fieldNames, Boolean isAsc, Boolean isNullsFirst) {
        if (a == null || b == null) {
            return compareNull(a, b, isNullsFirst);
        }

        for (String fieldName: fieldNames) {
            Object fieldA = getField(a, fieldName);
            Object fieldB = getField(b, fieldName);

            Integer val = comparePrimitives(fieldA, fieldB, isAsc, isNullsFirst);

            System.debug('compare '+fieldName+': '+fieldA+' - '+fieldB+' = '+val);

            if (val != 0) {
                return val;
            }
        }

        return 0;
    }

    /**
     * Compares two SObjects based on the given list of field values. This attempts to
     * replicate the behavior of an ORDER BY clause to allow similar sorting within apex code.
     * Sorts nulls first and in ascending order.
     * @param a             first SObject to compare
     * @param b             second SObject to compare
     * @param fieldNames    list of field names in order to sort by
     * @return greater than 0 if a is sorted after b, less than 0 if a is sorted before b, or 0 if a is sorted equal to to b
     */
    public static Integer compare(SObject a, SObject b, List<String> fieldNames) {
        return compare(a, b, fieldNames, true, true);
    }

    /**
     * Wraps a SObject instance to implement Comparable and allow sorting.
     * @author brendan.conniff
     */
    private class SObjectWrapper implements Comparable {
        /** SObject represented by this instance */
        public SObject sob { get; set; }

        private final List<String> fieldNames;
        private final Boolean isAsc;
        private final Boolean isNullsFirst;

        /**
         * @param sob           SObject to wrap
         * @param fieldNames    names of fields to sort by in order
         * @param isAsc         if true, sort ascending, otherwise sort descending
         * @param isNullsFirst  if true, sort nulls first, otherwise sort nulls last
         */
        public SObjectWrapper(SObject sob, List<String> fieldNames, Boolean isAsc, Boolean isNullsFirst) {
            this.sob = sob;
            this.fieldNames = fieldNames;
            this.isAsc = isAsc;
            this.isNullsFirst = isNullsFirst;
        }

        /**
         * Compare this SObject to another
         * @param o  other SObject instance
         * @return greater than 0 if this is greater than o, less than 0 if this is less than o, or 0 if this == o
         */
        public Integer compareTo(Object o) {
            SObjectWrapper that = (SObjectWrapper)o;
            return compare(this.sob, that.sob, fieldNames);
        }
    }

    /**
     * Sorts a list of SObjects by the given fields.
     * @param sobs          list of SObjects to sort
     * @param fieldNames    list of field names to sort by in order
     * @param isAsc         if true, sort ascending, otherwise sort descending
     * @param isNullsFirst  if true, sort nulls first, otherwise sort nulls last
     * @return sorted list of SObjects
     */
    public static List<SObject> sort(List<SObject> sobs, List<String> fieldNames, Boolean isAsc, Boolean isNullsFirst) {
        List<SObjectWrapper> sobWrappers = new List<SObjectWrapper>();
        for (SObject sob: sobs) {
            sobWrappers.add(new SObjectWrapper(sob, fieldNames, isAsc, isNullsFirst));
        }

        sobWrappers.sort();

        List<SObject> result = new List<SObject>();
        for (SObjectWrapper sobWrapper: sobWrappers) {
            result.add(sobWrapper.sob);
        }

        return result;
    }

    /**
     * Sorts a list of SObjects by the given fields. Sorts nulls first and in ascending order.
     * @param sobs          list of SObjects to sort
     * @param fieldNames    list of field names to sort by in order
     * @return sorted list of SObjects
     */
    public static List<SObject> sort(List<SObject> sobs, List<String> fieldNames) {
        return sort(sobs, fieldNames, true, true);
    }

    /**
     * Removes SObjects with duplicate ID values from a list of SObjects.
     * @param sobs       list of SObjects to remove duplicates from
     * @param fieldName  name of ID field
     * @return list of SObjects with duplicates removed
     */
    public static List<SObject> removeDuplicates(List<SObject> sobs, String fieldName) {
        Set<Id> ids = new Set<Id>();
        List<SObject> results = new List<SObject>();
        for (SObject sob: sobs) {
            Id i = (Id)getField(sob, fieldName);
            if (!ids.contains(i)) {
                results.add(sob);
                ids.add(i);
            }
        }
        return results;
    }

    /**
     * Runs a SOQL query and accumulates the results by the given field name.
     * @param query      SOQL query to run
     * @param fieldName  name of field to accumulate by
     * @return map of accumulted field values to the SObjects which had that value
     */
    public static Map<Id,List<SObject>> queryAndAccumulate(TTISGSoqlUtils.SoqlQuery query, String fieldName) {
        Map<Id,List<SObject>> results = new Map<Id,List<SObject>>();
        for (List<SObject> sobs: Database.query(query.toString())) {
            Map<Id,List<SObject>> toMerge = TTISGSObjectUtils.accumulate(sobs, fieldName);

            for (Id mergeId: toMerge.keySet()) {
                if (results.containsKey(mergeId)) {
                    results.get(mergeId).addAll(toMerge.get(mergeId));
                } else {
                    results.put(mergeId, toMerge.get(mergeId));
                }
            }
        }
        return results;
    }

    /**
     * Combines two lists of SObjects by adding them together.
     * @param parentSobs  SObjects from the parent record
     * @param childSobs   SObjects from the child record
     * @param merged list of SObjects
     */
    public static List<SObject> combineAdditive(List<SObject> parentSobs, List<SObject> childSobs) {
        List<SObject> result = new List<SObject>();
        result.addAll(parentSobs);
        result.addAll(childSobs);
        return result;
    }

    /**
     * Combines two lists of SObjects by overwriting records from the parent with records from the child when the child
     * records are not empty.
     * @param parentSobs  SObjects from the parent record
     * @param childSobs   SObjects from the child record
     * @param childSobs if not empty, otherwise parentSobs
     */
    public static List<SObject> combineOverwrite(List<SObject> parentSobs, List<SObject> childSobs) {
        return childSobs.isEmpty() ? parentSobs : childSobs;
    }

    /**
     * Combines two lists of SObjects by overwriting records from the parent with records from the child when an ID field on the
     * child's SObject conflicts with an ID field on the parent SObject.
     * This is used to implement attribute value inheritance where parent attribute values are on only overwritten by a child
     * if the child has attribute values belonging to the same attribute.
     * @param parentSobs  SObjects from the parent record
     * @param childSobs   SObjects from the child record
     * @param childSobs if not empty, otherwise parentSobs
     */
    public static List<SObject> combineOverwriteById(List<SObject> parentSobs, List<SObject> childSobs, String fieldName) {
        Map<Id,List<SObject>> parentSobsByField = TTISGSObjectUtils.accumulate(parentSobs, fieldName);
        Map<Id,List<SObject>> childSobsByField = TTISGSObjectUtils.accumulate(childSobs, fieldName);

        for (Id childField: childSobsByField.keySet()) {
            parentSobsByField.put(childField, childSobsByField.get(childField));
        }

        return flatten(parentSobsByField.values());
    }

    /**
     * Flattens a list of lists of SObjects.
     * @param xss  list of lists of SObjects.
     * @return flattened list of SObjects
     */
    public static List<SObject> flatten(List<List<SObject>> xss) {
        List<SObject> result = new List<SObject>();
        for (List<SObject> xs: xss) {
            result.addAll(xs);
        }
        return result;
    } 

    /**
     * Checks if the current time is between date fields on a SObject. Implements equivalent logic to TTISGSoqlUtils.getBetween(...).
     * @param sob         SObject to check
     * @param dt          datetime to use as current time
     * @param startField  field name containing start date
     * @param endField    field name containing end date
     * @return true if dt is between the start and end date, false otherwise
     */
    public static Boolean isBetween(SObject sob, Datetime dt, String startField, String endField) {
        Datetime startDt = (Datetime)TTISGSObjectUtils.getField(sob, startField);
        Datetime endDt = (Datetime)TTISGSObjectUtils.getField(sob, endField);

        return isBetween(dt, startDt, endDt);
    }

    /**
     * Checks if a datetime is between a start and end date. Implements equivalent logic to TTISGSoqlUtils.getBetween(...).
     * @param dt       datetime to use as current time
     * @param startDt  datetime containing start date
     * @param endDt    datetime containing end date
     * @return true if dt is between the start and end date, false otherwise
     */
    public static Boolean isBetween(Datetime dt, Datetime startDt, Datetime endDt) {
        return (startDt != null && startDt <= dt) && (endDt == null || endDt > dt);
    }

}