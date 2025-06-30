import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/auth_provider.dart' as app_auth;
import 'package:e_commerce/core/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce/data/models/user.dart' as app_user;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../onboarding/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModifyAccountScreen extends StatefulWidget {
  const ModifyAccountScreen({Key? key}) : super(key: key);

  @override
  _ModifyAccountScreenState createState() => _ModifyAccountScreenState();
}

class _ModifyAccountScreenState extends State<ModifyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _postalCodeController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    final user =
        Provider.of<app_auth.AuthProvider>(context, listen: false).userProfile;
    _nameController = TextEditingController(text: user?.username ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _address1Controller = TextEditingController(text: user?.addressLine1 ?? '');
    _address2Controller = TextEditingController(text: user?.addressLine2 ?? '');
    _postalCodeController = TextEditingController(text: user?.postalCode ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
    _dateOfBirth = user?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider =
          Provider.of<app_auth.AuthProvider>(context, listen: false);
      final updates = {
        'username': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'addressLine1': _address1Controller.text.trim(),
        'addressLine2': _address2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'country': _countryController.text.trim(),
        'dateOfBirth': _dateOfBirth,
      };

      try {
        await authProvider.updateProfile(updates);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update profile: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    String password = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-authenticate'),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Enter your password'),
          onChanged: (value) => password = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, password),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modify your account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<app_auth.AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userProfile;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  const Text('YOUR PROFILE',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDateField(context),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _phoneController,
                      label: 'Telephone',
                      icon: Icons.phone_outlined),
                  const SizedBox(height: 12),
                  _buildTextField(
                      initialValue: user.email,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      readOnly: true),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _address1Controller,
                      label: 'Address',
                      icon: Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _address2Controller,
                      label: 'Address 2',
                      icon: Icons.add_location_alt_outlined),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _postalCodeController,
                      label: 'Postal code',
                      icon: Icons.local_post_office_outlined),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _countryController,
                      label: 'Country',
                      icon: Icons.public),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(app_user.User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: const Icon(Icons.person,
                color: AppConstants.primaryColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(user.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                if (user.createdAt != null)
                  Text(
                    'Joined ${DateFormat('dd/MM/yyyy').format(user.createdAt!)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                      'Are you sure you want to delete your account? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  final authProvider = Provider.of<app_auth.AuthProvider>(
                      context,
                      listen: false);
                  final firebaseUser = authProvider.firebaseUser;
                  if (firebaseUser != null) {
                    final email = firebaseUser.email;
                    final password = await _showPasswordDialog(context);
                    if (password == null) return;
                    final cred = EmailAuthProvider.credential(
                        email: email!, password: password);
                    await firebaseUser.reauthenticateWithCredential(cred);
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(firebaseUser.uid)
                        .delete();
                    await firebaseUser.delete();
                  }
                  await authProvider.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const OnboardingScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to delete account: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          _dateOfBirth != null
              ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
              : 'Date of birth',
          style: TextStyle(
              color:
                  _dateOfBirth != null ? Colors.black : Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
