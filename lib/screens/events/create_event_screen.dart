import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';
import '../../services/event_service.dart';
import '../../services/connectivity_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errorFieldRequired;
    }
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _handleCreateEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Combine date and time
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Create event in Firestore
    final eventService = EventService();
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    final isOnline = connectivityService.isOnline;

    final result = await eventService.createEvent(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dateTime: dateTime,
      location: _locationController.text.trim(),
      isOnline: isOnline,
    );

    if (!mounted) return;

    final error = result['error'];
    final message = result['message'];
    final isOffline = result['isOffline'] ?? false;

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message ?? 'Event created successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isOffline ? Colors.orange : Colors.green,
        ),
      );

      // Small delay to ensure UI updates before popping
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        navigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'e.g., Birthday Party',
                  prefixIcon: Icon(Icons.event),
                ),
                validator: _validateRequired,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'Select event date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : 'Tap to select date',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time picker
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    hintText: 'Select event time',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _selectedTime != null
                        ? _formatTime(_selectedTime!)
                        : 'Tap to select time',
                    style: TextStyle(
                      color: _selectedTime != null
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Central Park',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: _validateRequired,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Tell attendees about your event',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: _validateRequired,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You\'ll be able to invite friends after creating the event',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Create Event',
                onPressed: _handleCreateEvent,
                isLoading: _isLoading,
                icon: Icons.check,
              ),
              const SizedBox(height: 12),

              CustomButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
