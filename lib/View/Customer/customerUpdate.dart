// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../Provider/customer/customer_provider.dart';
// import '../../Provider/product/product_provider.dart';
// import '../../Provider/staff/StaffProvider.dart';
//
// class UpdateCustomerScreen extends StatefulWidget {
//   final String? customerId; // 👈 null = Add mode, not null = Edit mode
//   const UpdateCustomerScreen({super.key, this.customerId});
//
//   @override
//   State<UpdateCustomerScreen> createState() => _AddCustomerScreenState();
// }
//
// class _AddCustomerScreenState extends State<UpdateCustomerScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() async {
//       final staff = Provider.of<StaffProvider>(context, listen: false);
//       final product = Provider.of<ProductProvider>(context, listen: false);
//       final companyProvider = Provider.of<CompanyProvider>(context, listen: false);
//
//       await staff.fetchStaff();
//       await product.fetchProducts();
//
//       // 👇 If editing existing customer, load its data
//       if (widget.customerId != null) {
//         await companyProvider.fetchCustomerById(widget.customerId!);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<CompanyProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(child: const Text('Update Customer',
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
//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 🖼 Company Logo
//             GestureDetector(
//               onTap: provider.pickImage,
//               child: provider.companyLogo != null
//                   ? Image.file(provider.companyLogo!,
//                   height: 100, width: 100, fit: BoxFit.cover)
//                   : Container(
//                 height: 100,
//                 width: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(Icons.add_a_photo, size: 40),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             _buildTextField(provider.businessTypeController, 'Business Type'),
//             _buildTextField(provider.companyNameController, 'Company Name'),
//             _buildTextField(provider.addressController, 'Address'),
//             _buildTextField(provider.cityController, 'City'),
//             _buildTextField(provider.emailController, 'Email'),
//             _buildTextField(provider.phoneController, 'Phone Number'),
//
//             const Divider(height: 40),
//             const Text('Person Details',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             const SizedBox(height: 10),
//
//             // 👨‍💼 Dynamic person fields
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: provider.personsList.length,
//               itemBuilder: (context, index) {
//                 final person = provider.personsList[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Person ${index + 1}',
//                                 style: const TextStyle(fontWeight: FontWeight.bold)),
//                             if (provider.personsList.length > 1)
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () => provider.removePerson(index),
//                               ),
//                           ],
//                         ),
//                         _buildTextField(person['fullName']!, 'Full Name'),
//                         _buildTextField(person['designation']!, 'Designation'),
//                         _buildTextField(person['department']!, 'Department'),
//                         _buildTextField(person['phoneNumber']!, 'Phone Number'),
//                         _buildTextField(person['email']!, 'Email'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//             OutlinedButton.icon(
//               onPressed: provider.addPerson,
//               icon: const Icon(Icons.add),
//               label: const Text('Add Another Person'),
//             ),
//
//             const Divider(height: 40),
//
//             // Assigned Staff Dropdown
//             Consumer<StaffProvider>(
//               builder: (context, staffProvider, _) {
//                 if (staffProvider.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final staffList = staffProvider.staffs;
//                 return DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(
//                     labelText: 'Assigned Staff',
//                     border: OutlineInputBorder(),
//                   ),
//                   value: provider.selectedStaffName,
//                   items: staffList.map((staff) {
//                     return DropdownMenuItem<String>(
//                       value: staff.sId,
//                       child: Text(staff.username ?? 'Unnamed Staff'),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     provider.selectedStaffName = value;
//                     provider.notifyListeners();
//                   },
//                 );
//               },
//             ),
//
//             const SizedBox(height: 10),
//
//             // Assigned Product Dropdown
//             Consumer<ProductProvider>(
//               builder: (context, productProvider, _) {
//                 if (productProvider.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final productList = productProvider.products;
//                 return DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(
//                     labelText: 'Assigned Product',
//                     border: OutlineInputBorder(),
//                   ),
//                   value: provider.selectedProductId,
//                   items: productList.map((product) {
//                     return DropdownMenuItem<String>(
//                       value: product.sId,
//                       child: Text(product.name ?? 'Unnamed Product'),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     provider.selectedProductId = value;
//                     provider.notifyListeners();
//                   },
//                 );
//               },
//             ),
//
//             const SizedBox(height: 20),
//
//             ElevatedButton.icon(
//               onPressed: () async {
//                 if (widget.customerId == null) {
//                   await provider.createCustomer();
//                 } else {
//                   await provider.UpdateCustomer(widget.customerId!);
//                 }
//
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(provider.message),
//                     backgroundColor: Colors.blue,
//                   ));
//                 }
//               },
//               icon: const Icon(Icons.save),
//               label: Text(widget.customerId == null
//                   ? 'Create Customer'
//                   : 'Update Customer'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/customer/customer_provider.dart';
import '../../Provider/product/product_provider.dart';
import '../../Provider/staff/StaffProvider.dart';
import '../../compoents/responsive_helper.dart';

class UpdateCustomerScreen extends StatefulWidget {
  final String? customerId; // 👈 null = Add mode, not null = Edit mode
  const UpdateCustomerScreen({super.key, this.customerId});

  @override
  State<UpdateCustomerScreen> createState() => _UpdateCustomerScreenState();
}

class _UpdateCustomerScreenState extends State<UpdateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _logoError;

  @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() async {
  //     final staff = Provider.of<StaffProvider>(context, listen: false);
  //     final product = Provider.of<ProductProvider>(context, listen: false);
  //     final companyProvider = Provider.of<CompanyProvider>(context, listen: false);
  //
  //     await staff.fetchStaff();
  //     await product.fetchProducts();
  //
  //     // 👇 If editing existing customer, load its data
  //     if (widget.customerId != null) {
  //       await companyProvider.fetchCustomerById(widget.customerId!);
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final staff = Provider.of<StaffProvider>(context, listen: false);
      final product = Provider.of<ProductProvider>(context, listen: false);
      final companyProvider = Provider.of<CompanyProvider>(context, listen: false);

      // Clear previous data when editing
      if (widget.customerId != null) {
        companyProvider.clearForm();
      }

      await staff.fetchStaff();
      await product.fetchProducts();

      // Load customer data if editing
      if (widget.customerId != null) {
        await companyProvider.fetchCustomerById(widget.customerId!);
      }
    });
  }

  void _showImagePicker(BuildContext context) {
    final provider = Provider.of<CompanyProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Change Company Logo',
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
              if (mounted) {
                setState(() => _logoError = null);
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.camera_alt_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Take a Photo'),
            onTap: () {
              Navigator.pop(context);
              // Add camera functionality if needed
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;

    }

    final provider = Provider.of<CompanyProvider>(context, listen: false);

    // Validate logo for new customers
    if (widget.customerId == null && provider.companyLogo == null) {
      setState(() => _logoError = 'Please select a company logo');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.customerId == null) {
        // Create new customer
        final success = await provider.createCustomer();
        if (mounted) {
          _showSuccessDialog(context, 'Customer Added Successfully!');
        }
      } else {
        // Update existing customer
        final success = await provider.UpdateCustomer(widget.customerId!);
        if (mounted) {
          _showSuccessDialog(context, 'Customer Updated Successfully!');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String title) {
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
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          widget.customerId == null
              ? 'The new customer has been added to your system.'
              : 'The customer details have been updated successfully.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Back to List'),
          ),
          if (widget.customerId == null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Provider.of<CompanyProvider>(context, listen: false).clearForm();
                _formKey.currentState?.reset();
                setState(() => _logoError = null);
              },
              child: const Text('Add Another'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final provider = Provider.of<CompanyProvider>(context);
    final staffProvider = Provider.of<StaffProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    // Get the current company data if editing
    dynamic currentCompany;
    if (widget.customerId != null && provider.companies.isNotEmpty) {
      try {
        currentCompany = provider.companies.firstWhere(
              (company) => company.id == widget.customerId,
        );
      } catch (e) {
        // Company not found, handle appropriately
        currentCompany = null;
      }
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: context.sh(0.1),
            elevation: 0,
            backgroundColor: theme.appBarTheme.backgroundColor,
            surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.customerId == null ? 'Add New Customer' : 'Update Customer',
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
              child: provider.isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.customerId == null
                          ? 'Loading...'
                          : 'Loading customer details...',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Logo Section
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                        ),
                      ),
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _showImagePicker(context),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: (_logoError != null)
                                          ? Colors.red.withOpacity(0.5)
                                          : theme.colorScheme.primary.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: provider.companyLogo != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      provider.companyLogo!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline_rounded,
                                                size: 32,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Invalid Image',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                      : (widget.customerId != null &&
                                      currentCompany != null &&
                                      currentCompany.companyLogo?.url != null &&
                                      provider.companyLogo == null)
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      currentCompany.companyLogo!.url!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.business_rounded,
                                              size: 40,
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.5),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Current Logo',
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  )
                                      : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_rounded,
                                        size: 40,
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.customerId == null
                                            ? 'Add Logo'
                                            : 'Change Logo',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_logoError != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _logoError!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                widget.customerId == null
                                    ? 'Tap to add company logo'
                                    : 'Tap to change company logo',
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
                    const SizedBox(height: 24),

                    // Company Information Card
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
                              'Company Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              provider.companyNameController,
                              'Company Name *',
                              Icons.business_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              provider.businessTypeController,
                              'Business Type *',
                              Icons.category_rounded,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    provider.cityController,
                                    'City *',
                                    Icons.location_city_rounded,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    provider.phoneController,
                                    'Phone *',
                                    Icons.phone_rounded,
                                    TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              provider.addressController,
                              'Address *',
                              Icons.location_on_rounded,
                              TextInputType.text,
                              2,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              provider.emailController,
                              'Email *',
                              Icons.email_rounded,
                              TextInputType.emailAddress,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Persons Card
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Contact Persons',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: provider.addPerson,
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: const Text('Add Person'),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.personsList.length,
                              itemBuilder: (context, index) {
                                final person = provider.personsList[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Person ${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          if (provider.personsList.length > 1)
                                            IconButton(
                                              onPressed: () => provider.removePerson(index),
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildPersonTextField(
                                        person['fullName']!,
                                        'Full Name *',
                                        Icons.person_outline_rounded,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildPersonTextField(
                                              person['designation']!,
                                              'Designation *',
                                              Icons.work_outline_rounded,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildPersonTextField(
                                              person['department']!,
                                              'Department *',
                                              Icons.business_center_outlined,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildPersonTextField(
                                              person['phoneNumber']!,
                                              'Phone *',
                                              Icons.phone_outlined,
                                              TextInputType.phone,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildPersonTextField(
                                              person['email']!,
                                              'Email *',
                                              Icons.email_outlined,
                                              TextInputType.emailAddress,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Assignments Card
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
                              'Assignments',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),

                           // Assigned Staff
                            _buildDropdownField(
                              context,
                              staffProvider,
                              'Assigned Staff *',
                              provider.selectedStaffName,
                                  (value) {
                                provider.selectedStaffName = value;
                                provider.notifyListeners();
                              },
                                  (staff) => DropdownMenuItem<String>(
                                value: staff.sId,
                                child: Text(staff.username ?? 'Unnamed Staff'),
                              ),
                              staffProvider.staffs,
                            ),
                           // In UpdateCustomerScreen's _buildDropdownField call for staff:

                            const SizedBox(height: 16),

                            // Assigned Product
                            // _buildDropdownField(
                            //   context,
                            //   productProvider,
                            //   'Assigned Product *',
                            //   provider.selectedProductId,
                            //       (value) {
                            //     provider.selectedProductId = value;
                            //     provider.notifyListeners();
                            //   },
                            //       (product) => DropdownMenuItem<String>(
                            //     value: product.sId,
                            //     child: Text(product.name ?? 'Unnamed Product'),
                            //   ),
                            //   productProvider.products,
                            // ),
                            // In UpdateCustomerScreen's _buildDropdownField call for products:
                            _buildDropdownField(
                              context,
                              productProvider,
                              'Assigned Product *',
                              provider.selectedProductId,
                                  (value) {
                                provider.selectedProductId = value;
                                provider.notifyListeners();
                              },
                                  (product) => DropdownMenuItem<String>(
                                value: product.sId,
                                child: Text(product.name ?? 'Unnamed Product'),
                              ),
                              productProvider.products,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    _isSubmitting
                        ? Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.customerId == null
                                ? 'Creating Customer...'
                                : 'Updating Customer...',
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
                            child: Text(
                              widget.customerId == null
                                  ? 'Create Customer'
                                  : 'Update Customer',
                              style: const TextStyle(
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, [
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      ]) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (label.contains('Email') && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPersonTextField(
      TextEditingController controller,
      String label,
      IconData icon, [
        TextInputType keyboardType = TextInputType.text,
      ]) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        color: isDarkMode ? Colors.white : Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isDarkMode ? Colors.white70 : Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 18,
        ),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (label.contains('Email') && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Invalid email';
        }
        return null;
      },
    );
  }

  // Widget _buildDropdownField<T>(
  //     BuildContext context,
  //     dynamic provider,
  //     String label,
  //     String? value,
  //     Function(String?) onChanged,
  //     DropdownMenuItem<String> Function(T) itemBuilder,
  //     List<T> items,
  //     ) {
  //   final theme = Theme.of(context);
  //   final isDarkMode = theme.brightness == Brightness.dark;
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //           color: isDarkMode ? Colors.white : Colors.grey[700],
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       provider.isLoading
  //           ? Container(
  //         padding: const EdgeInsets.symmetric(vertical: 16),
  //         child: Center(
  //           child: CircularProgressIndicator(
  //             strokeWidth: 2,
  //             color: theme.colorScheme.primary,
  //           ),
  //         ),
  //       )
  //           : items.isEmpty
  //           ? Container(
  //         padding: const EdgeInsets.symmetric(vertical: 12),
  //         decoration: BoxDecoration(
  //           color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Center(
  //           child: Text(
  //             'No items available',
  //             style: TextStyle(
  //               color: Colors.grey[500],
  //             ),
  //           ),
  //         ),
  //       )
  //           : Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 12),
  //         decoration: BoxDecoration(
  //           color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(
  //             color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
  //           ),
  //         ),
  //         child: DropdownButtonFormField<String>(
  //           value: value,
  //           isExpanded: true,
  //           decoration: const InputDecoration(
  //             border: InputBorder.none,
  //           ),
  //           hint: Text(
  //             'Select ${label.replaceAll(' *', '')}',
  //             style: TextStyle(
  //               color: Colors.grey[500],
  //             ),
  //           ),
  //           icon: Icon(
  //             Icons.arrow_drop_down_rounded,
  //             color: theme.colorScheme.primary,
  //           ),
  //           style: TextStyle(
  //             color: isDarkMode ? Colors.white : Colors.grey[800],
  //             fontSize: 14,
  //           ),
  //           validator: (value) => value == null || value.isEmpty
  //               ? 'Please select ${label.replaceAll(' *', '').toLowerCase()}'
  //               : null,
  //           onChanged: onChanged,
  //           items: items.map(itemBuilder).toList(),
  //         ),
  //       ),
  //     ],
  //   );
  // }


  Widget _buildDropdownField<T>(
      BuildContext context,
      dynamic provider,
      String label,
      String? value,
      Function(String?) onChanged,
      DropdownMenuItem<String> Function(T) itemBuilder,
      List<T> items,
      ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Create unique items list
    List<DropdownMenuItem<String>> uniqueItems = [];
    Set<String> seenValues = {};

    for (final item in items) {
      final dropdownItem = itemBuilder(item);
      if (dropdownItem.value != null &&
          !seenValues.contains(dropdownItem.value)) {
        seenValues.add(dropdownItem.value!);
        uniqueItems.add(dropdownItem);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        provider.isLoading
            ? Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        )
            : uniqueItems.isEmpty
            ? Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'No items available',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ),
        )
            : Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            hint: Text(
              'Select ${label.replaceAll(' *', '')}',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: theme.colorScheme.primary,
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.grey[800],
              fontSize: 14,
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Please select ${label.replaceAll(' *', '').toLowerCase()}'
                : null,
            onChanged: onChanged,
            items: uniqueItems,
          ),
        ),
      ],
    );
  }

// Helper method to ensure unique dropdown items
  List<DropdownMenuItem<String>> _getUniqueDropdownItems<T>(
      List<T> items,
      DropdownMenuItem<String> Function(T) itemBuilder,
      ) {
    final uniqueItems = <DropdownMenuItem<String>>[];
    final seenValues = <String>{};

    for (final item in items) {
      final dropdownItem = itemBuilder(item);
      if (!seenValues.contains(dropdownItem.value)) {
        seenValues.add(dropdownItem.value ?? '');
        uniqueItems.add(dropdownItem);
      }
    }

    return uniqueItems;
  }
}