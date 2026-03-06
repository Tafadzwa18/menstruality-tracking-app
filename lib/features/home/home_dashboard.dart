import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildFlowIntensity(),
              const SizedBox(height: 24),
              _buildCurrentMood(),
              const SizedBox(height: 24),
              _buildPhysicalSymptoms(),
              const SizedBox(height: 24),
              _buildEnergyAndFocus(),
              const SizedBox(height: 24),
              _buildInsightCard(),
              const SizedBox(height: 48), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.menu, color: Colors.white, size: 28),
            Column(
              children: [
                Text(
                  'Day 14',
                  style: TextStyle(
                    color: AppTheme.primaryPink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'OVULATION PHASE',
                  style: TextStyle(
                    color: AppTheme.phaseOvulatory,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 26),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowIntensity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Flow Intensity',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Optional',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFlowOption('None', false),
              _buildFlowOption('Light', false),
              _buildFlowOption('Medium', true),
              _buildFlowOption('Heavy', false),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFlowOption(String label, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPink : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentMood() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_emotions, color: AppTheme.phaseOvulatory),
              const SizedBox(width: 8),
              const Text(
                'Current Mood',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildChip('Energetic', false),
              _buildChip('Calm', false),
              _buildChip('Happy', true),
              _buildChip('Anxious', false),
              _buildChip('Productive', false),
              _buildChip('Sensitive', false),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryPink.withOpacity(0.15) : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppTheme.primaryPink : AppTheme.borderSubtle,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryPink : AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildPhysicalSymptoms() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services_outlined, color: AppTheme.primaryPink),
              const SizedBox(width: 8),
              const Text(
                'Physical Symptoms',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSymptomIcon(Icons.waves, 'CRAMPS', false),
              _buildSymptomIcon(Icons.bolt, 'HEADACHE', true),
              _buildSymptomIcon(Icons.air, 'BLOATING', false),
              _buildSymptomIcon(Icons.spa, 'SKIN', false),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSymptomIcon(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryPink.withOpacity(0.15) : AppTheme.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: AppTheme.primaryPink, width: 2) : null,
          ),
          child: Icon(
            icon,
            color: isSelected ? AppTheme.primaryPink : AppTheme.textMuted,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryPink : AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyAndFocus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_charging_full, color: AppTheme.primaryPink),
              const SizedBox(width: 8),
              const Text(
                'Energy & Focus',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LOW ENERGY', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('HIGH ENERGY', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [1, 2, 3, 4, 5].map((level) {
              bool isSelected = level == 4;
              return Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.primaryPink.withOpacity(0.15) : AppTheme.background.withOpacity(0.5),
                  border: isSelected ? Border.all(color: AppTheme.primaryPink, width: 2) : null,
                ),
                child: Center(
                  child: Text(
                    level.toString(),
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryPink : AppTheme.textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DISTRACTED', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('LASER FOCUS', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.phaseOvulatory,
              inactiveTrackColor: AppTheme.borderSubtle,
              thumbColor: Colors.white,
              trackHeight: 6,
            ),
            child: Slider(
              value: 0.7,
              onChanged: (val) {},
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
            child: Container(
              width: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrange],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Icon(Icons.wb_sunny, color: Colors.white, size: 60),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OVULATION INSIGHT',
                    style: TextStyle(color: AppTheme.primaryPink, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your energy peaks today. It's a great time for high-intensity workouts and creative projects.",
                    style: TextStyle(color: AppTheme.textLight, fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
