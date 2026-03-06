import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/models.dart';

class DailyCheckin extends StatefulWidget {
  const DailyCheckin({Key? key}) : super(key: key);

  @override
  State<DailyCheckin> createState() => _DailyCheckinState();
}

class _DailyCheckinState extends State<DailyCheckin> {
  String _selectedMood = 'Calm';
  Set<String> _selectedSymptoms = {};
  double _energyLevel = 3;
  String _flowIntensity = 'Medium';
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    
    // Pre-fill if log exists for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final log = context.read<AppState>().todayLog;
      if (log != null) {
        setState(() {
          _selectedMood = log.mood;
          _selectedSymptoms = Set.from(log.symptoms);
          _energyLevel = log.energyLevel.toDouble();
          _notesController.text = log.notes;
          _flowIntensity = log.flowIntensity;
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveLog() {
    final newLog = DailyLog(
      date: DateTime.now(),
      mood: _selectedMood,
      symptoms: _selectedSymptoms.toList(),
      energyLevel: _energyLevel.toInt(),
      notes: _notesController.text,
      flowIntensity: _flowIntensity,
    );
    context.read<AppState>().addLog(newLog);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log Saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppTheme.cardColor, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daily Check-in', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateStrip(),
            const SizedBox(height: 32),
            _buildSectionTitle('Flow Intensity'),
            const SizedBox(height: 16),
            _buildFlowSelection(),
            const SizedBox(height: 32),
            _buildSectionTitle('How are you feeling?'),
            const SizedBox(height: 16),
            _buildMoodRow(),
            const SizedBox(height: 32),
            _buildSectionTitle('Symptoms'),
            const SizedBox(height: 16),
            _buildSymptomGrid(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Energy Level'),
                Text(
                  _energyLevel > 3 ? 'High' : (_energyLevel < 3 ? 'Low' : 'Moderate'),
                  style: const TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 16),
            _buildEnergySlider(),
            const SizedBox(height: 32),
            _buildSectionTitle('Notes'),
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveLog,
                icon: const Icon(Icons.check_circle),
                label: const Text('Save Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateStrip() {
    final now = DateTime.now();
    final days = List.generate(6, (i) => now.subtract(Duration(days: 5 - i)));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((date) {
        bool isSelected = date.day == now.day;
        final weekDay = _getWeekdayAbbr(date.weekday);
        return Column(
          children: [
            if (isSelected)
              Container(
                height: 60,
                width: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(weekDay, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    Text('${date.day}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Text(weekDay, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${date.day}', style: const TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              )
          ],
        );
      }).toList(),
    );
  }

  String _getWeekdayAbbr(int weekday) {
    const abbrs = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return abbrs[weekday - 1];
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildFlowSelection() {
    return Row(
      children: ['None', 'Light', 'Medium', 'Heavy'].map((flow) {
        bool isSelected = _flowIntensity == flow;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _flowIntensity = flow),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryPink : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  flow,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMoodItem('Happy', '😊'),
          _buildMoodItem('Calm', '😌'),
          _buildMoodItem('Tired', '😴'),
          _buildMoodItem('Sad', '😔'),
          _buildMoodItem('Anxious', '😰'),
          _buildMoodItem('Productive', '🤓'),
          _buildMoodItem('Sensitive', '🥺'),
          _buildMoodItem('Energetic', '🤩'),
        ].map((w) => Padding(padding: const EdgeInsets.only(right: 12), child: w)).toList(),
      ),
    );
  }

  Widget _buildMoodItem(String label, String emoji) {
    bool isSelected = _selectedMood == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = label),
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppTheme.primaryPink, width: 2) : null,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryPink : AppTheme.textLight,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomGrid() {
    final symptoms = [
      {'icon': Icons.pregnant_woman, 'label': 'Cramps'},
      {'icon': Icons.waves, 'label': 'Bloating'},
      {'icon': Icons.sick, 'label': 'Headache'},
      {'icon': Icons.water_drop, 'label': 'Spotting'},
      {'icon': Icons.face, 'label': 'Acne'},
      {'icon': Icons.restaurant, 'label': 'Cravings'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: symptoms.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final sym = symptoms[index];
        final label = sym['label'] as String;
        bool isSelected = _selectedSymptoms.contains(label);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSymptoms.remove(label);
              } else {
                _selectedSymptoms.add(label);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: isSelected ? Border.all(color: AppTheme.primaryPink, width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  sym['icon'] as IconData,
                  color: isSelected ? AppTheme.primaryPink : AppTheme.primaryPink,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnergySlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryPink,
            inactiveTrackColor: AppTheme.cardColor,
            thumbColor: Colors.white,
            trackHeight: 6,
          ),
          child: Slider(
            value: _energyLevel,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (val) {
              setState(() {
                _energyLevel = val;
              });
            },
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Low', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            Text('High', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'How was your day? Any specific\npatterns...',
          hintStyle: TextStyle(color: AppTheme.textMuted, height: 1.5),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }
}
