/// Supported operations in the access-only screen. The Windows search and TD0.2 test use
/// the shared CPS, Java and TLS ports already used by the document deposit.
/// Keep unrelated operations disabled until their Windows workflow is reviewed.
bool dv1AccessPlatformSupported({
  required String platform,
  bool documentSearch = false,
  bool existenceCheck = false,
  bool authorizationAdd = false,
  bool authorizationWithdrawal = false,
  bool otherAction = false,
}) =>
    platform == 'macos' ||
    (platform == 'windows' &&
        (documentSearch ||
            existenceCheck ||
            authorizationAdd ||
            authorizationWithdrawal) &&
        !otherAction);
