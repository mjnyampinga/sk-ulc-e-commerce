import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/category_service.dart';
import '../../../data/models/category.dart';
import '../../../core/services/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/services/firebase_service.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  String? _editingCategoryId;
  String? _selectedImageAsset;
  XFile? _pickedImageFile;

  // List of available asset icons
  final List<String> _assetIcons = [
    'assets/icons/cosmetics.png',
    'assets/icons/fragrance.png',
    'assets/icons/face_care.png',
    'assets/icons/tools.png',
    'assets/icons/hair_care.png',
    'assets/icons/eco.png',
    'assets/icons/nutri.png',
    'assets/icons/house.png',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _showCategoryModal({Category? category}) {
    if (category != null) {
      _editingCategoryId = category.id;
      _nameController.text = category.name;
      _iconController.text = category.icon ?? '';
      _selectedImageAsset =
          _assetIcons.contains(category.icon) ? category.icon : null;
      _pickedImageFile = null;
    } else {
      _editingCategoryId = null;
      _nameController.clear();
      _iconController.clear();
      _selectedImageAsset = null;
      _pickedImageFile = null;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String? selectedAsset = _selectedImageAsset;
        XFile? pickedFile = _pickedImageFile;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category == null ? 'Add Category' : 'Edit Category',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Category Name'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  Text('Select Icon',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _assetIcons.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        if (i == _assetIcons.length) {
                          // Upload button
                          return GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (file != null) {
                                setModalState(() {
                                  pickedFile = file;
                                  selectedAsset = null;
                                });
                              }
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Icon(Icons.upload,
                                  size: 32, color: Colors.grey),
                            ),
                          );
                        }
                        final asset = _assetIcons[i];
                        final isSelected =
                            selectedAsset == asset && pickedFile == null;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedAsset = asset;
                              pickedFile = null;
                            });
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(asset, width: 40, height: 40),
                          ),
                        );
                      },
                    ),
                  ),
                  if (pickedFile != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(pickedFile!.path),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              pickedFile = null;
                            });
                          },
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = _nameController.text.trim();
                        String? icon;
                        if (pickedFile != null) {
                          icon = await FirebaseService.uploadImage(
                            'category_icons/${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}',
                            await pickedFile!.readAsBytes(),
                          );
                        } else if (selectedAsset != null) {
                          icon = selectedAsset;
                        } else if (_iconController.text.isNotEmpty) {
                          icon = _iconController.text.trim();
                        }
                        final userId =
                            Provider.of<AuthProvider>(context, listen: false)
                                    .firebaseUser
                                    ?.uid ??
                                '';
                        final now = DateTime.now();
                        if (_editingCategoryId == null) {
                          await CategoryService.addCategory(Category(
                            id: '',
                            name: name,
                            icon: icon,
                            createdBy: userId,
                            createdAt: Timestamp.fromDate(now),
                          ));
                        } else {
                          await CategoryService.updateCategory(
                              _editingCategoryId!, {
                            'name': name,
                            'icon': icon,
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: Text(category == null
                          ? 'Add Category'
                          : 'Update Category'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _delete(String id) async {
    await CategoryService.deleteCategory(id);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                    onPressed: () => _showCategoryModal(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: CategoryService.streamCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \\${snapshot.error}'));
                }
                final categories = snapshot.data ?? [];
                if (categories.isEmpty) {
                  return const Center(child: Text('No categories yet.'));
                }
                return ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    return ListTile(
                      leading: cat.icon != null && cat.icon!.isNotEmpty
                          ? (cat.icon!.startsWith('assets/')
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey[300]!, width: 1),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      cat.icon!,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.category),
                                    ),
                                  ),
                                )
                              : Image.network(
                                  cat.icon!,
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.category),
                                ))
                          : const Icon(Icons.category),
                      title: Text(cat.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showCategoryModal(category: cat),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _delete(cat.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
