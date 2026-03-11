import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import 'add_doctor.dart';

class DoctorList extends StatelessWidget {
  const DoctorList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final doctors = context.watch<AppState>().doctors;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Your Care Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: doctors.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPink.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryPink.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.health_and_safety_outlined, color: AppTheme.primaryPink, size: 56),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your Care Team is Empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add your doctors and healthcare providers to keep track of your care contacts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doc = doctors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildDoctorCard(doc),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Fab space
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddDoctorForm()),
            );
          },
          backgroundColor: AppTheme.primaryPink,
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text('Add Doctor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services, color: AppTheme.primaryPink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(doc.specialty, style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
