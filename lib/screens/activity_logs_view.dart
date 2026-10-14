import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muit_sales_app/models/log_model.dart';
import 'package:muit_sales_app/res/brand.dart';

import '../services/log_services.dart';

class ActivityLogsView extends StatelessWidget {
  const ActivityLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.canvas,
      appBar: Brand.appBar('Activity Logs & Report'),
      body: Column(
        children: [
          // LIVE CURRENT SESSION CARD
          _liveActiveCard(),
          const Divider(height: 1),
          // HISTORY LOGS LIST
          Expanded(
            child: Obx(() {
              final logs = LogService.to.rxLogs;
              if (logs.isEmpty) {
                return const Center(
                  child: Text(
                    'No past activity logs recorded yet.',
                    style: TextStyle(color: Brand.inkSoft),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return _logTile(logs[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _liveActiveCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brand.maroon,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Brand.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_outlined, color: Brand.gold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Active App Session',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final totalSecs = LogService.to.currentSessionSeconds.value;
                  final mins = totalSecs ~/ 60;
                  final secs = totalSecs % 60;
                  final timeText = mins > 0 ? '$mins mins $secs secs' : '$secs secs';

                  return Text(
                    timeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: Colors.white),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logTile(LogModel log) {
    IconData icon;
    Color color;

    switch (log.actionType) {
      case 'CALL':
        icon = Icons.call;
        color = Colors.green;
        break;
      case 'WHATSAPP':
        icon = Icons.chat;
        color = Colors.teal;
        break;
      case 'VISIT':
        icon = Icons.location_on;
        color = Colors.orange;
        break;
      case 'APP_USAGE':
        icon = Icons.timer;
        color = Colors.purple;
        break;
      case 'LOGIN':
        icon = Icons.login;
        color = Colors.blue;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Brand.softShadow,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          log.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Brand.ink,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'By: ${log.userName} • ${log.timestamp}',
            style: const TextStyle(fontSize: 12, color: Brand.inkSoft),
          ),
        ),
      ),
    );
  }
}