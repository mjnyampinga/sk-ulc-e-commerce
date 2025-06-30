import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/banner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ManageBannersScreen extends StatelessWidget {
  const ManageBannersScreen({Key? key}) : super(key: key);

  Future<List<AppBanner>> _getSupplierBanners(String supplierId) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final box = await Hive.openBox<AppBanner>('banners');
    if (connectivityResult != ConnectivityResult.none) {
      // Online: fetch from Firestore and update Hive
      final snapshot = await FirebaseFirestore.instance
          .collection('banners')
          .where('supplierId', isEqualTo: supplierId)
          .get();
      final banners = snapshot.docs
          .map((doc) => AppBanner.fromMap(doc.data(), doc.id))
          .toList();
      await box.clear();
      await box.addAll(banners);
      return banners;
    } else {
      // Offline: load from Hive
      return box.values.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplierId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Banners'),
      ),
      body: FutureBuilder<List<AppBanner>>(
        future: _getSupplierBanners(supplierId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final banners = snapshot.data ?? [];
          if (banners.isEmpty) {
            return const Center(child: Text('No banners yet.'));
          }
          return ListView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return ListTile(
                leading: CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    width: 60,
                    height: 60,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                title: Text(banner.title),
                subtitle: Text(banner.subtitle),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // TODO: Delete logic
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBannerScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddBannerScreen extends StatefulWidget {
  const AddBannerScreen({Key? key}) : super(key: key);

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _ctaController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select an image.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final supplierId = FirebaseAuth.instance.currentUser?.uid;
      if (supplierId == null) throw 'Not authenticated.';
      // Upload image
      final bytes = await _imageFile!.readAsBytes();
      final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref('banners/$fileName');
      final uploadTask = await ref.putData(bytes);
      final imageUrl = await uploadTask.ref.getDownloadURL();
      // Save to Firestore
      await FirebaseFirestore.instance.collection('banners').add({
        'imageUrl': imageUrl,
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'cta': _ctaController.text.trim(),
        'supplierId': supplierId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Banner added!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Banner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to select banner image',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(labelText: 'Subtitle'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter subtitle' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ctaController,
                decoration:
                    const InputDecoration(labelText: 'Call to Action (CTA)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter CTA' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Banner'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
