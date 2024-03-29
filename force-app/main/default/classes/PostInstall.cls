/**
 * Created by mhoefer on 11/9/20.
 */

public without sharing class PostInstall implements InstallHandler {
    public void onInstall(InstallContext context) {
        List<Employee> emps = [SELECT Id FROM Employee];
        System.debug(LoggingLevel.DEBUG, emps);

        List<Schema.Location> locs = [SELECT Id FROM Location];
        System.debug(LoggingLevel.DEBUG, locs);
        
        List<Account> accs = [SELECT Id FROM Account];
        System.debug(LoggingLevel.DEBUG, accs);
    }
}
