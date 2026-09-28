import 'package:intl/intl.dart';
import 'languages.dart';

class LanguageAr extends BaseLanguage {
  @override
  String get onlinePaymentUnavailable =>
      'الدفع الإلكتروني غير متاح مؤقتًا. يُرجى اختيار الدفع نقدًا أو المحفظة.';
  @override
  String get loading => 'جارٍ التحميل';
  @override
  String get cashAfterService => 'الدفع نقدًا بعد الخدمة';
  @override
  String get pharmacy => 'الصيدلية';
  @override
  String get language => 'اللغة';

  @override
  String get badRequest => '400: طلب غير صالح';

  @override
  String get forbidden => '403: غير مسموح';

  @override
  String get pageNotFound => '404: الصفحة غير موجودة';

  @override
  String get tooManyRequests => '429: عدد كبير جدًا من الطلبات';

  @override
  String get internalServerError => '500: خطأ داخلي في الخادم';

  @override
  String get badGateway => '502: خطأ في البوابة';

  @override
  String get serviceUnavailable => '503: الخدمة غير متوفرة';

  @override
  String get gatewayTimeout => '504: انتهت مهلة الاتصال بالبوابة';

  @override
  String get hey => 'مرحبًا';

  @override
  String get hello => 'مرحبًا';

  @override
  String get thisFieldIsRequired => 'هذا الحقل مطلوب';

  @override
  String get contactNumber => 'رقم الهاتف';

  @override
  String get gallery => 'المعرض';

  @override
  String get camera => 'الكاميرا';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get update => 'تحديث';

  @override
  String get reload => 'إعادة تحميل';

  @override
  String get address => 'العنوان';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get pressBackAgainToExitApp => 'اضغط مرة أخرى للخروج من التطبيق';

  @override
  String get invalidUrl => 'الرابط غير صالح';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get deleteAccountConfirmation =>
      'سيتم حذف حسابك بشكل دائم. لن تتم استعادة بياناتك مرة أخرى.';

  @override
  String get demoUserCannotBeGrantedForThis =>
      'لا يمكن منح المستخدم التجريبي لهذا الإجراء';

  @override
  String get somethingWentWrong => 'هناك خطأ ما';

  @override
  String get requestTimedOut =>
      'انتهت مهلة الطلب. يُرجى المحاولة مرة أخرى.';

  @override
  String get requestTimedOutAfterSubmission =>
      'انتهت مهلة الطلب بعد الإرسال. تحقّق من حالة الطلب قبل إعادة المحاولة.';

  @override
  String get yourInternetIsNotWorking => 'الإنترنت الخاص بك لا يعمل';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get wouldYouLikeToSetProfilePhotoAs =>
      'هل ترغب في تعيين هذه الصورة كصورة ملفك الشخصي؟';

  @override
  String get yourOldPasswordDoesnT =>
      'كلمة المرور القديمة الخاصة بك غير صحيحة!';

  @override
  String get yourNewPasswordDoesnT =>
      'كلمة المرور الجديدة لا تطابق كلمة المرور المؤكدة!';

  @override
  String get location => 'الموقع';

  @override
  String get startLocation => 'موقع الانطلاق';

  @override
  String get yes => 'نعم';

  @override
  String get submit => 'إرسال';

  @override
  String get select => 'اختيار';

  @override
  String get chooseAnother => 'اختر خيارًا آخر';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get yourNewPasswordMust =>
      'يجب أن تكون كلمة المرور الجديدة مختلفة عن كلمة المرور السابقة';

  @override
  String get password => 'كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get mainStreet => 'الشارع الرئيسي';

  @override
  String get toResetYourNew =>
      'لإعادة تعيين كلمة المرور، يُرجى إدخال بريدك الإلكتروني';

  @override
  String get stayTunedNoNew => 'لا توجد إشعارات جديدة حاليًا.';

  @override
  String get noNewNotificationsAt =>
      'لا توجد إشعارات جديدة حاليًا. سنخبرك عند وجود تحديث.';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get explore => 'استكشاف';

  @override
  String get settings => 'الإعدادات';

  @override
  String get rateApp => 'قيّم التطبيق';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'هل نسيت كلمة المرور؟';

  @override
  String get registerNow => 'سجّل الآن';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get createYourAccountFor => 'أنشئ حسابك لتجربة أفضل';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get alreadyHaveAnAccount => 'هل لديك حساب؟';

  @override
  String get yourPasswordHasBeen =>
      'تمت إعادة تعيين كلمة المرور الخاصة بك بنجاح';

  @override
  String get youCanNowLog =>
      'يمكنك الآن تسجيل الدخول إلى حسابك الجديد بكلمة مرورك الجديدة';

  @override
  String get done => 'تم';

  @override
  String get pleaseAcceptTermsAnd => 'يرجى قبول الشروط والأحكام';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get eG => 'على سبيل المثال';

  @override
  String get merry => 'ميري';

  @override
  String get doe => 'دو';

  @override
  String get welcomeBackToThe => 'مرحبًا بعودتك إلى';

  @override
  String get welcomeToThe => 'مرحبًا بك في';

  @override
  String get doYouWantToLogout => 'هل ترغب بالخروج؟';

  @override
  String get appTheme => 'مظهر التطبيق';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get guest => 'ضيف';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get notificationPermissionDescription =>
      'احصل على تذكيرات المواعيد وتحديثات الرعاية.';

  @override
  String get notificationPermissionDenied =>
      'الإشعارات متوقفة. يمكنك تفعيلها من إعدادات التطبيق.';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get getInTouchWithSupport => 'تواصل مع الدعم';

  @override
  String get newUpdate => 'تحديث جديد';

  @override
  String get anUpdateTo => 'يتوفر تحديث لـ';

  @override
  String get isAvailableGoTo =>
      'متاح. انتقل إلى المتجر لتنزيل الإصدار الجديد من التطبيق.';

  @override
  String get later => 'لاحقاً';

  @override
  String get closeApp => 'إغلاق التطبيق';

  @override
  String get updateNow => 'تحديث الآن';
  @override
  String get updateLinkUnavailable =>
      'رابط التحديث غير متاح حاليًا. يُرجى المحاولة لاحقًا.';

  @override
  String get signInFailed => 'فشل تسجيل الدخول';

  @override
  String get userCancelled => 'ألغى المستخدم العملية';

  @override
  String get appleSigninIsNot => 'تسجيل الدخول عبر Apple غير متوفر لجهازك';

  @override
  String get eventStatus => 'حالة الحدث';

  @override
  String get eventAddedSuccessfully => 'تمت إضافة الحدث بنجاح';

  @override
  String get notRegistered => 'ألست مسجلًا؟';

  @override
  String get signInWithGoogle => 'تسجيل الدخول باستخدام Google';

  @override
  String get signInWithApple => 'تسجيل الدخول باستخدام Apple';

  @override
  String get orSignInWith => 'أو سجّل الدخول باستخدام';

  @override
  String get ohNoYouAreLeaving => 'أنت على وشك المغادرة';

  @override
  String get oldPassword => 'كلمة المرور القديمة';

  @override
  String get oldAndNewPassword => 'كلمة المرور القديمة والجديدة هي نفسها.';

  @override
  String get personalizeYourProfile => 'تخصيص ملفك الشخصي';

  @override
  String get themeAndMore => 'المظهر والمزيد';

  @override
  String get showSomeLoveShare => 'شارك التطبيق مع من تحب';

  @override
  String get privacyPolicyTerms => 'سياسة الخصوصية والشروط والأحكام';

  @override
  String get securelyLogOutOfAccount => 'قم بتسجيل الخروج من الحساب بشكل آمن';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get successfully => 'بنجاح';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get notificationDeleted => 'تم حذف الإشعار';

  @override
  String get doYouWantToRemoveNotification => 'هل تريد حذف هذا الإشعار؟';

  @override
  String get doYouWantToClearAllNotification => 'هل تريد حذف جميع الإشعارات؟';

  @override
  String get locationPermissionDenied => 'تم رفض إذن الموقع';

  @override
  String get enableLocation => 'تفعيل الموقع';

  @override
  String get permissionDeniedPermanently => 'تم رفض الإذن بشكل دائم';

  @override
  String get chooseYourLocation => 'اختر موقعك';

  @override
  String get setAddress => 'تعيين العنوان';

  @override
  String get sorryUserCannotSignin => 'عذرًا، لا يمكن تسجيل الدخول';

  @override
  String get iAgreeToThe => 'أنا أوافق على';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get doYouConfirmThisAppointment => 'هل تؤكد هذا الموعد؟';

  @override
  String get confirmAppointment => 'تأكيد الموعد';

  @override
  String get iHaveReadAll => 'راجعت تفاصيل الحجز وأؤكد الموعد مع';

  @override
  String get confirm => 'تأكيد';

  @override
  String get doYouConfirmThisPayment => 'هل تريد تأكيد عملية الدفع؟';

  @override
  String get exploreTopClinicsWithAdvancedServicesTailored =>
      "استكشف أفضل العيادات وخدماتها المتقدمة المصممة لتلبية احتياجاتك";

  @override
  String get discoverYourIdealClinicWithOurPersonalizedSea =>
      'اعثر على العيادة المناسبة لك من خلال بحث مخصص. لنبدأ!';

  @override
  String get weHaveEmailedYourPasswordResetLink =>
      "لقد أرسلنا بريدًا إلكترونيًا إلى رابط إعادة تعيين كلمة المرور الخاصة بك!";

  @override
  String get resetYourPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get enterYourEmailAddressToResetYourNewPassword =>
      "أدخل عنوان بريدك الإلكتروني لإعادة تعيين كلمة المرور الجديدة.";

  @override
  String get sendCode => "إرسال الرمز";

  @override
  String get edit => "تعديل";

  @override
  String get gender => 'الجنس';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get encounters => 'الزيارات الطبية';

  @override
  String get seeYourEncounterData => 'عرض بيانات زيارتك الطبية';

  @override
  String get version => 'الإصدار';

  @override
  String get userNotCreated => 'تعذر إنشاء المستخدم';

  @override
  String get notAMember => 'لست عضوًا؟';

  @override
  String get registerYourAccountForBetterExperience =>
      'سجّل حسابك لتحصل على تجربة أفضل';

  @override
  String get termsConditions => 'الشروط والأحكام';

  @override
  String get and => "و";

  @override
  String get privacyPolicy => "سياسة الخصوصية";

  @override
  String get appointment => 'الموعد';

  @override
  String get doctor => 'الطبيب';

  @override
  String get payment => 'الدفع';

  @override
  String get doYouWantToCancelAppointment => "هل تريد إلغاء الموعد؟";

  @override
  String get videoCallLinkIsNotFound =>
      "لم يتم العثور على رابط مكالمات الفيديو!";

  @override
  String get thisIsNotAOnlineService => "هذه ليست خدمة عبر الإنترنت!";

  @override
  String get oppsThisAppointmentIsNotConfirmedYet =>
      "عذرًا، لم يتم تأكيد هذا الموعد بعد.";

  @override
  String get oppsThisAppointmentHasBeenCancelled =>
      "عذرًا، تم إلغاء هذا الموعد.";

  @override
  String get oppsThisAppointmentHasBeenCompleted => "عذرًا، اكتمل هذا الموعد.";

  @override
  String get noTimeSlotsAvailable => "لا توجد مواعيد متاحة.";

  @override
  String get chooseTime => "اختر الوقت";

  @override
  String get rescheduleBooking => "إعادة جدولة الحجز";

  @override
  String get searchForService => "ابحث عن الخدمة";

  @override
  String get statusListIsEmpty => "لا توجد حالات لعرضها حاليًا";

  @override
  String get thereAreNoStatusListedAtTheMomentStayTunedFor =>
      "لا توجد حالات مدرجة حاليًا. سنخبرك عند توفر المزيد.";

  @override
  String get chooseDate => 'اختر تاريخًا';

  @override
  String get doYouWantToChangeTheTimeSlotOfThisAppointment =>
      "هل تريد تغيير موعد هذا الحجز؟";

  @override
  String get no => "لا";

  @override
  String get somethingWentWrongPleaseTryAgainLater =>
      "هناك خطأ ما. الرجاء معاودة المحاولة في وقت لاحق.";

  @override
  String get doYouWantToRemoveThisReview => "هل تريد حذف هذا التقييم؟";

  @override
  String get encounterDetail => 'تفاصيل الزيارة الطبية';

  @override
  String get view => "عرض";

  @override
  String get doctorName => "اسم الطبيب";

  @override
  String get active => 'نشط';

  @override
  String get closed => "مغلق";

  @override
  String get clinicName => "اسم العيادة";

  @override
  String get description => 'الوصف';

  @override
  String get payNow => "ادفع الآن";

  @override
  String get medicalReport => "تقرير طبي";

  @override
  String get paymentDetail => "تفاصيل الدفع";

  @override
  String get price => "السعر";

  @override
  String get discount => 'الخصم';

  @override
  String get off => "خصم";

  @override
  String get subtotal => "المجموع الفرعي";

  @override
  String get tax => 'الضريبة';

  @override
  String get taxIncluded => 'السعر شامل الضريبة';

  @override
  String get total => "المجموع";

  @override
  String get yourReview => 'تقييمك';

  @override
  String get by => "بواسطة";

  @override
  String get youHaventRatedYet => "لم تصنف بعد";

  @override
  String get yourFeedbackWillImproveOurService => 'ستساعد ملاحظاتك على تحسين خدمتنا.';

  @override
  String get writeHere => "اكتب هنا..";

  @override
  String get writeYourFeedbackHere => "اكتب ملاحظاتك هنا ..";

  @override
  String get pleaseSelectRatings => 'يرجى اختيار التقييم';

  @override
  String get all => 'الكل';

  @override
  String get upcoming => "القادمة";

  @override
  String get completed => "مكتمل";

  @override
  String get appointmentCancelSuccessfully => "تم إلغاء الموعد بنجاح";

  @override
  String get appointments => "المواعيد";

  @override
  String get noAppointmentsFound => "لم يتم العثور على مواعيد";

  @override
  String get thereAreCurrentlyNoAppointmentsAvailableStart =>
      "لا توجد مواعيد متاحة حاليًا. يمكنك حجز موعدك التالي الآن.";

  @override
  String get encounter => 'الزيارة الطبية';

  @override
  String get basicInformation => 'معلومات أساسية';

  @override
  String get problems => 'المشكلات';

  @override
  String get observations => "الملاحظات";

  @override
  String get notes => "ملحوظات";

  @override
  String get prescription => 'الوصفة الطبية';

  @override
  String get frequency => 'التكرار';

  @override
  String get days => "أيام";

  @override
  String get otherInformation => "معلومات أخرى";

  @override
  String get patientSoap => "ملف SOAP للمريض";

  @override
  String get category => "الفئة";

  @override
  String get noCategoryFound => "لم يتم العثور على فئة";

  @override
  String get viewDetail => "عرض التفاصيل";

  @override
  String get noServicesFoundAtAMoment => 'لا توجد خدمات متاحة حاليًا';

  @override
  String get noServicesMatchFilters => "لا توجد خدمات مطابقة لاختياراتك";

  @override
  String get tryChangingFiltersOrSearchAgain =>
      "جرّب تغيير الاختيارات أو البحث عن خدمة أخرى.";

  @override
  String get looksLikeThereIsNoServicesForThis => 'يبدو أنه لا توجد خدمات متاحة لهذا القسم';

  @override
  String get wellKeepYouPostedWhenTheresAnUpdate => "سنخبرك عند توفر تحديث.";

  @override
  String get services => 'الخدمات';

  @override
  String get sessions => 'الجلسات';

  @override
  String get clinicSessionsInformation => "معلومات جلسات العيادة";

  @override
  String get servicesAvailable => "الخدمات المتاحة";

  @override
  String get noServicesAvailable => "لا توجد خدمات متاحة";

  @override
  String get doctors => "الأطباء";

  @override
  String get noSystemServicesFoundAtAMoment =>
      "لم نعثر على خدمات النظام حاليًا.";

  @override
  String get looksLikeThereIsNoSystemServicesForThis =>
      "يبدو أنه لا توجد خدمات نظام لهذا القسم.";

  @override
  String get appointmentsSummary => "ملخص المواعيد";

  @override
  String get date => 'التاريخ';

  @override
  String get time => 'الوقت';

  @override
  String get service => 'الخدمة';

  @override
  String get clinic => 'العيادة';

  @override
  String get proceed => "متابعة";

  @override
  String get video => "فيديو";

  @override
  String get bookingForm => "استمارة الحجز";

  @override
  String get bookingInfo => "معلومات الحجز";

  @override
  String get serviceName => "اسم الخدمة";

  @override
  String get chooseService => "اختر الخدمة";

  @override
  String get serviceListIsEmpty => 'لا توجد خدمات';

  @override
  String get thereAreNoServicesListedAtTheMomentStayTunedF =>
      "لا توجد خدمات مدرجة حاليًا. سنخبرك عند توفر المزيد.";

  @override
  String get kindlyChooseAServiceFirst => 'يرجى اختيار الخدمة أولًا';

  @override
  String get chooseClinic => "اختر العيادة";

  @override
  String get searchForClinic => "ابحث عن العيادة";

  @override
  String get clinicListIsEmpty => 'لا توجد عيادات';

  @override
  String get thereAreNoClinicsListedAtTheMomentStayTunedFo =>
      "لا توجد عيادات مدرجة حاليًا. سنخبرك عند توفر المزيد.";

  @override
  String get kindlyChooseAClinicFirst => 'يرجى اختيار عيادة أولًا';

  @override
  String get chooseDoctor => "اختر الطبيب";

  @override
  String get searchForDoctor => "ابحث عن الطبيب";

  @override
  String get thereAreNoDoctorsListedAtTheMomentStayTunedFo =>
      "لا يوجد أطباء مدرجون حاليًا. سنخبرك عند توفر المزيد.";

  @override
  String get writeMedicalHistory => 'اكتب تاريخك الطبي';

  @override
  String get paymentDetails => "بيانات الدفع";

  @override
  String get asPerDoctorCharges => "حسب رسوم الطبيب";

  @override
  String get next => "التالي";

  @override
  String get skip => 'تخطي';

  @override
  String get finish => 'إنهاء';

  @override
  String pageOf(int current, int total) => 'الصفحة $current من $total';

  @override
  String get personalizedHealthPlansForYourJourney => "خطط صحية مخصصة لرحلتك";

  @override
  String get stayOnTrackAndSetPersonalGoals =>
      'حافظ على تقدمك وحدد أهدافك الشخصية';

  @override
  String get discoverAndGetSupportWithin24Hours =>
      "اكتشف واحصل على الدعم في غضون 24 ساعة";

  @override
  String get customizeHealthPlansForATailoredApproachAlign =>
      'خصّص خطتك الصحية بما يناسب احتياجاتك في كل خطوة.';

  @override
  String get focusOnYourPathSetClearGoalsAndStrideForwardW =>
      'ركّز على طريقك، وحدد أهدافًا واضحة، وتقدّم بثبات وإصرار.';

  @override
  String get exploreFindSolutionsAndReceiveAssistanceSwift =>
      'استكشف الخيارات، واعثر على الحلول، واحصل على الدعم خلال 24 ساعة.';

  @override
  String get transactionIsInProcess => 'المعاملة قيد التنفيذ...';

  @override
  String get enterYourMsisdnHere => 'أدخل رقم هاتفك (MSISDN) هنا';

  @override
  String get pleaseCheckThePayment => 'يرجى التأكد من إرسال طلب الدفع إلى رقمك';

  @override
  String get ambiguous => 'غامض';

  @override
  String get success => 'نجاح';

  @override
  String get incorrectPin => 'رقم التعريف الشخصي غير صحيح';

  @override
  String get exceedsWithdrawalAmountLimit =>
      'تجاوزت العملية الحد الأقصى لمبلغ السحب.';

  @override
  String get inProcess => 'تحت المعالجة';

  @override
  String get transactionTimedOut => 'انتهت مهلة المعاملة';

  @override
  String get notEnoughBalance => 'لا يوجد رصيد كافي';

  @override
  String get refused => 'رفض';

  @override
  String get doNotHonor => 'تم رفض العملية من البنك';

  @override
  String get transactionNotPermittedTo =>
      'المعاملة غير مسموح بها للمستفيد';

  @override
  String get transactionIdIsInvalid => 'معرف المعاملة غير صالح';

  @override
  String get errorWhileFetchingEncryption => 'حدث خطأ أثناء جلب مفتاح التشفير';

  @override
  String get transactionExpired => 'انتهت صلاحية المعاملة';

  @override
  String get invalidAmount => 'مبلغ غير صحيح';

  @override
  String get transactionNotFound => 'لم يتم العثور على المعاملة';

  @override
  String get successfullyFetchedEncryptionKey => 'تم جلب مفتاح التشفير بنجاح';

  @override
  String get theTransactionIsStill =>
      'لا تزال المعاملة قيد المعالجة. تحقّق من حالتها لاحقًا.';

  @override
  String get transactionIsSuccessful => 'عملية ناجحة';

  @override
  String get incorrectPinHasBeen => 'تم إدخال رقم التعريف الشخصي بشكل غير صحيح';

  @override
  String get theUserHasExceeded =>
      'لقد تجاوز المستخدم حد المعاملات المسموح به في محفظته';

  @override
  String get theAmountUserIs =>
      'المبلغ الذي يحاول المستخدم تحويله أقل من الحد الأدنى المسموح به';

  @override
  String get userDidnTEnterThePin => 'لم يدخل المستخدم الرقم السري';

  @override
  String get transactionInPendingState =>
      'المعاملة في حالة معلقة. يرجى التحقق بعد وقت ما';

  @override
  String get userWalletDoesNot =>
      'لا تحتوي محفظة المستخدم على أموال كافية لتغطية المبلغ المستحق';

  @override
  String get theTransactionWasRefused => 'تم رفض المعاملة';

  @override
  String get encryptionKeyHasBeen => 'تم جلب مفتاح التشفير بنجاح';

  @override
  String get transactionHasBeenExpired => 'لقد انتهت صلاحية المعاملة';

  @override
  String get payeeIsAlreadyInitiated =>
      'تم إيقاف المستفيد أو حظره أو أنه غير مسجل في منصة Airtel Money.';

  @override
  String get theTransactionWasNot => 'لم يتم العثور على المعاملة.';

  @override
  String get thisIsAGeneric => 'هذا رفض عام له عدة أسباب محتملة';

  @override
  String get theTransactionWasTimed => 'انتهت مهلة المعاملة.';

  @override
  String get xSignatureAndPayloadDid => 'توقيع x والحمولة غير متطابقين';

  @override
  String get couldNotFetchEncryption => 'تعذر جلب مفتاح التشفير';

  @override
  String get transactionFailed => 'فشلت العملية';

  @override
  String get transactionCancelled => 'تم إلغاء المعاملة';

  @override
  String get paymentSuccess => "تم الدفع بنجاح";

  @override
  String get redirectingToBookings => 'جارٍ الانتقال إلى الحجوزات...';

  @override
  String get pleaseConfirmYourAppointmentByCheckingTheBox =>
      "يرجى تأكيد موعدك من خلال التحقق من المربع";

  @override
  String get appointmentDetail => "تفاصيل الموعد";

  @override
  String get reschedule => "إعادة جدولة";

  @override
  String get invoice => "فاتورة";

  @override
  String get dateTime => "التاريخ والوقت";

  @override
  String get appointmentStatus => "حالة الموعد";

  @override
  String get paymentStatus => "حالة السداد";

  @override
  String get subjective => "شخصي";

  @override
  String get objective => "موضوعي";

  @override
  String get assessment => 'التقييم';

  @override
  String get plan => 'الخطة';

  @override
  String get bodyChart => "مخطط الجسم";

  @override
  String get doctorsAvailable => "الأطباء المتاحين";

  @override
  String get noDoctorsAvailable => 'لا يوجد أطباء متاحون حاليًا.';

  @override
  String get photosAvailable => "الصور المتاحة";

  @override
  String get noPhotosAvailable => 'لا توجد صور متاحة';

  @override
  String get looksLikeThereIsNoServicesListedOnThisClinicW =>
      'لا توجد خدمات متاحة حاليًا في هذه العيادة. سنخبرك عند توفر تحديث.';

  @override
  String get session => 'جلسة';

  @override
  String get unavailable => 'غير متوفرة';

  @override
  String get lblBreak => "استراحة";

  @override
  String get clinicDetail => "تفاصيل العيادة";

  @override
  String get pincode => "الرمز البريدي";

  @override
  String get readMore => 'اقرأ المزيد';

  @override
  String get readLess => 'عرض أقل';

  @override
  String get noGalleryFoundAtAMoment => "لا توجد صور للعرض حاليًا";

  @override
  String get looksLikeThereIsNoGalleryForThisClinicWellKee =>
      'لا توجد صور متاحة حاليًا لهذه العيادة. سنخبرك عند توفر تحديث.';

  @override
  String get clinics => "العيادات";

  @override
  String get availableClinicsFor => 'العيادات المتاحة لـ';

  @override
  String get noClinicsFoundAtAMoment => 'لا توجد عيادات متاحة حاليًا.';

  @override
  String get looksLikeThereIsNoClinicForThisServiceWellKee =>
      'لا توجد عيادات متاحة حاليًا لهذه الخدمة. سنخبرك عند توفر تحديث.';

  @override
  String get searchClinicHere => "ابحث عن عيادة هنا";

  @override
  String get home => 'الرئيسية';

  @override
  String get aboutMyself => 'نبذة عني';

  @override
  String get about => 'نبذة';

  @override
  String get contactInfo => "معلومات الاتصال";

  @override
  String get specialization => "التخصص";

  @override
  String get experience => "سنوات الخبرة";

  @override
  String get experienceSpecializationContactInfo =>
      'الخبرة والتخصص ومعلومات الاتصال';

  @override
  String get reviews => "المراجعات";

  @override
  String get noReviewsAvailable => "لا توجد مراجعات متاحة";

  @override
  String get qualification => 'المؤهل العلمي';

  @override
  String get qualificationInDetail => "المؤهلات بالتفصيل";

  @override
  String get year => "سنة";

  @override
  String get degree => 'الدرجة العلمية';

  @override
  String get university => 'الجامعة';

  @override
  String get noQualificationsFound => "لم يتم العثور على مؤهلات!";

  @override
  String get looksLikeThereAreNoQualificationsAddedByThisD =>
      "يبدو أنه لا توجد مؤهلات مضافة لهذا الطبيب.";

  @override
  String get totalAppointmentsDone => "إجمالي المواعيد المنجزة";

  @override
  String get looksLikeThereIsNoServicesProvidedByThisDocto =>
      'لا توجد خدمات متاحة حاليًا لهذا الطبيب. سنخبرك عند توفر تحديث.';

  @override
  String get doctorDetail => "تفاصيل الطبيب";

  @override
  String get socialMedia => "وسائل التواصل الاجتماعي";

  @override
  String get noDoctorsFoundAtAMoment => "لم نعثر على أطباء حاليًا";

  @override
  String get looksLikeThereIsNoDoctorsForThisClinicWellKee =>
      'لا يوجد أطباء متاحون حاليًا لهذه العيادة. سنخبرك عند توفر تحديث.';

  @override
  String get noReviewsFoundAtAMoment => "لا توجد تقييمات حاليًا";

  @override
  String get looksLikeThereIsNoReviewsWellKeepYouPostedWhe =>
      'لا توجد تقييمات متاحة حاليًا. سنخبرك عند توفر تحديث.';

  @override
  String get searchHere => "ابحث هنا";

  @override
  String get searchDoctorHere => "ابحث عن طبيب هنا";

  @override
  String get noEncountersFound => 'لم يتم العثور على زيارات طبية';

  @override
  String get looksLikeThereIsNoEncountersWellKeepYouPosted =>
      'لا توجد زيارات طبية متاحة حاليًا. سنخبرك عند توفر تحديث.';

  @override
  String get clinicsNearYou => "العيادات القريبة منك";

  @override
  String get upcomingAppointments => "المواعيد القادمة";

  @override
  String get great => "عظيم!";

  @override
  String get bookingSuccessful => "تم الحجز بنجاح";

  @override
  String get yourAppointmentHasBeenBookedSuccessfully => "تم حجز موعدك بنجاح";

  @override
  String get totalPayment => "المبلغ الإجمالي";

  @override
  String get goToAppointments => 'الانتقال إلى المواعيد';

  @override
  String get noteForCashPaymentPurposesDontUseThePayNowBut =>
      'ملاحظة: للدفع النقدي، لا تستخدم زر «الدفع الآن». ادفع للطبيب نقدًا لإكمال موعدك.';

  @override
  String get choosePaymentMethod => "اختر طريقة الدفع المناسبة لك";

  @override
  String get chooseOurConvenientPaymentOptionAndUnlockUnli =>
      "اختر طريقة الدفع الأنسب لك لإكمال الحجز بسهولة.";

  @override
  String get doYouWantToReplaceThePreviousServiceWithTheCu =>
      'هل تريد استبدال الخدمة السابقة بالخدمة الحالية؟';

  @override
  String get bookNow => "احجز الآن";

  @override
  String get aboutService => 'نبذة عن الخدمة';

  @override
  String get advancePayableAmount => 'المبلغ المستحق مقدمًا';

  @override
  String get advancePaidAmount => 'المبلغ المدفوع مقدمًا';

  @override
  String get remainingPayableAmount => 'المبلغ المتبقي المستحق';

  @override
  String get walletHistory => "سجل المحفظة";

  @override
  String get noWalletDataFound => "لم يتم العثور على بيانات محفظة!";

  @override
  String get oppsNoWalletDataFoundAtAMoment =>
      'عذرًا، لم يتم العثور على بيانات المحفظة حاليًا.';

  @override
  String get walletBalance => "رصيد المحفظة";

  @override
  String get addFiles => 'إضافة ملفات';

  @override
  String get file => 'ملف';

  @override
  String get apply => 'تطبيق';

  @override
  String get filterBy => 'تصفية حسب';

  @override
  String get priceRange => 'نطاق السعر';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get serviceType => 'نوع الخدمة';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get passwordLengthShouldBe8To14Characters =>
      'يجب أن يكون طول كلمة المرور من 8 إلى 14 حرفًا';

  @override
  String get noteInCaseYouFailToMakeTheAdvancePaymentYouWi =>
      'ملاحظة: إذا تعذر سداد الدفعة المقدمة، اضغط «الدفع الآن» لسداد المبلغ المستحق. وإلا فلن تتم معالجة الموعد وستحتاج إلى حجز موعد جديد.';

  @override
  String get serviceTotal => 'إجمالي الخدمة';

  @override
  String get remainingAmount => 'المبلغ المتبقي';

  @override
  String get refundableAmount => 'المبلغ القابل للاسترداد';

  @override
  String get appointmentId => 'معرّف الموعد:';

  @override
  String get youDontHaveEnoughBalanceToCompleteThePaymentU =>
      'ليس لديك رصيد كافي لإكمال الدفع باستخدام محفظتك.';

  @override
  String get advancePayment => 'الدفعة المقدمة';

  @override
  String get doYouWantToPerformThisAction => 'هل تريد تنفيذ هذا الإجراء؟';

  @override
  String get bookedFor => 'الحجز باسم';

  @override
  String get addPatient => 'إضافة مريض';

  @override
  String get relation => 'صلة القرابة';

  @override
  String get save => 'حفظ';

  @override
  String get managePatient => 'إدارة المريض';

  @override
  String get otherPatient => 'مريض آخر';

  @override
  String get manageOtherPatient => 'إدارة المريض الآخر';

  @override
  String get genderWithColon => 'الجنس:';

  @override
  String get contactNumberWithColon => 'رقم الهاتف:';

  @override
  String get dobWithColon => 'تاريخ الميلاد:';

  @override
  String get noPatientsFound => 'لم يتم العثور على مرضى';

  @override
  String get editPatient => 'تعديل المريض';

  @override
  String get doYouWantToDeleteYourOtherPatientsProfile =>
      'هل تريد حذف الملف الشخصي لمريضك الآخر؟';

  @override
  String get birthdateIsRequired => 'تاريخ الميلاد مطلوب';

  @override
  String get selectBirthdate => 'اختر تاريخ الميلاد';

  @override
  String get bookedForWithColon => 'الحجز باسم: ';

  @override
  String get inClinic => 'في العيادة';

  @override
  String get online => 'عن بُعد';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get checkIn => 'تسجيل الحضور';

  @override
  String get cancelled => 'تم الإلغاء';

  @override
  String get advancePaid => 'مدفوع مقدمًا';

  @override
  String get paid => 'مدفوع';

  @override
  String get advanceRefunded => 'تم رد الدفعة المقدمة';

  @override
  String get refunded => 'تم رد المبلغ';
  @override
  String get preparing => 'جاري التجهيز';
  @override
  String get outForDelivery => 'خرج للتوصيل';
  @override
  String get delivered => 'تم التوصيل';
  @override
  String get reviewed => 'تمت المراجعة';
  @override
  String get processed => 'تمت المعالجة';

  @override
  String get failed => 'فشل';

  @override
  String get ourPopularDoctor => 'أطباؤنا المميزون';

  @override
  String get ourPopularSevices => 'خدماتنا الشائعة';

  @override
  String get ourPopularClinics => 'اعثر على عيادتك المثالية';

  @override
  String get newAppointmentBooked => 'تم حجز موعد جديد';

  @override
  String get appointmentCompleted => 'اكتمل الموعد';

  @override
  String get appointmentRejected => 'تم رفض الموعد';

  @override
  String get appointmentCancelled => 'تم إلغاء الموعد';

  @override
  String get appointmentRescheduled => 'تمت إعادة جدولة الموعد';

  @override
  String get appointmentAccepted => 'تم قبول الموعد';

  @override
  String get forgetEmailPassword => 'هل نسيت بريدك الإلكتروني أو كلمة المرور؟';

  @override
  String get parents => 'أحد الوالدين';

  @override
  String get brother => 'أخ';

  @override
  String get siblings => 'الإخوة';

  @override
  String get spouse => 'الزوج/الزوجة';

  @override
  String get relative => 'قريب';

  @override
  String get deleteConfirmation => 'تأكيد الحذف';

  @override
  String get patientUpdatedSuccessfully => 'تم تحديث المريض بنجاح';

  @override
  String get patientAddedSuccessfully => 'تمت إضافة المريض بنجاح';

  @override
  String get recordDeletedSuccessfully => 'تم حذف السجل بنجاح';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get other => 'آخر';

  @override
  String get others => 'آخرون';

  @override
  String get appliedInclusiveTaxes => 'الضرائب المشمولة المطبقة';

  @override
  String get includesInclusiveTax => 'يشمل الضريبة المشمولة';

  @override
  String get inclusiveTaxes => 'الضرائب المشمولة';

  @override
  String get servicePrice => "سعر الخدمة";

  @override
  String get inclusiveTax => 'الضريبة المشمولة';

  @override
  String get appliedExclusiveTaxes => 'الضرائب غير المشمولة المطبقة';

  @override
  String get exclusiveTax => 'الضريبة غير المشمولة';

  @override
  String get appliedTaxes => "الضرائب المطبقة";

  @override
  String cancellationChargesWillBeAppliedForCancellationWithin(
          String amount, String hours) =>
      "سيتم تطبيق رسوم إلغاء بقيمة $amount للإلغاء خلال $hours ساعة.";

  @override
  String get cancelAppointment => 'إلغاء الموعد';

  @override
  String get goBack => "العودة";

  @override
  String cancellationFeesWillBeAppliedIfYouCancelWithinHoursOfScheduledTime(
          String hours, bool isCancellationChargesEnabled) =>
      "هل تريد إلغاء هذا الموعد؟ ${isCancellationChargesEnabled ? 'سيتم تطبيق رسوم الإلغاء إذا قمت بالإلغاء خلال $hours ساعة من الوقت المحدد' : ''}";

  @override
  String get reason => "السبب";

  @override
  String get continueText => "متابعة";

  @override
  String get wouldYouLikeToProceedAndConfirmPayment =>
      "هل ترغب في المتابعة وتأكيد الدفع؟";

  @override
  String get cancellationFee => "رسوم الإلغاء";

  @override
  String get yourAppointmentHasBeenSuccessfullyCancelled =>
      "تم إلغاء موعدك بنجاح";

  @override
  String get appointmentRefundWillBeProcessedWithingHoursIfApplicable =>
      "سيتم رد المبلغ خلال 24 ساعة إذا انطبق ذلك.";

  @override
  String get noteCheckYourAppointmentHistoryForRefundDetailsIfApplicable =>
      "*ملاحظة: تحقق من سجل مواعيدك للحصول على تفاصيل الاسترداد إذا كان ذلك ممكنًا.";

  @override
  String get ok => "حسنًا";

  @override
  String get hintReason => "على سبيل المثال: غيرت رأيي، إلخ";

  @override
  String get medicalHistory => "التاريخ الطبي";

  @override
  String get clinicClosed => "العيادة مغلقة";

  @override
  String get satisfactionToCustomer => "رضا العملاء";

  @override
  String get totalVerifiedPatients => 'إجمالي الأطباء';

  @override
  String get encounterId => 'معرّف الزيارة الطبية: ';

  @override
  String get dateIsNotSelected => 'لم يتم تحديد التاريخ';

  @override
  String get selectClinic => 'اختر عيادة';

  @override
  String get selectService => 'اختر الخدمة';

  @override
  String get quicklyBookYourAppointmentNow => 'سارع بحجز موعدك الآن';

  @override
  String get noDataFound => 'لم يتم العثور على بيانات';

  @override
  String get filterService => 'الخدمة';

  @override
  String get filterRating => 'التقييم';

  @override
  String get filterCategory => 'الفئة';

  @override
  String get incidentManagement => 'إدارة البلاغات';

  @override
  String get requestHelpForAnyMistakeHappen =>
      'اطلب المساعدة عند حدوث أي مشكلة';

  @override
  String get verify => 'تحقق';

  @override
  String get closedOn => 'أُغلق في';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get title => 'العنوان';

  @override
  String get enterYourDetailDescriptionForYourComplaint =>
      'أدخل وصفًا تفصيليًا لشكواك';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get chooseImage => 'اختر الصورة';

  @override
  String get browse => 'تصفح';

  @override
  String get noQueryYet => 'لا توجد بلاغات بعد';

  @override
  String get add => 'إضافة';

  @override
  String get toSubmitYourProblemsSimplyPressAddButtonAndExplainYourConcern =>
      'لإرسال بلاغ، اضغط على زر الإضافة واشرح المشكلة';

  @override
  String get open => 'فتح';

  @override
  String get close => 'إغلاق';

  @override
  String get pleaseEnterValidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get passwordMustIncludeSpacialCharacter =>
      'يجب أن تتضمن كلمة المرور حرفًا خاصًا واحدًا على الأقل';

  @override
  String get passwordMustIncludeAtLeastOneLowercaseCharacter =>
      'يجب أن تتضمن كلمة المرور حرفًا صغيرًا واحدًا على الأقل';

  @override
  String get passwordMustIncludeAtLeastOneNumber =>
      'يجب أن تتضمن كلمة المرور رقمًا واحدًا على الأقل';

  @override
  String get passwordMustIncludeAtLeastOneCapitalCharacter =>
      'يجب أن تتضمن كلمة المرور حرفًا كبيرًا واحدًا على الأقل';

  @override
  String get addFile => 'إضافة ملف';

  @override
  String get uploadMedicalReport => 'رفع التقرير الطبي';

  @override
  String get optional => '(اختياري)';

  @override
  String get reply => 'رد';

  @override
  String get passwordIsRequired => "كلمة المرور مطلوبة";

  @override
  String get passwordDoesNotMeetRequirements =>
      "كلمة المرور لا تستوفي الشروط المطلوبة";

  @override
  String get passwordTooShort => "يجب أن تتكون كلمة المرور من 8 أحرف على الأقل";

  @override
  String get emailHasAlreadyBeenTaken => 'لقد تم أخذ البريد الإلكتروني بالفعل.';

  @override
  String get markAsClosed => 'وضع علامة «مغلق»';

  @override
  String get hideMessage => 'إخفاء الرسالة';

  @override
  String get showMessage => 'إظهار الرسالة';

  @override
  String get createdBy => 'تم الإنشاء بواسطة';
  @override
  String get createdOn => 'أُنشئ في';

  @override
  String get incident => 'البلاغ';

  @override
  String get invalidIncidentType => 'نوع البلاغ المحدد غير صالح';

  @override
  String get reject => 'رفض';

  @override
  String get successfullyAdded => 'تمت الإضافة بنجاح';

  @override
  String get rejected => "مرفوض";

  @override
  String get incidenceReportReply => 'الرد على البلاغ';

  @override
  String get quickServices => 'الخدمات السريعة';

  @override
  String get labs => 'الفحوصات المخبرية';

  @override
  String get radiology => "أشعة";

  @override
  String get homeCare => 'الرعاية المنزلية';

  // NURSE REQUEST MODULE
  @override
  String get homeNursing => 'تمريض منزلي';

  @override
  String get newRequest => 'طلب جديد';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get requestHomeNursing => 'اطلب خدمة تمريض منزلي';

  @override
  String get serviceDescriptionEnglish => 'وصف الخدمة (بالإنجليزية)';

  @override
  String get serviceDescriptionArabic => 'وصف الخدمة (بالعربية)';

  @override
  String get atLeastOneDescriptionRequired =>
      'يرجى تقديم وصف الخدمة بلغة واحدة على الأقل.';

  @override
  String get preferredDate => 'التاريخ المفضل';

  @override
  String get preferredTime => 'الوقت المفضل (اختياري)';

  @override
  String get clear => 'مسح';

  @override
  String get durationHours => 'المدة (بالساعات)';

  // Verified CLDR Arabic plural forms: 1→ساعة، 2→ساعتان، 3-10→n ساعات، 11+→n ساعة
  @override
  String durationHoursValue(int n) {
    return Intl.plural(
      n,
      locale: 'ar',
      zero: 'صفر ساعات',
      one: 'ساعة واحدة',
      two: 'ساعتان',
      few: '$n ساعات',
      many: '$n ساعة',
      other: '$n ساعة',
    );
  }

  @override
  String get addressLine1 => 'العنوان (السطر الأول)';

  @override
  String get addressLine2 => 'سطر العنوان 2 (اختياري)';

  @override
  String get moreAddressDetails => 'تفاصيل عنوان إضافية';

  @override
  String get governorate => 'المحافظة';

  @override
  String get city => 'المدينة';

  @override
  String get stateLabel => 'الولاية / المنطقة';

  @override
  String get countryLabel => 'الدولة';

  @override
  String get postalCode => 'الرمز البريدي';

  @override
  String get contactPhone => 'هاتف الاتصال';

  @override
  String get patientNotes => 'ملاحظات إضافية (اختياري)';

  @override
  String get submitting => 'جارٍ الإرسال...';

  @override
  String get requestSubmitted => 'تم إرسال الطلب!';

  @override
  String get referenceNumber => 'رقم المرجع';

  @override
  String get copyReferenceNumber => 'نسخ رقم المرجع';

  @override
  String get copied => 'تم النسخ!';

  @override
  String get notifyTeamWillAssign =>
      'سيقوم فريقنا بتعيين ممرضة وتأكيد التفاصيل قريباً.';

  @override
  String get viewRequest => 'عرض الطلب';

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterPending => 'قيد الانتظار';

  @override
  String get filterAssigned => 'تم التعيين';

  @override
  String get filterConfirmed => 'مؤكد';

  @override
  String get filterInProgress => 'قيد التنفيذ';

  @override
  String get filterCompleted => 'مكتمل';

  @override
  String get filterCancelled => 'ملغى';

  @override
  String get nurseStatusPending => 'قيد الانتظار';

  @override
  String get nurseStatusAssigned => 'تم التعيين';

  @override
  String get nurseStatusConfirmed => 'مؤكد';

  @override
  String get nurseStatusInProgress => 'جارٍ التنفيذ';

  @override
  String get nurseStatusCompleted => 'مكتمل';

  @override
  String get nurseStatusCancelled => 'ملغى';

  @override
  String get assignedNurse => 'الممرضة المعيّنة';

  @override
  String get nurseRating => 'التقييم';

  @override
  String get nursePhone => 'هاتف الممرضة';

  @override
  String get estimatedTotal => 'الإجمالي التقديري';

  @override
  String get paymentStatusUnpaid => 'غير مدفوع';

  @override
  String get paymentContextUnavailable =>
      'لم نتمكن من فتح شاشة الدفع. جرّب مرة أخرى.';

  @override
  String get paymentStatusPaid => 'مدفوع';

  @override
  String get paymentStatusRefunded => 'مسترد';

  @override
  String get cancellationReason => 'سبب الإلغاء';

  @override
  String get completedOn => 'اكتمل في';

  @override
  String get statusHistory => 'سجل الحالة';

  @override
  String get emptyRequestsTitle => 'لا توجد طلبات بعد';

  @override
  String get emptyRequestsSubtitle => 'أرسل طلبك الأول للبدء';

  @override
  String get loadFailed => 'فشل التحميل. يرجى المحاولة مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get paymentConfirmationFailedRetry =>
      'تم خصم المبلغ لكن تعذر تأكيد الدفع مع الخادم. يُرجى إعادة المحاولة حتى لا تفقد دفعتك.';

  @override
  String get pleaseContactSupportWithTransactionId =>
      'يُرجى التواصل مع الدعم ومشاركة رقم العملية التالي:';

  @override
  String get phoneInvalid => 'يرجى إدخال رقم هاتف صالح (مثال: +201001234567)';

  @override
  String get noDialerAvailable => 'لا يوجد تطبيق هاتف متاح لإجراء المكالمات.';

  @override
  String get descriptionTooLong => 'يجب أن يكون الوصف 2000 حرف أو أقل';

  @override
  String get notesTooLong => 'يجب أن تكون الملاحظات 2000 حرف أو أقل';

  @override
  String get addressTooLong => 'يجب أن يكون العنوان 255 حرفًا أو أقل';

  @override
  String get cityRequired => 'المدينة مطلوبة';

  @override
  String get addressLine1Required => 'العنوان (السطر الأول) مطلوب';

  @override
  String get preferredDateRequired => 'التاريخ المفضل مطلوب';

  @override
  String get durationOutOfRange => 'يجب أن تكون المدة بين 1 و24 ساعة';

  @override
  String get unknownSubmitOutcomeBanner =>
      'يرجى التأكد من إنشاء طلبك قبل الإرسال مرة أخرى.';

  @override
  String get quickServiceHomeNursing => 'تمريض منزلي';

  // Pharmacy
  @override
  String get pharmacyHome => 'الصفحة الرئيسية للصيدلية';
  @override
  String get searchProducts => 'ابحث عن منتجات...';
  @override
  String get categories => 'الفئات';
  @override
  String get brands => 'العلامات التجارية';
  @override
  String get productTypes => 'أنواع المنتجات';
  @override
  String get featuredProducts => 'منتجات مميزة';
  @override
  String get addToCart => 'أضف إلى السلة';
  @override
  String get viewCart => 'عرض السلة';
  @override
  String get cart => 'السلة';
  @override
  String get cartEmpty => 'سلة التسوق فارغة';
  @override
  String get cartEmptyHint =>
      'لا توجد منتجات في السلة بعد. تصفح المنتجات أو ارفع وصفتك الطبية.';
  @override
  String get browsePharmacy => 'تصفح الصيدلية';
  @override
  String get deliveryAtCheckout => 'يتم احتساب التوصيل عند الدفع';
  @override
  String get needHelpUploadPrescription =>
      'هل تحتاج مساعدة في الاختيار؟ ارفع وصفتك الطبية.';
  @override
  String get checkout => 'إتمام الطلب';
  @override
  String get placeOrder => 'إتمام الطلب';
  @override
  String get orderSuccess => 'تم تقديم الطلب بنجاح';
  @override
  String get orderFailed => 'فشل تقديم الطلب';
  @override
  String get availablePharmacies => 'الصيدليات المتاحة';
  @override
  String get selectPharmacy => 'اختر الصيدلية';
  @override
  String get deliveryAddress => 'عنوان التوصيل';
  @override
  String get paymentMethod => 'طريقة الدفع';
  @override
  String get applyCoupon => 'تطبيق الكوبون';
  @override
  String get couponCode => 'رمز الخصم';
  @override
  String get deliveryFee => 'رسوم التوصيل';
  @override
  String get orders => 'الطلبات';
  @override
  String get orderDetail => 'تفاصيل الطلب';
  @override
  String get orderStatus => 'حالة الطلب';
  @override
  String get trackOrder => 'تتبع الطلب';
  @override
  String get cancelOrder => 'إلغاء الطلب';
  @override
  String get requestRefund => 'طلب استرداد';
  @override
  String get refundReason => 'سبب الاسترداد';
  @override
  String get prescriptions => 'الوصفات الطبية';
  @override
  String get uploadPrescription => 'رفع وصفة طبية';
  @override
  String get prescriptionRequired => 'الوصفة الطبية مطلوبة';
  @override
  String get uploadPrescriptionInstructions =>
      'يرجى رفع صورة واضحة لوصفتك الطبية.';
  @override
  String get takePhoto => 'التقاط صورة';
  @override
  String get chooseFromGallery => 'اختيار من المعرض';
  @override
  String get maxImageLimitReached => 'تم الوصول للحد الأقصى للصور (5 صور)';
  @override
  String get maximumQuantityReached => 'تم الوصول للحد الأقصى للكمية';
  @override
  String get markAllAsRead => 'تحديد الكل كمقروء';
  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';
  @override
  String get filter => 'تصفية';
  @override
  String get sort => 'فرز';

  // Pharmacy Sorting
  @override
  String get sortNewest => 'الأحدث';
  @override
  String get sortPriceAsc => 'السعر: من الأقل إلى الأعلى';
  @override
  String get sortPriceDesc => 'السعر: من الأعلى إلى الأقل';
  @override
  String get sortRating => 'التقييم';

  // Pharmacy Details
  @override
  String get productInfo => 'معلومات المنتج';
  @override
  String get manufacturer => 'الشركة المصنعة';
  @override
  String get dosage => 'الجرعة';
  @override
  String get unit => 'الوحدة';
  @override
  String get inStock => 'متوفر';
  @override
  String get outOfStock => 'غير متوفر';
  @override
  String get productUnavailable => 'هذا المنتج غير متاح حاليًا';

  // Pharmacy Prescription
  @override
  String get notesOptional => 'ملاحظات (اختياري)';
  @override
  String get submitPrescription => 'إرسال الوصفة الطبية';
  @override
  String get chooseImageSource => 'اختر مصدر الصورة';

  // Pharmacy Orders
  @override
  String get placedOn => 'تاريخ الطلب';
  @override
  String get items => 'الأصناف';
  @override
  String get orderNumber => 'رقم الطلب';
  @override
  String get fulfillFullCart => 'متاح بالكامل';
  @override
  String get fulfillPartialCart => 'متاح جزئيًا';
  @override
  String get partialFulfillWarning =>
      'هذه الصيدلية يمكنها فقط توفير بعض الأصناف في سلتك. هل تريد المتابعة مع الأصناف المتوفرة؟ سيتم إزالة الأصناف غير المتوفرة من هذا الطلب.';

  // Pharmacy Refunds
  @override
  String get refundRequests => 'طلبات الاسترداد';
  @override
  String get damagedProduct => 'منتج تالف';
  @override
  String get wrongProductReceived => 'استلام منتج غير صحيح';
  @override
  String get expiredProduct => 'منتج منتهي الصلاحية';
  @override
  String get qualityIssue => 'مشكلة في الجودة';
  @override
  String get submitRequest => 'إرسال الطلب';
  @override
  String get selectGovernorate => 'اختر المحافظة';

  @override
  String get selectCity => 'اختر المدينة';

  @override
  String get searchGovernorate => 'ابحث عن محافظة';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get allGovernorates => 'كل المحافظات';

  @override
  String get allCities => 'كل المدن';

  @override
  String get showDoctorsFromAllGovernorates => 'عرض الأطباء من كل المحافظات';

  @override
  String get showAllCitiesInGovernorate => 'عرض كل المدن في هذه المحافظة';

  @override
  String get showingCitiesInGovernorate => 'عرض المدن في هذه المحافظة';

  @override
  String get xDoctors => 'عدد الأطباء: {count}';

  @override
  String get xCities => '{count} مدينة';

  @override
  String get noGovernoratesFound => 'لم يتم العثور على محافظات';

  @override
  String get noCitiesFound => 'لم يتم العثور على مدن';

  @override
  String get noResultsFor => 'لا توجد نتائج لـ "{query}"';

  @override
  String get noCitiesAvailable => 'لا توجد مدن متاحة';

  @override
  String get applyGovernorateOnly => 'تطبيق المحافظة فقط';

  @override
  String get changeGovernorate => 'تغيير المحافظة';

  @override
  String get change => 'تغيير';

  @override
  String get failedToLoadGovernorates => 'تعذر تحميل المحافظات';

  @override
  String get failedToLoadCities => 'تعذر تحميل المدن';

  @override
  String get allLocations => 'كل المواقع';

  @override
  String get locationFilterFormat => '{governorate} > {city}';

  // DOCTOR VISIT MODULE
  @override
  String get homeVisit => 'زيارة منزلية';

  @override
  String get doctorVisit => 'زيارة الطبيب';

  @override
  String get homeVisitRequests => 'طلبات الزيارة المنزلية';

  @override
  String get newHomeVisitRequest => 'طلب زيارة منزلية جديد';

  @override
  String get requestHomeVisit => 'اطلب زيارة منزلية';

  @override
  String get noVisitRequests => 'لا توجد طلبات زيارة';

  @override
  String get noVisitRequestsTitle => 'لا توجد طلبات بعد';

  @override
  String get requestYourFirstVisit => 'أرسل طلب زيارتك الأول للبدء';

  @override
  String get visitReason => 'سبب الزيارة';

  @override
  String get visitReasonHint => 'صف أعراضك أو سبب الزيارة...';

  @override
  String get visitReasonRequired => 'سبب الزيارة مطلوب';

  @override
  String get visitReasonTooLong => 'الحد الأقصى 1000 حرف';

  @override
  String get preferredDateMustBeFuture =>
      'يجب أن يكون التاريخ اليوم أو في المستقبل';

  @override
  String get contactPhoneRequired => 'هاتف الاتصال مطلوب';

  @override
  String get contactPhoneInvalid => 'أدخل رقم هاتف صالح (مثال: +201001234567)';

  @override
  String get preferredDoctor => 'الطبيب المفضل';

  @override
  String get preferredDoctorOptional => 'الطبيب المفضل (اختياري)';

  @override
  String get selectPreferredDoctor => 'اختر الطبيب المفضل';

  @override
  String get clearDoctorSelection => 'إلغاء الاختيار';

  @override
  String get additionalNotes => 'ملاحظات إضافية';

  @override
  String get additionalNotesOptional => 'ملاحظات إضافية (اختياري)';

  @override
  String get additionalNotesHint =>
      'أي معلومات إضافية للطبيب (مثال: الطابق الثالث، لا يوجد مصعد)...';

  @override
  String get additionalNotesTooLong => 'الحد الأقصى 2000 حرف';

  @override
  String get requestSubmittedSuccessfully => 'تم إرسال الطلب بنجاح';

  @override
  String get referenceCopied => 'تم نسخ رقم المرجع';

  @override
  String get weWillGetBackToYouSoon => 'سنراجع طلبك ونعود إليك قريباً';

  @override
  String get requestDetails => 'تفاصيل الطلب';

  @override
  String get visitInformation => 'معلومات الزيارة';

  @override
  String get assignedDoctor => 'الطبيب المعين';

  @override
  String get yourVisitingDoctor => 'طبيب الزيارة';

  @override
  String get noDoctorAssignedYet => 'لم يتم تعيين طبيب بعد';

  @override
  String get visitCompleted => 'اكتملت الزيارة';

  @override
  String get visitCompletedAt => 'اكتملت الزيارة في';

  @override
  String get submittedOn => 'أُرسل في';

  @override
  String get visitChangedBy => 'عُدّلت الزيارة بواسطة';

  @override
  String get discountApplied => 'تم تطبيق الخصم';

  @override
  String get visitOfferCode => 'رمز العرض';

  @override
  String get youSaved => 'وفّرت';

  @override
  String get refresh => 'تحديث';

  @override
  String get serviceDuration => 'المدة';

  @override
  String get patientServed => 'المرضى';

  @override
  String get bookAppointment => 'احجز موعدًا';

  @override
  String get noUpcomingAppointments => 'لا توجد مواعيد قادمة';

  @override
  String get bookYourFirstAppointment => 'احجز موعدك الأول';

  // ICU Admission Module
  @override
  String get icuAdmission => 'الدخول إلى العناية المركزة';
  @override
  String get icuHospitals => 'مستشفيات تضم وحدات عناية مركزة';
  @override
  String get searchHospitals => 'ابحث عن مستشفيات...';
  @override
  String get hospitalsFound => 'مستشفيات متاحة';
  @override
  String get noHospitalsFound => 'لم يتم العثور على مستشفيات';
  @override
  String get hasAvailableBeds => 'توجد أسرة متاحة';
  @override
  String get noBedsAvailable => 'لا توجد أسرة متاحة';
  @override
  String get hospitalDetail => 'تفاصيل المستشفى';
  @override
  String get aboutHospital => 'نبذة عن المستشفى';
  @override
  String get departments => 'الأقسام';
  @override
  String get availableBeds => 'الأسرة المتاحة';
  @override
  String get totalBeds => 'إجمالي الأسرة';
  @override
  String get callHospital => 'اتصل بالمستشفى';
  @override
  String get callEmergency => 'اتصل بالطوارئ';
  @override
  String get openInMaps => 'فتح في تطبيق الخرائط';
  @override
  String get requestIcuAdmissionHere => 'اطلب دخول العناية المركزة هنا';
  @override
  String get icuDepartments => 'أقسام العناية المركزة';
  @override
  String get browseByDepartment => 'تصفح حسب قسم العناية المركزة';
  @override
  String get departmentDescription => 'وصف القسم';
  @override
  String get patientName => 'اسم المريض';
  @override
  String get patientAge => 'عمر المريض';

  @override
  String get invalidPatientAge => 'أدخل عمرًا من 0 إلى 150';

  @override
  String get reportDownloadUnavailable => 'هذا التقرير غير متاح بعد';

  @override
  String get invalidReportDownloadUrl => 'رابط التقرير غير آمن';

  @override
  String get reportDownloadFailed => 'تعذر تنزيل التقرير';

  @override
  String get labTestRequired => 'اختر تحليلًا قبل الحجز';

  @override
  String get preferredDatePast => 'اختر تاريخ اليوم أو تاريخًا لاحقًا';

  @override
  String get preferredTimeInvalid => 'اختر وقت موعد صالحًا';

  @override
  String get patientNotesTooLong => 'يجب ألا تتجاوز ملاحظات المريض 1000 حرف';
  @override
  String get selectedTest => 'الفحص المحدد';
  @override
  String get patientGender => 'جنس المريض';
  @override
  String get diagnosis => 'التشخيص';
  @override
  String get urgencyLevel => 'درجة الإلحاح';
  @override
  String get accompanyingName => 'اسم المرافق';
  @override
  String get accompanyingRelation => 'صلة القرابة بالمريض';
  @override
  String get accompanyingPhone => 'هاتف المرافق';
  @override
  String get nationalId => 'الرقم القومي (اختياري)';
  @override
  String get currentCondition => 'الحالة الراهنة (اختياري)';
  @override
  String get attendingDoctor => 'الطبيب المعالج (اختياري)';
  @override
  @override
  String get currentMedications => 'الأدوية الحالية (اختياري)';
  @override
  String get allergies => 'الحساسية (اختياري)';
  @override
  @override
  @override
  String get selectHospital => 'اختر المستشفى';
  @override
  String get selectDepartment => 'اختر القسم';
  @override
  String get changeHospital => 'تغيير';
  @override
  String get routine => 'اعتيادي';
  @override
  String get urgent => 'عاجل';
  @override
  String get critical => 'حرج';
  @override
  String get criticalUrgencyAlertTitle => 'درجة إلحاح حرجة!';
  @override
  String get criticalUrgencyAlertMessage =>
      'لقد اخترت درجة الإلحاح الحرج. للحالات الطارئة التي تهدد الحياة، يرجى الاتصال بخط الطوارئ فوراً.';
  @override
  String get callEmergencyHotline => 'اتصل بخط الطوارئ';
  @override
  String get continueForm => 'متابعة النموذج';
  @override
  @override
  String get underReview => 'قيد المراجعة';
  @override
  String get approved => 'تمت الموافقة';
  @override
  String get admitted => 'تم قبول الدخول';
  @override
  String get discharged => 'تم الخروج';
  @override
  @override
  @override
  String get status => 'الحالة';
  @override
  @override
  String get fieldRequired => 'هذا الحقل مطلوب';
  @override
  String get invalidPhone => 'صيغة الهاتف غير صالحة';
  @override
  String get maxCharsReached => 'تم الوصول إلى الحد الأقصى من الأحرف';
  @override
  String get invalidDate => 'تاريخ غير صالح';
  @override
  String get pleaseSelectHospital => 'الرجاء اختيار مستشفى';
  @override
  String get pleaseSelectDepartment => 'الرجاء اختيار قسم';
  @override
  @override
  @override
  String get copyReference => 'نسخ الرقم المرجعي';
  @override
  @override
  String get trackRequest => 'تتبع هذا الطلب';
  @override
  String get lastReference => 'آخر رقم مرجعي';
  @override
  String get goBackToHome => 'العودة إلى الرئيسية';
  @override
  String get cancelRequest => 'إلغاء الطلب';
  @override
  String get cancelConfirmation => 'هل أنت متأكد من إلغاء طلب الدخول هذا؟';
  @override
  String get cancelReason => 'سبب الإلغاء (اختياري)';
  @override
  String get confirmCancellation => 'تأكيد الإلغاء';
  @override
  String get keepRequest => 'الإبقاء على الطلب';
  @override
  String get requestCancelled => 'تم إلغاء الطلب بنجاح';
  @override
  String get emergencyHotline => 'خط الطوارئ';
  @override
  String get emergencyNumberCopied => 'تم نسخ رقم الطوارئ';
  @override
  String get callNow => 'اتصل الآن';

  @override
  String get locationUnavailable => 'الموقع غير متاح';
  @override
  String get myAdmissionRequests => 'طلبات الدخول إلى العناية المركزة';
  @override
  String get statusTimeline => 'التسلسل الزمني للحالة';
  @override
  String get admissionDetails => 'تفاصيل الدخول';
  @override
  String get room => 'الغرفة';
  @override
  String get bed => 'السرير';
  @override
  String get admittedAt => 'تاريخ الدخول';
  @override
  String get dischargeDetails => 'تفاصيل الخروج';
  @override
  String get dischargedAt => 'تاريخ الخروج';
  @override
  String get dischargeSummary => 'ملخص الخروج';
  @override
  String get rejectionReason => 'سبب الرفض';
  @override

  // Pharmacy Localized Strings
  @override
  String get pharmacyCouponApplied => 'تم تطبيق الكوبون بنجاح';
  @override
  String get pharmacyInvalidCoupon => 'كوبون غير صالح';
  @override
  String get pharmacyDeliveryAddressRequired => 'عنوان التوصيل مطلوب';
  @override
  String get pharmacyPrescriptionRequired =>
      'يرجى إرفاق وصفة طبية للأصناف التي تستلزم وصفة';
  @override
  String get pharmacySelectDeliveryAddress => 'اختر عنوان التوصيل';
  @override
  String get pharmacyCartPrescriptionWarning =>
      'بعض الأصناف في سلتك تستلزم وصفة طبية';
  @override
  String get pharmacyPrescriptionLabel => 'وصفة طبية';
  @override
  String get pharmacySelectPrescription => 'اختر وصفة طبية';
  @override
  String get pharmacyUploadNewPrescription => '+ رفع وصفة طبية جديدة';
  @override
  String get pharmacyCashOnDelivery => 'الدفع عند الاستلام';
  @override
  String get pharmacyWallet => 'المحفظة';
  @override
  String get pharmacyCancelOrderConfirm => 'هل أنت متأكد من إلغاء هذا الطلب؟';
  @override
  String get pharmacyYesCancel => 'نعم، إلغاء';
  @override
  String get pharmacyQty => 'الكمية';
  @override
  String get pharmacyNoOrders => 'لم تُجرِ أي طلبات بعد';
  @override
  String get pharmacyOrderSuccess => 'تم تقديم طلبك رقم #{orderNumber} بنجاح';
  @override
  String get pharmacyBackToHome => 'العودة إلى الصيدلية';
  @override
  String get pharmacyNoPharmaciesAvailable =>
      'لا توجد صيدليات يمكنها تلبية طلبك حالياً';
  @override
  String get pharmacyNoPrescriptions => 'لم تقم برفع أي وصفة طبية بعد';
  @override
  String get pharmacyPrescriptionImages => 'صور الوصفة الطبية';
  @override
  String get pharmacyRejectionReason => 'سبب الرفض';
  @override
  String get pharmacyUploadedOn => 'رُفعت في';
  @override
  String get pharmacySelectReason => 'اختر سبباً...';
  @override
  String get pharmacyRefundSubmitted => 'تم تقديم طلب الاسترداد بنجاح';
  @override
  String get pharmacyAdditionalNotes => 'ملاحظات إضافية';
  @override
  String get pharmacyDescribeIssue => 'اشرح المشكلة بالتفصيل...';
  @override
  String get pharmacyNoRefunds => 'لم تقم بأي طلبات استرداد بعد';
  @override
  String get pharmacyReason => 'السبب';
  @override
  String get pharmacyRefundAmount => 'مبلغ الاسترداد';
  @override
  String get pharmacyNoNotifications => 'لا توجد إشعارات حتى الآن';
  @override
  String get pharmacyNotesForPharmacy => 'أضف ملاحظات للصيدلية...';
  @override
  String get pharmacyNoDescription => 'لا يوجد وصف متاح';

  // LABS & RADIOLOGY MODULE
  @override
  String get labsAndRadiology => 'المختبرات والأشعة';
  @override
  String get bookDiagnosticTestsSubtitle =>
      'احجز الفحوصات التشخيصية واستعرض التقارير';
  @override
  String get orderMedicinesSubtitle => 'اطلب الأدوية ومستلزمات الرعاية الصحية';
  @override
  String get radiologyCenters => 'مراكز الأشعة';
  @override
  String get searchLabs => 'ابحث عن مختبرات';
  @override
  String get searchRadiologyCenters => 'ابحث عن مراكز أشعة';
  @override
  String get viewTests => 'عرض الفحوصات';
  @override
  String get startingFrom => 'يبدأ السعر من';
  @override
  String xReviews(int n) => Intl.plural(n,
      locale: 'ar',
      zero: 'لا توجد تقييمات',
      one: 'تقييم واحد',
      two: 'تقييمان',
      few: '$n تقييمات',
      many: '$n تقييماً',
      other: '$n تقييم');
  @override
  String get nearby => 'بالقرب مني';
  @override
  String get browseTestCategories => 'تصفح فئات التحاليل';
  @override
  String get allTests => 'كل الفحوصات';
  @override
  String get myTestOrders => 'طلباتي';
  @override
  String get noFacilitiesFound => 'لم يتم العثور على مراكز';
  @override
  String get testCategories => 'فئات الفحوصات';
  @override
  String xTests(int n) => Intl.plural(n,
      locale: 'ar',
      zero: 'لا توجد تحاليل',
      one: 'تحليل واحد',
      two: 'تحليلان',
      few: '$n تحاليل',
      many: '$n تحليلاً',
      other: '$n تحليل');
  @override
  String get noCategoriesFound => 'لم يتم العثور على فئات';
  @override
  String get tests => 'فحوصات';
  @override
  String get allTestsTitle => 'التحاليل التشخيصية';
  @override
  String get testDetails => 'تفاصيل التحليل';
  @override
  String get preparationInstructions => 'تعليمات التحضير';
  @override
  String get turnaroundTime => 'مدة ظهور النتائج';
  @override
  String xHoursTurnaround(int n) => 'النتائج خلال $n ساعة';
  @override
  String get imaging => 'فحوصات الأشعة';
  @override
  String get bookTest => 'حجز فحص';
  @override
  String get bookThisTest => 'احجز هذا الفحص';
  @override
  String get testCategoryLabel => 'الفئة';
  @override
  String get priceLabel => 'السعر';
  @override
  String get servicesOffered => 'الخدمات المقدمة';
  @override
  String get availableTests => 'الفحوصات المتاحة';
  @override
  String get facilityAddress => 'عنوان المركز';
  @override
  String get contactFacility => 'اتصل بالمركز';
  @override
  String get selectTime => 'اختر الوقت';
  @override
  String get selectDate => 'اختر التاريخ';
  @override
  String get availableSlots => 'المواعيد المتاحة';
  @override
  String get noSlotsAvailable => 'لا توجد مواعيد متاحة';
  @override
  String get tryAnotherDate => 'جرّب تاريخًا آخر';
  @override
  String get continueToConfirm => 'المتابعة للتأكيد';
  @override
  String get selectASlot => 'يرجى اختيار موعد متاح';
  @override
  String get slotConflictTitle => 'تعارض في الموعد';
  @override
  String get slotConflictBody =>
      'تم حجز هذا الموعد للتو. يرجى اختيار موعد آخر.';
  @override
  String get confirmBooking => 'تأكيد الحجز';
  @override
  String get bookingSummary => 'ملخص الحجز';
  @override
  String get testPrice => 'سعر الفحص';
  @override
  String get patientNotesOptional => 'ملاحظات إضافية (اختياري)';
  @override
  String get patientNotesHint => 'أضف أي تعليمات خاصة للمركز...';
  @override
  String get confirmAndBook => 'تأكيد وحجز';
  @override
  String get bookingSubmitted => 'تم إرسال الحجز بنجاح';
  @override
  String get yourTestIsBooked => 'تم حجز فحصك التشخيصي بنجاح';
  @override
  String get backToLabs => 'العودة للمختبرات والأشعة';
  @override
  String get myOrders => 'طلباتي';
  @override
  String get orderRef => 'رقم الطلب';
  @override
  String get bookedOn => 'تاريخ الحجز';
  @override
  String get slotDate => 'تاريخ الموعد';
  @override
  String get slotTime => 'وقت الموعد';
  @override
  String get pricing => 'الأسعار';
  @override
  String get downloadingReport => 'جارٍ تحميل التقرير...';
  @override
  String get downloadFailed => 'فشل التحميل. يرجى المحاولة مرة أخرى.';
  @override
  String get reportNotReady => 'التقرير غير جاهز للتحميل بعد.';
  @override
  String get cancelOrderTitle => 'إلغاء طلب الفحص';
  @override
  String get cancelOrderConfirm => 'هل أنت متأكد من إلغاء هذا الطلب؟';
  @override
  String get cancelReasonOptional => 'سبب الإلغاء (اختياري)';
  @override
  String get keepOrder => 'الاحتفاظ بالطلب';
  @override
  String get statusPending => 'قيد الانتظار';
  @override
  String get statusConfirmed => 'مؤكد';
  @override
  String get statusSampleCollected => 'تم جمع العينة';
  @override
  String get statusInProgress => 'قيد التنفيذ';
  @override
  String get statusCompleted => 'مكتمل';
  @override
  String get statusCancelled => 'أُلغي';
  @override
  String get statusRejected => 'مرفوض';
}
