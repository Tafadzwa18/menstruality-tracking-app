import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../core/report_service.dart';
import 'share_email.dart';

class ExportConfig extends StatefulWidget {
  const ExportConfig({Key? key}) : super(key: key);

  @override
  State<ExportConfig> createState() => _ExportConfigState();
}

class _ExportConfigState extends State<ExportConfig> {
  final Set<String> _selectedCategories = {'Cycle Dates', 'Symptom Trends'};
  String _selectedRange = 'Last 3 Cycles';
  bool _isGenerating = false;

  final _reportService = ReportService();

  Future<void> _generateReport() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one category')));
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final appState = context.read<AppState>();
      final file = await _reportService.generateHealthReport(
        userName: appState.userName,
        logs: appState.logs,
        cycleLength: appState.cycleLength,
        periodLength: appState.periodLength,
        categories: _selectedCategories,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Generated: ${file.path.split('/').last}'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShareEmailScreen()),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Export Health Report', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Date Range', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateTab('Last 3 Cycles'),
                    _buildDateTab('Last 6 Months'),
                    _buildDateTab('Custom'),
                  ],
                ),
                const Divider(color: AppTheme.primaryPinkLight, height: 1),
                const SizedBox(height: 32),
                Center(child: _buildReportPreview()),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Generating detailed summary of 84 days...',
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Data Categories to Include', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildCategoryRow('Cycle Dates', Icons.calendar_month),
                const SizedBox(height: 16),
                _buildCategoryRow('Symptom Trends', Icons.trending_up),
                const SizedBox(height: 16),
                _buildCategoryRow('Mood & Energy Logs', Icons.mood),
                const SizedBox(height: 16),
                _buildCategoryRow('Note History', Icons.notes),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateReport,
                    icon: _isGenerating 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.picture_as_pdf),
                    label: Text(_isGenerating ? 'Generating...' : 'Export as PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ShareEmailScreen()),
                      );
                    },
                    icon: const Icon(Icons.medical_services, color: AppTheme.primaryPink),
                    label: const Text('Share with Doctor', style: TextStyle(color: AppTheme.primaryPink)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Your report is encrypted and only accessible to you. We never\nshare your health data with third parties.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          if (_isGenerating)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink)),
            ),
        ],
      ),
    );
  }

  Widget _buildDateTab(String label) {
    bool isSelected = _selectedRange == label;
    return InkWell(
      onTap: () => setState(() => _selectedRange = label),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
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
            color: isSelected ? AppTheme.primaryPink : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    return Container(
      width: 180,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 16, decoration: BoxDecoration(color: AppTheme.primaryPinkLight.withOpacity(0.3), borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primaryPinkLight.withOpacity(0.3), shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 80, height: 8, decoration: BoxDecoration(color: AppTheme.primaryPinkLight.withOpacity(0.3), borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 8),
                        Container(width: 60, height: 8, decoration: BoxDecoration(color: AppTheme.primaryPinkLight.withOpacity(0.3), borderRadius: BorderRadius.circular(4))),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Container(width: double.infinity, height: 8, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 8, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(width: 100, height: 8, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.1),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, color: AppTheme.primaryPinkLight),
                    const SizedBox(height: 4),
                    const Text('PREVIEW ONLY', style: TextStyle(color: AppTheme.primaryPink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String label, IconData icon) {
    bool isSelected = _selectedCategories.contains(label);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategories.remove(label);
          } else {
            _selectedCategories.add(label);
          }
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryPinkLight, size: 24),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSelected ? AppTheme.primaryPink : Colors.grey.shade300,
            size: 28,
          )
        ],
      ),
    );
  }
}
