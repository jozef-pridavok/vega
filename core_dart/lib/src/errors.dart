class CoreError {
  final int code;
  final String message;
  final Object? innerException;
  final Object? payload;

  const CoreError({required this.code, required this.message, this.innerException, this.payload});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CoreError && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() {
    return "$message ($code)";
  }
}

const errorRouteNotFound = CoreError(code: 1, message: "Route not found.");

/// Code 97
const errorNoInstallation = CoreError(code: 97, message: "No installation.");

/// Code 98
const errorNoUser = CoreError(code: 98, message: "No user.");

// Keys - forbidden

/// Code 99
const errorConnectionTimeout = CoreError(code: 99, message: "Connection timeout.");

/// Code 100
const errorNoApiKey = CoreError(code: 100, message: "No API Key.");

/// Code 101
const errorInvalidApiKey = CoreError(code: 101, message: "Invalid API key.");

/// Code 102
const errorInvalidApiIpAddress = CoreError(code: 102, message: "Invalid remote address.");

/// Code 103
const errorNoSession = CoreError(code: 103, message: "No session.");

/// Code 104
const errorNoClientId = CoreError(code: 104, message: "No client id.");

/// Code 105
const errorInvalidCredentials = CoreError(code: 105, message: "Invalid credentials.");

/// Code 106
const errorInvalidContentType = CoreError(code: 106, message: "Invalid content type.");

/// Code 107
const errorUserAlreadyExists = CoreError(code: 107, message: "User already exists.");

/// Code 108
const errorUserAlreadySignedIn = CoreError(code: 108, message: "User already signed in.");

/// Code 109
const errorUserNotSignedIn = CoreError(code: 109, message: "User not signed in.");

/// Code 110
const errorToManyAttempts = CoreError(code: 110, message: "Too many login attempts from your IP address.");

/// Code 111
const errorToManySessions = CoreError(code: 111, message: "Too many active sessions from your IP address.");

/// Code 112
const errorAccountBlocked = CoreError(code: 112, message: "Account blocked.");

/// Code 113
const errorUserCardNotActive = CoreError(code: 113, message: "User card is not active.");

/// Code 114
const errorCardIsBlocked = CoreError(code: 114, message: "Card is blocked.");

/// Code 115
const errorClientIsBlocked = CoreError(code: 115, message: "Client is blocked.");

/// Code 116
const errorProgramIsNotActive = CoreError(code: 116, message: "Program is not active.");

/// Code 117
const errorProgramRewardIsNotActive = CoreError(code: 117, message: "Program reward is not active.");

/// Code 118
const errorNotEnoughPoints = CoreError(code: 118, message: "Not enough points.");

/// Code 119
const errorNoAccessToken = CoreError(code: 119, message: "No access token.");

/// Code 120
const errorInvalidAccessToken = CoreError(code: 120, message: "Invalid access token.");
CoreError errorInvalidAccessTokenEx(String info) => CoreError(code: 120, message: "Invalid access token. $info.");

/// Code 121
const errorInvalidRefreshToken = CoreError(code: 121, message: "Invalid refresh token.");
CoreError errorInvalidRefreshTokenEx(String info) => CoreError(code: 121, message: "Invalid refresh token. $info.");

/// Code 122
const errorInvalidRefreshTokenPayload = CoreError(code: 122, message: "Invalid refresh token payload.");

/// Code 123
const errorRefreshTokenReuseDetected = CoreError(code: 123, message: "Refresh token reuse detected.");

/// Code 124
const errorTokenIsStolen = CoreError(code: 124, message: "Token belongs to different user.");

/// Code 125
const errorInvalidInstallation = CoreError(code: 125, message: "Invalid installation id.");
CoreError errorInvalidInstallationEx(String info) => CoreError(code: 125, message: "Invalid installation id. $info.");

/// Code 126
const errorUserRoleMissing = CoreError(code: 126, message: "User role missing.");

/// Code 127
const errorUserIsBlocked = CoreError(code: 127, message: "User is blocked.");

// errorClientIsBlocked already defined, 115

/// Code 128
const errorInvalidLicense = CoreError(code: 128, message: "Invalid license.");

// bad request

/// Code 145
const errorBrokenLogic = CoreError(code: 145, message: "Broken logic.");

/// Code 145
CoreError errorBrokenLogicEx(String info) => CoreError(code: 145, message: "Broken logic. $info.");

/// Code 146
const errorBrokenSecurity = CoreError(code: 146, message: "Broken security.");

/// Code 146
CoreError errorBrokenSecurityEx(String info) => CoreError(code: 146, message: "Broken security. $info.");

// Search

/// Code 150
const errorObjectNotFound = CoreError(code: 150, message: "Object not found.");

/// Code 151
const errorMoreObjectsFound = CoreError(code: 151, message: "More objects found.");

/// Code 152
const errorReceiptImplementationNotFound = CoreError(code: 152, message: "Receipt implementation not found.");

/// Code 153
const errorReceiptInvalid = CoreError(code: 153, message: "Invalid receipt.");

/// Code 154
const errorMessageImplementationNotFound = CoreError(code: 154, message: "Message implementation not found.");

// Params

/// Code 200
CoreError errorMissingParameter(String parameter) => CoreError(code: 200, message: "Missing parameter '$parameter'.");

/// Code 201
CoreError errorInvalidParameterType(String parameter, String expected) =>
    CoreError(code: 201, message: "Invalid parameter type '$parameter'. Expected: $expected.");

/// Code 202
CoreError errorInvalidParameterRange(String parameter, String expected) =>
    CoreError(code: 202, message: "Invalid parameter '$parameter'. Expected: $expected.");

// Response

/// Code 250
const errorInvalidResponseFormat = CoreError(code: 250, message: "Invalid response format.");

/// Code 250
CoreError errorInvalidResponseFormatEx(String desired) =>
    CoreError(code: 250, message: "Invalid response format. Expected: $desired.");

/// Code 251
const errorUnexpectedResponseStatusCode = CoreError(code: 251, message: "Unexpected response status code.");

/// Code 251
CoreError errorUnexpectedResponseStatusCodeEx(int unknown, {String? aux}) =>
    CoreError(code: 251, message: "Invalid response status code: $unknown. $aux.");

/// Code 252
const errorUnexpectedResponseAppCode = CoreError(code: 252, message: "Unexpected response app code.");

/// Code 252
CoreError errorUnexpectedResponseAppCodeEx(int unknown, {String? aux}) =>
    CoreError(code: 252, message: "Invalid response app code: $unknown. $aux.");

// State and data

/// Code 300
const errorCannotLoadInOfflineMode = CoreError(code: 300, message: "Failed to load data in offline mode.");

/// Code 302
const errorAlreadyInProgress = CoreError(code: 301, message: "Already in progress.");

/// Code 302
const errorAlreadyLoaded = CoreError(code: 302, message: "Data are already loaded.");

/// Code 303
const errorFailedToLoadData = CoreError(code: 303, message: "Failed to load data.");

CoreError errorFailedToLoadDataEx({Exception? ex}) =>
    CoreError(code: 303, message: "Failed to load data.", innerException: ex);

/// Code 304
const errorSettingsNotLoaded = CoreError(code: 304, message: "User settings are not loaded.");

/// Code 305
const errorUnexpectedState = CoreError(code: 305, message: "Unexpected state.");

/// Code 305
CoreError errorUnexpectedStateEx(String message) => CoreError(code: 305, message: "Unexpected state. $message");

/// Code 305
CoreError errorUnexpectedStateType(Type expected, Type got) => errorUnexpectedStateEx("$got but expect $expected.");

/// Code 306
const errorFailedToSaveData = CoreError(code: 306, message: "Failed to save data.");

/// Code 306
errorFailedToSaveDataEx({Exception? ex}) => CoreError(code: 306, message: "Failed to save data.", innerException: ex);

/// Code 307
const errorNoData = CoreError(code: 307, message: "No data.");

/// Code 308
const errorFailedToDeleteData = CoreError(code: 308, message: "Failed to delete data.");

/// Code 308
CoreError errorFailedToDeleteDataEx({Exception? ex}) =>
    CoreError(code: 308, message: "Failed to delete data.", innerException: ex);

/// Code 309
const errorLocationPermanentlyDenied = CoreError(code: 309, message: "Location permission permanently denied.");

/// Code 988
const errorCancelled = CoreError(code: 898, message: "Cancelled.");

/// Code 989
const errorServiceUnavailable = CoreError(code: 899, message: "Service unavailable.");

/// Code 999
const errorSynchronization = CoreError(code: 999, message: "Synchronization error.");

/// Code 999
errorSynchronizationEx({Exception? ex}) => CoreError(code: 999, message: "Synchronization error.", innerException: ex);

/// Code 900
CoreError errorUnexpectedException(Object exception) => CoreError(
      code: 900,
      message: "Unexpected exception: '$exception'.",
      innerException: exception,
    );

// eof
