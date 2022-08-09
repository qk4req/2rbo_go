import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationController {
  final String _channelKey = 'basic_channel';
  final String _channelName = 'Basic channel';
  final String _channelDesc = 'Notification channel for basic tests';
  final String _channelGroupKey = 'basic_channel_group';
  final String _channelGroupName = 'Basic group';
  final Color _defaultColor = const Color(0xFF9D50DD);
  final Color _ledColor = Colors.white;
  final AwesomeNotifications _notifications = AwesomeNotifications();

  NotificationController() {
    _notifications.initialize(
        '',
        [
          NotificationChannel(
              playSound: true,
              defaultRingtoneType: DefaultRingtoneType.Notification,
              //enableVibration: true,
              //vibrationPattern: ,
              channelGroupKey: _channelGroupKey,
              channelKey: _channelKey,
              channelName: _channelName,
              channelDescription: _channelDesc,
              defaultColor: _defaultColor,
              ledColor: _ledColor,
              importance: NotificationImportance.Max
          )
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupkey: _channelGroupKey,
              channelGroupName: _channelGroupName)
        ],
        debug: true
    );
  }

  int create(int? id, {
    String? title,
    String? body
  }) {
    id ??= Random().nextInt(AwesomeNotifications.maxID);
    _notifications.createNotification(
        content: NotificationContent(
            id: id,
            channelKey: _channelKey,
            title: title,
            body: body
        )
    );
    return id;
  }

  void delete(int id) {
    _notifications.dismiss(id);
  }
}