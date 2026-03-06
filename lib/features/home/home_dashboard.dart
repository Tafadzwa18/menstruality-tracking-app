import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/models.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  String _getPhaseName(CyclePhase phase) {
    switch(phase) {
      case CyclePhase.menstrual: return 'MENSTRUAL PHASE';
      case CyclePhase.follicular: return 'FOLLICULAR PHASE';
      case CyclePhase.ovulatory: return 'OVULATION PHASE';
      case CyclePhase.luteal: return 'LUTEAL PHASE';
    }
  }

  Color _getPhaseColor(CyclePhase phase) {
    switch(phase) {
      case CyclePhase.menstrual: return AppTheme.phaseMenstrual;
      case CyclePhase.follicular: return AppTheme.phaseFollicular;
      case CyclePhase.ovulatory: return AppTheme.phaseOvulatory;
      case CyclePhase.luteal: return AppTheme.phaseLuteal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final todayLog = appState.todayLog;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(appState),
              const SizedBox(height: 32),
              _buildFlowIntensity(todayLog),
              const SizedBox(height: 24),
              _buildCurrentMood(todayLog, appState.currentPhase),
              const SizedBox(height: 24),
              _buildPhysicalSymptoms(todayLog),
              const SizedBox(height: 24),
              _buildEnergyAndFocus(context, todayLog),
              const SizedBox(height: 24),
              _buildInsightCard(appState.currentPhase),
              const SizedBox(height: 48), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.menu, color: Colors.white, size: 28),
            Column(
              children: [
                Text(
                  'Day ${appState.currentCycleDay}',
                  style: const TextStyle(
                    color: AppTheme.primaryPink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _getPhaseName(appState.currentPhase),
                  style: TextStyle(
                    color: _getPhaseColor(appState.currentPhase),
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

  Widget _buildFlowIntensity(DailyLog? log) {
    final flow = log?.flowIntensity;
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
              _buildFlowOption('None', flow == 'None'),
              _buildFlowOption('Light', flow == 'Light'),
              _buildFlowOption('Medium', flow == 'Medium'),
              _buildFlowOption('Heavy', flow == 'Heavy'),
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

  Widget _buildCurrentMood(DailyLog? log, CyclePhase phase) {
    final mood = log?.mood;
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
              Icon(Icons.emoji_emotions, color: _getPhaseColor(phase)),
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
              _buildChip('Energetic', mood == 'Energetic'),
              _buildChip('Calm', mood == 'Calm'),
              _buildChip('Happy', mood == 'Happy'),
              _buildChip('Anxious', mood == 'Anxious'),
              _buildChip('Productive', mood == 'Productive'),
              _buildChip('Sensitive', mood == 'Sensitive'),
              _buildChip('Tired', mood == 'Tired'),
              _buildChip('Sad', mood == 'Sad'),
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
        color: isSelected ? AppTheme.primaryPink.withValues(alpha: 0.15) : Colors.transparent,
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

  Widget _buildPhysicalSymptoms(DailyLog? log) {
    final symps = log?.symptoms ?? [];
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
              const Icon(Icons.medical_services_outlined, color: AppTheme.primaryPink),
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
              _buildSymptomIcon(Icons.waves, 'CRAMPS', symps.contains('Cramps')),
              _buildSymptomIcon(Icons.bolt, 'HEADACHE', symps.contains('Headache')),
              _buildSymptomIcon(Icons.air, 'BLOATING', symps.contains('Bloating')),
              _buildSymptomIcon(Icons.spa, 'ACNE', symps.contains('Acne')),
            ],
          ),
          if (symps.isEmpty)
             Padding(
                 padding: const EdgeInsets.only(top: 16),
                 child: Text("No symptoms logged today", style: TextStyle(color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
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
            color: isSelected ? AppTheme.primaryPink.withValues(alpha: 0.15) : AppTheme.background.withValues(alpha: 0.5),
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

  Widget _buildEnergyAndFocus(BuildContext context, DailyLog? log) {
    final energy = log?.energyLevel ?? 0;
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
              const Icon(Icons.battery_charging_full, color: AppTheme.primaryPink),
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
              bool isSelected = level == energy;
              return Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.primaryPink.withValues(alpha: 0.15) : AppTheme.background.withValues(alpha: 0.5),
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
        ],
      ),
    );
  }

  Widget _buildInsightCard(CyclePhase phase) {
    String title = "DAILY INSIGHT";
    String description = "Listen to your body today.";
    Color baseColor = AppTheme.primaryPink;

    switch(phase) {
      case CyclePhase.menstrual:
        title = "MENSTRUAL INSIGHT";
        description = "Your body is working hard. Focus on rest, gentle stretches, and staying hydrated.";
        baseColor = AppTheme.phaseMenstrual;
        break;
      case CyclePhase.follicular:
        title = "FOLLICULAR INSIGHT";
        description = "Estrogen is rising! You might feel more creative and ready to tackle new challenges.";
        baseColor = AppTheme.phaseFollicular;
        break;
      case CyclePhase.ovulatory:
        title = "OVULATION INSIGHT";
        description = "Your energy peaks today. It's a great time for high-intensity workouts and creative projects.";
        baseColor = AppTheme.phaseOvulatory;
        break;
      case CyclePhase.luteal:
        title = "LUTEAL INSIGHT";
        description = "Energy might dip as your period approaches. Prioritize self-care and light exercise.";
        baseColor = AppTheme.phaseLuteal;
        break;
    }

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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [baseColor, baseColor.withValues(alpha: 0.4)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 60),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: baseColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
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
