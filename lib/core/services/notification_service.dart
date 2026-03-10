import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final Logger _logger;

  NotificationService(this._messaging, this._firestore) : _logger = Logger();

  Future<void> initialize(String userId) async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.i('FCM permission granted');

      // Get and store FCM token
      final token = await _messaging.getToken();
      if (token != null) await _saveFcmToken(userId, token);

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((token) => _saveFcmToken(userId, token));

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    }
  }

  Future<void> _saveFcmToken(String userId, String token) async {
    try {
      await _firestore.collection(AppConstants.colUsers).doc(userId).update(
          {'fcmToken': token, 'tokenUpdatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      _logger.w('Failed to save FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _logger.d('Foreground message: ${message.notification?.title}');
    // TODO: Show in-app notification banner
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.d('App opened from notification: ${message.data}');
    // TODO: Navigate to relevant screen based on message.data
  }

  /// Send push notification to a specific user.
  /// In production, this would be done via Cloud Functions, not from the client.
  Future<void> sendNotificationToUser({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // Retrieve target user's FCM token
    final doc = await _firestore
        .collection(AppConstants.colUsers)
        .doc(targetUserId)
        .get();

    final token = (doc.data())?['fcmToken'] as String?;
    if (token == null) return;

    // NOTE: In production, trigger a Cloud Function to send FCM.
    // Direct FCM sends from client require your server key which should never be in the app.
    _logger.d('Would send notification "$title" to $targetUserId');
  }

  // Notification type helpers
  Future<void> notifyExpenseAdded({
    required List<String> memberIds,
    required String addedBy,
    required String groupName,
    required String expenseDescription,
    required double amount,
  }) async {
    for (final memberId in memberIds) {
      if (memberId == addedBy) continue;
      await sendNotificationToUser(
        targetUserId: memberId,
        title: 'New expense in $groupName',
        body: '$expenseDescription · \$${amount.toStringAsFixed(2)}',
        data: {'type': 'expense_added'},
      );
    }
  }

  Future<void> notifySettlement({
    required String targetUserId,
    required String fromUserName,
    required double amount,
    required String groupName,
  }) async {
    await sendNotificationToUser(
      targetUserId: targetUserId,
      title: '$fromUserName paid you \$${amount.toStringAsFixed(2)}',
      body: 'In $groupName',
      data: {'type': 'settlement'},
    );
  }

  Future<void> notifyGroupInvite({
    required String targetUserId,
    required String inviterName,
    required String groupName,
    required String inviteId,
  }) async {
    await sendNotificationToUser(
      targetUserId: targetUserId,
      title: '$inviterName invited you to $groupName',
      body: 'Tap to join the group',
      data: {'type': 'group_invite', 'inviteId': inviteId},
    );
  }
}
