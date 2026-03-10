import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sync_service.dart';

part 'models.g.dart';

enum CyclePhase { menstrual, follicular, ovulatory, luteal }

@HiveType(typeId: 0)
class DailyLog {
  @HiveField(0)
  final DateTime date;
  @HiveField(1)
  final String flowIntensity; // Light, Medium, Heavy, None
  @HiveField(2)
  final String mood; // Emoji string
  @HiveField(3)
  final List<String> symptoms;
  @HiveField(4)
  final int energyLevel; // 1 to 5
  @HiveField(5)
  final String notes;
  @HiveField(6)
  final bool isSynced;

  DailyLog({
    required this.date,
    required this.flowIntensity,
    required this.mood,
    required this.symptoms,
    required this.energyLevel,
    this.notes = '',
    this.isSynced = false,
  });

  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'date': date.toIso8601String().substring(0, 10), // YYYY-MM-DD
      'flow_intensity': flowIntensity,
      'mood': mood,
      'symptoms': symptoms,
      'energy_level': energyLevel,
      'notes': notes,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      date: DateTime.parse(map['date']),
      flowIntensity: map['flow_intensity'] ?? 'None',
      mood: map['mood'] ?? '',
      symptoms: List<String>.from(map['symptoms'] ?? []),
      energyLevel: map['energy_level'] ?? 3,
      notes: map['notes'] ?? '',
      isSynced: true,
    );
  }

  DailyLog copyWith({bool? isSynced}) {
    return DailyLog(
      date: date,
      flowIntensity: flowIntensity,
      mood: mood,
      symptoms: symptoms,
      energyLevel: energyLevel,
      notes: notes,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

@HiveType(typeId: 1)
class Doctor {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String specialty;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String phone;
  @HiveField(5)
  final bool isSynced;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.email,
    required this.phone,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'specialty': specialty,
      'email': email,
      'phone': phone,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      name: map['name'],
      specialty: map['specialty'],
      email: map['email'],
      phone: map['phone'],
      isSynced: true,
    );
  }

  Doctor copyWith({bool? isSynced}) {
    return Doctor(
      id: id,
      name: name,
      specialty: specialty,
      email: email,
      phone: phone,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

class AppState extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isLoggedIn = false;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;

  String _userName = 'User';
  String _userEmail = '';
  
  String get userName => _userName;
  String get userEmail => _userEmail;

  final _supabase = Supabase.instance.client;
  final _syncService = SyncService();

  Future<void> init() async {
    final session = _supabase.auth.currentSession;
    _isLoggedIn = session != null;
    
    if (_isLoggedIn) {
      _userEmail = session?.user.email ?? '';
      _userName = session?.user.userMetadata?['full_name'] ?? 'User';
      
      // Sync offline data
      try {
        await _syncService.syncPendingData();
      } catch (e) {
        debugPrint('Initial sync failed: $e');
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    _cycleLength = prefs.getInt('cycleLength') ?? 28;
    _periodLength = prefs.getInt('periodLength') ?? 5;
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    
    if (response.user != null) {
      _userName = name;
      _userEmail = email;
      _isLoggedIn = (_supabase.auth.currentSession != null);
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user != null) {
      _isLoggedIn = true;
      _userEmail = email;
      _userName = response.user!.userMetadata?['full_name'] ?? 'User';
      
      // Load user data from cloud
      await _syncService.fetchFromCloud();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }

  // Data Access using SyncService
  List<DailyLog> get logs => _syncService.getAllLogs();
  List<Doctor> get doctors => _syncService.getAllDoctors();

  // Cycle tracking
  int _cycleLength = 28;
  int _periodLength = 5;

  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;

  void updateCycleLength(int length) async {
    _cycleLength = length;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cycleLength', length);
    notifyListeners();
  }

  void updatePeriodLength(int length) async {
    _periodLength = length;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('periodLength', length);
    notifyListeners();
  }

  DateTime _cycleStartDate = DateTime.now().subtract(const Duration(days: 13)); 

  DateTime get cycleStartDate => _cycleStartDate;

  void setCycleStartDate(DateTime date) {
    _cycleStartDate = date;
    notifyListeners();
  }

  int get currentCycleDay {
    final now = DateTime.now();
    final difference = now.difference(_cycleStartDate).inDays;
    return (difference % _cycleLength) + 1;
  }

  CyclePhase get currentPhase {
    final day = currentCycleDay;
    if (day >= 1 && day <= _periodLength) return CyclePhase.menstrual;
    
    final ovulationDay = _cycleLength - 14; 
    
    if (day > _periodLength && day < ovulationDay - 1) return CyclePhase.follicular;
    if (day >= ovulationDay - 1 && day <= ovulationDay + 1) return CyclePhase.ovulatory;
    return CyclePhase.luteal;
  }

  // Helpers
  DailyLog? getLogForDate(DateTime date) {
    try {
      return logs.firstWhere((log) => 
        log.date.year == date.year && 
        log.date.month == date.month && 
        log.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }

  DailyLog? get todayLog => getLogForDate(DateTime.now());

  Future<void> addLog(DailyLog log) async {
    await _syncService.saveLog(log);
    notifyListeners();
  }

  // Settings
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _darkModeEnabled = value;
    notifyListeners();
  }

  // Insight Helpers
  Map<String, int> get symptomCounts {
    final Map<String, int> counts = {};
    for (var log in logs) {
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
    // Note: Future feature to sync doctors specifically
    notifyListeners();
  }
}
