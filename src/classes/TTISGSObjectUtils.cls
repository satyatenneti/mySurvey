/**
 * Provides some convenience methods for working with SObjects.
 * @author brendan.conniff
 */
public with sharing class TTISGSObjectUtils {
    /**
     * Retrieves a primitive field from an object at a given path. 
     *
     * @param sob   SObject to get field from
     * @param path  path of the field
     * @return primitive value of the field
     */
    public static Object getField(SObject sob, String path) {
        return sob == null ? null : sob.get(path);
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

    
}