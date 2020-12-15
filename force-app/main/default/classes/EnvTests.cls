/**
 * Provides important information about runtime environment
 * All this information is produced by methods, to avoid calling it every time we launch a transaction.
 */
@IsTest
private class EnvTests {
    @IsTest
    static void testBehavior() {
        System.debug('Is this a scratch org? ' + Env.isScratchOrg());
        System.debug('Instance is ' + Env.orgInfo().InstanceName);
        System.debug('Type is ' + Env.orgType());
    }
}
