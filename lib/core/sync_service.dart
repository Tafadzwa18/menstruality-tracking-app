import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  late Box<DailyLog> _logBox;
  late Box<Doctor> _doctorBox;
  final _supabase = Supabase.instance.client;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(DailyLogAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DoctorAdapter());

    _logBox = await Hive.openBox<DailyLog>('daily_logs');
    _doctorBox = await Hive.openBox<Doctor>('doctors');

    // Start listening for connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        syncPendingData();
      }
    });
  }

  // --- Daily Logs Sync ---

  Future<void> saveLog(DailyLog log) async {
    // Save locally first
    final key = log.date.toIso8601String().substring(0, 10);
    await _logBox.put(key, log.copyWith(isSynced: false));

    // Try to sync if user is logged in
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase
            .from('daily_logs')
            .upsert(log.toMap(user.id));
        
        // Mark as synced if successful
        await _logBox.put(key, log.copyWith(isSynced: true));
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  Future<void> syncPendingData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Sync logs
    for (var key in _logBox.keys) {
      final log = _logBox.get(key);
      if (log != null && !log.isSynced) {
        try {
          await _supabase.from('daily_logs').upsert(log.toMap(user.id));
          await _logBox.put(key, log.copyWith(isSynced: true));
        } catch (e) {
          print('Sync failed for $key: $e');
        }
      }
    }

    // Sync doctors
    for (var key in _doctorBox.keys) {
      final doc = _doctorBox.get(key);
      if (doc != null && !doc.isSynced) {
        try {
          await _supabase.from('doctors').upsert(doc.toMap(user.id));
          await _doctorBox.put(key, doc.copyWith(isSynced: true));
        } catch (e) {
          print('Sync failed for doctor $key: $e');
        }
      }
    }

    // Optionally fetch latest from cloud
    await fetchFromCloud();
  }

  Future<void> fetchFromCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Fetch logs
      final List<dynamic> logData = await _supabase
          .from('daily_logs')
          .select()
          .eq('user_id', user.id);
      
      for (var data in logData) {
        final log = DailyLog.fromMap(data);
        final key = log.date.toIso8601String().substring(0, 10);
        await _logBox.put(key, log);
      }

      // Fetch doctors
      final List<dynamic> docData = await _supabase
          .from('doctors')
          .select()
          .eq('user_id', user.id);
      
      for (var data in docData) {
        final doc = Doctor.fromMap(data);
        await _doctorBox.put(doc.id, doc);
      }
    } catch (e) {
      print('Fetch failed: $e');
    }
  }

  List<DailyLog> getAllLogs() => _logBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  List<Doctor> getAllDoctors() => _doctorBox.values.toList();
}
