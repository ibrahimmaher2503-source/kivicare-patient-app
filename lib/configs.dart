// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

const APP_NAME = 'Espitalia';
const APP_LOGO_URL = '$DOMAIN_URL/img/logo/mini_logo.png';
const DEFAULT_LANGUAGE = 'ar';
const ENABLE_GOOGLE_SIGN_IN = true;

/// Debug targets the local Android-emulator host; release always uses production.
const DOMAIN_URL = kDebugMode
    ? String.fromEnvironment(
        'API_DOMAIN_URL',
        defaultValue: 'http://10.0.2.2:8000',
      )
    : 'https://espitalia.net';

const BASE_URL = '$DOMAIN_URL/api/';

const APP_PLAY_STORE_URL = String.fromEnvironment('APP_PLAY_STORE_URL');
const APP_APPSTORE_URL = String.fromEnvironment('APP_APPSTORE_URL');

const TERMS_CONDITION_URL = '$DOMAIN_URL/page/terms-conditions';
const PRIVACY_POLICY_URL = '$DOMAIN_URL/page/privacy-policy';
const INQUIRY_SUPPORT_EMAIL = '';

const HELP_LINE_NUMBER = '';
const EMERGENCY_HOTLINE = String.fromEnvironment(
  'EMERGENCY_HOTLINE',
  defaultValue: '123',
);

//region Payment Gateway
//region STRIPE
const STRIPE_URL = 'https://api.stripe.com/v1/payment_intents';
const STRIPE_merchantIdentifier = "merchant.flutter.stripe.test";
const STRIPE_CURRENCY_CODE = 'EGP';
//endregion

/// PAYSTACK
const String payStackCurrency = 'EGP';

/// PAYPAl
const String payPalSupportedCurrency = 'USD';

/// Airtel Money Payments
///It Supports ["UGX", "NGN", "TZS", "KES", "RWF", "ZMW", "CFA", "XOF", "XAF", "CDF", "USD", "XAF", "SCR", "MGA", "MWK"]
const airtel_currency_code = "MWK";
const airtel_country_code = "MW";
const AIRTEL_BASE = kDebugMode
    ? 'https://openapiuat.airtel.africa/'
    : "https://openapi.airtel.africa";

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

//end region
