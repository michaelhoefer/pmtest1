/**
 * Created by mhoefer on 11/9/20.
 */

@IsTest
private class PostInstallTests {
    @IsTest
    static void testBehavior() {
        System.Test.testInstall(new PostInstall(), null);
    }
}
