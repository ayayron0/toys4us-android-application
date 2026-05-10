import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StripeService {
  // TEST key only — never use in production
  static const _secretKey = 'sk_test_51TVHQC2fXz6tcjzdiIrWbRpMng7mcuTFbNFZLzDyUBN5dFK89OPyc1YOHcW5IshhPbx4lFVpZT5yFSw4QxeJBrck00WLpuBP6i';

  static Future<bool> processGooglePay({required double amount}) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: await _createPaymentIntent(amount),
          merchantDisplayName: 'Toys 4 Us',
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'CA',
            currencyCode: 'cad',
            testEnv: true,
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      rethrow;
    }
  }

  static Future<bool> processApplePay({required double amount}) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: await _createPaymentIntent(amount),
          merchantDisplayName: 'Toys 4 Us',
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'CA',
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      rethrow;
    }
  }


  static Future<String> _createPaymentIntent(double amount, {String? customerName}) async {
    // First create a customer if name is provided
    String? customerId;
    if (customerName != null && customerName.isNotEmpty) {
      final customerResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'name': customerName},
      );
      final customerData = json.decode(customerResponse.body);
      customerId = customerData['id'] as String?;
    }

    final body = {
      'amount': (amount * 100).toInt().toString(),
      'currency': 'cad',
      'setup_future_usage': 'off_session', // saves the payment method
    };

    if (customerId != null) body['customer'] = customerId;

    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    final data = json.decode(response.body);
    return data['client_secret'] as String;
  }


  static Future<bool> processPayment({
    required double amount,
    String? customerName,
  }) async {
    try {
      final clientSecret = await _createPaymentIntent(
        amount,
        customerName: customerName,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Toys 4 Us',
          billingDetails: customerName != null
              ? BillingDetails(name: customerName)
              : null,

        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      rethrow;
    }
  }
}