import 'dart:io';
import 'package:flutter/material.dart';
import 'package:infinity/compoents/AppButton.dart';
import 'package:infinity/compoents/AppTextfield.dart';
import 'package:provider/provider.dart';
import '../../Provider/staff/StaffProvider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StaffCreateScreen extends StatefulWidget {
  const StaffCreateScreen({super.key});

  @override
  State<StaffCreateScreen> createState() => _StaffCreateScreenState();
}

class _StaffCreateScreenState extends State<StaffCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final deptController = TextEditingController();
  final desigController = TextEditingController();
  final addressController = TextEditingController();
  final numberController = TextEditingController();
  final passwordController = TextEditingController();
  final roleController = TextEditingController();

  String? _selectedRole = 'staff'; // Default role

  final List<String> _roles = [
    'staff',
    'admin',
    'manager',
    'supervisor'
  ];

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    deptController.dispose();
    desigController.dispose();
    addressController.dispose();
    numberController.dispose();
    passwordController.dispose();
    roleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final provider = Provider.of<StaffProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
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
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.photo_library_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(context);
              await provider.pickImage();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.camera_alt_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Take a Photo'),
            onTap: () async {
              Navigator.pop(context);
              // You'll need to add camera functionality to your provider
              // await provider.pickImage(fromCamera: true);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Future<void> _submitForm(BuildContext context) async {
  //   if (_formKey.currentState!.validate()) {
  //     final provider = Provider.of<StaffProvider>(context, listen: false);
  //
  //     if (provider.selectedImage == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Please select a profile picture'),
  //           backgroundColor: Colors.orange,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //       return;
  //     }
  //
  //     try {
  //       final success = await provider.uploadStaff(
  //         username: usernameController.text.trim(),
  //         email: emailController.text.trim(),
  //         department: deptController.text.trim(),
  //         designation: desigController.text.trim(),
  //         address: addressController.text.trim(),
  //         number: numberController.text.trim(),
  //         password: passwordController.text,
  //         role: _selectedRole ?? 'staff',
  //       );
  //
  //       // if (success) {
  //       //   _showSuccessDialog(context);
  //       // }
  //     } catch (e) {
  //       // Error is handled in provider and shown via snackbar
  //     }
  //   }
  // }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<StaffProvider>(context, listen: false);

      if (provider.selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a profile picture'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      try {
        final success = await provider.uploadStaff(
          username: usernameController.text.trim(),
          email: emailController.text.trim(),
          department: deptController.text.trim(),
          designation: desigController.text.trim(),
          address: addressController.text.trim(),
          number: numberController.text.trim(),
          password: passwordController.text,
          role: _selectedRole ?? 'staff',
        );

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Staff added successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Show success dialog
          _showSuccessDialog(context);
        } else {
          // Show error message from provider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.message.isNotEmpty
                  ? provider.message
                  : 'Failed to add staff'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
          'Staff Added Successfully!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'The new staff member has been added to your team.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Back to Staff List'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _clearForm(); // Clear form for next entry
            },
            child: const Text('Add Another'),
          ),
        ],
      ),
    );
  }

  // void _clearForm() {
  //   _formKey.currentState?.reset();
  //   setState(() {
  //     usernameController.clear();
  //     emailController.clear();
  //     deptController.clear();
  //     desigController.clear();
  //     addressController.clear();
  //     numberController.clear();
  //     passwordController.clear();
  //     _selectedRole = 'staff';
  //   });
  //   Provider.of<StaffProvider>(context, listen: false);//.clearImage();
  // }
  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      usernameController.clear();
      emailController.clear();
      deptController.clear();
      desigController.clear();
      addressController.clear();
      numberController.clear();
      passwordController.clear();
      _selectedRole = 'staff';
    });
    Provider.of<StaffProvider>(context, listen: false).clearImage();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form cleared'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final provider = Provider.of<StaffProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            elevation: 0,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: _clearForm,
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Clear Form',
              ),
            ],
            //flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              //titlePadding: const EdgeInsets.only(bottom: 16),
              title: Text(
                'Add New Staff',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              // background: Container(
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //       colors: [
              //         theme.colorScheme.primary.withOpacity(0.1),
              //         Colors.transparent,
              //       ],
              //     ),
              //   ),
              // ),
            ),
        //  ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    Center(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                          ),
                        ),
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _pickImage(context),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: provider.selectedImage != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      provider.selectedImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.error_outline_rounded,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                      : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 40,
                                        color: theme.colorScheme.primary.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to add profile picture',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              if (provider.selectedImage != null) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _pickImage(context),
                                  icon: Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  label: Text(
                                    'Change Photo',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Personal Information Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                        ),
                      ),
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AppTextField(
                              controller: usernameController,
                              label: 'Full Name',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: emailController,
                              label: 'Email Address',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email address';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: numberController,
                              label: 'Phone Number',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: addressController,
                              label: 'Address',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter address';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Professional Information Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                        ),
                      ),
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Professional Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AppTextField(
                              controller: deptController,
                              label: 'Department',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter department';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: desigController,
                              label: 'Designation',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter designation';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Role Selection
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Role',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedRole,
                                      isExpanded: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.grey[800],
                                        fontSize: 14,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedRole = newValue;
                                        });
                                      },
                                      items: _roles.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value.toUpperCase()),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: passwordController,
                              label: 'Password',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    provider.isLoading
                        ? Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Adding Staff Member...',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                        : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _submitForm(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Add Staff',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}







class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isCircular;

  const SafeNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    // If no URL or empty URL, show error widget
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    // Check if URL is valid
    if (!_isValidUrl(imageUrl!)) {
      return _buildErrorWidget();
    }

    // Use CachedNetworkImage for better performance and caching
    return Container(
      width: width,
      height: height,
      decoration: isCircular
          ? BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      )
          : null,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
        placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) =>
        errorWidget ?? _buildErrorWidget(),
        imageBuilder: isCircular
            ? (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        )
            : null,
      ),
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      return uri != null && uri.hasScheme;
    } catch (e) {
      return false;
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.person,
          size: width != null ? width! * 0.4 : 24,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ?? _buildPlaceholder();
  }
}