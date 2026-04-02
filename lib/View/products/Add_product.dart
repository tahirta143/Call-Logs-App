// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:infinity/compoents/AppTextfield.dart';
// import 'package:provider/provider.dart';
//
// import '../../Provider/product/product_provider.dart';
//
// class AddProductScreen extends StatefulWidget {
//   const AddProductScreen({super.key});
//
//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }
//
// class _AddProductScreenState extends State<AddProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   bool _isEnable = true;
//   File? _imageFile;
//
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _pickImage() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         _imageFile = File(picked.path);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ProductProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(child: const Text('Add Product',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 22,
//               letterSpacing: 1.2,
//             )),
//         ),
//         centerTitle: true,
//         elevation: 6,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: _imageFile == null
//                       ? Container(
//                     height: 150,
//                     width: 150,
//                     color: Colors.grey[200],
//                     child: const Icon(Icons.camera_alt, size: 50),
//                   )
//                       : Image.file(_imageFile!, height: 150, width: 150, fit: BoxFit.cover),
//                 ),
//                 const SizedBox(height: 16),
//                 AppTextField(controller: _nameController, label: 'Product Name',
//                   validator: (value) => value!.isEmpty ? 'Enter name' : null,
//                 ),
//                 const SizedBox(height: 10),
//                 AppTextField(controller:_priceController, label:'Price',
//                   keyboardType: TextInputType.number,
//                   validator: (value) => value!.isEmpty ? 'Enter price' : null,),
//                 // TextFormField(
//                 //   controller: _priceController,
//                 //   decoration: const InputDecoration(labelText: 'Price'),
//                 //   keyboardType: TextInputType.number,
//                 //   validator: (value) => value!.isEmpty ? 'Enter price' : null,
//                 // ),
//                 const SizedBox(height: 10),
//                 SwitchListTile(
//                   title: const Text('Is Enabled?'),
//                   value: _isEnable,
//                   onChanged: (val) => setState(() => _isEnable = val),
//                 ),
//                 const SizedBox(height: 20),
//                 provider.isLoading
//                     ? const CircularProgressIndicator()
//                     : ElevatedButton.icon(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate() && _imageFile != null) {
//                       provider.addProduct(
//                         name: _nameController.text.trim(),
//                         price: _priceController.text.trim(),
//                         isEnable: _isEnable,
//                         imageFile: _imageFile!,
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Please fill all fields & pick an image')),
//                       );
//                     }
//                   },
//                   icon: const Icon(Icons.add),
//                   label: const Text('Add Product'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../Provider/product/product_provider.dart';
import '../../compoents/AppTextfield.dart';
import '../../compoents/responsive_helper.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isEnable = true;
  File? _imageFile;
  bool _isUploading = false;
  String? _uploadError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _uploadError = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _uploadError = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to take photo: ${e.toString()}';
      });
    }
  }

  void _clearImage() {
    setState(() {
      _imageFile = null;
    });
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _nameController.clear();
      _priceController.clear();
      _imageFile = null;
      _isEnable = true;
      _uploadError = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        setState(() {
          _uploadError = 'Please select an image';
        });
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadError = null;
      });

      try {
        final success = await Provider.of<ProductProvider>(context, listen: false).addProduct(
          name: _nameController.text.trim(),
          price: _priceController.text.trim(),
          isEnable: _isEnable,
          imageFile: _imageFile!,
        );

        setState(() {
          _isUploading = false;
        });

        if (mounted) {
          // Show success dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              title: const Text(
                'Product Added',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: const Text(
                'Your product has been successfully added to the catalog.',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close screen
                  },
                  child: const Text('View Products'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    _clearForm(); // Clear form for next product
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Another'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isUploading = false;
          _uploadError = 'Failed to add product: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: context.sh(0.1),
            elevation: 0,
            backgroundColor: theme.appBarTheme.backgroundColor,
            surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: _clearForm,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Clear Form',
              ),
            ],
            title: Text(
              'Add New Product',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Upload Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.photo_library_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Product Image',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: theme.cardColor,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Text(
                                          'Choose Image Source',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.photo_library_rounded,
                                          color: theme.colorScheme.primary,
                                        ),
                                        title: const Text('Gallery'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage();
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.camera_alt_rounded,
                                          color: theme.colorScheme.primary,
                                        ),
                                        title: const Text('Camera'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _takePhoto();
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[900]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.grey[800]!
                                        : Colors.grey[300]!,
                                    width: 2,
                                    style: _imageFile == null
                                        ? BorderStyle.solid
                                        : BorderStyle.none,
                                  ),
                                ),
                                child: _imageFile == null
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_rounded,
                                      size: 48,
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tap to upload image',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'JPEG, PNG (Max 5MB)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                )
                                    : ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.5),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: IconButton(
                                          onPressed: _clearImage,
                                          icon: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_uploadError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _uploadError!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Form Fields
                        Column(
                          children: [
                            AppTextField(
                              controller: _nameController,
                              label: 'Product Name',
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter product name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _priceController,
                              label: 'Price',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter price';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Status Switch
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[900]
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isEnable
                                        ? Icons.check_circle_rounded
                                        : Icons.remove_circle_outline_rounded,
                                    color: _isEnable
                                        ? Colors.green
                                        : Colors.grey[500],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Product Status',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          _isEnable
                                              ? 'Active and visible'
                                              : 'Hidden from catalog',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _isEnable,
                                    onChanged: (value) =>
                                        setState(() => _isEnable = value),
                                    activeColor: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _submitForm,
                            icon: _isUploading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.add_rounded),
                            label: Text(
                              _isUploading
                                  ? 'Adding...'
                                  : 'Add Product',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Ensure all details are accurate before adding.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}