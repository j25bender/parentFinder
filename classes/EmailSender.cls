public class EmailSender {
    public static void sendemail(String[] toAddresses, String[] ccAddresses, String subject, String body) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    mail.setToAddresses(toAddresses);
		mail.setCcAddresses(ccAddresses);

    mail.setSubject(subject);

    mail.setPlainTextBody(body);
		mail.setHtmlBody(body);

    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}