public class authorizeDotNetParser {
	public transaction_Response transactionResponse;
	public rootMessages messages;

	public class transaction_Response {
		public String transId;
		public String accountType;
		public message[] messages;
		public error[] errors;
	}

	public class rootMessages {
		public String resultCode;
		public message[] message;
	}

	public class message {
		public String code;
		public String description;
		public String text;
	}

	public class error {
		public String errorCode;
		public String errorText;
	}
	//
	//     "transactionResponse":
	//     {
	//         "responseCode": "1",
	//         "authCode": "1B42UO",
	//         "avsResultCode": "Y",
	//         "cvvResultCode": "P",
	//         "cavvResultCode": "2",
	//         "transId": "40015935525",
	//         "refTransID": "",
	//         "transHash": "6AD4EA75A7B856070A6F362DA9A9D26B",
	//         "testRequest": "0",
	//         "accountNumber": "XXXX0015",
	//         "accountType": "MasterCard",
	//         "messages":
	//         [
	//             {
	//                 "code": "1",
	//                 "description": "This transaction has been approved."
	//             }
	//         ],
	//         "transHashSha2": ""
	//     },
	//     "messages":
	//     {
	//         "resultCode": "Ok",
	//         "message":
	//         [
	//             {
	//                 "code": "I00001",
	//                 "text": "Successful."
	//             }
	//         ]
	//     }
	// }
}
