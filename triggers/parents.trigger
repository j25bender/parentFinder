trigger parents on parent__c (after insert) {
  //this if statement is to protect against idiots of the future
  //check that a parent has been added to completion success
  if(Trigger.isAfter && Trigger.isInsert) {
    sendWelcomeEmails();
  }

  private String[] toAddresses() {
    String[] addresses = new String[] {};
//this for is similar to a forEach
//Trigger.new.forEach(parent { push the parent email into the addresses array })
    for(parent__c parent: Trigger.new) {
      addresses.add(parent.email__c);
    }
    return addresses;
  }

  private void sendWelcomeEmails() {
    String[] toAddresses = toAddresses();
    String subject;
    String body;

    if(Trigger.size > 1) {
      subject = 'This is the subject for many';
      body = 'This is th body for many ';
    } else {
      subject = 'This is the subject for' + Trigger.new[0].name;
      body = 'This is the body for ' + Trigger.new[0].name;
    }
    EmailSender.sendemail(toAddresses, null, subject, body);
  }
}