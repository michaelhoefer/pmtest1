// @todo: namespace testing. If this code is namespaced, how does it work when un-namespaced names are passed in?
/**
 * DescribeCache - caches describes in the transaction
 *
 * Requires 'without sharing'.  This is used in post-install, and because statics are involved we cannot trust
 * inherited sharing, as this class could be loaded prior to the caller, resulting in sharing being enforced
 * unintentionally. See W-8767869.
 */
public without sharing class DescribeCache {
    private static final Map<Schema.SObjectType, DescribeCache> CACHE = new Map<Schema.SObjectType, DescribeCache>();

    public Schema.SObjectType objectToken { get; private set; }
    public Schema.DescribeSObjectResult objectDescribe { get; private set; }
    public String objectName {
        get {
            if (objectName == null) {
                objectName = String.valueOf(this.objectToken);
            }
            return objectName;
        }
        private set;
    }

    private DescribeCache(Schema.SObjectType sot) {
        this.objectToken = sot;
        this.objectDescribe = sot.getDescribe();
    }


    public static DescribeCache getDescribeCache(String objectName) {
        Schema.SObjectType sot;
        //Runtime error if Location is passed due to System namespace: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_system_Location.htm
        if (objectName == 'Location') {
            sot = Schema.Location.getSObjectType();
            //Runtime error if Network is passed due to System namespace: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_network.htm#apex_classes_network
        } else if (objectName == 'Network') {
            sot = Schema.Network.getSObjectType();
        } else {
            Type candidateObjectType = Type.forName(objectName);

            if (SObject.class.isAssignableFrom(candidateObjectType)) {
                sot = ((SObject) Type.forName(objectName).newInstance()).getSObjectType(); // this is faster than describeSObject/globalDescribe
            }
        }

        return getDescribeCache(sot);
    }

    public static DescribeCache getDescribeCache(Schema.SObjectType objectType) {
        if (objectType != null && !CACHE.containsKey(objectType)) {
            CACHE.put(objectType, new DescribeCache(objectType));
        }
        return CACHE.get(objectType);
    }
}
