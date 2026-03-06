import 'package:flutter/foundation.dart';

enum CyclePhase { menstrual, follicular, ovulatory, luteal }

class DailyLog {
  final DateTime date;
  final String mood;
  final List<String> symptoms;
  final int energyLevel; // 1 to 5
  final String notes;
  final String? flowIntensity; // Optional

  DailyLog({
    required this.date,
    required this.mood,
    required this.symptoms,
    required this.energyLevel,
    required this.notes,
    this.flowIntensity,
  });
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String email;
  final String phone;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.email,
    required this.phone,
  });
}

class AppState extends ChangeNotifier {
  // Mock Data
  final List<DailyLog> _logs = [
    DailyLog(
      date: DateTime.now().subtract(const Duration(days: 0)),
      mood: 'Calm',
      symptoms: ['Cramps', 'Bloating'],
      energyLevel: 3,
      notes: 'Feeling okay today.',
      flowIntensity: 'Medium',
    ),
    DailyLog(
      date: DateTime.now().subtract(const Duration(days: 1)),
      mood: 'Tired',
      symptoms: ['Headache'],
      energyLevel: 2,
      notes: 'Had a long day.',
      flowIntensity: 'Heavy',
    ),
  ];
  
  final List<Doctor> _doctors = [
    Doctor(id: '1', name: 'Dr. Sarah Jenkins', specialty: 'Gynecologist', email: 'sarah@example.com', phone: '555-0100'),
    Doctor(id: '2', name: 'Dr. Emily Chen', specialty: 'Primary Care', email: 'emily@example.com', phone: '555-0200'),
  ];
  
  List<DailyLog> get logs => List.unmodifiable(_logs);
  List<Doctor> get doctors => List.unmodifiable(_doctors);

  // Cycle simulation
  int get currentCycleDay => 14;
  CyclePhase get currentPhase => CyclePhase.ovulatory;

  void addLog(DailyLog log) {
    _logs.add(log);
    notifyListeners();
  }

  void addDoctor(Doctor doc) {
    _doctors.add(doc);
    notifyListeners();
  }
}
