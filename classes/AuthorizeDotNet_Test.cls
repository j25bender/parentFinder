@isTest
private class AuthorizeDotNet_Test {

	@testSetup static void setup() {
		child__c child = new child__c(Age__c = 8, Hair_Color__c = 'brown', Email__c = 'j25bender+3@gmail.com', Password__c = '123');
		insert child;
	}

	@isTest static void testInitialValues() {
		AuthorizeDotNet controller = new AuthorizeDotNet();

		SelectOption[] monthOptions = controller.getexpMonthOptions();
		for(Integer i = 0; i < monthOptions.size(); i++) {
			System.assertEquals(String.valueOf(i + 1), monthOptions[i].getLabel());
			System.assertEquals(String.valueOf(i + 1), monthOptions[i].getValue());
		}
	}

	@isTest static void testProcessPaymentSuccess() {
		// String body = '{{"transactionResponse": {"transId": "123", "accountType": "Mastercard", "messages": [{"description": "Approved"}]}, "errors": [{"errorText": ""}]}, "messages": {"resultCode": "Ok"}}';

		String result_code = 'Ok';
		String error_text = '';
		String transaction_id = '123';
		String successText = 'Approved';
 		String body = '{{"transactionResponse": {"transId": ' + transaction_id + ', "accountType": "Mastercard", "messages": [{"description": "' + successText + '"}], "errors": [{"errorText": "' + error_text + '"}]}, "Messages": {"resultCode": "' + result_code + '"}}';
		mockHttpResponse mockResponse = new mockHttpResponse(body);

		test.setMock(HttpCalloutMock.class, mockResponse);
		child__c child = [select id, transaction_info__c from child__c limit 1];
		System.assertEquals(null, child.transaction_info__c);
		System.assertEquals(0, [select count() from transaction_info__c]);

		test.startTest();
		AuthorizeDotNet controller = new AuthorizeDotNet();
		System.assertEquals('50', controller.amount);
		controller.record_id = child.id;
		controller.processPayment();


		transaction_info__c testTransaction = [select id, amount__c, credit_card__c, transaction_id__c from transaction_info__c limit 1];
		System.assertEquals(50, testTransaction.amount__c);
		System.assertEquals('Mastercard', testTransaction.credit_card__c);
		System.assertEquals('123', testTransaction.transaction_id__c);
		System.assertEquals('Approved', controller.authResponse);

		child = [select id, transaction_info__c from child__c limit 1];
		System.assertEquals(testTransaction.id, child.transaction_info__c);
		test.stopTest();
	}

	@isTest static void testProcessPaymentFailure() {
		// String body = '{{"transactionResponse": {"transId": "123", "accountType": "Mastercard", "messages": [{"description": "Approved"}]}, "errors": [{"errorText": ""}]}, "messages": {"resultCode": "Ok"}}';

		String result_code = 'Not Ok';
		String error_text = 'Error!';
		String transaction_id = '123';
		String successText = 'Approved';
 		String body = '{{"transactionResponse": {"transId": ' + transaction_id + ', "accountType": "Mastercard", "messages": [{"description": "' + successText + '"}], "errors": [{"errorText": "' + error_text + '"}]}, "Messages": {"resultCode": "' + result_code + '"}}';
		mockHttpResponse mockResponse = new mockHttpResponse(body);

		test.setMock(HttpCalloutMock.class, mockResponse);

		test.startTest();
			AuthorizeDotNet controller = new AuthorizeDotNet();
			controller.processPayment();

			System.assertEquals('Error!', controller.authResponse);
		test.stopTest();
	}

	public class mockHttpResponse implements HttpCalloutMock {
		public String body;
		public mockHttpResponse(String mockResponse) {
			body = mockResponse;
		}
		public HttpResponse respond(HttpRequest request) {
			HttpResponse res = new HttpResponse();
			res.setBody(body);
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(200);
			return res;
		}
	}

}
