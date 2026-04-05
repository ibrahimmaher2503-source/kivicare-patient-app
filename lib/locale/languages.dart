import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage)!;

  String get language;

  String get badRequest;

  String get forbidden;

  String get pageNotFound;

  String get tooManyRequests;

  String get internalServerError;

  String get badGateway;

  String get serviceUnavailable;

  String get gatewayTimeout;

  String get hey;

  String get hello;

  String get thisFieldIsRequired;

  String get contactNumber;

  String get gallery;

  String get camera;

  String get editProfile;

  String get update;

  String get reload;

  String get address;

  String get viewAll;

  String get pressBackAgainToExitApp;

  String get invalidUrl;

  String get cancel;

  String get delete;

  String get deleteAccountConfirmation;

  String get demoUserCannotBeGrantedForThis;

  String get somethingWentWrong;

  String get yourInternetIsNotWorking;

  String get profileUpdatedSuccessfully;

  String get wouldYouLikeToSetProfilePhotoAs;

  String get yourOldPasswordDoesnT;

  String get yourNewPasswordDoesnT;

  String get location;

  String get yes;

  String get submit;

  String get firstName;

  String get lastName;

  String get changePassword;

  String get yourNewPasswordMust;

  String get password;

  String get newPassword;

  String get confirmNewPassword;

  String get email;

  String get mainStreet;

  String get toResetYourNew;

  String get stayTunedNoNew;

  String get noNewNotificationsAt;

  String get signIn;

  String get explore;

  String get settings;

  String get rateApp;

  String get aboutApp;

  String get logout;

  String get rememberMe;

  String get forgotPassword;

  String get forgotPasswordTitle;

  String get registerNow;

  String get createYourAccount;

  String get createYourAccountFor;

  String get signUp;

  String get alreadyHaveAnAccount;

  String get yourPasswordHasBeen;

  String get youCanNowLog;

  String get done;

  String get pleaseAcceptTermsAnd;

  String get deleteAccount;

  String get eG;

  String get merry;

  String get doe;

  String get welcomeBackToThe;

  String get welcomeToThe;

  String get doYouWantToLogout;

  String get appTheme;

  String get guest;

  String get notifications;

  String get contactUs;

  String get getInTouchWithSupport;

  String get newUpdate;

  String get anUpdateTo;

  String get isAvailableGoTo;

  String get later;

  String get closeApp;

  String get updateNow;

  String get signInFailed;

  String get userCancelled;

  String get appleSigninIsNot;

  String get eventStatus;

  String get eventAddedSuccessfully;

  String get notRegistered;

  String get signInWithGoogle;

  String get signInWithApple;

  String get orSignInWith;

  String get ohNoYouAreLeaving;

  String get oldPassword;

  String get oldAndNewPassword;

  String get personalizeYourProfile;

  String get themeAndMore;

  String get showSomeLoveShare;

  String get privacyPolicyTerms;

  String get securelyLogOutOfAccount;

  String get termsOfService;

  String get successfully;

  String get clearAll;

  String get notificationDeleted;

  String get doYouWantToRemoveNotification;

  String get doYouWantToClearAllNotification;

  String get locationPermissionDenied;

  String get enableLocation;

  String get permissionDeniedPermanently;

  String get chooseYourLocation;

  String get setAddress;

  String get sorryUserCannotSignin;

  String get iAgreeToThe;

  String get logIn;

  String get doYouConfirmThisAppointment;

  String get confirmAppointment;

  String get iHaveReadAll;

  String get confirm;

  String get doYouConfirmThisPayment;

  String get exploreTopClinicsWithAdvancedServicesTailored;

  String get discoverYourIdealClinicWithOurPersonalizedSea;

  String get weHaveEmailedYourPasswordResetLink;

  String get resetYourPassword;

  String get enterYourEmailAddressToResetYourNewPassword;

  String get sendCode;

  String get edit;

  String get gender;

  String get profile;

  String get encounters;

  String get seeYourEncounterData;

  String get version;

  String get userNotCreated;

  String get notAMember;

  String get registerYourAccountForBetterExperience;

  String get termsConditions;

  String get and;

  String get privacyPolicy;

  String get appointment;

  String get doctor;

  String get payment;

  String get doYouWantToCancelAppointment;

  String get videoCallLinkIsNotFound;

  String get thisIsNotAOnlineService;

  String get oppsThisAppointmentIsNotConfirmedYet;

  String get oppsThisAppointmentHasBeenCancelled;

  String get oppsThisAppointmentHasBeenCompleted;

  String get noTimeSlotsAvailable;

  String get chooseTime;

  String get rescheduleBooking;

  String get searchForService;

  String get statusListIsEmpty;

  String get thereAreNoStatusListedAtTheMomentStayTunedFor;

  String get chooseDate;

  String get doYouWantToChangeTheTimeSlotOfThisAppointment;

  String get no;

  String get somethingWentWrongPleaseTryAgainLater;

  String get doYouWantToRemoveThisReview;

  String get encounterDetail;

  String get view;

  String get doctorName;

  String get active;

  String get closed;

  String get clinicName;

  String get description;

  String get payNow;

  String get medicalReport;

  String get paymentDetail;

  String get price;

  String get discount;

  String get off;

  String get subtotal;

  String get tax;

  String get total;

  String get yourReview;

  String get by;

  String get youHaventRatedYet;

  String get yourFeedbackWillImproveOurService;

  String get writeHere;

  String get writeYourFeedbackHere;

  String get pleaseSelectRatings;

  String get all;

  String get upcoming;

  String get completed;

  String get appointmentCancelSuccessfully;

  String get appointments;

  String get noAppointmentsFound;

  String get thereAreCurrentlyNoAppointmentsAvailableStart;

  String get encounter;

  String get basicInformation;

  String get problems;

  String get observations;

  String get notes;

  String get prescription;

  String get frequency;

  String get days;

  String get otherInformation;

  String get patientSoap;

  String get category;

  String get noCategoryFound;

  String get viewDetail;

  String get noServicesFoundAtAMoment;

  String get looksLikeThereIsNoServicesForThis;

  String get wellKeepYouPostedWhenTheresAnUpdate;

  String get services;

  String get sessions;

  String get clinicSessionsInformation;

  String get servicesAvailable;

  String get noServicesAvailable;

  String get doctors;

  String get noSystemServicesFoundAtAMoment;

  String get looksLikeThereIsNoSystemServicesForThis;

  String get appointmentsSummary;

  String get date;

  String get time;

  String get service;

  String get clinic;

  String get proceed;

  String get video;

  String get bookingForm;

  String get bookingInfo;

  String get serviceName;

  String get chooseService;

  String get serviceListIsEmpty;

  String get thereAreNoServicesListedAtTheMomentStayTunedF;

  String get kindlyChooseAServiceFirst;

  String get chooseClinic;

  String get searchForClinic;

  String get clinicListIsEmpty;

  String get thereAreNoClinicsListedAtTheMomentStayTunedFo;

  String get kindlyChooseAClinicFirst;

  String get chooseDoctor;

  String get searchForDoctor;

  String get thereAreNoDoctorsListedAtTheMomentStayTunedFo;

  String get writeMedicalHistory;

  String get paymentDetails;

  String get asPerDoctorCharges;

  String get next;

  String get personalizedHealthPlansForYourJourney;

  String get stayOnTrackAndSetPersonalGoals;

  String get discoverAndGetSupportWithin24Hours;

  String get customizeHealthPlansForATailoredApproachAlign;

  String get focusOnYourPathSetClearGoalsAndStrideForwardW;

  String get exploreFindSolutionsAndReceiveAssistanceSwift;

  String get transactionIsInProcess;

  String get enterYourMsisdnHere;

  String get pleaseCheckThePayment;

  String get ambiguous;

  String get success;

  String get incorrectPin;

  String get exceedsWithdrawalAmountLimit;

  String get inProcess;

  String get transactionTimedOut;

  String get notEnoughBalance;

  String get refused;

  String get doNotHonor;

  String get transactionNotPermittedTo;

  String get transactionIdIsInvalid;

  String get errorWhileFetchingEncryption;

  String get transactionExpired;

  String get invalidAmount;

  String get transactionNotFound;

  String get successfullyFetchedEncryptionKey;

  String get theTransactionIsStill;

  String get transactionIsSuccessful;

  String get incorrectPinHasBeen;

  String get theUserHasExceeded;

  String get theAmountUserIs;

  String get userDidnTEnterThePin;

  String get transactionInPendingState;

  String get userWalletDoesNot;

  String get theTransactionWasRefused;

  String get encryptionKeyHasBeen;

  String get transactionHasBeenExpired;

  String get payeeIsAlreadyInitiated;

  String get theTransactionWasNot;

  String get thisIsAGeneric;

  String get theTransactionWasTimed;

  String get xSignatureAndPayloadDid;

  String get couldNotFetchEncryption;

  String get transactionFailed;

  String get transactionCancelled;

  String get paymentSuccess;

  String get redirectingToBookings;

  String get pleaseConfirmYourAppointmentByCheckingTheBox;

  String get appointmentDetail;

  String get reschedule;

  String get invoice;

  String get dateTime;

  String get appointmentStatus;

  String get paymentStatus;

  String get subjective;

  String get objective;

  String get assessment;

  String get plan;

  String get bodyChart;

  String get doctorsAvailable;

  String get noDoctorsAvailable;

  String get photosAvailable;

  String get noPhotosAvailable;

  String get looksLikeThereIsNoServicesListedOnThisClinicW;

  String get session;

  String get unavailable;

  String get lblBreak;

  String get clinicDetail;

  String get pincode;

  String get readMore;

  String get readLess;

  String get noGalleryFoundAtAMoment;

  String get looksLikeThereIsNoGalleryForThisClinicWellKee;

  String get clinics;

  String get availableClinicsFor;

  String get noClinicsFoundAtAMoment;

  String get looksLikeThereIsNoClinicForThisServiceWellKee;

  String get searchClinicHere;

  String get home;

  String get aboutMyself;

  String get about;

  String get contactInfo;

  String get specialization;

  String get experience;

  String get experienceSpecializationContactInfo;

  String get reviews;

  String get noReviewsAvailable;

  String get qualification;

  String get qualificationInDetail;

  String get year;

  String get degree;

  String get university;

  String get noQualificationsFound;

  String get looksLikeThereAreNoQualificationsAddedByThisD;

  String get totalAppointmentsDone;

  String get looksLikeThereIsNoServicesProvidedByThisDocto;

  String get doctorDetail;

  String get socialMedia;

  String get noDoctorsFoundAtAMoment;

  String get looksLikeThereIsNoDoctorsForThisClinicWellKee;

  String get noReviewsFoundAtAMoment;

  String get looksLikeThereIsNoReviewsWellKeepYouPostedWhe;

  String get searchHere;

  String get searchDoctorHere;

  String get noEncountersFound;

  String get looksLikeThereIsNoEncountersWellKeepYouPosted;

  String get clinicsNearYou;

  String get upcomingAppointments;

  String get great;

  String get bookingSuccessful;

  String get yourAppointmentHasBeenBookedSuccessfully;

  String get totalPayment;

  String get goToAppointments;

  String get noteForCashPaymentPurposesDontUseThePayNowBut;

  String get choosePaymentMethod;

  String get chooseOurConvenientPaymentOptionAndUnlockUnli;

  String get doYouWantToReplaceThePreviousServiceWithTheCu;

  String get bookNow;

  String get aboutService;

  String get advancePayableAmount;

  String get advancePaidAmount;

  String get remainingPayableAmount;

  String get walletHistory;

  String get noWalletDataFound;

  String get oppsNoWalletDataFoundAtAMoment;

  String get walletBalance;

  String get addFiles;

  String get file;

  String get apply;

  String get filterBy;

  String get reset;

  String get priceRange;

  String get serviceType;

  String get dateOfBirth;

  String get passwordLengthShouldBe8To14Characters;

  String get noteInCaseYouFailToMakeTheAdvancePaymentYouWi;

  String get serviceTotal;

  String get remainingAmount;

  String get refundableAmount;

  String get appointmentId;

  String get youDontHaveEnoughBalanceToCompleteThePaymentU;

  String get advancePayment;

  String get doYouWantToPerformThisAction;

  String get bookedFor;

  String get addPatient;

  String get relation;

  String get save;

  String get managePatient;

  String get otherPatient;

  String get manageOtherPatient;

  String get genderWithColon;

  String get contactNumberWithColon;

  String get dobWithColon;

  String get noPatientsFound;

  String get editPatient;

  String get doYouWantToDeleteYourOtherPatientsProfile;

  String get birthdateIsRequired;

  String get selectBirthdate;

  String get bookedForWithColon;

  String get inClinic;

  String get online;

  String get pending;

  String get confirmed;

  String get checkIn;

  String get cancelled;

  String get advancePaid;

  String get paid;

  String get advanceRefunded;

  String get refunded;

  String get failed;

  String get ourPopularDoctor;

  String get ourPopularSevices;

  String get ourPopularClinics;

  String get newAppointmentBooked;

  String get appointmentCompleted;

  String get appointmentRejected;

  String get appointmentCancelled;

  String get appointmentRescheduled;

  String get appointmentAccepted;

  String get forgetEmailPassword;

  String get parents;

  String get brother;

  String get siblings;

  String get spouse;

  String get relative;

  String get deleteConfirmation;

  String get patientUpdatedSuccessfully;

  String get patientAddedSuccessfully;

  String get recordDeletedSuccessfully;

  String get male;

  String get female;

  String get other;

  String get others;

  String get appliedInclusiveTaxes;

  String get includesInclusiveTax;

  String get inclusiveTaxes;

  String get servicePrice;

  String get inclusiveTax;

  String get appliedExclusiveTaxes;

  String get exclusiveTax;

  String get appliedTaxes;

  String cancellationChargesWillBeAppliedForCancellationWithin(String amount, String hours);

  String get cancelAppointment;

  String get goBack;

  String cancellationFeesWillBeAppliedIfYouCancelWithinHoursOfScheduledTime(String hours, bool isCancellationChargesEnabled);

  String get reason;

  String get continueText;

  String get wouldYouLikeToProceedAndConfirmPayment;

  String get cancellationFee;

  String get yourAppointmentHasBeenSuccessfullyCancelled;

  String get appointmentRefundWillBeProcessedWithingHoursIfApplicable;

  String get noteCheckYourAppointmentHistoryForRefundDetailsIfApplicable;

  String get ok;

  String get hintReason;

  String get medicalHistory;

  String get clinicClosed;

  String get satisfactionToCustomer;

  String get totalVerifiedPatients;

  String get encounterId;

  String get dateIsNotSelected;

  String get selectClinic;

  String get selectService;

  String get quicklyBookYourAppointmentNow;

  String get noDataFound;

  String get filterService;

  String get filterCategory;

  String get filterRating;

  String get filterLocation;

  String get incidentManagement;

  String get requestHelpForAnyMistakeHappen;

  String get otp;

  String get verify;

  String get closedOn;

  String get viewDetails;

  String get title;

  String get enterYourDetailDescriptionForYourComplaint;

  String get phoneNumber;

  String get chooseImage;

  String get browse;

  String get noQueryYet;

  String get add;

  String get toSubmitYourProblemsSimplyPressAddButtonAndExplainYourConcern;

  String get tryToAnotherWay;

  String get pleaseEnterValid6digitOTP;

  String get otpFromAuthenticatorApp;

  String get open;

  String get close;

  String get pleaseEnterValidEmail;

  String get pleaseEnterOTP;

  String get passwordMustIncludeSpacialCharacter;

  String get passwordMustIncludeAtLeastOneLowercaseCharacter;

  String get passwordMustIncludeAtLeastOneNumber;

  String get passwordMustIncludeAtLeastOneCapitalCharacter;

  String get addFile;

  String get uploadMedicalReport;

  String get optional;

  String get reply;

  String get passwordIsRequired;

  String get passwordDoesNotMeetRequirements;

  String get passwordTooShort;

  String get emailHasAlreadyBeenTaken;

  String get markAsClosed;

  String get hideMessage;

  String get showMessage;

  String get createdBy;

  String get incident;

  String get reject;

  String get successfullyAdded;

  String get otpSentToEmail;

  String get rejected;

  String get incidenceReportReply;

  // Nurse Module
  String get requestNurse;
  String get nurses;
  String get nurseDetails;
  String get browseNurses;
  String get myNurseRequests;
  String get createNurseRequest;
  String get editNurseRequest;
  String get serviceDescription;
  String get preferredDate;
  String get preferredTime;
  String get durationHours;
  String get patientNotes;
  String get selectNurse;
  String get hourlyRate;
  String get serviceArea;
  String get availabilityStatus;
  String get nurseAvailable;
  String get nurseBusy;
  String get nurseOffDuty;
  String get nurseRequestSubmitted;
  String get nurseRequestUpdated;
  String get nurseRequestCancelled;
  String get cancellationReason;
  String get totalAmount;
  String get addressLine1;
  String get addressLine2;
  String get city;
  String get postalCode;
  String get nurseRequestPending;
  String get nurseRequestConfirmed;
  String get nurseRequestInProgress;
  String get nurseRequestCompleted;

  // Lab Test Module
  String get labTests;
  String get labTestCategories;
  String get labTestDetails;
  String get browseLabTests;
  String get myTestOrders;
  String get createTestOrder;
  String get testOrderDetails;
  String get orderNumber;
  String get clinicalNotes;
  String get priority;
  String get priorityRoutine;
  String get priorityUrgent;
  String get priorityStat;
  String get selectTests;
  String get addTest;
  String get removeTest;
  String get sampleType;
  String get preparationInstructions;
  String get turnaroundTime;
  String get defaultPrice;
  String get department;
  String get laboratory;
  String get radiology;
  String get testOrderCreated;
  String get testOrderCancelled;
  String get downloadReport;
  String get reportDownloaded;
  String get orderDate;
  String get resultValue;
  String get resultStatus;
  String get resultNormal;
  String get resultAbnormal;
  String get resultCritical;
  String get sampleCollected;
  String get processing;
  String get delivered;
  String get referenceRange;
  String get testCount;

  // Request Service Module
  String get requestService;
  String get myServiceRequests;
  String get createServiceRequest;
  String get serviceRequestSubmitted;
  String get serviceStatusPending;
  String get serviceStatusAccepted;
  String get serviceStatusRejected;

  String get hours;
  String get adminNotes;
  String get quickServices;
  String get myRequests;
  String get noNurseRequestsYet;
  String get noTestCategoriesAvailable;
  String get noTestOrdersFound;
  String get fillDetailsBelow;
  String get cancelledByPatient;
  String get categoriesAvailable;
  String get stateLabel;
  String get countryLabel;
  String get perHour;
  String get estimatedTotal;
  String get toBeDetermined;
  String get freeLabel;

  // ICU Admissions
  String get icuAdmissions;
  String get hospitals;
  String get hospitalDetails;
  String get icuDepartments;
  String get browseHospitals;
  String get myIcuRequests;
  String get createAdmissionRequest;
  String get admissionRequestDetails;
  String get admissionSubmitted;
  String get admissionCancelled;
  String get patientInformation;
  String get caseDetailsLabel;
  String get emergencyContact;
  String get paymentInformation;
  String get medicalReportsLabel;
  String get patientName;
  String get patientAge;
  String get patientGender;
  String get nationalId;
  String get insuranceNumberLabel;
  String get medicalCondition;
  String get diagnosisLabel;
  String get caseTypeLabel;
  String get urgencyLabel;
  String get needsVentilator;
  String get needsOxygen;
  String get currentLocationLabel;
  String get needsAmbulance;
  String get contactNameLabel;
  String get contactPhoneLabel;
  String get relationshipLabel;
  String get paymentMethodLabel;
  String get insuranceProviderLabel;
  String get attachReports;
  String get supportedFileFormats;
  String get requestNumberLabel;
  String get totalBedsLabel;
  String get availableBedsLabel;
  String get dailyPriceLabel;
  String get equipmentLevelLabel;
  String get hospitalTypeLabel;
  String get noHospitalsFound;
  String get noIcuRequestsYet;
  String get criticalLabel;
  String get urgentLabel;
  String get standardLabel;
  String get acceptedLabel;
  String get rejectedLabel;
  String get infoRequestedLabel;
  String get maleLabel;
  String get femaleLabel;
  String get insuranceLabel;
  String get cashLabel;

  // ICU Case Types
  String get caseTypeStroke;
  String get caseTypeCardiac;
  String get caseTypePostOperative;
  String get caseTypeVentilator;
  String get caseTypeNeonatal;
  String get caseTypePediatric;
  String get caseTypeBurns;
  String get caseTypeGeneral;

  // ICU Specialties
  String get specialtyCardiac;
  String get specialtyNeurology;
  String get specialtyPediatric;
  String get specialtyNeonatal;
  String get specialtyBurns;
  String get specialtyChest;
  String get specialtySurgical;
  String get specialtyGeneral;

  // Call Booking
  String get callBooking;
  String get callDoctors;
  String get browseCallDoctors;
  String get myCallBookings;
  String get bookCall;
  String get videoConsultation;
  String get phoneConsultation;
  String get callServices;
  String get selectDate;
  String get selectTimeSlot;
  String get availableSlots;
  String get noSlotsAvailable;
  String get tryAnotherDate;
  String get bookingConfirmed;
  String get meetingLinkLabel;
  String get joinCall;
  String get callTypeLabel;
  String get videoCallLabel;
  String get phoneCallLabel;
  String get durationMinLabel;
  String get startingFrom;
  String get originalPriceLabel;
  String get discountLabel;
  String get finalPriceLabel;
  String get appointmentDateLabel;
  String get appointmentTimeLabel;
  String get serviceNameLabel;
  String get totalAmountLabel;
  String get noCallDoctorsFound;
  String get noCallBookingsYet;
  String get selectServiceLabel;
  String get confirmBooking;
  String get bookingDetailsLabel;
  String get transactionTypeLabel;

  // Independent Doctor Booking
  String get independentBooking;
  String get independentDoctors;
  String get browseIndependentDoctors;
  String get myIndependentBookings;
  String get bookAppointmentLabel;
  String get independentServices;
  String get inPersonConsultation;
  String get totalAppointmentsLabel;
  String get totalPatientsLabel;
  String get taxIncludedLabel;
  String get inclusiveTaxLabel;
  String get pricingBreakdownLabel;
  String get noIndependentDoctorsFound;
  String get noIndependentBookingsYet;
  String get independentBookingConfirmed;
  String get appointmentDetailsLabel;
  String get slotIntervalLabel;

  // Labs Browse
  String get labs;
  String get browseLabs;
  String get noLabsFound;

  // Location Filter
  String get governorate;
  String get allGovernorates;
  String get allCities;
  String get selectGovernorate;
  String get selectCity;
  String get locationFilter;

  // Radiology
  String get browseRadiology;
  String get radiologyCenters;
  String get scanType;
  String get availableScans;
  String get mriScan;
  String get ctScan;
  String get xRay;
  String get ultrasound;
  String get mammogram;
  String get dexaScan;
  String get noRadiologyCentersFound;
  String get radiologyCenterDetail;
  String get contactCenter;
  String get operatingHours;
  String get pricing;

  // Location & Search
  String get searchProviders;
  String get searchDoctors;
  String get searchClinics;
  String get searchNurses;
  String get searchLabs;
  String get searchRadiology;
  String get searchHomeHealthcare;
  String get specialty;
  String get minPrice;
  String get maxPrice;
  String get noSearchResults;
  String get broadenFilters;
  String get homeHealthcare;
  String get radiologyCenter;
  String get allSpecialties;
  String get filterByGender;
  String get filterByAvailability;
  String get physiotherapy;
  String get elderlyCare;
  String get postSurgery;
  String get chronicCare;

  // Unified Doctor Booking
  String get bookADoctor;
  String get videoConsult;
  String get myDoctorAppointments;
  String get myVideoConsults;
}
