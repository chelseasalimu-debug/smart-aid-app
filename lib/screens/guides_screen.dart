import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

  static const _guides = [
    {
      'icon': Icons.local_fire_department,
      'title': 'Burns',
      'steps': [
        'Cool the burn with running water for 20 minutes.',
        'Remove tight items (rings, watches) before swelling.',
        'Cover loosely with clean, non-fluffy cloth.',
        'Do NOT apply butter, oil, or ice.',
        'Seek help if burn is larger than the palm or blistered.',
      ],
    },
    {
      'icon': Icons.bloodtype,
      'title': 'Severe Bleeding',
      'steps': [
        'Apply firm, direct pressure with a clean cloth.',
        'Do NOT remove the cloth if it soaks — add another on top.',
        'Elevate the injured limb above heart level if possible.',
        'Keep pressure until help arrives.',
        'Call emergency services immediately.',
      ],
    },
    {
      'icon': Icons.healing,
      'title': 'Fractures / Sprains',
      'steps': [
        'Keep the injured area still — do not try to straighten it.',
        'Apply a cold pack (wrapped in cloth) for 15–20 minutes.',
        'Support with a splint or sling if trained.',
        'Elevate if possible to reduce swelling.',
        'Seek medical attention for suspected fractures.',
      ],
    },
    {
      'icon': Icons.psychology,
      'title': 'Choking (Adult)',
      'steps': [
        'Ask "Are you choking?" — if they can cough, encourage coughing.',
        'If they cannot breathe, give 5 back blows between shoulder blades.',
        'If unsuccessful, give 5 abdominal thrusts (Heimlich).',
        'Alternate 5 back blows and 5 abdominal thrusts.',
        'Call emergency services if the object does not come out.',
      ],
    },
    {
      'icon': Icons.air,
      'title': 'Not Breathing / CPR',
      'steps': [
        'Call emergency services immediately.',
        'Place the person on a firm, flat surface.',
        'Give 30 chest compressions (5–6 cm deep, 100–120 per minute).',
        'Give 2 rescue breaths if trained.',
        'Continue until help arrives or the person recovers.',
      ],
    },
    {
      'icon': Icons.water_drop,
      'title': 'Poisoning',
      'steps': [
        'Do NOT make the person vomit.',
        'Identify the substance and time of exposure.',
        'If on skin/eyes, rinse with clean water for 15 minutes.',
        'Call emergency services or poison control immediately.',
        'Keep the container/label for medical staff.',
      ],
    },
    {
      'icon': Icons.warning_amber,
      'title': 'Snake Bite',
      'steps': [
        'Keep the person calm and still — movement spreads venom faster.',
        'Keep the bitten limb BELOW heart level.',
        'Remove rings, watches, tight clothing near the bite.',
        'Do NOT cut, suck, or apply ice to the bite.',
        'Note the time and snake appearance, then get to a hospital FAST.',
      ],
    },
    {
      'icon': Icons.sick,
      'title': 'Seizure / Fits',
      'steps': [
        'Do NOT restrain the person or put anything in their mouth.',
        'Clear the area of hard or sharp objects.',
        'Cushion the head with something soft (folded jacket).',
        'Time the seizure — if it lasts over 5 minutes, call emergency services.',
        'After it stops, turn them on their side (recovery position).',
      ],
    },
    {
      'icon': Icons.thermostat,
      'title': 'Heat Stroke',
      'steps': [
        'Move the person to a cool, shaded area immediately.',
        'Remove excess clothing.',
        'Cool them fast: wet cloths, fan, cool water on skin.',
        'Do NOT give fluids if they are unconscious or confused.',
        'Call emergency services — heat stroke is life-threatening.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First-aid guides')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _guides.length,
        itemBuilder: (_, i) {
          final g = _guides[i];
          return Card(
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(g['icon'] as IconData, color: AppColors.primary),
              ),
              title: Text(
                g['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                ...(g['steps'] as List<String>).asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${e.key + 1}. ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(child: Text(e.value)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
