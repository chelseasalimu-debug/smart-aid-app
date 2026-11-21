import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../theme/app_theme.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});
  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _reasonController = TextEditingController();

  String _serviceType = 'General Consultation';
  String _location = 'CUT Campus Clinic';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _saving = false;

  static const _services = [
    'General Consultation',
    'Dental',
    'Emergency',
    'Counseling',
    'Vaccination',
  ];

  static const _locations = [
    'CUT Campus Clinic',
    'Chinhoyi Provincial Hospital',
    'Other',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    final appt = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceType: _serviceType,
      dateTime: dt,
      reason: _reasonController.text.trim().isEmpty
          ? 'No reason provided'
          : _reasonController.text.trim(),
      location: _location,
    );

    await AppointmentService.add(appt);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Appointment booked!'),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pop(context, true);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _label('Service type'),
          DropdownButtonFormField<String>(
            initialValue: _serviceType,
            decoration: _inputDecoration(),
            items: _services
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _serviceType = v!),
          ),
          const SizedBox(height: 20),

          _label('Location'),
          DropdownButtonFormField<String>(
            initialValue: _location,
            decoration: _inputDecoration(),
            items: _locations
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) => setState(() => _location = v!),
          ),
          const SizedBox(height: 20),

          _label('Date'),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: _inputDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(_date)),
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _label('Time'),
          InkWell(
            onTap: _pickTime,
            child: InputDecorator(
              decoration: _inputDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatTime(_time)),
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _label('Reason (optional)'),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: _inputDecoration().copyWith(
              hintText: 'e.g. Persistent headache for 3 days',
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(_saving ? 'Saving...' : 'Confirm appointment'),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    ),
  );

  InputDecoration _inputDecoration() => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
