public class AuthorizeDotNet {

  private Boolean not_production = (sandbox() || test.isRunningTest());

  private Credentials__mdt credentials = [select Username__c, Password__c from Credentials__mdt where developerName = 'Authorize' limit 1];
  public String authResponse {get; private set;}
  public String record_id {get; set;}
  public String description {get; set;}
  public String first_name {get; set;}
  public String last_name {get; set;}
  public String email {get; set;}
  public String street {get; set;}
  public String zipcode {get; set;}
  public String amount {get; private set;}
  public Long cc_number {get; set;}
  public String exp_month {get; set;}
  public String exp_year {get; set;}
  public Integer ccv {get; set;}
  private String cc_number_string {get{return String.valueOf(cc_number);}}
  private String ccv_string {get {return String.valueOf(ccv);}}

  public void processPayment(){
    Http http = new http();

    HttpRequest request = new HttpRequest();
    request.setMethod('POST');
    request.setHeader('Content-Type','application/json');
    request.setEndPoint(endPoint());
    request.setBody(generateJson());

    HttpResponse response = http.send(request);
    processResponse(response);
  }

  private void processResponse(HttpResponse response) {
    authorizeDotNetParser parser = (authorizeDotNetParser)JSON.deserialize(response.getBody().subString(1), authorizeDotNetParser.class);
    System.debug(response.getBody());
    System.debug(parser);
    if(parser.messages.resultCode == 'Ok') {
      authResponse = parser.transactionResponse.messages[0].description;

      transaction_info__c transaction_info = new transaction_info__c(amount__c = Decimal.valueOf(amount), transaction_id__c = parser.transactionResponse.transId, credit_card__c = parser.transactionResponse.accountType);
      insert transaction_info;
      id recordToUpdateID = Id.valueOf(record_id);
      SObject recordToUpdate = recordToUpdateID.getSObjectType().newSObject(recordToUpdateID);
      recordToUpdate.put('transaction_info__c', transaction_info.id);
      update recordToUpdate;
      // child__c updated_child = new child__c(id = record_id, transaction_info__c = transaction_info.id);
      // update updated_child;
    } else {
      authResponse = parser.transactionResponse.errors[0].errorText;
    }
  }

  public selectOption[] getexpMonthOptions(){

    selectOption[] options = new selectOption[]{};
    for (Integer i = 1; i <= 12; i++) {
      options.add(new selectOption(String.valueOf(i), String.valueOf(i)));
    }
    return options;
  }

   public selectOption[] getexpYearOptions(){
    Integer currentYear = Date.today().year();
    selectOption[] options = new selectOption[]{};
    for (Integer i = currentYear; i <= currentYear + 4; i++) {
      options.add(new selectOption(String.valueOf(i), String.valueOf(i)));
    }
    return options;
  }

	public AuthorizeDotNet() {
    amount = '50';
		cc_number = 5424000000000015L;
	}

  private String endPoint(){
    return 'https://apitest.authorize.net/xml/v1/request.api';
  }

  private Boolean sandbox(){
    return [select isSandbox from organization limit 1].isSandbox;
  }

  private String generateJson() {
      // For some reason, the Authorize Dot Net API requires the components of this JSON string to be in a specific order,
      // so we are forced to use the JSON Generator instead of serializing an APEX object.
      // This is lame but out of our control...
      // ----------------- EXAMPLE JSON -----------------
      // {
      //   "createTransactionRequest" : {
      //     "merchantAuthentication" : {
      //       "name" : "9jrFZ3Sw9uDg",
      //       "transactionKey" : "629t6v7VTFC2y2c8"
      //     },
      //     "transactionRequest" : {
      //       "transactionType" : "authCaptureTransaction",
      //       "amount" : "13.14",
      //       "payment" : {
      //         "creditCard" : {
      //           "cardNumber" : "5424000000000015",
      //           "expirationDate" : "052018",
      //           "cardCode" : "123"
      //         }
      //       },
      //       "order" : {
      //         "invoiceNumber" : "123"
      //         "description" : "FWI Stuff"
      //       },
      //       "customer" : {
      //         "email" : "alon.waisman@fourwindsinteractive.com"
      //       },
      //       "billTo" : {
      //         "firstName" : "test",
      //         "lastName" : "last",
      //         "address": "1313 Mockingbird Lane",
      //         "zip" : "03062"
      //       },
      //       "transactionSettings" : {
      //         "setting" : {
      //           "settingName" : "emailCustomer",
      //           "settingValue" : "1"
      //         }
      //       }
      //     }
      //   }
      // }
      String the_record_id = value_or_blank(record_id);
      String description   = value_or_blank(description);
      String first_name    = value_or_blank(first_name);
      String last_name     = value_or_blank(last_name);
      String email         = value_or_blank(email);
      String street        = value_or_blank(street);
      String zipcode       = value_or_blank(zipcode);
      String amount        = value_or_blank(amount);
      String cc_number     = value_or_blank(cc_number_string);
      String exp_month     = value_or_blank(exp_month);
      String exp_year      = value_or_blank(exp_year);
      String ccv           = value_or_blank(ccv_string);
      // CCV may have leading zeroes, so we may need to put them back in
      ccv = padded_ccv(ccv, cc_number);
      if (not_production) {email = 'astro.viera+authStuff@gmail.com';}
      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartObject();
          gen.writeFieldName('createTransactionRequest');
          gen.writeStartObject();
            gen.writeFieldName('merchantAuthentication');
            gen.writeStartObject();
                gen.writeStringField('name',           credentials.Username__c);
                gen.writeStringField('transactionKey', credentials.Password__c);
            gen.writeEndObject();
            gen.writeFieldName('transactionRequest');
            gen.writeStartObject();
                gen.writeStringField('transactionType', 'authCaptureTransaction');
                gen.writeStringField('amount', amount);
                gen.writeFieldName('payment');
                gen.writeStartObject();
                  gen.writeFieldName('creditCard');
                  gen.writeStartObject();
                      gen.writeStringField('cardNumber',     cc_number);
                      gen.writeStringField('expirationDate', exp_month + exp_year);
                      gen.writeStringField('cardCode',       ccv);
                  gen.writeEndObject();
                gen.writeEndObject();
                gen.writeFieldName('order');
                gen.writeStartObject();
                  gen.writeStringField('invoiceNumber', the_record_id);
                  gen.writeStringField('description', description);
                gen.writeEndObject();
                gen.writeFieldName('customer');
                gen.writeStartObject();
                  gen.writeStringField('email', email);
                gen.writeEndObject();
                gen.writeFieldName('billTo');
                gen.writeStartObject();
                  gen.writeStringField('firstName', first_name);
                  gen.writeStringField('lastName',  last_name);
                  gen.writeStringField('address',   street);
                  gen.writeStringField('zip',       zipcode);
                gen.writeEndObject();
                gen.writeFieldName('transactionSettings');
                gen.writeStartObject();
                  gen.writeFieldname('setting');
                  gen.writeStartObject();
                      gen.writeStringField('settingName', 'emailCustomer');
                      gen.writeStringField('settingValue', '1');
                  gen.writeEndObject();
                gen.writeEndObject();
            gen.writeEndObject();
          gen.writeEndObject();
      gen.writeEndObject();
      // This output contains a credit card number, so we shouldn't log it in production where real details are used.
      if (not_production) {
          System.debug('*** JSON output ***');
          System.debug(gen.getAsString());
      }
      return gen.getAsString();
  }

  private String value_or_blank(String value) {
    return value == null ? '' : value;
  }


  @testVisible private String padded_ccv(String original_ccv, String cc_number) {
    // American Express starts with either '34' or '37' and has a four digit ccv
    Integer ccv_length = (cc_number.startsWith('34') || cc_number.startsWith('37')) ? 4 : 3;
    return original_ccv.leftPad(ccv_length, '0');
  }


}
