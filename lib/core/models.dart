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

  // Cycle tracking
  DateTime _cycleStartDate = DateTime.now().subtract(const Duration(days: 13)); // Default to day 14 for demo purposes

  DateTime get cycleStartDate => _cycleStartDate;

  void setCycleStartDate(DateTime date) {
    _cycleStartDate = date;
    notifyListeners();
  }

  int get currentCycleDay {
    final now = DateTime.now();
    final difference = now.difference(_cycleStartDate).inDays;
    // Assuming a standard 28 day cycle for simplicity
    return (difference % 28) + 1;
  }

  CyclePhase get currentPhase {
    final day = currentCycleDay;
    if (day >= 1 && day <= 5) return CyclePhase.menstrual;
    if (day >= 6 && day <= 13) return CyclePhase.follicular;
    if (day >= 14 && day <= 15) return CyclePhase.ovulatory;
    return CyclePhase.luteal;
  }

  // Helpers
  DailyLog? getLogForDate(DateTime date) {
    try {
      return _logs.firstWhere((log) => 
        log.date.year == date.year && 
        log.date.month == date.month && 
        log.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }

  DailyLog? get todayLog => getLogForDate(DateTime.now());

  void addLog(DailyLog log) {
    // Remove if updating same day
    _logs.removeWhere((l) => 
        l.date.year == log.date.year && 
        l.date.month == log.date.month && 
        l.date.day == log.date.day
    );
    _logs.add(log);
    _logs.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // Insight Helpers
  Map<String, int> get symptomCounts {
    final Map<String, int> counts = {};
    for (var log in _logs) {
      for (var sym in log.symptoms) {
        counts[sym] = (counts[sym] ?? 0) + 1;
      }
    }
    return counts;
  }
  
  List<MapEntry<String, int>> get topSymptoms {
    final entries = symptomCounts.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  void addDoctor(Doctor doc) {
    _doctors.add(doc);
    notifyListeners();
  }
}
