import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SymptomTrends extends StatelessWidget {
  const SymptomTrends({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Symptom Trends', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTab('Overview', false),
                  _buildTab('Symptoms', true),
                  _buildTab('Correlations', false),
                ],
              ),
              const Divider(height: 1, color: AppTheme.borderSubtle),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Logged Symptoms', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('LAST 30 DAYS', style: TextStyle(color: AppTheme.primaryPink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                )
              ],
            ),
            const SizedBox(height: 16),
            _buildSymptomItem('Bloating', Icons.water_drop, 8, false),
            const SizedBox(height: 16),
            _buildExpandedSymptomItem('Fatigue', Icons.battery_charging_full, 12),
            const SizedBox(height: 16),
            _buildSymptomItem('Mood Swings', Icons.emoji_emotions, 5, false),
            const SizedBox(height: 32),
            Row(
              children: [
                Icon(Icons.auto_graph, color: AppTheme.primaryPink),
                const SizedBox(width: 8),
                const Text('Correlations', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildCorrelationCard(),
            const SizedBox(height: 80), // Fab space
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? AppTheme.primaryPink : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryPink : AppTheme.textMuted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSymptomItem(String title, IconData icon, int count, bool isExpanded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryPink, size: 20),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Text('$count logs', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(width: 8),
              Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.textMuted),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildExpandedSymptomItem(String title, IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryPink.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.battery_0_bar, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Text('$count logs', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_up, color: AppTheme.textMuted),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Text('Frequency by cycle phase', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          // Bar Chart mock mapping
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPhaseCol('MEN', AppTheme.phaseMenstrual, 0.4),
              _buildPhaseCol('FOL', AppTheme.phaseFollicular, 0.2),
              _buildPhaseCol('OVU', AppTheme.phaseOvulatory, 0.3),
              _buildPhaseCol('LUT', AppTheme.phaseLuteal, 0.8),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppTheme.primaryPink, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                children: [
                  const TextSpan(text: "You've logged fatigue 12 times this cycle, mostly in the "),
                  TextSpan(text: "Luteal phase.", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPink)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhaseCol(String phase, Color color, double val) {
    return Column(
      children: [
        Text(phase, style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
      ],
    ); // Placeholder since we can't do exact bar heights simply without more nesting, will just leave labels
  }

  Widget _buildCorrelationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withOpacity(0.05),
        border: Border.all(color: AppTheme.primaryPink.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: AppTheme.primaryPink, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Energy vs. Cycle', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.4),
                    children: [
                      const TextSpan(text: "You report "),
                      const TextSpan(text: "lower energy 3 days ", style: TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold)),
                      const TextSpan(text: "before your period begins consistently."),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
