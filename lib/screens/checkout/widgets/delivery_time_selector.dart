import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class DeliveryTimeSelector extends StatefulWidget {
  final DateTime? selectedDateTime;
  final Function(DateTime) onTimeSelected;

  const DeliveryTimeSelector({
    super.key,
    this.selectedDateTime,
    required this.onTimeSelected,
  });

  @override
  State<DeliveryTimeSelector> createState() => _DeliveryTimeSelectorState();
}

class _DeliveryTimeSelectorState extends State<DeliveryTimeSelector> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final defaultDateTime = _calculateDefaultDeliveryTime();
    _selectedDate = DateTime(defaultDateTime.year, defaultDateTime.month, defaultDateTime.day);
    _selectedTime = TimeOfDay.fromDateTime(defaultDateTime);
    
    // Gọi _updateDateTime để set giá trị mặc định vào formData
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDateTime();
    });
  }

  DateTime _calculateDefaultDeliveryTime() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    // If it's before 10 AM, set to 10:40 AM today
    if (currentTime.hour < 10 || (currentTime.hour == 10 && currentTime.minute < 40)) {
      return DateTime(now.year, now.month, now.day, 10, 40);
    }
    // If it's after 9 PM, set to 10:40 AM tomorrow
    else if (currentTime.hour >= 21) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 40);
    }
    // Otherwise, add 40 minutes to current time
    else {
      final deliveryTime = now.add(const Duration(minutes: 40));
      return deliveryTime;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final minDate = now;

    // Calculate maximum date (30 days from now)
    final maxDate = now.add(const Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      // Validate that the selected date/time is not in the past
      final selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (selectedDateTime.isBefore(now)) {
        // If selected time is in the past, adjust to minimum allowed time
        final adjustedDateTime = _calculateDefaultDeliveryTime();
        setState(() {
          _selectedDate = DateTime(adjustedDateTime.year, adjustedDateTime.month, adjustedDateTime.day);
          _selectedTime = TimeOfDay.fromDateTime(adjustedDateTime);
        });
      } else {
        setState(() {
          _selectedDate = picked;
        });
      }
      _updateDateTime();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();

    // Define allowed time range: 10:40 AM to 9:00 PM
    final minTime = const TimeOfDay(hour: 10, minute: 40);
    final maxTime = const TimeOfDay(hour: 21, minute: 0);

    // If selecting time for today, ensure it's not before current time + 40 minutes
    TimeOfDay actualMinTime = minTime;
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      final minAllowedTime = TimeOfDay.fromDateTime(now.add(const Duration(minutes: 40)));
      actualMinTime = _getLaterTime(minTime, minAllowedTime);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      // Validate time is within allowed range
      if (_isTimeInRange(picked, actualMinTime, maxTime)) {
        setState(() {
          _selectedTime = picked;
        });
        _updateDateTime();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time between 10:40 AM and 9:00 PM'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  TimeOfDay _getLaterTime(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1 > minutes2 ? time1 : time2;
  }

  bool _isTimeInRange(TimeOfDay time, TimeOfDay minTime, TimeOfDay maxTime) {
    final timeMinutes = time.hour * 60 + time.minute;
    final minMinutes = minTime.hour * 60 + minTime.minute;
    final maxMinutes = maxTime.hour * 60 + maxTime.minute;
    return timeMinutes >= minMinutes && timeMinutes <= maxMinutes;
  }

  void _updateDateTime() {
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    print('DeliveryTimeSelector: _updateDateTime called with: $dateTime');
    widget.onTimeSelected(dateTime);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Date Selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(_selectedTime),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Add some bottom padding to prevent screen jumping when time picker opens
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}