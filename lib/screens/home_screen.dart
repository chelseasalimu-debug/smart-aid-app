import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'guides_screen.dart';
import 'history_screen.dart';
import 'appointments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:+263000000000'); // ← replace with CUT clinic number
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartAID')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Emergency button
          GestureDetector(
            onTap: _callEmergency,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.emergency,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.phone_in_talk, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMERGENCY',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Tap to call campus clinic',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('What do you need?',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          _ActionCard(
            icon: Icons.chat_bubble_outline,
            title: 'Describe a situation',
            subtitle: 'Get AI first-aid guidance',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
          const SizedBox(height: 12),

          _ActionCard(
            icon: Icons.event_available,
            title: 'Book appointment',
            subtitle: 'Schedule a clinic visit',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
            ),
          ),
          const SizedBox(height: 12),

          _ActionCard(
            icon: Icons.menu_book,
            title: 'First-aid guides',
            subtitle: 'Common emergencies explained',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GuidesScreen()),
            ),
          ),
          const SizedBox(height: 12),

          _ActionCard(
            icon: Icons.history,
            title: 'My history',
            subtitle: 'Past conversations',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}