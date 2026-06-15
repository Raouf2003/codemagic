import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _data = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Attendance System',
      'signIn': 'Sign In',
      'signInHint': 'Sign in with your employee number',
      'employeeNumber': 'Employee Number',
      'password': 'Password',
      'enterEmployeeNumber': 'Please enter employee number',
      'enterPassword': 'Please enter password',
      'loginFailed': 'Could not sign in. Please check your employee number and password.',
      'wrongPassword': 'Incorrect password. Please try again.',
      'employeeNotFound': 'Employee number not found. Please check and try again.',
      'accountDisabled': 'Your account has been deactivated. Contact your administrator.',
      'toggleTheme': 'Toggle theme',
      'language': 'Language',
      'noReports': 'No reports yet',
      'noReportsSubtitle': 'Employees haven\'t submitted any reports',
      'reportDetails': 'Report Details',
      'employee': 'Employee',
      'description': 'Description',
      'photo': 'Photo',
      'issue': 'Issue',
      'inventory': 'Inventory',
      'feedback': 'Feedback',
      'searchReports': 'Search reports...',
      'all': 'All',
      'filterByType': 'Filter by type',
      'unknown': 'Unknown',
      'report': 'Report',
      'dashboard': 'Dashboard',
      'employees': 'Employees',
      'reports': 'Reports',
      'inbox': 'Inbox',
      'records': 'Records',
      'totalHours': 'Total Hours',
      'adminPanel': 'Admin Panel',
      'quickActions': 'Quick Actions',
      'todayOverview': 'Today\'s Overview',
      'manageEmployees': 'Manage Employees',
      'employeeReports': 'Emp Rpts',
      'administrator': 'Administrator',
      'manageEmployeesSubtitle': 'Add, edit, delete employees',
      'dailyMonthlyReportsSubtitle': 'Daily and monthly attendance reports',
      'viewEmployeeReportsSubtitle': 'View issues, inventory & feedback from employees',
      'logout': 'Logout',
      'attendance': 'Attendance',
      'history': 'History',
      'morning': 'Morning',
      'evening': 'Evening',
      'employeeId': 'ID',
      'working': 'Working',
      'finished': 'Finished',
      'notStarted': 'Not Started',
      'checkIn': 'Check In',
      'checkOut': 'Check Out',
      'breakPeriod': 'Break period (12:00 - 13:00)',
      'noMatchingReports': 'No matching reports',
      'tryDifferentSearch': 'Try a different search or filter',
      'submitted': 'Report submitted',
      'employeeReport': 'Employee Report',
      'morningCheckInSuccess': 'Morning check-in successful!',
      'morningCheckOutSuccess': 'Morning check-out successful!',
      'eveningCheckInSuccess': 'Evening check-in successful!',
      'eveningCheckOutSuccess': 'Evening check-out successful!',
      'newReport': 'New Report',
      'reportType': 'Report Type',
      'required': 'Required',
      'addPhoto': 'Add Photo',
      'submitReport': 'Submit Report',
      'noRecords': 'No records',
      'noRecordsSubtitle': 'No attendance records for this month',
      'days': 'Days',
      'hours': 'Hours',
      'attendanceSummary': 'Attendance Summary',
      'today': 'Today',
      'currentlyWorking': 'Currently Working',
      'noEmployeesWorking': 'No employees currently working',
      'auto': 'Auto',
      'insideAllowedArea': 'You are inside the check-in area',
      'outsideAllowedArea': 'You are outside the check-in area',
      'faceVerification': 'Face Verification',
      'faceVerificationCheckout': 'Face Verification \u2013 Check-out',
      'total': 'Total',
      'settings': 'Settings',
      'shiftConfig': 'Shift Configuration',
      'geofenceConfig': 'Geofence Configuration',
      'setShiftTimes': 'Set the start and end times for morning and evening shifts.',
      'morningStart': 'Morning Start',
      'morningEnd': 'Morning End',
      'eveningStart': 'Evening Start',
      'eveningEnd': 'Evening End',
      'saveShiftTimes': 'Save Shift Times',
      'morningStartBeforeEnd': 'Morning end must be after morning start',
      'eveningStartBeforeEnd': 'Evening end must be after evening start',
      'noOverlap': 'Morning end must not overlap with evening start',
      'goodMorning': 'Good morning',
      'goodAfternoon': 'Good afternoon',
      'goodEvening': 'Good evening',
      'totalEmployees': 'Total Employees',
      'workingNow': 'Working Now',
      'qrCheckin': 'QR Check-in',
      'manageStaff': 'Manage staff',
      'viewAttendance': 'View attendance',
      'addEmployee': 'Add Employee',
      'editEmployee': 'Edit Employee',
      'fullName': 'Full Name',
      'cancel': 'Cancel',
      'retakeAll': 'Retake All',
      'confirmSave': 'Confirm & Save',
      'search': 'Search',
      'companyLocation': 'Company Location',
      'allowedRadius': 'Allowed Radius',
      'meters': 'meters',
      'saveLocation': 'Save Location',
      'fetchingLocation': 'Fetching your location...',
      'selectTime24h': 'Select time (24-hour)',
      'displayQR': 'Display QR code',
      'saving': 'Saving...',
      'shiftSettings': 'Shift Settings',
      'selectLanguage': 'Select Language',
      'admin': 'Admin',
      'logoutConfirm': 'Are you sure you want to logout?',
      'employeeAddedWFace': 'Employee added with face enrollment \u2713',
      'employeeUpdated': 'Employee updated',
      'deleteEmployee': 'Delete Employee',
      'delete': 'Delete',
      'employeeDeleted': 'Employee deleted',
      'employeeNumberLabel': 'Employee Number',
      'newPassword': 'New Password (leave blank to keep)',
      'nextCaptureFace': 'Next: Capture Face',
      'save': 'Save',
      'noEmployeesFound': 'No employees found',
      'addFirstEmployee': 'Add your first employee to get started',
      'adminRole': 'ADMIN',
      'faceEnrolled': 'Face enrolled',
      'faceNotEnrolled': 'Face not enrolled',
      'editDetails': 'Edit Details',
      'reenrollFace': 'Re-enroll Face',
      'workingNowSection': 'WORKING NOW',
      'faceEnrollmentCancelled': 'Face enrollment was cancelled. Employee not created.',
      'faceReenrollmentCancelled': 'Face re-enrollment cancelled.',
      'noFaceDetected': 'No face detected. Ensure the face is well-lit and fully visible.',
      'cameraError': 'Camera access failed',
      'faceEnrollment': 'Face Enrollment',
      'startingCamera': 'Starting camera\u2026',
      'positionFaceInsideOval': 'Position face inside the oval',
      'capturing': 'Capturing\u2026',
      'extractingFaceData': 'Processing face data...',
      'tryAgain': 'Try Again',
      'faceCaptured': 'Face captured!',
      'goBack': 'Go Back',
      'identityConfirmed': 'Identity confirmed',
      'verificationFailed': 'Could not confirm your identity',
      'faceNotRegistered': 'No face is registered for your account',
      'verificationError': 'Something went wrong during face verification',
      'holdStill': 'Hold still\u2026',
      'verifyingIdentity': 'Verifying your identity\u2026',
      'initialisingCamera': 'Initialising camera\u2026',
      'comparingFace': 'Comparing face with your account\u2026',
      'capturingFace': 'Capturing face\u2026',
      'startCamera': 'Starting camera\u2026',
      'positionFaceInOval': 'Position your face inside the oval',
      'faceDoesNotMatch': 'Your face did not match the one on file for this account',
      'notEnrolledContactAdmin': 'Your account does not have a face enrolled. Please contact your administrator.',
      'checkinSuccessful': 'Check-in successful!',
      'checkoutSuccessful': 'Check-out successful!',
      'qrCheckinStep2': 'QR Check-in \u2014 Step 2 of 3',
      'validatingQR': 'Validating QR code\u2026',
      'step1Loc': '1 Loc',
      'step2QR': '2 QR',
      'step3Face': '3 Face',
      'scanAdminQR': 'Scan the admin\'s QR code',
      'locVerified': 'Location verified',
      'scanAgain': 'Scan Again',
      'qrInvalidOrExpired': 'QR code is invalid or expired. Ask the admin to refresh it.',
      'checkinCancelled': 'Check-in cancelled. Scan the QR code again to retry.',
      'failedToGenerateQR': 'Could not create the QR code. Please check your connection and try again.',
      'qrCheckinCode': 'Check-in QR Code',
      'employeeCheckin': 'Employee Check-in',
      'scanThisQR': 'Scan this QR code to check in',
      'refreshNow': 'Refresh Now',
      'manageShiftGeofence': 'Manage shift times and geofence configuration.',
      'setMorningEveningShift': 'Set morning and evening shift start & end times',
      'setCompanyLocationRadius': 'Set company location and allowed check-in radius',
      'invalidCoordinates': 'The coordinates entered are not valid. Please check the values.',
      'latitudeBetween': 'Latitude must be a number between -90 and 90',
      'longitudeBetween': 'Longitude must be a number between -180 and 180',
      'radiusBetween': 'Radius must be between 10 and 1000 meters',
      'geofenceUpdated': 'Geofence settings updated successfully',
      'geofenceConfigTitle': 'Geofence Configuration',
      'geofenceDescription': 'Set the company location and allowed radius for check-in geofencing.',
      'companyLocationSection': 'Company Location',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'egLatitude': 'e.g. 35.219445',
      'egLongitude': 'e.g. 4.204832',
      'minMaxRadius': 'Min: 10m  \u2014  Max: 1000m',
      'saveGeofence': 'Save Geofence',
      'dailyAttendanceReport': 'Daily Attendance Report',
      'date': 'Date',
      'totalRecords': 'Total Records',
      'monthlyAttendanceReport': 'Monthly Attendance Report',
      'period': 'Period',
      'daysPresent': 'Days Present',
      'employeeHash': 'Employee #',
      'checkInPdf': 'Check In',
      'checkOutPdf': 'Check Out',
      'totalTime': 'Total Time',
      'daily': 'Daily',
      'monthly': 'Monthly',
      'downloadReport': 'Download Report',
      'chooseFormat': 'Choose file format:',
      'noData': 'No data',
      'selectDateOrMonth': 'Select a date or month to view reports',
      'noAttendanceRecords': 'No attendance records',
      'noRecordsForDate': 'There are no records for this date',
      'autoCheckedOut': '(Auto checked out)',
      'noDataForMonth': 'No data for this month',
      'noRecordsFoundPeriod': 'No attendance records found for this period',
      'download': 'Download',
      'downloadFailed': 'Could not download the file. Please try again.',
      'myReports': 'My Reports',
      'submitFirstReport': 'Submit your first report from the home screen',
      'attendanceHistory': 'Attendance History',
      'noRecordsMonth': 'No attendance records for this month',
      'gpsNotAvailable': 'GPS location is not available. Please turn on location services in your phone settings.',
      'outsideAllowedAreaError': 'You are outside the company\'s allowed area. Please move closer to the office.',
      'checkinFailed': 'Could not check you in. Please try again or contact your administrator.',
      'checkoutFailed': 'Could not check you out. Please try again or contact your administrator.',
      'confirm': 'Confirm',
      'shiftUpdated': 'Shift settings updated successfully',
      'lookAtCamera': 'Look directly at the camera. Auto-capturing in',
      'authenticateCheckin': 'Authenticate to check in/out',
      'biometricNotAvailable': 'Fingerprint / face unlock is not available on this device',
      'morningCheckinTime': 'You can check in during morning hours only',
      'eveningCheckinTime': 'You can check in during evening hours only',
      'locationTracking': 'Tracking location for attendance check-in',
      'lookDirectlyAtCamera': 'Make sure you are looking directly at the camera with good lighting.',
      'deleteConfirm': 'Delete {name}?',
      'deleteReport': 'Delete Report',
      'reportDeleted': 'Report deleted',
      'faceReenrolled': 'Face re-enrolled for {name}',
      'collapse': 'Collapse',
      'expand': 'Expand',
      'networkError': 'Connection issue. Please check your internet and try again.',
      'faceVerificationUnavailable': 'Face verification could not start. Please check your internet connection and try again.',
      'noInternetConnection': 'No internet connection. Please check your network and try again.',
      'checkinNoInternet': 'Unable to check in. No internet connection.',
      'checkoutNoInternet': 'Unable to check out. No internet connection.',
      'loginNoInternet': 'Unable to log in. No internet connection.',
      'connectionLost': 'Internet connection lost',
      'autoCheckoutWarning': 'You will be automatically checked out if not restored within 5 minutes.',
      'manualAttendance': 'Manual Attendance',
      'requiredField': 'This field is required',
      'checkOutAfterCheckIn': 'Check-out time must be after check-in time',
      'reason': 'Reason',
      'reasonHint': 'Optional reason for manual entry',
      'jan': 'Jan',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Apr',
      'may': 'May',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Aug',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Dec',
      'am': 'AM',
      'pm': 'PM',
      'inLabel': 'IN',
      'outLabel': 'OUT',
      'workingLabel': 'Working: ',
      'switchToLight': 'Switch to Light Mode',
      'switchToDark': 'Switch to Dark Mode',
      'live': 'LIVE',
      'view': 'View',
      'refreshesIn': 'Refreshes in {seconds}s',
      'samplesCaptured': '3 samples captured ({n} total)',
      'unknownError': 'An unexpected error occurred',
      'success': 'Success!',
      'somethingWentWrong': 'Something went wrong. Please try again.',
      'retry': 'Retry',
      'noNonAdminEmployees': 'No employees found',
      'formatPdf': 'PDF',
      'formatExcel': 'Excel',
      'english': 'English',
      'arabic': 'Arabic',
      'french': 'French',
      'downloadEmployeeReport': 'Download employee report',
      'cameraErrorMessage': 'Couldn\'t access the camera. Please allow camera permissions in your phone settings and try again.',
      'morningPeriod': 'Morning',
      'eveningPeriod': 'Evening',
      'employeeFallback': 'Employee',
      'tapToCapture': 'Tap to capture',
    },
    'ar': {
      'appTitle': 'نظام الحضور',
      'signIn': 'تسجيل الدخول',
      'signInHint': 'سجل الدخول برقم الموظف',
      'employeeNumber': 'رقم الموظف',
      'password': 'كلمة المرور',
      'enterEmployeeNumber': 'الرجاء إدخال رقم الموظف',
      'enterPassword': 'الرجاء إدخال كلمة المرور',
      'loginFailed': 'تعذر تسجيل الدخول. يرجى التحقق من رقم الموظف وكلمة المرور.',
      'wrongPassword': 'كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.',
      'employeeNotFound': 'رقم الموظف غير موجود. يرجى التحقق والمحاولة مرة أخرى.',
      'accountDisabled': 'تم تعطيل حسابك. اتصل بالمسؤول.',
      'toggleTheme': 'تبديل السمة',
      'language': 'اللغة',
      'noReports': 'لا توجد تقارير بعد',
      'noReportsSubtitle': 'لم يقدم الموظفون أي تقارير',
      'reportDetails': 'تفاصيل التقرير',
      'employee': 'الموظف',
      'description': 'الوصف',
      'photo': 'الصورة',
      'issue': 'مشكلة',
      'inventory': 'المخزون',
      'feedback': 'ملاحظات',
      'searchReports': 'البحث في التقارير...',
      'all': 'الكل',
      'filterByType': 'تصفية حسب النوع',
      'unknown': 'غير معروف',
      'report': 'تقرير',
      'dashboard': 'لوحة المعلومات',
      'employees': 'الموظفين',
      'reports': 'التقارير',
      'inbox': 'صندوق الوارد',
      'records': 'السجلات',
      'totalHours': 'إجمالي الساعات',
      'adminPanel': 'لوحة الإدارة',
      'quickActions': 'إجراءات سريعة',
      'todayOverview': 'نظرة عامة اليوم',
      'manageEmployees': 'إدارة الموظفين',
      'employeeReports': 'تقارير الموظفين',
      'administrator': 'مدير النظام',
      'manageEmployeesSubtitle': 'إضافة وتعديل وحذف الموظفين',
      'dailyMonthlyReportsSubtitle': 'تقارير الحضور اليومية والشهرية',
      'viewEmployeeReportsSubtitle': 'عرض المشكلات والمخزون والملاحظات من الموظفين',
      'logout': 'تسجيل الخروج',
      'attendance': 'الحضور',
      'history': 'السجل',
      'morning': 'صباحي',
      'evening': 'مسائي',
      'employeeId': 'المعرف',
      'working': 'يعمل الآن',
      'finished': 'منتهٍ',
      'notStarted': 'لم يبدأ بعد',
      'checkIn': 'تسجيل دخول',
      'checkOut': 'تسجيل خروج',
      'breakPeriod': 'فترة الاستراحة (12:00 - 13:00)',
      'noMatchingReports': 'لا توجد تقارير مطابقة',
      'tryDifferentSearch': 'جرب بحثاً أو تصفية مختلفة',
      'submitted': 'تم تقديم التقرير',
      'employeeReport': 'تقرير الموظف',
      'morningCheckInSuccess': 'تم تسجيل الدخول الصباحي بنجاح!',
      'morningCheckOutSuccess': 'تم تسجيل الخروج الصباحي بنجاح!',
      'eveningCheckInSuccess': 'تم تسجيل الدخول المسائي بنجاح!',
      'eveningCheckOutSuccess': 'تم تسجيل الخروج المسائي بنجاح!',
      'newReport': 'تقرير جديد',
      'reportType': 'نوع التقرير',
      'required': 'مطلوب',
      'addPhoto': 'إضافة صورة',
      'submitReport': 'إرسال التقرير',
      'noRecords': 'لا توجد سجلات',
      'noRecordsSubtitle': 'لا توجد سجلات حضور لهذا الشهر',
      'days': 'أيام',
      'hours': 'ساعات',
      'attendanceSummary': 'ملخص الحضور',
      'today': 'اليوم',
      'currentlyWorking': 'يعمل حالياً',
      'noEmployeesWorking': 'لا يوجد موظفون يعملون حالياً',
      'auto': 'تلقائي',
      'insideAllowedArea': 'أنت داخل منطقة تسجيل الدخول',
      'outsideAllowedArea': 'أنت خارج منطقة تسجيل الدخول',
      'faceVerification': 'التحقق من الوجه',
      'faceVerificationCheckout': 'التحقق من الوجه – تسجيل الخروج',
      'total': 'الإجمالي',
      'settings': 'الإعدادات',
      'shiftConfig': 'إعدادات الورديات',
      'geofenceConfig': 'إعدادات الموقع الجغرافي',
      'setShiftTimes': 'حدد أوقات البدء والانتهاء للورديات الصباحية والمسائية.',
      'morningStart': 'بداية الوردية الصباحية',
      'morningEnd': 'نهاية الوردية الصباحية',
      'eveningStart': 'بداية الوردية المسائية',
      'eveningEnd': 'نهاية الوردية المسائية',
      'saveShiftTimes': 'حفظ أوقات الورديات',
      'morningStartBeforeEnd': 'يجب أن تكون نهاية الوردية الصباحية بعد بدايتها',
      'eveningStartBeforeEnd': 'يجب أن تكون نهاية الوردية المسائية بعد بدايتها',
      'noOverlap': 'يجب ألا تتداخل الوردية الصباحية مع المسائية',
      'goodMorning': 'صباح الخير',
      'goodAfternoon': 'مساء الخير',
      'goodEvening': 'مساء الخير',
      'totalEmployees': 'إجمالي الموظفين',
      'workingNow': 'يعمل الآن',
      'qrCheckin': 'تسجيل الدخول عبر QR',
      'manageStaff': 'إدارة الموظفين',
      'viewAttendance': 'عرض الحضور',
      'addEmployee': 'إضافة موظف',
      'editEmployee': 'تعديل موظف',
      'fullName': 'الاسم الكامل',
      'cancel': 'إلغاء',
      'retakeAll': 'إعادة الكل',
      'confirmSave': 'تأكيد وحفظ',
      'search': 'بحث',
      'companyLocation': 'موقع الشركة',
      'allowedRadius': 'نصف القطر المسموح',
      'meters': 'متر',
      'saveLocation': 'حفظ الموقع',
      'fetchingLocation': 'جاري تحديد موقعك...',
      'selectTime24h': 'اختر الوقت (24 ساعة)',
      'displayQR': 'عرض رمز QR',
      'saving': 'جاري الحفظ...',
      'shiftSettings': 'إعدادات الورديات',
      'selectLanguage': 'اختر اللغة',
      'admin': 'المسؤول',
      'logoutConfirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'employeeAddedWFace': 'تم إضافة الموظف مع تسجيل الوجه ✓',
      'employeeUpdated': 'تم تحديث بيانات الموظف',
      'deleteEmployee': 'حذف الموظف',
      'delete': 'حذف',
      'employeeDeleted': 'تم حذف الموظف',
      'employeeNumberLabel': 'رقم الموظف',
      'newPassword': 'كلمة مرور جديدة (اتركها فارغة للاحتفاظ بها)',
      'nextCaptureFace': 'التالي: التقاط الوجه',
      'save': 'حفظ',
      'noEmployeesFound': 'لم يتم العثور على موظفين',
      'addFirstEmployee': 'أضف موظفك الأول للبدء',
      'adminRole': 'مسؤول',
      'faceEnrolled': 'تم تسجيل الوجه',
      'faceNotEnrolled': 'لم يتم تسجيل الوجه',
      'editDetails': 'تعديل التفاصيل',
      'reenrollFace': 'إعادة تسجيل الوجه',
      'workingNowSection': 'يعمل الآن',
      'faceEnrollmentCancelled': 'تم إلغاء تسجيل الوجه. لم يتم إنشاء الموظف.',
      'faceReenrollmentCancelled': 'تم إلغاء إعادة تسجيل الوجه.',
      'noFaceDetected': 'لم يتم اكتشاف وجه. تأكد من أن الوجه مضاء جيداً ومرئي بالكامل.',
      'cameraError': 'تعذر الوصول إلى الكاميرا',
      'faceEnrollment': 'تسجيل الوجه',
      'startingCamera': 'جاري تشغيل الكاميرا…',
      'positionFaceInsideOval': 'ضع وجهك داخل الإطار البيضاوي',
      'capturing': 'جاري الالتقاط…',
      'extractingFaceData': 'جاري معالجة بيانات الوجه...',
      'tryAgain': 'حاول مرة أخرى',
      'faceCaptured': 'تم التقاط الوجه!',
      'goBack': 'العودة',
      'identityConfirmed': 'تم تأكيد الهوية',
      'verificationFailed': 'تعذر تأكيد هويتك',
      'faceNotRegistered': 'لا يوجد وجه مسجل لحسابك',
      'verificationError': 'حدث خطأ أثناء التحقق من الوجه',
      'holdStill': 'ابقَ ثابتاً…',
      'verifyingIdentity': 'جاري التحقق من هويتك…',
      'initialisingCamera': 'جاري تهيئة الكاميرا…',
      'comparingFace': 'جاري مقارنة الوجه بحسابك…',
      'capturingFace': 'جاري التقاط الوجه…',
      'startCamera': 'جاري بدء الكاميرا…',
      'positionFaceInOval': 'ضع وجهك داخل الإطار البيضاوي',
      'faceDoesNotMatch': 'وجهك لا يتطابق مع المسجل لهذا الحساب',
      'notEnrolledContactAdmin': 'حسابك ليس لديه وجه مسجل. يرجى الاتصال بالمسؤول.',
      'checkinSuccessful': 'تم تسجيل الدخول بنجاح!',
      'checkoutSuccessful': 'تم تسجيل الخروج بنجاح!',
      'qrCheckinStep2': 'تسجيل الدخول عبر QR — الخطوة 2 من 3',
      'validatingQR': 'جاري التحقق من رمز QR…',
      'step1Loc': '1 الموقع',
      'step2QR': '2 رمز QR',
      'step3Face': '3 الوجه',
      'scanAdminQR': 'امسح رمز QR الخاص بالمسؤول',
      'locVerified': 'تم التحقق من الموقع',
      'scanAgain': 'مسح مرة أخرى',
      'qrInvalidOrExpired': 'رمز QR غير صالح أو منتهي الصلاحية. اطلب من المسؤول تحديثه.',
      'checkinCancelled': 'تم إلغاء تسجيل الدخول. امسح رمز QR مرة أخرى للمحاولة.',
      'failedToGenerateQR': 'تعذر إنشاء رمز QR. يرجى التحقق من اتصالك والمحاولة مرة أخرى.',
      'qrCheckinCode': 'رمز QR لتسجيل الدخول',
      'employeeCheckin': 'تسجيل دخول الموظف',
      'scanThisQR': 'امسح رمز QR هذا لتسجيل الدخول',
      'refreshNow': 'تحديث الآن',
      'manageShiftGeofence': 'إدارة أوقات الورديات وإعدادات الموقع الجغرافي.',
      'setMorningEveningShift': 'تعيين أوقات بدء وانتهاء الورديات الصباحية والمسائية',
      'setCompanyLocationRadius': 'تعيين موقع الشركة ونصف القطر المسموح لتسجيل الدخول',
      'invalidCoordinates': 'الإحداثيات المدخلة غير صالحة. يرجى التحقق من القيم.',
      'latitudeBetween': 'يجب أن يكون خط العرض رقماً بين -90 و 90',
      'longitudeBetween': 'يجب أن يكون خط الطول رقماً بين -180 و 180',
      'radiusBetween': 'يجب أن يكون نصف القطر بين 10 و 1000 متر',
      'geofencedUpdated': 'تم تحديث إعدادات الموقع الجغرافي بنجاح',
      'geofenceConfigTitle': 'إعدادات الموقع الجغرافي',
      'geofenceDescription': 'تعيين موقع الشركة ونصف القطر المسموح للسياج الجغرافي لتسجيل الدخول.',
      'companyLocationSection': 'موقع الشركة',
      'latitude': 'خط العرض',
      'longitude': 'خط الطول',
      'egLatitude': 'مثال: 35.219445',
      'egLongitude': 'مثال: 4.204832',
      'minMaxRadius': 'الحد الأدنى: 10م - الحد الأقصى: 1000م',
      'saveGeofence': 'حفظ الموقع الجغرافي',
      'dailyAttendanceReport': 'تقرير الحضور اليومي',
      'date': 'التاريخ',
      'totalRecords': 'إجمالي السجلات',
      'monthlyAttendanceReport': 'تقرير الحضور الشهري',
      'period': 'الفترة',
      'daysPresent': 'أيام الحضور',
      'employeeHash': 'رقم الموظف',
      'checkInPdf': 'تسجيل دخول',
      'checkOutPdf': 'تسجيل خروج',
      'totalTime': 'الوقت الإجمالي',
      'daily': 'يومي',
      'monthly': 'شهري',
      'downloadReport': 'تنزيل التقرير',
      'chooseFormat': 'اختر تنسيق الملف:',
      'noData': 'لا توجد بيانات',
      'selectDateOrMonth': 'اختر تاريخاً أو شهراً لعرض التقارير',
      'noAttendanceRecords': 'لا توجد سجلات حضور',
      'noRecordsForDate': 'لا توجد سجلات لهذا التاريخ',
      'autoCheckedOut': '(تسجيل خروج تلقائي)',
      'noDataForMonth': 'لا توجد بيانات لهذا الشهر',
      'noRecordsFoundPeriod': 'لم يتم العثور على سجلات حضور لهذه الفترة',
      'download': 'تنزيل',
      'downloadFailed': 'تعذر تنزيل الملف. يرجى المحاولة مرة أخرى.',
      'myReports': 'تقاريري',
      'submitFirstReport': 'قدم تقريرك الأول من الشاشة الرئيسية',
      'attendanceHistory': 'سجل الحضور',
      'noRecordsMonth': 'لا توجد سجلات حضور لهذا الشهر',
      'gpsNotAvailable': 'موقع GPS غير متاح. يرجى تشغيل خدمات الموقع في إعدادات هاتفك.',
      'outsideAllowedAreaError': 'أنت خارج المنطقة المسموحة للشركة. يرجى الاقتراب أكثر من المكتب.',
      'checkinFailed': 'تعذر تسجيل دخولك. يرجى المحاولة مرة أخرى أو الاتصال بالمسؤول.',
      'checkoutFailed': 'تعذر تسجيل خروجك. يرجى المحاولة مرة أخرى أو الاتصال بالمسؤول.',
      'confirm': 'تأكيد',
      'shiftUpdated': 'تم تحديث إعدادات الورديات بنجاح',
      'lookAtCamera': 'انظر مباشرة إلى الكاميرا. الالتقاط التلقائي في',
      'authenticateCheckin': 'التحقق لتسجيل الدخول أو الخروج',
      'biometricNotAvailable': 'بصمة الإصبع / فتح الوجه غير متاح على هذا الجهاز',
      'morningCheckinTime': 'يمكنك تسجيل الدخول في الفترة الصباحية فقط',
      'eveningCheckinTime': 'يمكنك تسجيل الدخول في الفترة المسائية فقط',
      'locationTracking': 'تتبع الموقع لتسجيل الحضور',
      'lookDirectlyAtCamera': 'تأكد من أنك تنظر مباشرة إلى الكاميرا مع إضاءة جيدة.',
      'deleteConfirm': 'حذف {name}؟',
      'deleteReport': 'حذف التقرير',
      'reportDeleted': 'تم حذف التقرير',
      'faceReenrolled': 'تم إعادة تسجيل الوجه لـ {name}',
      'collapse': 'طي',
      'expand': 'توسيع',
      'networkError': 'مشكلة في الاتصال. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
      'faceVerificationUnavailable': 'تعذر بدء التحقق من الوجه. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
      'noInternetConnection': 'لا يوجد اتصال بالإنترنت. يرجى التحقق من شبكتك والمحاولة مرة أخرى.',
      'checkinNoInternet': 'تعذر تسجيل الدخول. لا يوجد اتصال بالإنترنت.',
      'checkoutNoInternet': 'تعذر تسجيل الخروج. لا يوجد اتصال بالإنترنت.',
      'loginNoInternet': 'تعذر تسجيل الدخول إلى النظام. لا يوجد اتصال بالإنترنت.',
      'connectionLost': 'تم فقدان اتصال الإنترنت',
      'autoCheckoutWarning': 'سيتم تسجيل خروجك تلقائياً إذا لم يتم استعادة الاتصال خلال 5 دقائق.',
      'manualAttendance': 'تسجيل حضور يدوي',
      'requiredField': 'هذا الحقل مطلوب',
      'checkOutAfterCheckIn': 'يجب أن يكون وقت الخروج بعد وقت الدخول',
      'reason': 'السبب',
      'reasonHint': 'سبب اختياري للتسجيل اليدوي',
      'jan': 'يناير',
      'feb': 'فبراير',
      'mar': 'مارس',
      'apr': 'أبريل',
      'may': 'ماي',
      'jun': 'يونيو',
      'jul': 'يوليو',
      'aug': 'أغسطس',
      'sep': 'سبتمبر',
      'oct': 'أكتوبر',
      'nov': 'نوفمبر',
      'dec': 'ديسمبر',
      'am': 'صباحاً',
      'pm': 'مساءً',
      'inLabel': 'دخول',
      'outLabel': 'خروج',
      'workingLabel': 'يعمل: ',
      'switchToLight': 'التحويل إلى الوضع النهاري',
      'switchToDark': 'التحويل إلى الوضع الليلي',
      'live': 'مباشر',
      'view': 'عرض',
      'refreshesIn': 'التحديث بعد {seconds}ث',
      'samplesCaptured': 'تم التقاط 3 عينات ({n} إجمالاً)',
      'unknownError': 'حدث خطأ غير متوقع',
      'success': 'تم بنجاح!',
      'somethingWentWrong': 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
      'retry': 'إعادة المحاولة',
      'noNonAdminEmployees': 'لم يتم العثور على موظفين',
      'formatPdf': 'PDF',
      'formatExcel': 'Excel',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'french': 'الفرنسية',
      'downloadEmployeeReport': 'تنزيل تقرير الموظف',
      'cameraErrorMessage': 'تعذر الوصول إلى الكاميرا. يرجى السماح بأذونات الكاميرا في إعدادات هاتفك والمحاولة مرة أخرى.',
      'morningPeriod': 'صباحي',
      'eveningPeriod': 'مسائي',
      'employeeFallback': 'موظف',
      'tapToCapture': 'اضغط للتصوير',
    },
    'fr': {
      'appTitle': 'Système de Présence',
      'signIn': 'Connexion',
      'signInHint': 'Connectez-vous avec votre numéro d\'employé',
      'employeeNumber': 'Numéro d\'employé',
      'password': 'Mot de passe',
      'enterEmployeeNumber': 'Veuillez entrer le numéro d\'employé',
      'enterPassword': 'Veuillez entrer le mot de passe',
      'loginFailed': 'Impossible de se connecter. Veuillez vérifier votre numéro d\'employé et votre mot de passe.',
      'wrongPassword': 'Mot de passe incorrect. Veuillez réessayer.',
      'employeeNotFound': 'Numéro d\'employé introuvable. Veuillez vérifier et réessayer.',
      'accountDisabled': 'Votre compte a été désactivé. Contactez votre administrateur.',
      'toggleTheme': 'Changer le thème',
      'language': 'Langue',
      'noReports': 'Aucun rapport',
      'noReportsSubtitle': 'Les employés n\'ont soumis aucun rapport',
      'reportDetails': 'Détails du rapport',
      'employee': 'Employé',
      'description': 'Description',
      'photo': 'Photo',
      'issue': 'Problème',
      'inventory': 'Inventaire',
      'feedback': 'Commentaires',
      'searchReports': 'Rechercher des rapports...',
      'all': 'Tous',
      'filterByType': 'Filtrer par type',
      'unknown': 'Inconnu',
      'report': 'Rapport',
      'dashboard': 'Tableau de bord',
      'employees': 'Employés',
      'reports': 'Rapports',
      'inbox': 'Boîte de réception',
      'records': 'Enregistrements',
      'totalHours': 'Heures totales',
      'adminPanel': 'Panneau d\'administration',
      'quickActions': 'Actions rapides',
      'todayOverview': 'Aperçu du jour',
      'manageEmployees': 'Gérer les employés',
      'employeeReports': 'Rapports employés',
      'administrator': 'Administrateur',
      'manageEmployeesSubtitle': 'Ajouter, modifier, supprimer des employés',
      'dailyMonthlyReportsSubtitle': 'Rapports de présence quotidiens et mensuels',
      'viewEmployeeReportsSubtitle': 'Voir les problèmes, inventaire et commentaires des employés',
      'logout': 'Déconnexion',
      'attendance': 'Présence',
      'history': 'Historique',
      'morning': 'Matin',
      'evening': 'Soir',
      'employeeId': 'ID',
      'working': 'En activité',
      'finished': 'Terminé',
      'notStarted': 'Pas commencé',
      'checkIn': 'Entrée',
      'checkOut': 'Sortie',
      'breakPeriod': 'Pause (12:00 - 13:00)',
      'noMatchingReports': 'Aucun rapport correspondant',
      'tryDifferentSearch': 'Essayez une recherche ou un filtre différent',
      'submitted': 'Rapport soumis',
      'employeeReport': 'Rapport d\'employé',
      'morningCheckInSuccess': 'Entrée matinale réussie !',
      'morningCheckOutSuccess': 'Sortie matinale réussie !',
      'eveningCheckInSuccess': 'Entrée du soir réussie !',
      'eveningCheckOutSuccess': 'Sortie du soir réussie !',
      'newReport': 'Nouveau rapport',
      'reportType': 'Type de rapport',
      'required': 'Requis',
      'addPhoto': 'Ajouter une photo',
      'submitReport': 'Soumettre le rapport',
      'noRecords': 'Aucun enregistrement',
      'noRecordsSubtitle': 'Aucun enregistrement de présence pour ce mois',
      'days': 'Jours',
      'hours': 'Heures',
      'attendanceSummary': 'Résumé de présence',
      'today': 'Aujourd\'hui',
      'currentlyWorking': 'En cours de travail',
      'noEmployeesWorking': 'Aucun employé en train de travailler',
      'auto': 'Auto',
      'insideAllowedArea': 'Vous êtes dans la zone d\'enregistrement',
      'outsideAllowedArea': 'Vous êtes en dehors de la zone d\'enregistrement',
      'faceVerification': 'Vérification faciale',
      'faceVerificationCheckout': 'Vérification faciale – Sortie',
      'total': 'Total',
      'settings': 'Paramètres',
      'shiftConfig': 'Configuration des quarts',
      'geofenceConfig': 'Configuration géofence',
      'setShiftTimes': 'Définissez les heures de début et de fin des quarts matin et soir.',
      'morningStart': 'Début du matin',
      'morningEnd': 'Fin du matin',
      'eveningStart': 'Début du soir',
      'eveningEnd': 'Fin du soir',
      'saveShiftTimes': 'Enregistrer les horaires',
      'morningStartBeforeEnd': 'La fin du matin doit être après le début',
      'eveningStartBeforeEnd': 'La fin du soir doit être après le début',
      'noOverlap': 'Le quart du matin ne doit pas chevaucher celui du soir',
      'goodMorning': 'Bonjour',
      'goodAfternoon': 'Bon après-midi',
      'goodEvening': 'Bonsoir',
      'totalEmployees': 'Total employés',
      'workingNow': 'En activité',
      'qrCheckin': 'Entrée par QR',
      'manageStaff': 'Gérer le personnel',
      'viewAttendance': 'Voir les présences',
      'addEmployee': 'Ajouter un employé',
      'editEmployee': 'Modifier un employé',
      'fullName': 'Nom complet',
      'cancel': 'Annuler',
      'retakeAll': 'Tout reprendre',
      'confirmSave': 'Confirmer et enregistrer',
      'search': 'Rechercher',
      'companyLocation': 'Emplacement de l\'entreprise',
      'allowedRadius': 'Rayon autorisé',
      'meters': 'mètres',
      'saveLocation': 'Enregistrer l\'emplacement',
      'fetchingLocation': 'Récupération de votre position...',
      'selectTime24h': 'Sélectionnez l\'heure (24h)',
      'displayQR': 'Afficher le code QR',
      'saving': 'Enregistrement...',
      'shiftSettings': 'Paramètres des quarts',
      'selectLanguage': 'Choisir la langue',
      'admin': 'Admin',
      'logoutConfirm': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'employeeAddedWFace': 'Employé ajouté avec inscription faciale \u2713',
      'employeeUpdated': 'Employé mis à jour',
      'deleteEmployee': 'Supprimer l\'employé',
      'delete': 'Supprimer',
      'employeeDeleted': 'Employé supprimé',
      'employeeNumberLabel': 'Numéro d\'employé',
      'newPassword': 'Nouveau mot de passe (laisser vide pour conserver)',
      'nextCaptureFace': 'Suivant : Capturer le visage',
      'save': 'Enregistrer',
      'noEmployeesFound': 'Aucun employé trouvé',
      'addFirstEmployee': 'Ajoutez votre premier employé pour commencer',
      'adminRole': 'ADMIN',
      'faceEnrolled': 'Visage enregistré',
      'faceNotEnrolled': 'Visage non enregistré',
      'editDetails': 'Modifier les détails',
      'reenrollFace': 'Réinscrire le visage',
      'workingNowSection': 'EN ACTIVITÉ',
      'faceEnrollmentCancelled': 'L\'inscription faciale a été annulée. Employé non créé.',
      'faceReenrollmentCancelled': 'Réinscription faciale annulée.',
      'noFaceDetected': 'Aucun visage détecté. Assurez-vous que le visage est bien éclairé et entièrement visible.',
      'cameraError': 'Échec d\'accès à la caméra',
      'faceEnrollment': 'Enregistrement facial',
      'startingCamera': 'Démarrage de la caméra\u2026',
      'positionFaceInsideOval': 'Positionnez votre visage dans l\'ovale',
      'capturing': 'Capture en cours\u2026',
      'extractingFaceData': 'Traitement des données faciales...',
      'tryAgain': 'Réessayer',
      'faceCaptured': 'Visage capturé !',
      'goBack': 'Retour',
      'identityConfirmed': 'Identité confirmée',
      'verificationFailed': 'Impossible de confirmer votre identité',
      'faceNotRegistered': 'Aucun visage n\'est enregistré pour votre compte',
      'verificationError': 'Une erreur est survenue lors de la vérification faciale',
      'holdStill': 'Restez immobile\u2026',
      'verifyingIdentity': 'Vérification de votre identité\u2026',
      'initialisingCamera': 'Initialisation de la caméra\u2026',
      'comparingFace': 'Comparaison du visage avec votre compte\u2026',
      'capturingFace': 'Capture du visage\u2026',
      'startCamera': 'Démarrage de la caméra\u2026',
      'positionFaceInOval': 'Positionnez votre visage dans l\'ovale',
      'faceDoesNotMatch': 'Votre visage ne correspond pas à celui enregistré pour ce compte',
      'notEnrolledContactAdmin': 'Votre compte n\'a pas de visage enregistré. Veuillez contacter votre administrateur.',
      'checkinSuccessful': 'Entrée réussie !',
      'checkoutSuccessful': 'Sortie réussie !',
      'qrCheckinStep2': 'Entrée par QR \u2014 Étape 2 sur 3',
      'validatingQR': 'Validation du code QR\u2026',
      'step1Loc': '1 Localisation',
      'step2QR': '2 QR',
      'step3Face': '3 Visage',
      'scanAdminQR': 'Scannez le code QR de l\'administrateur',
      'locVerified': 'Localisation vérifiée',
      'scanAgain': 'Scanner à nouveau',
      'qrInvalidOrExpired': 'Le code QR est invalide ou expiré. Demandez à l\'admin de le rafraîchir.',
      'checkinCancelled': 'Entrée annulée. Scannez à nouveau le QR pour réessayer.',
      'failedToGenerateQR': 'Impossible de créer le code QR. Veuillez vérifier votre connexion et réessayer.',
      'qrCheckinCode': 'Code QR d\'entrée',
      'employeeCheckin': 'Entrée employé',
      'scanThisQR': 'Scannez ce code QR pour vous connecter',
      'refreshNow': 'Rafraîchir',
      'manageShiftGeofence': 'Gérer les horaires des quarts et la configuration géofence.',
      'setMorningEveningShift': 'Définir les heures de début et fin des quarts matin et soir',
      'setCompanyLocationRadius': 'Définir l\'emplacement de l\'entreprise et le rayon d\'entrée autorisé',
      'invalidCoordinates': 'Les coordonnées saisies ne sont pas valides. Veuillez vérifier les valeurs.',
      'latitudeBetween': 'La latitude doit être un nombre compris entre -90 et 90',
      'longitudeBetween': 'La longitude doit être un nombre compris entre -180 et 180',
      'radiusBetween': 'Le rayon doit être compris entre 10 et 1000 mètres',
      'geofenceUpdated': 'Paramètres géofence mis à jour avec succès',
      'geofenceConfigTitle': 'Configuration géofence',
      'geofenceDescription': 'Définissez l\'emplacement de l\'entreprise et le rayon autorisé pour le géorepérage d\'entrée.',
      'companyLocationSection': 'Emplacement de l\'entreprise',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'egLatitude': 'ex. 35.219445',
      'egLongitude': 'ex. 4.204832',
      'minMaxRadius': 'Min : 10m  \u2014  Max : 1000m',
      'saveGeofence': 'Enregistrer le géofence',
      'dailyAttendanceReport': 'Rapport de présence quotidien',
      'date': 'Date',
      'totalRecords': 'Total des enregistrements',
      'monthlyAttendanceReport': 'Rapport de présence mensuel',
      'period': 'Période',
      'daysPresent': 'Jours de présence',
      'employeeHash': 'Employé #',
      'checkInPdf': 'Entrée',
      'checkOutPdf': 'Sortie',
      'totalTime': 'Temps total',
      'daily': 'Quotidien',
      'monthly': 'Mensuel',
      'downloadReport': 'Télécharger le rapport',
      'chooseFormat': 'Choisir le format de fichier :',
      'noData': 'Aucune donnée',
      'selectDateOrMonth': 'Sélectionnez une date ou un mois pour voir les rapports',
      'noAttendanceRecords': 'Aucun enregistrement de présence',
      'noRecordsForDate': 'Aucun enregistrement pour cette date',
      'autoCheckedOut': '(Sortie automatique)',
      'noDataForMonth': 'Aucune donnée pour ce mois',
      'noRecordsFoundPeriod': 'Aucun enregistrement de présence trouvé pour cette période',
      'download': 'Télécharger',
      'downloadFailed': 'Impossible de télécharger le fichier. Veuillez réessayer.',
      'myReports': 'Mes rapports',
      'submitFirstReport': 'Soumettez votre premier rapport depuis l\'écran d\'accueil',
      'attendanceHistory': 'Historique de présence',
      'noRecordsMonth': 'Aucun enregistrement de présence pour ce mois',
      'gpsNotAvailable': 'La localisation GPS n\'est pas disponible. Veuillez activer les services de localisation dans les paramètres de votre téléphone.',
      'outsideAllowedAreaError': 'Vous êtes en dehors de la zone autorisée de l\'entreprise. Veuillez vous rapprocher du bureau.',
      'checkinFailed': 'Impossible de vous enregistrer. Veuillez réessayer ou contacter votre administrateur.',
      'checkoutFailed': 'Impossible de vous désenregistrer. Veuillez réessayer ou contacter votre administrateur.',
      'confirm': 'Confirmer',
      'shiftUpdated': 'Paramètres des quarts mis à jour avec succès',
      'lookAtCamera': 'Regardez directement la caméra. Capture automatique dans',
      'authenticateCheckin': 'Authentifiez-vous pour entrer ou sortir',
      'biometricNotAvailable': 'L\'empreinte digitale / le déverrouillage facial n\'est pas disponible sur cet appareil',
      'morningCheckinTime': 'Vous pouvez vous enregistrer uniquement pendant les heures du matin',
      'eveningCheckinTime': 'Vous pouvez vous enregistrer uniquement pendant les heures du soir',
      'locationTracking': 'Suivi de localisation pour l\'entrée',
      'lookDirectlyAtCamera': 'Assurez-vous de regarder directement la caméra avec un bon éclairage.',
      'deleteConfirm': 'Supprimer {name} ?',
      'deleteReport': 'Supprimer le rapport',
      'reportDeleted': 'Rapport supprimé',
      'faceReenrolled': 'Visage réinscrit pour {name}',
      'collapse': 'Réduire',
      'expand': 'Agrandir',
      'networkError': 'Problème de connexion. Veuillez vérifier votre connexion Internet et réessayer.',
      'faceVerificationUnavailable': 'La vérification faciale n\'a pas pu démarrer. Veuillez vérifier votre connexion Internet et réessayer.',
      'noInternetConnection': 'Aucune connexion Internet. Vérifiez votre réseau et réessayez.',
      'checkinNoInternet': 'Impossible d\'enregistrer l\'entrée. Aucune connexion Internet.',
      'checkoutNoInternet': 'Impossible d\'enregistrer la sortie. Aucune connexion Internet.',
      'loginNoInternet': 'Impossible de se connecter. Aucune connexion Internet.',
      'connectionLost': 'Connexion Internet perdue',
      'autoCheckoutWarning': 'Vous serez automatiquement déconnecté(e) si elle n\'est pas rétablie dans 5 minutes.',
      'manualAttendance': 'Présence manuelle',
      'requiredField': 'Ce champ est requis',
      'checkOutAfterCheckIn': 'L\'heure de sortie doit être après l\'heure d\'entrée',
      'reason': 'Motif',
      'reasonHint': 'Motif optionnel pour la saisie manuelle',
      'jan': 'Jan',
      'feb': 'Fév',
      'mar': 'Mar',
      'apr': 'Avr',
      'may': 'Mai',
      'jun': 'Juin',
      'jul': 'Juil',
      'aug': 'Août',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Déc',
      'am': 'MAT',
      'pm': 'SOIR',
      'inLabel': 'ENTRÉE',
      'outLabel': 'SORTIE',
      'workingLabel': 'En cours: ',
      'switchToLight': 'Passer en mode clair',
      'switchToDark': 'Passer en mode sombre',
      'live': 'EN DIRECT',
      'view': 'Voir',
      'refreshesIn': 'Actualisation dans {seconds}s',
      'samplesCaptured': '3 échantillons capturés ({n} total)',
      'unknownError': 'Une erreur inattendue s\'est produite',
      'success': 'Succès !',
      'somethingWentWrong': 'Une erreur est survenue. Veuillez réessayer.',
      'retry': 'Réessayer',
      'noNonAdminEmployees': 'Aucun employé trouvé',
      'formatPdf': 'PDF',
      'formatExcel': 'Excel',
      'english': 'Anglais',
      'arabic': 'Arabe',
      'french': 'Français',
      'downloadEmployeeReport': 'Télécharger le rapport employé',
      'cameraErrorMessage': 'Impossible d\'accéder à la caméra. Veuillez autoriser les permissions de la caméra dans les paramètres de votre téléphone et réessayer.',
      'morningPeriod': 'Matin',
      'eveningPeriod': 'Soir',
      'employeeFallback': 'Employé',
      'tapToCapture': 'Tapez pour capturer',
    },
  };

  String t(String key) {
    return _data[locale.languageCode]?[key] ?? _data['en']?[key] ?? key;
  }

  String get appTitle => t('appTitle');
  String get signIn => t('signIn');
  String get signInHint => t('signInHint');
  String get employeeNumber => t('employeeNumber');
  String get password => t('password');
  String get enterEmployeeNumber => t('enterEmployeeNumber');
  String get enterPassword => t('enterPassword');
  String get loginFailed => t('loginFailed');
  String get wrongPassword => t('wrongPassword');
  String get employeeNotFound => t('employeeNotFound');
  String get accountDisabled => t('accountDisabled');
  String get toggleTheme => t('toggleTheme');
  String get language => t('language');
  String get noReports => t('noReports');
  String get noReportsSubtitle => t('noReportsSubtitle');
  String get reportDetails => t('reportDetails');
  String get employee => t('employee');
  String get description => t('description');
  String get photo => t('photo');
  String get issue => t('issue');
  String get inventory => t('inventory');
  String get feedback => t('feedback');
  String get searchReports => t('searchReports');
  String get all => t('all');
  String get filterByType => t('filterByType');
  String get unknown => t('unknown');
  String get report => t('report');
  String get dashboard => t('dashboard');
  String get employees => t('employees');
  String get reports => t('reports');
  String get inbox => t('inbox');
  String get records => t('records');
  String get totalHours => t('totalHours');
  String get adminPanel => t('adminPanel');
  String get quickActions => t('quickActions');
  String get todayOverview => t('todayOverview');
  String get manageEmployees => t('manageEmployees');
  String get employeeReports => t('employeeReports');
  String get administrator => t('administrator');
  String get manageEmployeesSubtitle => t('manageEmployeesSubtitle');
  String get dailyMonthlyReportsSubtitle => t('dailyMonthlyReportsSubtitle');
  String get viewEmployeeReportsSubtitle => t('viewEmployeeReportsSubtitle');
  String get logout => t('logout');
  String get attendance => t('attendance');
  String get history => t('history');
  String get morning => t('morning');
  String get evening => t('evening');
  String get employeeId => t('employeeId');
  String get working => t('working');
  String get finished => t('finished');
  String get notStarted => t('notStarted');
  String get checkIn => t('checkIn');
  String get checkOut => t('checkOut');
  String get breakPeriod => t('breakPeriod');
  String get noMatchingReports => t('noMatchingReports');
  String get tryDifferentSearch => t('tryDifferentSearch');
  String get submitted => t('submitted');
  String get employeeReport => t('employeeReport');
  String get morningCheckInSuccess => t('morningCheckInSuccess');
  String get morningCheckOutSuccess => t('morningCheckOutSuccess');
  String get eveningCheckInSuccess => t('eveningCheckInSuccess');
  String get eveningCheckOutSuccess => t('eveningCheckOutSuccess');
  String get newReport => t('newReport');
  String get reportType => t('reportType');
  String get required => t('required');
  String get addPhoto => t('addPhoto');
  String get submitReport => t('submitReport');
  String get noRecords => t('noRecords');
  String get noRecordsSubtitle => t('noRecordsSubtitle');
  String get days => t('days');
  String get hours => t('hours');
  String get attendanceSummary => t('attendanceSummary');
  String get today => t('today');
  String get currentlyWorking => t('currentlyWorking');
  String get noEmployeesWorking => t('noEmployeesWorking');
  String get auto => t('auto');
  String get insideAllowedArea => t('insideAllowedArea');
  String get outsideAllowedArea => t('outsideAllowedArea');
  String get faceVerification => t('faceVerification');
  String get faceVerificationCheckout => t('faceVerificationCheckout');
  String get total => t('total');
  String get settings => t('settings');
  String get shiftConfig => t('shiftConfig');
  String get geofenceConfig => t('geofenceConfig');
  String get setShiftTimes => t('setShiftTimes');
  String get morningStart => t('morningStart');
  String get morningEnd => t('morningEnd');
  String get eveningStart => t('eveningStart');
  String get eveningEnd => t('eveningEnd');
  String get saveShiftTimes => t('saveShiftTimes');
  String get morningStartBeforeEnd => t('morningStartBeforeEnd');
  String get eveningStartBeforeEnd => t('eveningStartBeforeEnd');
  String get noOverlap => t('noOverlap');
  String get goodMorning => t('goodMorning');
  String get goodAfternoon => t('goodAfternoon');
  String get goodEvening => t('goodEvening');
  String get totalEmployees => t('totalEmployees');
  String get workingNow => t('workingNow');
  String get qrCheckin => t('qrCheckin');
  String get manageStaff => t('manageStaff');
  String get viewAttendance => t('viewAttendance');
  String get addEmployee => t('addEmployee');
  String get editEmployee => t('editEmployee');
  String get fullName => t('fullName');
  String get cancel => t('cancel');
  String get retakeAll => t('retakeAll');
  String get confirmSave => t('confirmSave');
  String get search => t('search');
  String get companyLocation => t('companyLocation');
  String get allowedRadius => t('allowedRadius');
  String get meters => t('meters');
  String get saveLocation => t('saveLocation');
  String get fetchingLocation => t('fetchingLocation');
  String get selectTime24h => t('selectTime24h');
  String get displayQR => t('displayQR');
  String get saving => t('saving');
  String get shiftSettings => t('shiftSettings');
  String get selectLanguage => t('selectLanguage');
  String get admin => t('admin');
  String get logoutConfirm => t('logoutConfirm');
  String get employeeAddedWFace => t('employeeAddedWFace');
  String get employeeUpdated => t('employeeUpdated');
  String get deleteEmployee => t('deleteEmployee');
  String get delete => t('delete');
  String get employeeDeleted => t('employeeDeleted');
  String get employeeNumberLabel => t('employeeNumberLabel');
  String get newPassword => t('newPassword');
  String get nextCaptureFace => t('nextCaptureFace');
  String get save => t('save');
  String get noEmployeesFound => t('noEmployeesFound');
  String get addFirstEmployee => t('addFirstEmployee');
  String get adminRole => t('adminRole');
  String get faceEnrolled => t('faceEnrolled');
  String get faceNotEnrolled => t('faceNotEnrolled');
  String get editDetails => t('editDetails');
  String get reenrollFace => t('reenrollFace');
  String get workingNowSection => t('workingNowSection');
  String get faceEnrollmentCancelled => t('faceEnrollmentCancelled');
  String get faceReenrollmentCancelled => t('faceReenrollmentCancelled');
  String get noFaceDetected => t('noFaceDetected');
  String get cameraError => t('cameraError');
  String get faceEnrollment => t('faceEnrollment');
  String get startingCamera => t('startingCamera');
  String get positionFaceInsideOval => t('positionFaceInsideOval');
  String get capturing => t('capturing');
  String get extractingFaceData => t('extractingFaceData');
  String get tryAgain => t('tryAgain');
  String get faceCaptured => t('faceCaptured');
  String get goBack => t('goBack');
  String get identityConfirmed => t('identityConfirmed');
  String get verificationFailed => t('verificationFailed');
  String get faceNotRegistered => t('faceNotRegistered');
  String get verificationError => t('verificationError');
  String get holdStill => t('holdStill');
  String get verifyingIdentity => t('verifyingIdentity');
  String get initialisingCamera => t('initialisingCamera');
  String get comparingFace => t('comparingFace');
  String get capturingFace => t('capturingFace');
  String get startCamera => t('startCamera');
  String get positionFaceInOval => t('positionFaceInOval');
  String get faceDoesNotMatch => t('faceDoesNotMatch');
  String get notEnrolledContactAdmin => t('notEnrolledContactAdmin');
  String get checkinSuccessful => t('checkinSuccessful');
  String get checkoutSuccessful => t('checkoutSuccessful');
  String get qrCheckinStep2 => t('qrCheckinStep2');
  String get validatingQR => t('validatingQR');
  String get step1Loc => t('step1Loc');
  String get step2QR => t('step2QR');
  String get step3Face => t('step3Face');
  String get scanAdminQR => t('scanAdminQR');
  String get locVerified => t('locVerified');
  String get scanAgain => t('scanAgain');
  String get qrInvalidOrExpired => t('qrInvalidOrExpired');
  String get checkinCancelled => t('checkinCancelled');
  String get failedToGenerateQR => t('failedToGenerateQR');
  String get qrCheckinCode => t('qrCheckinCode');
  String get employeeCheckin => t('employeeCheckin');
  String get scanThisQR => t('scanThisQR');
  String get refreshNow => t('refreshNow');
  String get manageShiftGeofence => t('manageShiftGeofence');
  String get setMorningEveningShift => t('setMorningEveningShift');
  String get setCompanyLocationRadius => t('setCompanyLocationRadius');
  String get invalidCoordinates => t('invalidCoordinates');
  String get latitudeBetween => t('latitudeBetween');
  String get longitudeBetween => t('longitudeBetween');
  String get radiusBetween => t('radiusBetween');
  String get geofenceUpdated => t('geofenceUpdated');
  String get geofenceConfigTitle => t('geofenceConfigTitle');
  String get geofenceDescription => t('geofenceDescription');
  String get companyLocationSection => t('companyLocationSection');
  String get latitude => t('latitude');
  String get longitude => t('longitude');
  String get egLatitude => t('egLatitude');
  String get egLongitude => t('egLongitude');
  String get minMaxRadius => t('minMaxRadius');
  String get saveGeofence => t('saveGeofence');
  String get dailyAttendanceReport => t('dailyAttendanceReport');
  String get date => t('date');
  String get totalRecords => t('totalRecords');
  String get monthlyAttendanceReport => t('monthlyAttendanceReport');
  String get period => t('period');
  String get daysPresent => t('daysPresent');
  String get employeeHash => t('employeeHash');
  String get checkInPdf => t('checkInPdf');
  String get checkOutPdf => t('checkOutPdf');
  String get totalTime => t('totalTime');
  String get daily => t('daily');
  String get monthly => t('monthly');
  String get downloadReport => t('downloadReport');
  String get chooseFormat => t('chooseFormat');
  String get noData => t('noData');
  String get selectDateOrMonth => t('selectDateOrMonth');
  String get noAttendanceRecords => t('noAttendanceRecords');
  String get noRecordsForDate => t('noRecordsForDate');
  String get autoCheckedOut => t('autoCheckedOut');
  String get noDataForMonth => t('noDataForMonth');
  String get noRecordsFoundPeriod => t('noRecordsFoundPeriod');
  String get download => t('download');
  String get downloadFailed => t('downloadFailed');
  String get myReports => t('myReports');
  String get submitFirstReport => t('submitFirstReport');
  String get attendanceHistory => t('attendanceHistory');
  String get noRecordsMonth => t('noRecordsMonth');
  String get gpsNotAvailable => t('gpsNotAvailable');
  String get outsideAllowedAreaError => t('outsideAllowedAreaError');
  String get checkinFailed => t('checkinFailed');
  String get checkoutFailed => t('checkoutFailed');
  String get confirm => t('confirm');
  String get shiftUpdated => t('shiftUpdated');
  String get lookAtCamera => t('lookAtCamera');
  String get authenticateCheckin => t('authenticateCheckin');
  String get biometricNotAvailable => t('biometricNotAvailable');
  String get morningCheckinTime => t('morningCheckinTime');
  String get eveningCheckinTime => t('eveningCheckinTime');
  String get locationTracking => t('locationTracking');
  String get lookDirectlyAtCamera => t('lookDirectlyAtCamera');
  String get deleteConfirm => t('deleteConfirm');
  String get deleteReport => t('deleteReport');
  String get reportDeleted => t('reportDeleted');
  String get faceReenrolled => t('faceReenrolled');
  String get collapse => t('collapse');
  String get expand => t('expand');
  String get networkError => t('networkError');
  String get faceVerificationUnavailable => t('faceVerificationUnavailable');
  String get noInternetConnection => t('noInternetConnection');
  String get checkinNoInternet => t('checkinNoInternet');
  String get checkoutNoInternet => t('checkoutNoInternet');
  String get loginNoInternet => t('loginNoInternet');
  String get connectionLost => t('connectionLost');
  String get autoCheckoutWarning => t('autoCheckoutWarning');
  String get manualAttendance => t('manualAttendance');
  String get requiredField => t('requiredField');
  String get checkOutAfterCheckIn => t('checkOutAfterCheckIn');
  String get reason => t('reason');
  String get reasonHint => t('reasonHint');
  String get jan => t('jan');
  String get feb => t('feb');
  String get mar => t('mar');
  String get apr => t('apr');
  String get may => t('may');
  String get jun => t('jun');
  String get jul => t('jul');
  String get aug => t('aug');
  String get sep => t('sep');
  String get oct => t('oct');
  String get nov => t('nov');
  String get dec => t('dec');
  String get am => t('am');
  String get pm => t('pm');
  String get inLabel => t('inLabel');
  String get outLabel => t('outLabel');
  String get workingLabel => t('workingLabel');
  String get switchToLight => t('switchToLight');
  String get switchToDark => t('switchToDark');
  String get live => t('live');
  String get view => t('view');
  String get refreshesIn => t('refreshesIn');
  String get samplesCaptured => t('samplesCaptured');
  String get unknownError => t('unknownError');
  String get success => t('success');
  String get somethingWentWrong => t('somethingWentWrong');
  String get retry => t('retry');
  String get noNonAdminEmployees => t('noNonAdminEmployees');
  String get formatPdf => t('formatPdf');
  String get formatExcel => t('formatExcel');
  String get english => t('english');
  String get arabic => t('arabic');
  String get french => t('french');
  String get downloadEmployeeReport => t('downloadEmployeeReport');
  String get cameraErrorMessage => t('cameraErrorMessage');
  String get morningPeriod => t('morningPeriod');
  String get eveningPeriod => t('eveningPeriod');
  String get employeeFallback => t('employeeFallback');
  String get tapToCapture => t('tapToCapture');
  String refreshesInText(int seconds) => t('refreshesIn').replaceAll('{seconds}', '$seconds');
  String samplesCapturedText(int total) => t('samplesCaptured').replaceAll('{n}', '$total');
  String cameraErrorMessageText(String error) => t('cameraErrorMessage').replaceAll('{error}', error);
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}
