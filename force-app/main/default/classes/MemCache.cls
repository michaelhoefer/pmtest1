
public with sharing class MemCache {
    /**
     * Checking whether platform cache is allowed for this org,
     * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_platform_cache_limits.htm
     * Currently we are not using this method, but instead just try it.
     * This way we can use cache that our customers purchase later, without changing their org type - as Mike Hoefer suggested.
     */
    private static Boolean isCacheProvided() {
        switch on Env.orgType() {
            when 'Enterprise', 'Unlimited', 'Performance' {
                return true;
            }
            when else {
                return Env.IsScratchOrg();
            }
        }
    }

    @TestVisible
    private static boolean platformCacheEnabled = true;

    @TestVisible
    private static boolean platformCacheRequired = true;

    // TTL limits, see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_cache_Org.htm#apex_cache_Org_put_2
    public final static Integer MinTTL = 300; // 5 minutes
    public final static Integer MaxTTL = 86400; // 48 hours

    private final static String ClassName = MemCache.class.getName();

    /**
     * Cached record: data type, data value, expiration time (milliseconds)
     */
    @TestVisible
    private class Rec {
        private final Object value;
        private final Integer ttlSec;
        private Long expiresAt; // not final, because can be invalidated

        public Rec(Object value, Integer ttlSec) {
            this.value = value;
            this.ttlSec = Math.min(MemCache.MaxTTL, Math.max(MemCache.MinTTL, ttlSec));
            this.expiresAt = System.currentTimeMillis() + ttlSec * 1000;
        }

        public boolean isExpired() {
            return System.currentTimeMillis() > expiresAt;
        }

        public Object get() {
            return isExpired() ? null : value;
        }

        public void invalidate() {
            expiresAt = 0;
        }

        override public String toString() {
            return 'Rec(' + value + ', expires at ' + expiresAt + ')';
        }
    }

    interface Storage {
        Boolean test();
        Rec get(String key);
        void put(String key, Rec rec);
        void remove(String key);
    }

    private static Storage storage = null;

    static {
        if (platformCacheEnabled) {
            tryUsePlatform();
        }
    }

    @TestVisible
    static void tryUsePlatform() {
        try {
            storage = new PlatformCache();
            platformCacheEnabled = storage.test();
        } catch (Exception e) {
            if (platformCacheRequired) {
                throw new IllegalArgumentException(
                        'Required platform cache, but it\'s not available on ' + Env.orgType() + '.' + e);
            } else {
                useLocal();
            }
        }
    }

    @TestVisible
    static void useLocal() {
        platformCacheEnabled = false;
        storage = new LocalCache();
    }

    @TestVisible
    private static Rec getRec(String key) {
        return storage.get(key);
    }

    /**
     * Retrieve a value from org cache, or return null if expired
     * @param  key cache key
     * @return the object
     */
    public static Object get(String key) {
        try {
            Rec rec = getRec(key);
            return rec == null ? null : rec.get();
        } catch (Exception e) {
            MemCache.useLocal();
            return null;
        }
    }

    /**
     * Put a value into org cache
     * @param  key cache key
     * @param value cached value
     * @param ttlSec time to live, in seconds
     */
    public static void put(String key, Object value, Integer ttlSec) {
        try {
            storage.put(key, new Rec(value, ttlSec));
        } catch (Exception e) {
            MemCache.useLocal();
        }
    }

    /**
     * remove record at given key
     * Good for cache invalidation
     */
    public static void remove(String key) {
        storage.remove(key);
    }

    class PlatformCache implements Storage {

        public boolean test() {
            try {
                Rec sut = new Rec('test value', MinTTL);
                put('test key', sut);
                return get('test key') == sut;
            } catch (Exception e) {
                return false;
            }
        }

        public Rec get(String key) {
            return (Rec) Cache.Org.get(key);
        }

        public void put(String key, Rec rec) {
            Cache.Org.put(key, rec, rec.ttlSec);
        }

        public void remove(String key) {
            Cache.Org.remove(key);
        }
    }


    class LocalCache implements Storage {
        Map<String, Rec> memory = new Map<String, Rec>();

        public Boolean test() {
            return true;
        }

        public Rec get(String key) {
            return memory.get(key);
        }

        public void put(String key, Rec rec) {
            memory.put(key, rec);
        }

        public void remove(String key) {
            Rec rec = get(key);
            if (rec != null) {
                rec.invalidate();
                memory.remove(key);
            }
        }
    }
}
