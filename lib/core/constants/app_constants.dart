class AppConstants {
  // Firestore Collections
  static const String colUsers       = 'users';
  static const String colGroups      = 'groups';
  static const String colExpenses    = 'expenses';
  static const String colSettlements = 'settlements';
  static const String colInvites     = 'invites';

  // Firebase Storage
  static const String pathProfileImages = 'profile_images';
  static const String pathReceiptImages = 'receipt_images';
  static const String pathGroupImages   = 'group_images';

  // Hive Boxes
  static const String boxUser     = 'user_box';
  static const String boxSettings = 'settings_box';

  // SharedPreferences
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrency  = 'currency';

  // Invite
  static const int inviteExpiryHours = 48;

  // Pagination
  static const int pageSize = 20;

  // Split Types
  static const String splitEqual      = 'equal';
  static const String splitPercentage = 'percentage';
  static const String splitExact      = 'exact';

  // Roles
  static const String roleAdmin  = 'admin';
  static const String roleMember = 'member';

  // Supported Currencies
  static const List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': '\$',   'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€',   'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£',   'name': 'British Pound'},
    {'code': 'INR', 'symbol': '₹',   'name': 'Indian Rupee'},
    {'code': 'JPY', 'symbol': '¥',   'name': 'Japanese Yen'},
    {'code': 'CAD', 'symbol': 'CA\$','name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
  ];
}
