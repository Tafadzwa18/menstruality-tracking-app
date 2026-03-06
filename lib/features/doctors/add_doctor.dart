import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/models.dart';

class AddDoctorForm extends StatefulWidget {
  const AddDoctorForm({Key? key}) : super(key: key);

  @override
  State<AddDoctorForm> createState() => _AddDoctorFormState();
}

class _AddDoctorFormState extends State<AddDoctorForm> {
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveDoctor() {
    if (_nameController.text.isNotEmpty) {
      final newDoc = Doctor(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        specialty: _specialtyController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      context.read<AppState>().addDoctor(newDoc);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Doctor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField('Doctor Name', 'Dr. Jane Smith', _nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField('Specialty', 'Gynecologist', _specialtyController, Icons.medical_services_outlined),
            const SizedBox(height: 20),
            _buildTextField('Email Address', 'doctor@clinic.com', _emailController, Icons.email_outlined),
            const SizedBox(height: 20),
            _buildTextField('Phone Number', '(555) 123-4567', _phoneController, Icons.phone_outlined),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDoctor,
                child: const Text('Save Contact'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textMuted),
            prefixIcon: Icon(icon, color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
