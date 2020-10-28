/**
 * Created by mhoefer on 8/18/20.
 */
@IsTest
public with sharing class PersonAccountTest {

    @IsTest
    public static void testQuery() {
        Employee[] emps = [SELECT PersonAccount__c FROM Employee];
        System.debug(emps[0].PersonAccount__c);
    }
}
