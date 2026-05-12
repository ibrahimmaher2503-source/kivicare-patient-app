import 'package:intl/intl.dart';
import 'languages.dart';

class LanguageAr extends BaseLanguage {
  @override
  String get pharmacy => 'الصيدلية';
  @override
  String get language => 'لغة';

  @override
  String get badRequest => '400 طلب سىء';

  @override
  String get forbidden => '403 ممنوع';

  @override
  String get pageNotFound => '404: الصفحة لم يتم العثور عليها';

  @override
  String get tooManyRequests => '429: الكثير من الطلبات';

  @override
  String get internalServerError => '500: خطأ الخادم الداخلي';

  @override
  String get badGateway => '502 مدخل غير صالح';

  @override
  String get serviceUnavailable => '503 الخدمة غير متوفرة';

  @override
  String get gatewayTimeout => 'البوابة 504 انتهى الزمن';

  @override
  String get hey => 'يا';

  @override
  String get hello => 'مرحبًا';

  @override
  String get thisFieldIsRequired => 'هذه الخانة مطلوبه';

  @override
  String get contactNumber => 'رقم الاتصال';

  @override
  String get gallery => 'صالة عرض';

  @override
  String get camera => 'آلة تصوير';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get update => 'تحديث';

  @override
  String get reload => 'إعادة تحميل';

  @override
  String get address => 'عنوان';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get pressBackAgainToExitApp => 'اضغط مرة أخرى للخروج من التطبيق';

  @override
  String get invalidUrl => 'URL غير صالح';

  @override
  String get cancel => 'يلغي';

  @override
  String get delete => 'يمسح';

  @override
  String get deleteAccountConfirmation =>
      'سيتم حذف حسابك بشكل دائم. لن تتم استعادة بياناتك مرة أخرى.';

  @override
  String get demoUserCannotBeGrantedForThis =>
      'لا يمكن منح المستخدم التجريبي لهذا الإجراء';

  @override
  String get somethingWentWrong => 'هناك خطأ ما';

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
      'كلمة المرور الجديدة لا تتطابق مع مؤكد كلمة المرور!';

  @override
  String get location => 'موقع';

  @override
  String get yes => 'نعم';

  @override
  String get submit => 'يُقدِّم';

  @override
  String get select => 'اختيار';

  @override
  String get chooseAnother => 'اختر آخر';

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
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get email => 'بريد إلكتروني';

  @override
  String get mainStreet => 'شارع رئيسي';

  @override
  String get toResetYourNew =>
      'لإعادة تعيين كلمة المرور الجديدة ، يرجى إدخال عنوان بريدك الإلكتروني';

  @override
  String get stayTunedNoNew => 'ابقوا متابعين! لا يوجد إشعارات جديدة.';

  @override
  String get noNewNotificationsAt =>
      'لا توجد إشعارات جديدة في الوقت الحالي. سنبقيك على اطلاع عندما يكون هناك تحديث.';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get explore => 'يستكشف';

  @override
  String get settings => 'إعدادات';

  @override
  String get rateApp => 'قيم التطبيق';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get logout => 'تسجيل خروج';

  @override
  String get rememberMe => 'تذكرنى';

  @override
  String get forgotPassword => 'هل نسيت كلمة السر؟';

  @override
  String get forgotPasswordTitle => 'هل نسيت كلمة السر';

  @override
  String get registerNow => 'سجل الان';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get createYourAccountFor => 'قم بإنشاء حسابك لتجربة أفضل';

  @override
  String get signUp => 'اشتراك';

  @override
  String get alreadyHaveAnAccount => 'هل لديك حساب؟';

  @override
  String get yourPasswordHasBeen =>
      'تمت إعادة تعيين كلمة المرور الخاصة بك بنجاح';

  @override
  String get youCanNowLog =>
      'يمكنك الآن تسجيل الدخول إلى حسابك الجديد بكلمة مرورك الجديدة';

  @override
  String get done => 'منتهي';

  @override
  String get pleaseAcceptTermsAnd => 'يرجى قبول الشروط والأحكام';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get eG => 'على سبيل المثال';

  @override
  String get merry => 'مرح';

  @override
  String get doe => 'ظبية';

  @override
  String get welcomeBackToThe => 'مرحبًا بك في';

  @override
  String get welcomeToThe => 'أهلا بك في';

  @override
  String get doYouWantToLogout => 'هل ترغب بالخروج؟';

  @override
  String get appTheme => 'موضوع التطبيق';

  @override
  String get guest => 'ضيف';

  @override
  String get notifications => 'إشعارات';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get getInTouchWithSupport => 'تواصل مع الدعم';

  @override
  String get newUpdate => 'تحديث جديد';

  @override
  String get anUpdateTo => 'تحديث ل';

  @override
  String get isAvailableGoTo =>
      'متاح. انتقل إلى المتجر وتنزيل الإصدار الجديد من التطبيق.';

  @override
  String get later => 'لاحقاً';

  @override
  String get closeApp => 'أغلق التطبيق';

  @override
  String get updateNow => 'تحديث الان';

  @override
  String get signInFailed => 'فشل تسجيل الدخول';

  @override
  String get userCancelled => 'تم إلغاء المستخدم';

  @override
  String get appleSigninIsNot => 'علامة Apple غير متوفرة لجهازك';

  @override
  String get eventStatus => 'حالة الحدث';

  @override
  String get eventAddedSuccessfully => 'تمت إضافة الحدث بنجاح';

  @override
  String get notRegistered => 'غير مسجل؟';

  @override
  String get signInWithGoogle => 'الدخول مع جوجل';

  @override
  String get signInWithApple => 'تسجيل الدخول مع Apple';

  @override
  String get orSignInWith => 'أو تسجيل الدخول مع';

  @override
  String get ohNoYouAreLeaving => 'أوه لا ، أنت تغادر!';

  @override
  String get oldPassword => 'كلمة المرور القديمة';

  @override
  String get oldAndNewPassword => 'كلمة المرور القديمة والجديدة هي نفسها.';

  @override
  String get personalizeYourProfile => 'تخصيص ملفك الشخصي';

  @override
  String get themeAndMore => 'موضوع وأكثر';

  @override
  String get showSomeLoveShare => 'أظهر بعض الحب ، شارك!';

  @override
  String get privacyPolicyTerms => 'سياسة الخصوصية والشروط والأحكام';

  @override
  String get securelyLogOutOfAccount => 'قم بتسجيل الخروج من الحساب بشكل آمن';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get successfully => 'بنجاح';

  @override
  String get clearAll => 'امسح الكل';

  @override
  String get notificationDeleted => 'تم حذف الإخطار';

  @override
  String get doYouWantToRemoveNotification => 'هل تريد إزالة الإخطار';

  @override
  String get doYouWantToClearAllNotification => 'هل تريد إلغاء الإخطار';

  @override
  String get locationPermissionDenied => 'تم رفض إذن الموقع';

  @override
  String get enableLocation => 'تمكن موقع';

  @override
  String get permissionDeniedPermanently => 'تم رفض الإذن بشكل دائم';

  @override
  String get chooseYourLocation => 'اختر موقعك';

  @override
  String get setAddress => 'تعيين العنوان';

  @override
  String get sorryUserCannotSignin => 'آسف لا يمكن للمستخدم تسجيل الدخول';

  @override
  String get iAgreeToThe => 'أنا أوافق على';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get doYouConfirmThisAppointment => 'هل تؤكد هذا الموعد؟';

  @override
  String get confirmAppointment => 'تأكيد الموعد';

  @override
  String get iHaveReadAll =>
      'لقد قرأت جميع التفاصيل وملأت النموذج وسأؤكد هذا الموعد مع';

  @override
  String get confirm => 'تأكيد';

  @override
  String get doYouConfirmThisPayment => 'هل تؤكد هذه الدفعة؟';

  @override
  String get exploreTopClinicsWithAdvancedServicesTailored =>
      "استكشف العيادات العليا مع الخدمات المتقدمة المصممة لتلبية احتياجاتك";

  @override
  String get discoverYourIdealClinicWithOurPersonalizedSea =>
      "اكتشف عيادتك المثالية مع بحثنا الشخصي.هيا بنا نبدأ!";

  @override
  String get weHaveEmailedYourPasswordResetLink =>
      "لقد أرسلنا بريدًا إلكترونيًا إلى رابط إعادة تعيين كلمة المرور الخاصة بك!";

  @override
  String get resetYourPassword => "اعد ضبط كلمه السر";

  @override
  String get enterYourEmailAddressToResetYourNewPassword =>
      "أدخل عنوان بريدك الإلكتروني لإعادة تعيين كلمة المرور الجديدة.";

  @override
  String get sendCode => "إرسال الرمز";

  @override
  String get edit => "يحرر";

  @override
  String get gender => "جنس";

  @override
  String get profile => "حساب تعريفي";

  @override
  String get encounters => "اللقاءات";

  @override
  String get seeYourEncounterData => "انظر بيانات المواجهة الخاصة بك";

  @override
  String get version => "إصدار";

  @override
  String get userNotCreated => "لم يتم إنشاء المستخدم";

  @override
  String get notAMember => "ليس عضوا؟";

  @override
  String get registerYourAccountForBetterExperience =>
      "سجل حسابك للحصول على خبرة أفضل";

  @override
  String get termsConditions => "البنود و الظروف";

  @override
  String get and => "و";

  @override
  String get privacyPolicy => "سياسة الخصوصية";

  @override
  String get appointment => "ميعاد";

  @override
  String get doctor => "طبيب";

  @override
  String get payment => "قسط";

  @override
  String get doYouWantToCancelAppointment => "هل تريد إلغاء الموعد؟";

  @override
  String get videoCallLinkIsNotFound =>
      "لم يتم العثور على رابط مكالمات الفيديو!";

  @override
  String get thisIsNotAOnlineService => "هذه ليست خدمة عبر الإنترنت!";

  @override
  String get oppsThisAppointmentIsNotConfirmedYet =>
      "أوس!لم يتم تأكيد هذا الموعد بعد!";

  @override
  String get oppsThisAppointmentHasBeenCancelled => "أوس!تم إلغاء هذا الموعد!";

  @override
  String get oppsThisAppointmentHasBeenCompleted =>
      "أوس!تم الانتهاء من هذا الموعد!";

  @override
  String get noTimeSlotsAvailable => "لا توجد فتحات زمنية متاحة";

  @override
  String get chooseTime => "اختر الوقت";

  @override
  String get rescheduleBooking => "إعادة جدولة الحجز";

  @override
  String get searchForService => "ابحث عن الخدمة";

  @override
  String get statusListIsEmpty => "قائمة الحالة فارغة";

  @override
  String get thereAreNoStatusListedAtTheMomentStayTunedFor =>
      "لا توجد حالة مدرجة في الوقت الحالي.ترقبوا المزيد من الخيارات.";

  @override
  String get chooseDate => "اختر موعدا";

  @override
  String get doYouWantToChangeTheTimeSlotOfThisAppointment =>
      "هل تريد تغيير الفتحة الزمنية لهذا الموعد؟";

  @override
  String get no => "لا";

  @override
  String get somethingWentWrongPleaseTryAgainLater =>
      "هناك خطأ ما. الرجاء معاودة المحاولة في وقت لاحق.";

  @override
  String get doYouWantToRemoveThisReview => "هل تريد إزالة هذا الاستعراض؟";

  @override
  String get encounterDetail => "مواجهة التفاصيل";

  @override
  String get view => "منظر";

  @override
  String get doctorName => "اسم الطبيب";

  @override
  String get active => "نشيط";

  @override
  String get closed => "مغلق";

  @override
  String get clinicName => "اسم العيادة";

  @override
  String get description => "وصف";

  @override
  String get payNow => "ادفع الآن";

  @override
  String get medicalReport => "تقرير طبي";

  @override
  String get paymentDetail => "تفاصيل الدفع";

  @override
  String get price => "سعر";

  @override
  String get discount => "تخفيض";

  @override
  String get off => "أقل";

  @override
  String get subtotal => "نطاق فرعي";

  @override
  String get tax => "ضريبة";

  @override
  String get total => "المجموع";

  @override
  String get yourReview => "مراجعتك";

  @override
  String get by => "بواسطة";

  @override
  String get youHaventRatedYet => "لم تصنف بعد";

  @override
  String get yourFeedbackWillImproveOurService => "ملاحظاتك ستحسن خدمتنا.";

  @override
  String get writeHere => "اكتب هنا..";

  @override
  String get writeYourFeedbackHere => "اكتب ملاحظاتك هنا ..";

  @override
  String get pleaseSelectRatings => "الرجاء تحديد التصنيفات";

  @override
  String get all => "الجميع";

  @override
  String get upcoming => "القادمة";

  @override
  String get completed => "مكتمل";

  @override
  String get appointmentCancelSuccessfully => "موعد إلغاء بنجاح";

  @override
  String get appointments => "تعيينات";

  @override
  String get noAppointmentsFound => "لم يتم العثور على مواعيد";

  @override
  String get thereAreCurrentlyNoAppointmentsAvailableStart =>
      "لا توجد مواعيد متاحة حاليًا.ابدأ في حجز موعدك التالي الآن.";

  @override
  String get encounter => "يقابل";

  @override
  String get basicInformation => "معلومات اساسية";

  @override
  String get problems => "مشاكل";

  @override
  String get observations => "الملاحظات";

  @override
  String get notes => "ملحوظات";

  @override
  String get prescription => "روشتة";

  @override
  String get frequency => "تكرار";

  @override
  String get days => "أيام";

  @override
  String get otherInformation => "معلومات أخرى";

  @override
  String get patientSoap => "صابون المريض";

  @override
  String get category => "فئة";

  @override
  String get noCategoryFound => "لم يتم العثور على فئة";

  @override
  String get viewDetail => "عرض التفاصيل";

  @override
  String get noServicesFoundAtAMoment => "لم يتم العثور على خدمات في لحظة";

  @override
  String get looksLikeThereIsNoServicesForThis => "يبدو أنه لا توجد خدمات لهذا";

  @override
  String get wellKeepYouPostedWhenTheresAnUpdate =>
      "سنبقيك منشورًا عند وجود تحديث.";

  @override
  String get services => "خدمات";

  @override
  String get sessions => "جلسات";

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
      "لم يتم العثور على خدمات النظام في لحظة";

  @override
  String get looksLikeThereIsNoSystemServicesForThis =>
      "يبدو أنه لا توجد خدمات نظام لهذا";

  @override
  String get appointmentsSummary => "ملخص المواعيد";

  @override
  String get date => "تاريخ";

  @override
  String get time => "وقت";

  @override
  String get service => "خدمة";

  @override
  String get clinic => "عيادة";

  @override
  String get proceed => "يتابع";

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
  String get serviceListIsEmpty => "قائمة الخدمة فارغة.";

  @override
  String get thereAreNoServicesListedAtTheMomentStayTunedF =>
      "لا توجد خدمات مدرجة في الوقت الحالي.ترقبوا المزيد من عروض الخدمة.";

  @override
  String get kindlyChooseAServiceFirst => "يرجى اختيار الخدمة أولا";

  @override
  String get chooseClinic => "اختر العيادة";

  @override
  String get searchForClinic => "ابحث عن العيادة";

  @override
  String get clinicListIsEmpty => "قائمة العيادة فارغة.";

  @override
  String get thereAreNoClinicsListedAtTheMomentStayTunedFo =>
      "لا توجد عيادات مدرجة في الوقت الحالي.ترقبوا المزيد من العيادات.";

  @override
  String get kindlyChooseAClinicFirst => "يرجى اختيار عيادة أولا";

  @override
  String get chooseDoctor => "اختر الطبيب";

  @override
  String get searchForDoctor => "ابحث عن الطبيب";

  @override
  String get thereAreNoDoctorsListedAtTheMomentStayTunedFo =>
      "لا يوجد أطباء مدرجين في الوقت الحالي.ترقبوا المزيد من الخيارات.";

  @override
  String get writeMedicalHistory => "اكتب التاريخ الطبي";

  @override
  String get paymentDetails => "بيانات الدفع";

  @override
  String get asPerDoctorCharges => "حسب رسوم الطبيب";

  @override
  String get next => "التالي";

  @override
  String get personalizedHealthPlansForYourJourney => "خطط صحية مخصصة لرحلتك";

  @override
  String get stayOnTrackAndSetPersonalGoals =>
      "ابق على المسار الصحيح ووضع الأهداف الشخصية";

  @override
  String get discoverAndGetSupportWithin24Hours =>
      "اكتشف واحصل على الدعم في غضون 24 ساعة";

  @override
  String get customizeHealthPlansForATailoredApproachAlign =>
      "تخصيص الخطط الصحية لنهج مخصص ، ومواءمة كل جانب مع احتياجاتك.";

  @override
  String get focusOnYourPathSetClearGoalsAndStrideForwardW =>
      "ركز على طريقك ، ووضع أهداف واضحة ، والخطوة إلى الأمام مع العزم والغرض.";

  @override
  String get exploreFindSolutionsAndReceiveAssistanceSwift =>
      "استكشف ، وإيجاد الحلول ، وتلقي المساعدة بسرعة ، شبكة الدعم الخاصة بك جاهزة في غضون 24 ساعة.";

  @override
  String get transactionIsInProcess => 'الصفقة قيد التنفيذ...';

  @override
  String get enterYourMsisdnHere => 'أدخل msisdn الخاص بك هنا';

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
      'يتجاوز حد (حدود) مبلغ السحب / تم تجاوز حد مبلغ السحب';

  @override
  String get inProcess => 'تحت المعالجة';

  @override
  String get transactionTimedOut => 'انتهت مهلة المعاملة';

  @override
  String get notEnoughBalance => 'لا يوجد رصيد كافي';

  @override
  String get refused => 'رفض';

  @override
  String get doNotHonor => 'لا تتباهي';

  @override
  String get transactionNotPermittedTo =>
      'المعاملة غير مسموح بها للمدفوع لأمره';

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
      'لا تزال المعاملة قيد المعالجة وهي في حالة غامضة. يرجى إجراء الاستعلام عن المعاملة لجلب حالة المعاملة.';

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
  String get theTransactionWasRefused => 'تم رفض الصفقة';

  @override
  String get encryptionKeyHasBeen => 'تم جلب مفتاح التشفير بنجاح';

  @override
  String get transactionHasBeenExpired => 'لقد انتهت صلاحية المعاملة';

  @override
  String get payeeIsAlreadyInitiated =>
      'لقد تم بالفعل بدء المستفيد في الإيقاف أو الحظر أو عدم التسجيل على منصة Airtel Money';

  @override
  String get theTransactionWasNot => 'لم يتم العثور على الصفقة.';

  @override
  String get thisIsAGeneric => 'هذا رفض عام له عدة أسباب محتملة';

  @override
  String get theTransactionWasTimed => 'انتهت مهلة المعاملة.';

  @override
  String get xSignatureAndPayloadDid => 'توقيع x والحمولة غير متطابقين';

  @override
  String get couldNotFetchEncryption => 'تعذر جلب مفتاح التشفير';

  @override
  String get transactionFailed => 'فشل الاجراء';

  @override
  String get transactionCancelled => 'تم إلغاء المعاملة';

  @override
  String get paymentSuccess => "الدفع الناجح";

  @override
  String get redirectingToBookings => "إعادة التوجيه إلى الحجوزات ..";

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
  String get assessment => "تقدير";

  @override
  String get plan => "يخطط";

  @override
  String get bodyChart => "مخطط الجسم";

  @override
  String get doctorsAvailable => "الأطباء المتاحين";

  @override
  String get noDoctorsAvailable => "لا أطباء متاح";

  @override
  String get photosAvailable => "الصور المتاحة";

  @override
  String get noPhotosAvailable => "لا توجد صور متوفرة";

  @override
  String get looksLikeThereIsNoServicesListedOnThisClinicW =>
      "يبدو أنه لا توجد خدمات مدرجة في هذه العيادة ، سنبقيك على اطلاع عندما يكون هناك تحديث.";

  @override
  String get session => "حصة";

  @override
  String get unavailable => "غير متوفره";

  @override
  String get lblBreak => "استراحة";

  @override
  String get clinicDetail => "تفاصيل العيادة";

  @override
  String get pincode => "الرمز البريدي";

  @override
  String get readMore => "اقرأ أكثر";

  @override
  String get readLess => "أقرأ أقل";

  @override
  String get noGalleryFoundAtAMoment => "لم يتم العثور على معرض في لحظة";

  @override
  String get looksLikeThereIsNoGalleryForThisClinicWellKee =>
      "يبدو أنه لا يوجد معرض لهذه العيادة ، سنبقيك على اطلاع عندما يكون هناك تحديث.";

  @override
  String get clinics => "العيادات";

  @override
  String get availableClinicsFor => "العيادات المتاحة ل";

  @override
  String get noClinicsFoundAtAMoment => "لم يتم العثور على عيادات في لحظة";

  @override
  String get looksLikeThereIsNoClinicForThisServiceWellKee =>
      "يبدو أنه لا توجد عيادة لهذه الخدمة ، سنبقيك على اطلاع عندما يكون هناك تحديث.";

  @override
  String get searchClinicHere => "عيادة البحث هنا";

  @override
  String get home => "بيت";

  @override
  String get aboutMyself => "عن نفسي";

  @override
  String get about => "عن";

  @override
  String get contactInfo => "معلومات الاتصال";

  @override
  String get specialization => "تخصص";

  @override
  String get experience => "خبرة";

  @override
  String get experienceSpecializationContactInfo =>
      "الخبرة ، التخصص ، معلومات الاتصال";

  @override
  String get reviews => "المراجعات";

  @override
  String get noReviewsAvailable => "لا توجد مراجعات متاحة";

  @override
  String get qualification => "مؤهل";

  @override
  String get qualificationInDetail => "التأهيل بالتفصيل";

  @override
  String get year => "سنة";

  @override
  String get degree => "درجة";

  @override
  String get university => "جامعة";

  @override
  String get noQualificationsFound => "لم يتم العثور على مؤهلات!";

  @override
  String get looksLikeThereAreNoQualificationsAddedByThisD =>
      "يبدو أنه لا توجد مؤهلات يضاف إليها هذا الطبيب.";

  @override
  String get totalAppointmentsDone => "إجمالي المواعيد المنجزة";

  @override
  String get looksLikeThereIsNoServicesProvidedByThisDocto =>
      "يبدو أنه لا توجد خدمات يقدمها هذا الطبيب ، سنبقيك على اطلاع عندما يكون هناك تحديث.";

  @override
  String get doctorDetail => "تفاصيل الطبيب";

  @override
  String get socialMedia => "وسائل التواصل الاجتماعي";

  @override
  String get noDoctorsFoundAtAMoment => "لم يتم العثور على أطباء في لحظة";

  @override
  String get looksLikeThereIsNoDoctorsForThisClinicWellKee =>
      "يبدو أنه لا يوجد أطباء لهذه العيادة ، سنبقيك على اطلاع عندما يكون هناك تحديث.";

  @override
  String get noReviewsFoundAtAMoment => "لم يتم العثور على مراجعات في لحظة";

  @override
  String get looksLikeThereIsNoReviewsWellKeepYouPostedWhe =>
      "يبدو أنه لا توجد مراجعات ، سنبقيك على اطلاع عندما يكون هناك تحديث.";

  @override
  String get searchHere => "ابحث هنا";

  @override
  String get searchDoctorHere => "بحث الطبيب هنا";

  @override
  String get noEncountersFound => "لم يتم العثور على لقاءات!";

  @override
  String get looksLikeThereIsNoEncountersWellKeepYouPosted =>
      "يبدو أنه لا توجد لقاءات ، سنبقيك على اطلاع عندما يكون هناك تحديث.";

  @override
  String get clinicsNearYou => "العيادات القريبة منك";

  @override
  String get upcomingAppointments => "المواعيد القادمة";

  @override
  String get great => "عظيم!";

  @override
  String get bookingSuccessful => "حجز ناجح";

  @override
  String get yourAppointmentHasBeenBookedSuccessfully => "تم حجز موعدك بنجاح";

  @override
  String get totalPayment => "المبلغ الإجمالي";

  @override
  String get goToAppointments => "اذهب إلى المواعيد";

  @override
  String get noteForCashPaymentPurposesDontUseThePayNowBut =>
      "ملاحظة: لأغراض الدفع النقدي ، لا تستخدم زر \"الدفع الآن\".إذا كنت ترغب في إجراء دفعة نقدًا ، فيمكنك إعطاء الأموال يدويًا للطبيب وإكمال موعدك من جانب الطبيب.";

  @override
  String get choosePaymentMethod => "اختر وسيلة الدفع";

  @override
  String get chooseOurConvenientPaymentOptionAndUnlockUnli =>
      "اختر خيار الدفع المريح الخاص بنا وإلغاء تأمين وصول غير محدود إلى امتيازات حصرية.";

  @override
  String get doYouWantToReplaceThePreviousServiceWithTheCu =>
      "هل تريد استبدال الخدمة السابقة بالذات الحالية؟";

  @override
  String get bookNow => "احجز الآن";

  @override
  String get aboutService => "حول الخدمة";

  @override
  String get advancePayableAmount => "مبلغ مستحق الدفع";

  @override
  String get advancePaidAmount => "المبلغ المتقدم المدفوع";

  @override
  String get remainingPayableAmount => "المبلغ المستحق المتبقي";

  @override
  String get walletHistory => "تاريخ المحفظة";

  @override
  String get noWalletDataFound => "لم يتم العثور على بيانات محفظة!";

  @override
  String get oppsNoWalletDataFoundAtAMoment =>
      "أوس!لم يتم العثور على بيانات محفظة في لحظة.";

  @override
  String get walletBalance => "توازن المحفظة";

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
      '* ملاحظة: في حالة فشلك في سداد الدفعة المقدمة، ستحتاج إلى دفع المبلغ المستحق الدفع مقدمًا عن طريق النقر فوق الزر ""ادفع الآن"" أدناه. وإلا فلن تتم معالجة موعدك، أو ستحتاج إلى حجز موعد جديد.';

  @override
  String get serviceTotal => 'إجمالي الخدمة';

  @override
  String get remainingAmount => 'المبلغ المتبقي';

  @override
  String get refundableAmount => 'المبلغ القابل للاسترداد';

  @override
  String get appointmentId => 'معرف الموعد:';

  @override
  String get youDontHaveEnoughBalanceToCompleteThePaymentU =>
      'ليس لديك رصيد كافي لإكمال الدفع باستخدام محفظتك.';

  @override
  String get advancePayment => 'الدفع المسبق';

  @override
  String get doYouWantToPerformThisAction => 'هل تريد تنفيذ هذا الإجراء؟';

  @override
  String get bookedFor => 'حجزت ل';

  @override
  String get addPatient => 'إضافة مريض';

  @override
  String get relation => 'علاقة';

  @override
  String get save => 'يحفظ';

  @override
  String get managePatient => 'إدارة المريض';

  @override
  String get otherPatient => 'مريض آخر';

  @override
  String get manageOtherPatient => 'إدارة المريض الآخر';

  @override
  String get genderWithColon => 'جنس:';

  @override
  String get contactNumberWithColon => 'رقم الاتصال:';

  @override
  String get dobWithColon => 'د-و-ب:';

  @override
  String get noPatientsFound => 'لم يتم العثور على مرضى';

  @override
  String get editPatient => 'تحرير المريض';

  @override
  String get doYouWantToDeleteYourOtherPatientsProfile =>
      'هل تريد حذف الملف الشخصي لمريضك الآخر؟';

  @override
  String get birthdateIsRequired => 'مطلوب تاريخ الميلاد';

  @override
  String get selectBirthdate => 'حدد تاريخ الميلاد';

  @override
  String get bookedForWithColon => 'حجزت ل: ';

  @override
  String get inClinic => 'في العيادة';

  @override
  String get online => 'متصل';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get checkIn => 'تحقق في';

  @override
  String get cancelled => 'تم الإلغاء';

  @override
  String get advancePaid => 'المدفوعة مقدما';

  @override
  String get paid => 'مدفوع';

  @override
  String get advanceRefunded => 'تم رد المبلغ المدفوع مسبقًا';

  @override
  String get refunded => 'ردها';

  @override
  String get failed => 'فشل';

  @override
  String get ourPopularDoctor => 'أطباؤنا المشهورون';

  @override
  String get ourPopularSevices => 'خدماتنا الشائعة';

  @override
  String get ourPopularClinics => 'عياداتنا الشائعة';

  @override
  String get newAppointmentBooked => 'تم حجز موعد جديد';

  @override
  String get appointmentCompleted => 'اكتمل الموعد';

  @override
  String get appointmentRejected => 'تم رفض التعيين';

  @override
  String get appointmentCancelled => 'تم إلغاء الموعد';

  @override
  String get appointmentRescheduled => 'تمت إعادة جدولة الموعد';

  @override
  String get appointmentAccepted => 'تم قبول التعيين';

  @override
  String get forgetEmailPassword => 'نسيت كلمة مرور البريد الإلكتروني';

  @override
  String get parents => 'آباء';

  @override
  String get brother => 'أخ';

  @override
  String get siblings => 'إخوة';

  @override
  String get spouse => 'زوج';

  @override
  String get relative => 'نسبي';

  @override
  String get deleteConfirmation => 'حذف التأكيد';

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
  String get others => 'آحرون';

  @override
  String get appliedInclusiveTaxes => "الضرائب الشاملة المطبقة";

  @override
  String get includesInclusiveTax => "يشمل الضريبة الشاملة";

  @override
  String get inclusiveTaxes => "الضرائب الشاملة";

  @override
  String get servicePrice => "سعر الخدمة";

  @override
  String get inclusiveTax => "الضريبة الشاملة";

  @override
  String get appliedExclusiveTaxes => "الضرائب الحصرية المطبقة";

  @override
  String get exclusiveTax => "الضريبة الحصرية";

  @override
  String get appliedTaxes => "الضرائب المطبقة";

  @override
  String cancellationChargesWillBeAppliedForCancellationWithin(
          String amount, String hours) =>
      "سيتم تطبيق رسوم إلغاء بقيمة $amount للإلغاء خلال $hours ساعة.";

  @override
  String get cancelAppointment => "إلغاء الحجز";

  @override
  String get goBack => "العودة";

  @override
  String cancellationFeesWillBeAppliedIfYouCancelWithinHoursOfScheduledTime(
          String hours, bool isCancellationChargesEnabled) =>
      "هل تريد إلغاء هذا الموعد؟ ${isCancellationChargesEnabled ? 'سيتم تطبيق رسوم الإلغاء إذا قمت بالإلغاء خلال $hours ساعة من الوقت المحدد' : ''}";

  @override
  String get reason => "السبب";

  @override
  String get continueText => "استمر";

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
      "سيتم معالجة استرداد الموعد خلال 24 ساعة إذا كان ذلك ممكنًا.";

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
  String get totalVerifiedPatients => "إجمالي الأطباء المعتمدين";

  @override
  String get encounterId => "معرف اللقاء: ";

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
  String get incidentManagement => 'إدارة الحوادث';

  @override
  String get requestHelpForAnyMistakeHappen => 'اطلب المساعدة لأي خطأ يحدث';

  @override
  String get otp => 'كلمة المرور لمرة واحدة';

  @override
  String get verify => 'يؤكد';

  @override
  String get closedOn => 'مغلق في';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get title => 'عنوان';

  @override
  String get enterYourDetailDescriptionForYourComplaint =>
      'أدخل وصفًا تفصيليًا لشكواك';

  @override
  String get phoneNumber => 'رقم التليفون';

  @override
  String get chooseImage => 'اختر الصورة';

  @override
  String get browse => 'تصفح';

  @override
  String get noQueryYet => 'لا يوجد استفسار حتى الآن';

  @override
  String get add => 'يضيف';

  @override
  String get toSubmitYourProblemsSimplyPressAddButtonAndExplainYourConcern =>
      'لإرسال مشاكلك، ما عليك سوى الضغط على زر الإضافة وشرح مشكلتك';

  @override
  String get tryToAnotherWay => 'حاول بطريقة أخرى';

  @override
  String get pleaseEnterValid6digitOTP =>
      'الرجاء إدخال رمز OTP صالح مكون من 6 أرقام';

  @override
  String get otpFromAuthenticatorApp => 'OTP من تطبيق Authenticator';

  @override
  String get open => 'يفتح';

  @override
  String get close => 'يغلق';

  @override
  String get pleaseEnterValidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get pleaseEnterOTP => 'الرجاء إدخال كلمة المرور لمرة واحدة';

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
  String get uploadMedicalReport => 'تحميل التقرير الطبي';

  @override
  String get optional => '(خياري)';

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
  String get markAsClosed => 'وضع علامة على أنه مغلق';

  @override
  String get hideMessage => 'إخفاء الرسالة';

  @override
  String get showMessage => 'إظهار الرسالة';

  @override
  String get createdBy => 'تم الإنشاء بواسطة';

  @override
  String get incident => "حادث";

  @override
  String get reject => 'يرفض';

  @override
  String get successfullyAdded => 'تمت الإضافة بنجاح';

  @override
  String get otpSentToEmail =>
      "تم إرسال رمز التحقق إلى بريدك الإلكتروني، يرجى التحقق للمتابعة";

  @override
  String get rejected => "مرفوض";

  @override
  String get incidenceReportReply => "رد على تقرير الحادث";

  @override
  String get quickServices => "خدماتنا";

  @override
  String get labs => "مختبر";

  @override
  String get radiology => "أشعة";

  @override
  String get homeCare => "رعاية";

  // NURSE REQUEST MODULE
  @override
  String get homeNursing => 'تمريض منزلي';

  @override
  String get newRequest => 'طلب جديد';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get requestHomeNursing => 'اطلب تمريضاً منزلياً';

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
  String get addressLine1 => 'سطر العنوان 1';

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
  String get filterInProgress => 'جارٍ';

  @override
  String get filterCompleted => 'مكتمل';

  @override
  String get filterCancelled => 'ملغي';

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
  String get nurseStatusCancelled => 'ملغي';

  @override
  String get assignedNurse => 'الممرضة المعينة';

  @override
  String get nurseRating => 'التقييم';

  @override
  String get nursePhone => 'هاتف الممرضة';

  @override
  String get estimatedTotal => 'الإجمالي التقديري';

  @override
  String get paymentStatusUnpaid => 'غير مدفوع';

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
  String get addressLine1Required => 'سطر العنوان 1 مطلوب';

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
  String get pharmacyHome => 'رئيسية الصيدلية';
  @override
  String get searchProducts => 'البحث عن منتجات...';
  @override
  String get categories => 'الأقسام';
  @override
  String get brands => 'العلامات التجارية';
  @override
  String get productTypes => 'أنواع المنتجات';
  @override
  String get featuredProducts => 'منتجات مميزة';
  @override
  String get addToCart => 'أضف للسلة';
  @override
  String get viewCart => 'عرض السلة';
  @override
  String get cart => 'السلة';
  @override
  String get cartEmpty => 'سلة التسوق فارغة';
  @override
  String get cartEmptyHint =>
      'لا يوجد شيء هنا بعد. تصفح المنتجات أو ارفع روشتتك.';
  @override
  String get browsePharmacy => 'تصفح الصيدلية';
  @override
  String get deliveryAtCheckout => 'يتم احتساب التوصيل عند الدفع';
  @override
  String get needHelpUploadPrescription =>
      'تحتاج مساعدة في الاختيار؟ ارفع روشتتك.';
  @override
  String get checkout => 'الدفع';
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
  String get couponCode => 'كود الخصم';
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
  String get prescriptions => 'الروشتات';
  @override
  String get uploadPrescription => 'رفع روشتة';
  @override
  String get prescriptionRequired => 'روشتة مطلوبة';
  @override
  String get uploadPrescriptionInstructions =>
      'يرجى رفع صورة واضحة للروشتة الخاصة بك.';
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
  String get sort => 'ترتيب';

  // Pharmacy Sorting
  @override
  String get sortNewest => 'الأحدث';
  @override
  String get sortPriceAsc => 'السعر: من الأقل للأعلى';
  @override
  String get sortPriceDesc => 'السعر: من الأعلى للأقل';
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

  // Pharmacy Prescription
  @override
  String get notesOptional => 'ملاحظات (اختياري)';
  @override
  String get submitPrescription => 'إرسال الروشتة';
  @override
  String get chooseImageSource => 'اختر مصدر الصورة';

  // Pharmacy Orders
  @override
  String get placedOn => 'تم الطلب في';
  @override
  String get items => 'الأصناف';
  @override
  String get orderNumber => 'رقم الطلب';
  @override
  String get fulfillFullCart => 'سلة كاملة';
  @override
  String get fulfillPartialCart => 'سلة جزئية';
  @override
  String get partialFulfillWarning =>
      'هذه الصيدلية يمكنها فقط توفير بعض الأصناف في سلتك. هل تريد المتابعة مع الأصناف المتوفرة؟ سيتم إزالة الأصناف غير المتوفرة من هذا الطلب.';

  // Pharmacy Refunds
  @override
  String get refundRequests => 'طلبات الاسترداد';
  @override
  String get damagedProduct => 'منتج تالف';
  @override
  String get wrongProductReceived => 'استلام منتج خاطئ';
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
  String get xDoctors => '{count} طبيب';

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
  String get yourVisitingDoctor => 'طبيبك الزائر';

  @override
  String get noDoctorAssignedYet => 'لم يتم تعيين طبيب بعد';

  @override
  String get visitCompleted => 'اكتملت الزيارة';

  @override
  String get visitCompletedAt => 'اكتملت في';

  @override
  String get submittedOn => 'أُرسل في';

  @override
  String get visitChangedBy => 'تم التغيير بواسطة';

  @override
  String get discountApplied => 'تم تطبيق الخصم';

  @override
  String get visitOfferCode => 'كود العرض';

  @override
  String get youSaved => 'وفّرت';

  @override
  String get refresh => 'تحديث';

  @override
  String get serviceDuration => 'المدة';

  @override
  String get patientServed => 'مريض';

  @override
  String get bookAppointment => 'حجز موعد';

  @override
  String get noUpcomingAppointments => 'لا توجد مواعيد قادمة';

  @override
  String get bookYourFirstAppointment => 'احجز موعدك الأول';

  // ICU Admission Module
  @override
  String get icuAdmission => 'قسم العناية المركزة';
  @override
  String get icuHospitals => 'مستشفيات العناية المركزة';
  @override
  String get searchHospitals => 'ابحث عن مستشفيات...';
  @override
  String get hospitalsFound => 'مستشفى موجود';
  @override
  String get noHospitalsFound => 'لم يتم العثور على مستشفيات';
  @override
  String get hasAvailableBeds => 'يوجد أسرة متاحة';
  @override
  String get noBedsAvailable => 'لا توجد أسرة متاحة';
  @override
  String get hospitalDetail => 'تفاصيل المستشفى';
  @override
  String get aboutHospital => 'عن المستشفى';
  @override
  String get departments => 'الأقسام';
  @override
  String get availableBeds => 'أسرة متاحة';
  @override
  String get totalBeds => 'إجمالي الأسرة';
  @override
  String get callHospital => 'اتصل بالمستشفى';
  @override
  String get callEmergency => 'اتصل بالطوارئ';
  @override
  String get openInMaps => 'فتح في الخرائط';
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
  String get approved => 'موافق عليه';
  @override
  String get admitted => 'تم الدخول';
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
  String get cancelConfirmation =>
      'هل أنت متأكد من إلغاء طلب الدخول هذا؟';
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
  String get callNow => 'اتصل الآن';
  @override
  String get myAdmissionRequests => 'طلبات الدخول';
  @override
  String get statusTimeline => 'تسلسل الحالة';
  @override
  String get admissionDetails => 'تفاصيل الدخول';
  @override
  String get room => 'غرفة';
  @override
  String get bed => 'سرير';
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
  String get pharmacyNoOrders => 'لم تقم بأي طلبات بعد';
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
  String get pharmacyUploadedOn => 'تم الرفع في';
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
  String get pharmacyNoNotifications => 'لا توجد إشعارات بعد';
  @override
  String get pharmacyNotesForPharmacy => 'أضف ملاحظات للصيدلية...';
  @override
  String get pharmacyNoDescription => 'لا يوجد وصف متاح';

  // LABS & RADIOLOGY MODULE
  @override
  String get labsAndRadiology => 'المختبرات والأشعة';
  @override
  String get bookDiagnosticTestsSubtitle => 'احجز الفحوصات التشخيصية واستعرض التقارير';
  @override
  String get orderMedicinesSubtitle => 'اطلب الأدوية ومستلزمات الرعاية الصحية';
  @override
  String get radiologyCenters => 'مراكز الأشعة';
  @override
  String get searchLabs => 'البحث عن مختبرات';
  @override
  String get searchRadiologyCenters => 'البحث عن مراكز أشعة';
  @override
  String get viewTests => 'عرض التحاليل';
  @override
  String get startingFrom => 'يبدأ من';
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
  String get allTests => 'كل التحاليل';
  @override
  String get myTestOrders => 'طلباتي';
  @override
  String get noFacilitiesFound => 'لم يتم العثور على مرافق';
  @override
  String get testCategories => 'فئات التحاليل';
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
  String get tests => 'تحاليل';
  @override
  String get allTestsTitle => 'التحاليل التشخيصية';
  @override
  String get testDetails => 'تفاصيل التحليل';
  @override
  String get preparationInstructions => 'تعليمات التحضير';
  @override
  String get turnaroundTime => 'وقت الاستلام';
  @override
  String xHoursTurnaround(int n) => 'النتائج خلال $n ساعة';
  @override
  String get imaging => 'أشعة';
  @override
  String get bookTest => 'حجز تحليل';
  @override
  String get bookThisTest => 'احجز هذا التحليل';
  @override
  String get testCategoryLabel => 'الفئة';
  @override
  String get priceLabel => 'السعر';
  @override
  String get servicesOffered => 'الخدمات المقدمة';
  @override
  String get availableTests => 'التحاليل المتاحة';
  @override
  String get facilityAddress => 'عنوان المرفق';
  @override
  String get contactFacility => 'اتصل بالمرفق';
  @override
  String get selectTime => 'اختر الوقت';
  @override
  String get selectDate => 'اختر التاريخ';
  @override
  String get availableSlots => 'المواعيد المتاحة';
  @override
  String get noSlotsAvailable => 'لا توجد مواعيد متاحة';
  @override
  String get tryAnotherDate => 'جرب تاريخاً آخر';
  @override
  String get continueToConfirm => 'المتابعة للتأكيد';
  @override
  String get selectASlot => 'يرجى اختيار موعد';
  @override
  String get slotConflictTitle => 'تعارض في الموعد';
  @override
  String get slotConflictBody =>
      'هذا الموعد تم حجزه للتو. يرجى اختيار موعد آخر.';
  @override
  String get confirmBooking => 'تأكيد الحجز';
  @override
  String get bookingSummary => 'ملخص الحجز';
  @override
  String get testPrice => 'سعر التحليل';
  @override
  String get patientNotesOptional => 'ملاحظات إضافية (اختياري)';
  @override
  String get patientNotesHint => 'أي تعليمات خاصة للمرفق...';
  @override
  String get confirmAndBook => 'تأكيد وحجز';
  @override
  String get bookingSubmitted => 'تم إرسال الطلب بنجاح';
  @override
  String get yourTestIsBooked => 'تم حجز تحليلك التشخيصي بنجاح';
  @override
  String get backToLabs => 'العودة للمختبرات والأشعة';
  @override
  String get myOrders => 'طلباتي';
  @override
  String get orderRef => 'رقم الطلب';
  @override
  String get bookedOn => 'حجز في';
  @override
  String get slotDate => 'تاريخ الموعد';
  @override
  String get slotTime => 'وقت الموعد';
  @override
  String get pricing => 'التسعير';
  @override
  String get downloadingReport => 'جارٍ تحميل التقرير...';
  @override
  String get downloadFailed => 'فشل التحميل. يرجى المحاولة مرة أخرى.';
  @override
  String get reportNotReady => 'التقرير غير جاهز للتحميل بعد.';
  @override
  String get cancelOrderTitle => 'إلغاء طلب التحليل';
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
  String get statusSampleCollected => 'تم سحب العينة';
  @override
  String get statusInProgress => 'قيد التنفيذ';
  @override
  String get statusCompleted => 'مكتمل';
  @override
  String get statusCancelled => 'ملغي';
  @override
  String get statusRejected => 'مرفوض';
}
