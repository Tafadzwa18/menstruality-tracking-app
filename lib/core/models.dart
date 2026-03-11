import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sync_service.dart';
import 'notification_service.dart';

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
  final NotificationService _notificationService = NotificationService();

  Future<void> init() async {
    await _syncService.init();
    await _notificationService.init();
    
    // Initial check - set state silently
    final session = _supabase.auth.currentSession;
    _updateAuthState(session, notify: false);
    
    // Listen for changes (Login, Logout, Token Refresh)
    _supabase.auth.onAuthStateChange.listen((data) {
      _updateAuthState(data.session);
    });
    
    if (_isLoggedIn) {
      // Sync offline data in background
      _syncService.syncPendingData().catchError((e) {
        debugPrint('Sync failed: $e');
      });
    }

    _isInitialized = true;
    _loadSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? true;
    _cycleLength = prefs.getInt('cycleLength') ?? 28;
    _periodLength = prefs.getInt('periodLength') ?? 5;
    
    if (_notificationsEnabled) {
      _scheduleAllReminders();
    }
    notifyListeners();
  }

  void _updateAuthState(Session? session, {bool notify = true}) {
    _isLoggedIn = session != null;
    if (_isLoggedIn) {
      _userEmail = session?.user.email ?? '';
      _userName = session?.user.userMetadata?['full_name'] ?? 'User';
    } else {
      _userEmail = '';
      _userName = 'User';
    }
    
    if (notify) notifyListeners();
  }

  Future<void> register(String name, String email, String password, String phone) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'phone_number': phone},
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

  Future<void> deleteAccount() async {
    // Note: In a production app, this would involve calling a Supabase Edge Function 
    // to delete the user record from the auth.users table.
    // For now, we will sign out and clear local data.
    await logout();
    await _syncService.clearLocalData();
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
    if (_notificationsEnabled) _scheduleAllReminders();
    notifyListeners();
  }

  void updatePeriodLength(int length) async {
    _periodLength = length;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('periodLength', length);
    if (_notificationsEnabled) _scheduleAllReminders();
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
  bool _notificationsEnabled = false;
  bool _darkModeEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;

  Future<void> toggleNotifications(bool value) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        _notificationsEnabled = false;
      } else {
        _notificationsEnabled = true;
        await _scheduleAllReminders();
      }
    } else {
      _notificationsEnabled = false;
      await _notificationService.cancelAllNotifications();
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> _scheduleAllReminders() async {
    if (!_notificationsEnabled) return;
    
    await _notificationService.cancelAllNotifications();
    await _notificationService.scheduleDailyLogReminder();
    
    // Calculate predicted date for period reminder (2 days before)
    // For now, we use a simple prediction based on average cycle
    final lastLogDate = logs.isNotEmpty ? logs.first.date : DateTime.now();
    final predictedDate = lastLogDate.add(Duration(days: _cycleLength));
    await _notificationService.schedulePeriodReminder(predictedDate);
  }

  void toggleDarkMode(bool value) async {
    _darkModeEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    notifyListeners();
  }

  // Insight Helpers
  List<double> get energyChartData {
    final now = DateTime.now();
    return List.generate(28, (i) {
      final date = now.subtract(Duration(days: 27 - i));
      final log = getLogForDate(date);
      return log?.energyLevel.toDouble() ?? 0.0;
    });
  }

  List<double> get moodChartData {
    final now = DateTime.now();
    return List.generate(28, (i) {
      final date = now.subtract(Duration(days: 27 - i));
      final log = getLogForDate(date);
      if (log == null) return 0.0;
      
      // Map mood emojis/labels to 1-10 scale
      switch (log.mood) {
        case 'Happy': case 'Energetic': case 'Productive': return 9.0;
        case 'Calm': return 7.0;
        case 'Tired': case 'Sensitive': return 4.0;
        case 'Sad': case 'Anxious': return 2.0;
        default: return 5.0;
      }
    });
  }

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
