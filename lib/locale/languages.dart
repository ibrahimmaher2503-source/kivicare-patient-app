import 'package:flutter/material.dart';

abstract class BaseLanguage {
  String get onlinePaymentUnavailable;
  String get loading;
  String get cashAfterService;
  static BaseLanguage of(BuildContext context) =>
      Localizations.of<BaseLanguage>(context, BaseLanguage)!;

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

  String get requestTimedOut;

  String get requestTimedOutAfterSubmission;

  String get yourInternetIsNotWorking;

  String get profileUpdatedSuccessfully;

  String get wouldYouLikeToSetProfilePhotoAs;

  String get yourOldPasswordDoesnT;

  String get yourNewPasswordDoesnT;

  String get location;

  String get startLocation;

  String get yes;

  String get submit;

  String get select;

  String get chooseAnother;

  String get firstName;

  String get lastName;

  String get changePassword;

  String get yourNewPasswordMust;

  String get password;

  String get showPassword;

  String get hidePassword;

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

  String get themeSystem;

  String get themeLight;

  String get themeDark;

  String get guest;

  String get notifications;

  String get enableNotifications;

  String get notificationPermissionDescription;

  String get notificationPermissionDenied;

  String get contactUs;

  String get getInTouchWithSupport;

  String get newUpdate;

  String get anUpdateTo;

  String get isAvailableGoTo;

  String get later;

  String get closeApp;

  String get updateNow;
  String get updateLinkUnavailable;

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

  String get taxIncluded;

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

  String get noServicesMatchFilters;

  String get tryChangingFiltersOrSearchAgain;

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

  String get skip;

  String get finish;

  String pageOf(int current, int total);

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
  String get preparing;
  String get outForDelivery;
  String get delivered;
  String get reviewed;
  String get processed;

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

  String cancellationChargesWillBeAppliedForCancellationWithin(
      String amount, String hours);

  String get cancelAppointment;

  String get goBack;

  String cancellationFeesWillBeAppliedIfYouCancelWithinHoursOfScheduledTime(
      String hours, bool isCancellationChargesEnabled);

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

  String get incidentManagement;

  String get requestHelpForAnyMistakeHappen;

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

  String get open;

  String get close;

  String get pleaseEnterValidEmail;

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
  String get createdOn;

  String get incident;

  String get invalidIncidentType;

  String get reject;

  String get successfullyAdded;

  String get rejected;

  String get incidenceReportReply;

  String get quickServices;

  String get labs;

  String get radiology;

  String get pharmacy;

  String get homeCare;

  // NURSE REQUEST MODULE
  String get homeNursing;
  String get newRequest;
  String get myRequests;
  String get requestHomeNursing;
  String get serviceDescriptionEnglish;
  String get serviceDescriptionArabic;
  String get atLeastOneDescriptionRequired;
  String get preferredDate;
  String get preferredTime;
  String get clear;
  String get durationHours;
  String durationHoursValue(int n);
  String get addressLine1;
  String get addressLine2;
  String get moreAddressDetails;
  String get governorate;
  String get city;
  String get stateLabel;
  String get countryLabel;
  String get postalCode;
  String get contactPhone;
  String get patientNotes;
  String get submitting;
  String get requestSubmitted;
  String get referenceNumber;
  String get copyReferenceNumber;
  String get copied;
  String get notifyTeamWillAssign;
  String get viewRequest;
  String get backToHome;
  String get filterAll;
  String get filterPending;
  String get filterAssigned;
  String get filterConfirmed;
  String get filterInProgress;
  String get filterCompleted;
  String get filterCancelled;
  String get nurseStatusPending;
  String get nurseStatusAssigned;
  String get nurseStatusConfirmed;
  String get nurseStatusInProgress;
  String get nurseStatusCompleted;
  String get nurseStatusCancelled;
  String get assignedNurse;
  String get nurseRating;
  String get nursePhone;
  String get estimatedTotal;
  String get paymentStatusUnpaid;
  String get paymentContextUnavailable;
  String get paymentStatusPaid;
  String get paymentStatusRefunded;
  String get cancellationReason;
  String get completedOn;
  String get statusHistory;
  String get emptyRequestsTitle;
  String get emptyRequestsSubtitle;
  String get loadFailed;
  String get retry;
  String get paymentConfirmationFailedRetry;
  String get pleaseContactSupportWithTransactionId;
  String get phoneInvalid;
  String get noDialerAvailable;
  String get descriptionTooLong;
  String get notesTooLong;
  String get addressTooLong;
  String get cityRequired;
  String get addressLine1Required;
  String get preferredDateRequired;
  String get durationOutOfRange;
  String get unknownSubmitOutcomeBanner;
  String get quickServiceHomeNursing;

  // Pharmacy
  String get pharmacyHome;
  String get searchProducts;
  String get categories;
  String get brands;
  String get productTypes;
  String get featuredProducts;
  String get addToCart;
  String get viewCart;
  String get cart;
  String get cartEmpty;
  String get cartEmptyHint;
  String get browsePharmacy;
  String get deliveryAtCheckout;
  String get needHelpUploadPrescription;
  String get checkout;
  String get placeOrder;
  String get orderSuccess;
  String get orderFailed;
  String get availablePharmacies;
  String get selectPharmacy;
  String get deliveryAddress;
  String get paymentMethod;
  String get applyCoupon;
  String get couponCode;
  String get deliveryFee;
  String get orders;
  String get orderDetail;
  String get orderStatus;
  String get trackOrder;
  String get cancelOrder;
  String get requestRefund;
  String get refundReason;
  String get prescriptions;
  String get uploadPrescription;
  String get prescriptionRequired;
  String get uploadPrescriptionInstructions;
  String get takePhoto;
  String get chooseFromGallery;
  String get maxImageLimitReached;
  String get maximumQuantityReached;
  String get markAllAsRead;
  String get noProductsFound;
  String get filter;
  String get sort;

  // Pharmacy Sorting
  String get sortNewest;
  String get sortPriceAsc;
  String get sortPriceDesc;
  String get sortRating;

  // Pharmacy Details
  String get productInfo;
  String get manufacturer;
  String get dosage;
  String get unit;
  String get inStock;
  String get outOfStock;
  String get productUnavailable;

  // Pharmacy Prescription
  String get notesOptional;
  String get submitPrescription;
  String get chooseImageSource;

  // Pharmacy Orders
  String get placedOn;
  String get items;
  String get orderNumber;
  String get fulfillFullCart;
  String get fulfillPartialCart;
  String get partialFulfillWarning;

  // Pharmacy Refunds
  String get refundRequests;
  String get damagedProduct;
  String get wrongProductReceived;
  String get expiredProduct;
  String get qualityIssue;
  String get submitRequest;

  // Pharmacy Localized Strings
  String get pharmacyCouponApplied;
  String get pharmacyInvalidCoupon;
  String get pharmacyDeliveryAddressRequired;
  String get pharmacyPrescriptionRequired;
  String get pharmacySelectDeliveryAddress;
  String get pharmacyCartPrescriptionWarning;
  String get pharmacyPrescriptionLabel;
  String get pharmacySelectPrescription;
  String get pharmacyUploadNewPrescription;
  String get pharmacyCashOnDelivery;
  String get pharmacyWallet;
  String get pharmacyCancelOrderConfirm;
  String get pharmacyYesCancel;
  String get pharmacyQty;
  String get pharmacyNoOrders;
  String get pharmacyOrderSuccess;
  String get pharmacyBackToHome;
  String get pharmacyNoPharmaciesAvailable;
  String get pharmacyNoPrescriptions;
  String get pharmacyPrescriptionImages;
  String get pharmacyRejectionReason;
  String get pharmacyUploadedOn;
  String get pharmacySelectReason;
  String get pharmacyRefundSubmitted;
  String get pharmacyAdditionalNotes;
  String get pharmacyDescribeIssue;
  String get pharmacyNoRefunds;
  String get pharmacyReason;
  String get pharmacyRefundAmount;
  String get pharmacyNoNotifications;
  String get pharmacyNotesForPharmacy;
  String get pharmacyNoDescription;

  // LABS & RADIOLOGY MODULE
  String get labsAndRadiology;
  String get bookDiagnosticTestsSubtitle;
  String get orderMedicinesSubtitle;
  String get radiologyCenters;
  String get searchLabs;
  String get searchRadiologyCenters;
  String get viewTests;
  String get startingFrom;
  String xReviews(int n);
  String get nearby;
  String get browseTestCategories;
  String get allTests;
  String get myTestOrders;
  String get noFacilitiesFound;
  String get testCategories;
  String xTests(int n);
  String get noCategoriesFound;
  String get tests;
  String get allTestsTitle;
  String get testDetails;
  String get preparationInstructions;
  String get turnaroundTime;
  String xHoursTurnaround(int n);
  String get imaging;
  String get bookTest;
  String get bookThisTest;
  String get testCategoryLabel;
  String get priceLabel;
  String get servicesOffered;
  String get availableTests;
  String get facilityAddress;
  String get contactFacility;
  String get selectTime;
  String get selectDate;
  String get availableSlots;
  String get noSlotsAvailable;
  String get tryAnotherDate;
  String get continueToConfirm;
  String get selectASlot;
  String get slotConflictTitle;
  String get slotConflictBody;
  String get confirmBooking;
  String get bookingSummary;
  String get testPrice;
  String get patientNotesOptional;
  String get patientNotesHint;
  String get confirmAndBook;
  String get bookingSubmitted;
  String get yourTestIsBooked;
  String get backToLabs;
  String get myOrders;
  String get orderRef;
  String get bookedOn;
  String get slotDate;
  String get slotTime;
  String get pricing;
  String get downloadingReport;
  String get downloadFailed;
  String get reportNotReady;
  String get cancelOrderTitle;
  String get cancelOrderConfirm;
  String get cancelReasonOptional;
  String get keepOrder;
  String get statusPending;
  String get statusConfirmed;
  String get statusSampleCollected;
  String get statusInProgress;
  String get statusCompleted;
  String get statusCancelled;
  String get statusRejected;

  // Location filter
  String get selectGovernorate;
  String get selectCity;
  String get searchGovernorate;
  String get searchCity;
  String get clearSearch;
  String get allGovernorates;
  String get allCities;
  String get showDoctorsFromAllGovernorates;
  String get showAllCitiesInGovernorate;
  String get showingCitiesInGovernorate;
  String get xDoctors;
  String get xCities;
  String get noGovernoratesFound;
  String get noCitiesFound;
  String get noResultsFor;
  String get noCitiesAvailable;
  String get applyGovernorateOnly;
  String get changeGovernorate;
  String get change;
  String get failedToLoadGovernorates;
  String get failedToLoadCities;
  String get allLocations;
  String get locationFilterFormat;

  // DOCTOR VISIT MODULE
  String get homeVisit;
  String get doctorVisit;
  String get homeVisitRequests;
  String get newHomeVisitRequest;
  String get requestHomeVisit;
  String get noVisitRequests;
  String get noVisitRequestsTitle;
  String get requestYourFirstVisit;
  String get visitReason;
  String get visitReasonHint;
  String get visitReasonRequired;
  String get visitReasonTooLong;
  String get preferredDateMustBeFuture;
  String get contactPhoneRequired;
  String get contactPhoneInvalid;
  String get preferredDoctor;
  String get preferredDoctorOptional;
  String get selectPreferredDoctor;
  String get clearDoctorSelection;
  String get additionalNotes;
  String get additionalNotesOptional;
  String get additionalNotesHint;
  String get additionalNotesTooLong;
  String get requestSubmittedSuccessfully;
  String get referenceCopied;
  String get weWillGetBackToYouSoon;
  String get requestDetails;
  String get visitInformation;
  String get assignedDoctor;
  String get yourVisitingDoctor;
  String get noDoctorAssignedYet;
  String get visitCompleted;
  String get visitCompletedAt;
  String get submittedOn;
  String get visitChangedBy;
  String get discountApplied;
  String get visitOfferCode;
  String get youSaved;
  String get refresh;

  String get serviceDuration;
  String get patientServed;
  String get bookAppointment;
  String get noUpcomingAppointments;
  String get bookYourFirstAppointment;

  // ICU Admission Module
  String get icuAdmission;
  String get icuHospitals;
  String get searchHospitals;
  String get hospitalsFound;
  String get noHospitalsFound;
  String get hasAvailableBeds;
  String get noBedsAvailable;
  String get hospitalDetail;
  String get aboutHospital;
  String get departments;
  String get availableBeds;
  String get totalBeds;
  String get callHospital;
  String get callEmergency;
  String get openInMaps;
  String get requestIcuAdmissionHere;
  String get icuDepartments;
  String get browseByDepartment;
  String get departmentDescription;
  String get patientName;
  String get patientAge;
  String get invalidPatientAge;
  String get reportDownloadUnavailable;
  String get invalidReportDownloadUrl;
  String get reportDownloadFailed;
  String get labTestRequired;
  String get preferredDatePast;
  String get preferredTimeInvalid;
  String get patientNotesTooLong;
  String get selectedTest;
  String get patientGender;
  String get diagnosis;
  String get urgencyLevel;
  String get accompanyingName;
  String get accompanyingRelation;
  String get accompanyingPhone;
  String get nationalId;
  String get currentCondition;
  String get attendingDoctor;
  String get currentMedications;
  String get allergies;
  String get selectHospital;
  String get selectDepartment;
  String get changeHospital;
  String get routine;
  String get urgent;
  String get critical;
  String get criticalUrgencyAlertTitle;
  String get criticalUrgencyAlertMessage;
  String get callEmergencyHotline;
  String get continueForm;
  String get underReview;
  String get approved;
  String get admitted;
  String get discharged;
  String get status;
  String get fieldRequired;
  String get invalidPhone;
  String get maxCharsReached;
  String get invalidDate;
  String get pleaseSelectHospital;
  String get pleaseSelectDepartment;
  String get copyReference;
  String get trackRequest;
  String get lastReference;
  String get goBackToHome;
  String get cancelRequest;
  String get cancelConfirmation;
  String get cancelReason;
  String get confirmCancellation;
  String get keepRequest;
  String get requestCancelled;
  String get emergencyHotline;
  String get emergencyNumberCopied;
  String get callNow;
  String get locationUnavailable;
  String get myAdmissionRequests;
  String get statusTimeline;
  String get admissionDetails;
  String get room;
  String get bed;
  String get admittedAt;
  String get dischargeDetails;
  String get dischargedAt;
  String get dischargeSummary;
  String get rejectionReason;
}
