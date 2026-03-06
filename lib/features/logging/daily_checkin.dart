import 'package:flutter/material.dart';
import '../../core/theme.dart';

class DailyCheckin extends StatefulWidget {
  const DailyCheckin({Key? key}) : super(key: key);

  @override
  State<DailyCheckin> createState() => _DailyCheckinState();
}

class _DailyCheckinState extends State<DailyCheckin> {
  String _selectedMood = 'Calm';
  final Set<String> _selectedSymptoms = {'Bloating'};
  double _energyLevel = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daily Check-in', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_outlined, size: 20),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateStrip(),
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
                  style: TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold),
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
                onPressed: () => Navigator.pop(context),
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
    final days = ['MON\n12', 'TUE\n13', 'WED\n14', 'THU\n15', 'FRI\n16', 'SAT\n17'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((dayText) {
        bool isSelected = dayText.contains('15');
        return Column(
          children: [
            if (isSelected)
              Container(
                height: 60,
                width: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayText.split('\n')[0],
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dayText.split('\n')[1],
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Text(
                    dayText.split('\n')[0],
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayText.split('\n')[1],
                    style: TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMoodRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMoodItem('Happy', '😊', false),
        _buildMoodItem('Calm', '😌', true),
        _buildMoodItem('Tired', '😴', false),
        _buildMoodItem('Sad', '😔', false),
      ],
    );
  }

  Widget _buildMoodItem(String label, String emoji, bool isSelected) {
    return Container(
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
        bool isSelected = _selectedSymptoms.contains(sym['label']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSymptoms.remove(sym['label']);
              } else {
                _selectedSymptoms.add(sym['label'] as String);
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
                  sym['label'] as String,
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
        Row(
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
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'How was your day? Any specific\npatterns...',
          hintStyle: TextStyle(color: AppTheme.textMuted, height: 1.5),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
