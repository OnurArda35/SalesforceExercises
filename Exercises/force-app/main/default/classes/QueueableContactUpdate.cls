public class QueueableContactUpdate implements Queueable {
    private Set<Id> primaryAccountIds;
    private Set<Id> nonPrimaryAccountIds;

    public QueueableContactUpdate(Set<Id> primaryAccountIds, Set<Id> nonPrimaryAccountIds) {
        this.primaryAccountIds = primaryAccountIds;
        this.nonPrimaryAccountIds = nonPrimaryAccountIds;
    }

    public void execute(QueueableContext context) {
        updateContacts(primaryAccountIds);
        updateContacts(nonPrimaryAccountIds);
    }

    @future
    public static void updateContacts(Set<Id> accountIds) {
        List<Contact> allContactsToUpdate = new List<Contact>();

        for (Id accId : accountIds) {
            List<Contact> primaryContactPhone = [SELECT Phone FROM Contact WHERE AccountId = :accId AND Level__c = 'Primary' LIMIT 1];

            // Query for all contacts related to the same account
            List<Contact> allContacts = [SELECT Id FROM Contact WHERE AccountId = :accId AND Level__c != 'Primary'];

            // Update the Primary_Contact_Phone__c field for each contact
            for (Contact con : allContacts) {
                con.Primary_Contact_Phone__c = primaryContactPhone.isEmpty() ? null : primaryContactPhone[0].Phone;
                allContactsToUpdate.add(con);
            }
            Account acc = [SELECT Id,Phone FROM Account WHERE Id = :accId ];
            acc.Phone = primaryContactPhone.isEmpty() ? null : primaryContactPhone[0].Phone;
            update acc;
        }

        // Update all contacts
        update allContactsToUpdate;
    }
}