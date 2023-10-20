trigger SetPrimaryContactPhoneTrigger on Contact (before insert, before update) {
    Set<Id> primaryAccountIds = new Set<Id>();
    Set<Id> nonPrimaryAccountIds = new Set<Id>();

    for (Contact con : Trigger.new) {
        if (con.Level__c == 'Primary') {
            primaryAccountIds.add(con.AccountId);
        } else {
            nonPrimaryAccountIds.add(con.AccountId);
        }
    }

    if (!primaryAccountIds.isEmpty() || !nonPrimaryAccountIds.isEmpty()) {
        System.enqueueJob(new QueueableContactUpdate(primaryAccountIds, nonPrimaryAccountIds));
    }
}