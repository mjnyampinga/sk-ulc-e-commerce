import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/product_provider.dart';
import 'package:e_commerce/core/services/auth_provider.dart';
import 'package:e_commerce/core/utils/constants.dart';
import 'package:e_commerce/data/models/product.dart';
import 'package:e_commerce/core/services/firebase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/core/services/category_service.dart';
import 'package:e_commerce/data/models/category.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _quantityController = TextEditingController();

  final List<XFile> _imageFiles = [];
  final List<String> _networkImageUrls = [];

  String? _selectedCategoryId;
  bool _hasDiscount = false;
  bool _isLoading = false;
  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final p = widget.product!;
      _nameController.text = p.name;
      _subtitleController.text = p.subtitle;
      _descriptionController.text = p.description;
      _priceController.text = p.price.toString();
      _originalPriceController.text = p.originalPrice?.toString() ?? '';
      _quantityController.text = p.quantity?.toString() ?? '';
      _selectedCategoryId = p.category;
      _hasDiscount = p.hasDiscount;
      _networkImageUrls.addAll(p.imageUrls);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    setState(() {
      _imageFiles.addAll(images);
    });
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _networkImageUrls.length) {
        _networkImageUrls.removeAt(index);
      } else {
        _imageFiles.removeAt(index - _networkImageUrls.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return const Center(
              child: Text('Please login as a supplier'),
            );
          }

          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImagePicker(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Product Name',
                          hint: 'Enter product name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter product name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _subtitleController,
                          label: 'Product Subtitle',
                          hint: 'Enter product subtitle',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter product subtitle';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'Category',
                          value: _selectedCategoryId,
                          items: [],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _priceController,
                          label: 'Price (RWF)',
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Has Discount'),
                                value: _hasDiscount,
                                onChanged: (value) {
                                  setState(() {
                                    _hasDiscount = value ?? false;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          ],
                        ),
                        if (_hasDiscount) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _originalPriceController,
                            label: 'Original Price (RWF)',
                            hint: '0.00',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (_hasDiscount &&
                                  (value == null || value.isEmpty)) {
                                return 'Please enter original price';
                              }
                              if (value != null &&
                                  value.isNotEmpty &&
                                  double.tryParse(value) == null) {
                                return 'Please enter a valid price';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _quantityController,
                          label: 'Quantity in Stock',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid quantity';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Enter product description',
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    isEditMode
                                        ? 'Update Product'
                                        : 'Add Product',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Category> items,
    required void Function(String?) onChanged,
  }) {
    return StreamBuilder<List<Category>>(
      stream: CategoryService.streamCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];
        final validCategoryNames = categories.map((cat) => cat.name).toList();
        String? dropdownValue = value;
        if (dropdownValue != null &&
            !validCategoryNames.contains(dropdownValue)) {
          dropdownValue = null;
        }
        return DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(labelText: label),
          items: categories
              .map((cat) => DropdownMenuItem(
                    value: cat.name,
                    child: Text(cat.name),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null || v.isEmpty ? 'Select a category' : null,
        );
      },
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _networkImageUrls.length + _imageFiles.length + 1,
          itemBuilder: (context, index) {
            if (index == _networkImageUrls.length + _imageFiles.length) {
              return GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                      SizedBox(height: 4),
                      Text('Add Image',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }

            Widget imageWidget;
            if (index < _networkImageUrls.length) {
              imageWidget = CachedNetworkImage(
                imageUrl: _networkImageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              );
            } else {
              final fileIndex = index - _networkImageUrls.length;
              imageWidget = Image.file(File(_imageFiles[fileIndex].path),
                  fit: BoxFit.cover);
            }

            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: imageWidget,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.close, size: 16, color: Colors.red),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_imageFiles.isEmpty && _networkImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one product image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      List<String> imageUrls = List.from(_networkImageUrls);

      for (var imageFile in _imageFiles) {
        // final Uint8List imageBytes = await imageFile.readAsBytes();
        // final imageName =
        //     'product_${DateTime.now().millisecondsSinceEpoch}_${_imageFiles.indexOf(imageFile)}.jpg';
        // final imageUrl = await FirebaseService.uploadImage(
        //     'product_images/$imageName', imageBytes);
        // print('imageUrl: $imageUrl');
        // if (imageUrl != null) {
        //   imageUrls.add(imageUrl);
        // }
        imageUrls.add('assets/images/product.png');
      }

      if (imageUrls.isEmpty) {
        throw 'Image upload failed.';
      }

      if (isEditMode) {
        // Update product
        final updated = await productProvider.updateProduct(
          widget.product!.id,
          {
            'name': _nameController.text.trim(),
            'subtitle': _subtitleController.text.trim(),
            'price': double.parse(_priceController.text),
            'originalPrice':
                _hasDiscount && _originalPriceController.text.isNotEmpty
                    ? double.parse(_originalPriceController.text)
                    : null,
            'hasDiscount': _hasDiscount,
            'description': _descriptionController.text.trim(),
            'quantity': int.parse(_quantityController.text),
            'category': _selectedCategoryId,
            'imageUrls': imageUrls,
          },
        );
        if (updated) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to update product: ${productProvider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Add product
        final product = Product(
          id: '', // Will be set by Firebase
          name: _nameController.text.trim(),
          subtitle: _subtitleController.text.trim(),
          price: double.parse(_priceController.text),
          originalPrice:
              _hasDiscount && _originalPriceController.text.isNotEmpty
                  ? double.parse(_originalPriceController.text)
                  : null,
          hasDiscount: _hasDiscount,
          description: _descriptionController.text.trim(),
          quantity: int.parse(_quantityController.text),
          category: _selectedCategoryId,
          imageUrls: imageUrls,
        );

        final success = await productProvider.addProduct(
          product,
          authProvider.firebaseUser!.uid,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to add product: ${productProvider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
