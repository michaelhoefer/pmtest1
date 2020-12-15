/**
 * Provides important information about runtime environment
 * All this information is produced by methods, to avoid calling it every time we launch a transaction.
 */
public class Env {

    @TestVisible
    private static Organization cachedOrg = null;

    /**
     * Retrieves information about Org
     * Currently just two fields are included; feel free to add more.
     */
    public static Organization orgInfo() {
        if (cachedOrg == null) {
            cachedOrg = [SELECT OrganizationType, InstanceName, IsSandBox FROM Organization];
        }
        return cachedOrg;
    }

    /**
     * Retrieves org type, can be Enterprise, Developer, Unlimited, Performance
     */
    public static String orgType() {
        return (String) orgInfo().get('OrganizationType');
    }

    /**
     * Retrieves a flag which is true iff we are in a scratch org
     */
    public static Boolean isScratchOrg() {
        return (Boolean) orgInfo().get('IsSandBox');
    }

    /**
     * Namespace in current org
     */
    public final static String NameSpace = Env.class.getName().substringBefore('Env').removeEnd('.');
}
