import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/theme.dart';
import '../core/models.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cycle Calendar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: Column(
        children: [
          _buildCalendar(appState),
          const SizedBox(height: 24),
          _buildLegend(),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildCalendar(AppState appState) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          weekendTextStyle: const TextStyle(color: AppTheme.textMuted),
          outsideTextStyle: const TextStyle(color: Colors.white24),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryPink.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryPink.withOpacity(0.5), width: 1),
          ),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.primaryPink,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink,
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          markerDecoration: const BoxDecoration(
            color: AppTheme.phaseOvulatory,
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
          headerPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            // Check if day is within predicted period or ovulation
            // For now, let's use a simple mock marker logic
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildLegendRow(AppTheme.primaryPink, 'Current Period'),
          const SizedBox(height: 12),
          _buildLegendRow(AppTheme.phaseOvulatory, 'Ovulation Day'),
          const SizedBox(height: 12),
          _buildLegendRow(AppTheme.phaseFollicular, 'Predicted Period'),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
      ],
    );
  }
}
