
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../Provider/customer/customer_provider.dart';
// import '../../Provider/product/product_provider.dart';
// import '../../Provider/staff/StaffProvider.dart';
//
// class AddCustomerScreen extends StatefulWidget {
//   const AddCustomerScreen({super.key});
//
//   @override
//   State<AddCustomerScreen> createState() => _AddCustomerScreenState();
// }
//
// class _AddCustomerScreenState extends State<AddCustomerScreen> {
//   @override
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       Provider.of<StaffProvider>(context, listen: false).fetchStaff();
//       Provider.of<ProductProvider>(context, listen: false).fetchProducts();
//     });
//   }
//
//   Widget build(BuildContext context) {
//
//
//     final staffProvider = Provider.of<StaffProvider>(context, listen: false);
//
//     final provider = Provider.of<CompanyProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(child: const Text('Add Customer',
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
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Company Logo
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
//             const Text(
//               'Person Details',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 10),
//
//             // Dynamic Person Fields
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
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold)),
//                             if (provider.personsList.length > 1)
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () =>
//                                     provider.removePerson(index),
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
//             // Add another person button
//             OutlinedButton.icon(
//               onPressed: provider.addPerson,
//               icon: const Icon(Icons.add),
//               label: const Text('Add Another Person'),
//             ),
//
//             const Divider(height: 40),
//             Consumer<StaffProvider>(
//               builder: (context, staffProvider, _) {
//                 final staffList = staffProvider.staffs;
//
//                 if (staffProvider.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (staffList.isEmpty) {
//                   return const Text('No staff available');
//                 }
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       labelText: 'Assigned Staff',
//                       border: OutlineInputBorder(),
//                     ),
//                     // ✅ Ensure the selected value exists in list
//                     value: staffList.any((s) => s.username == provider.selectedStaffName)
//                         ? provider.selectedStaffName
//                         : null,
//                     items: staffList.map((staff) {
//                       return DropdownMenuItem<String>(
//                         value: staff.username, // ✅ store name as the value
//                         child: Text(staff.username ?? 'Unnamed Staff'),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       provider.selectedStaffName = value; // ✅ store name in provider
//                       provider.notifyListeners();
//                     },
//                   ),
//                 );
//               },
//             ),
//
//
//             //_buildTextField(provider.assignedProductsController, 'Assigned Product ID'),
//             Consumer<ProductProvider>(
//               builder: (context, productProvider, _) {
//                 final productList = productProvider.products;
//
//                 if (productProvider.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (productList.isEmpty) {
//                   return const Text('No products available');
//                 }
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       labelText: 'Assigned Product',
//                       border: OutlineInputBorder(),
//                     ),
//                     value: provider.selectedProductId,
//                     items: productList.map((product) {
//                       return DropdownMenuItem<String>(
//                         value: product.sId, // ✅ pass product ID
//                         child: Text(product.name ?? 'Unnamed Product'), // ✅ show product name
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       provider.selectedProductId = value;
//                       provider.notifyListeners();
//                     },
//                   ),
//                 );
//               },
//             ),
//
//
//             const SizedBox(height: 20),
//
//             provider.isLoading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton.icon(
//               onPressed: () async {
//                 await provider.createCustomer();
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(provider.message),
//                     backgroundColor: Colors.blue,
//                   ));
//                 }
//                 provider.clearForm();
//               },
//               icon: const Icon(Icons.save),
//               label: const Text('Create Customer'),
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

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _logoError;

  @override
  void initState() {
    super.initState();
    // 🔹 Clear form data when entering screen
    Future.microtask(() {
      final companyProvider = Provider.of<CompanyProvider>(context, listen: false);
      final staffProvider = Provider.of<StaffProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      // 🔹 IMPORTANT: Clear all form data first
      companyProvider.clearForm();

      // 🔹 Then fetch fresh data
      staffProvider.fetchStaff();
      productProvider.fetchProducts();
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
              'Select Company Logo',
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

    // Validate logo
    if (provider.companyLogo == null) {
      setState(() => _logoError = 'Please select a company logo');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await provider.createCustomer();

      if (mounted) {
        _showSuccessDialog(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
          'Customer Added Successfully!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'The new customer has been added to your system.',
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

    return Scaffold(
      //backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // SliverAppBar(
          //   pinned: true,
          //   expandedHeight: 120,
          //   elevation: 0,
          //   //backgroundColor: theme.colorScheme.primary,
          //   flexibleSpace: FlexibleSpaceBar(
          //     centerTitle: true,
          //     titlePadding: const EdgeInsets.only(bottom: 16),
          //     title: Text(
          //       'Add New Customer',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 22,
          //         shadows: [
          //           Shadow(
          //             color: Colors.black.withOpacity(0.3),
          //             blurRadius: 4,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //     ),
          //     // background: Container(
          //     //   decoration: BoxDecoration(
          //     //     gradient: LinearGradient(
          //     //       begin: Alignment.topCenter,
          //     //       end: Alignment.bottomCenter,
          //     //       // colors: [
          //     //       //   theme.colorScheme.primary,
          //     //       //   theme.colorScheme.primary.withOpacity(0.8),
          //     //       // ],
          //     //     ),
          //     //   ),
          //     // ),
          //   ),
          //   leading: IconButton(
          //     icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          //     onPressed: () => Navigator.pop(context),
          //   ),
          // ),
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
              'Add New Customer',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Logo Section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () => _showImagePicker(context),
                                  child: CircleAvatar(
                                    radius: context.sw(0.12),
                                    backgroundColor: theme.cardColor,
                                    backgroundImage: provider.companyLogo != null
                                        ? FileImage(provider.companyLogo!)
                                        : null,
                                    child: provider.companyLogo == null
                                        ? Icon(
                                      Icons.add_photo_alternate_rounded,
                                      size: 40,
                                      color: theme.colorScheme.primary,
                                    )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Company Logo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add or change logo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            if (_logoError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _logoError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Company Information Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.business_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Company Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _buildTextField(
                              provider.companyNameController,
                              'Company Name *',
                              Icons.business_outlined,
                                  (value) => value!.isEmpty ? 'Company name is required' : null,
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              provider.businessTypeController,
                              'Business Type *',
                              Icons.category_outlined,
                                  (value) => value!.isEmpty ? 'Business type is required' : null,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    provider.cityController,
                                    'City *',
                                    Icons.location_city_outlined,
                                        (value) => value!.isEmpty ? 'City is required' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    provider.phoneController,
                                    'Phone Number *',
                                    Icons.phone_outlined,
                                        (value) => value!.isEmpty ? 'Phone number is required' : null,

                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              provider.addressController,
                              'Address *',
                              Icons.location_on_outlined,
                                  (value) => value!.isEmpty ? 'Address is required' : null,

                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              provider.emailController,
                              'Email Address *',
                              Icons.email_outlined,
                                  (value) {
                                if (value!.isEmpty) return 'Email is required';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },

                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Persons Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people_alt_outlined,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Contact Persons',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: provider.addPerson,
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Add Person'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
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
                                    color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                color: theme.colorScheme.primary,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Person ${index + 1}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.colorScheme.primary,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (provider.personsList.length > 1)
                                            IconButton(
                                              onPressed: () => provider.removePerson(index),
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              tooltip: 'Remove Person',
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      _buildPersonTextField(
                                        person['fullName']!,
                                        'Full Name *',
                                        Icons.person_outline_rounded,
                                            (value) => value!.isEmpty ? 'Full name is required' : null,
                                      ),
                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildPersonTextField(
                                              person['designation']!,
                                              'Designation *',
                                              Icons.work_outline_rounded,
                                                  (value) => value!.isEmpty ? 'Designation is required' : null,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildPersonTextField(
                                              person['department']!,
                                              'Department *',
                                              Icons.business_center_outlined,
                                                  (value) => value!.isEmpty ? 'Department is required' : null,
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
                                              'Phone Number *',
                                              Icons.phone_outlined,
                                                  (value) => value!.isEmpty ? 'Phone number is required' : null,

                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildPersonTextField(
                                              person['email']!,
                                              'Email Address *',
                                              Icons.email_outlined,
                                                  (value) {
                                                if (value!.isEmpty) return 'Email is required';
                                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                                  return 'Enter a valid email';
                                                }
                                                return null;
                                              },
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
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Assignments',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Assigned Staff
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Staff *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                staffProvider.isLoading
                                    ? Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                )
                                    : staffProvider.staffs.isEmpty
                                    ? Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text('No staff available'),
                                  ),
                                )
                                    : // In your DropdownButtonFormField for staff:
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    // ✅ Store the actual staff name here
                                    value: provider.selectedStaffName,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    hint: const Text('Select Staff'),
                                    icon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.grey[800],
                                      fontSize: 14,
                                    ),
                                    validator: (value) => value == null || value.isEmpty
                                        ? 'Please select a staff member'
                                        : null,
                                    onChanged: (String? value) {
                                      // ✅ This will now store the staff name, not ID
                                      provider.selectedStaffName = value;
                                      provider.notifyListeners();
                                    },
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Select Staff'),
                                      ),
                                      ...staffProvider.staffs
                                          .map((staff) => DropdownMenuItem<String>(
                                        // ✅ Use staff.username as the value
                                        value: staff.username, // This stores the name
                                        child: Text(staff.username ?? 'Unnamed Staff'),
                                      ))
                                          .toList(),
                                    ],
                                  ),
                                ),

                                                                    // Container(
                                //   padding: const EdgeInsets.symmetric(horizontal: 12),
                                //   decoration: BoxDecoration(
                                //     color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                //     borderRadius: BorderRadius.circular(12),
                                //     border: Border.all(
                                //       color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                                //     ),
                                //   ),
                                //   child: DropdownButtonFormField<String>(
                                //     value: provider.selectedStaffName,
                                //     isExpanded: true,
                                //     decoration: const InputDecoration(
                                //       border: InputBorder.none,
                                //     ),
                                //     hint: const Text('Select Staff'),
                                //     icon: Icon(
                                //       Icons.arrow_drop_down_rounded,
                                //       color: theme.colorScheme.primary,
                                //     ),
                                //     style: TextStyle(
                                //       color: isDarkMode ? Colors.white : Colors.grey[800],
                                //       fontSize: 14,
                                //     ),
                                //     validator: (value) => value == null || value.isEmpty
                                //         ? 'Please select a staff member'
                                //         : null,
                                //     onChanged: (value) {
                                //       provider.selectedStaffName = value;
                                //       provider.notifyListeners();
                                //     },
                                //     items: [
                                //       const DropdownMenuItem<String>(
                                //         value: null,
                                //         child: Text('Select Staff'),
                                //       ),
                                //       ...staffProvider.staffs
                                //           .map((staff) => DropdownMenuItem<String>(
                                //         value: staff.sId,
                                //         child: Text(staff.username ?? 'Unnamed Staff'),
                                //       ))
                                //           .toList(),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Assigned Product
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Product *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                productProvider.isLoading
                                    ? Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                )
                                    : productProvider.products.isEmpty
                                    ? Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text('No products available'),
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
                                    value: provider.selectedProductId,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    hint: const Text('Select Product'),
                                    icon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.grey[800],
                                      fontSize: 14,
                                    ),
                                    validator: (value) => value == null || value.isEmpty
                                        ? 'Please select a product'
                                        : null,
                                    onChanged: (value) {
                                      provider.selectedProductId = value;
                                      provider.notifyListeners();
                                    },
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Select Product'),
                                      ),
                                      ...productProvider.products
                                          .map((product) => DropdownMenuItem<String>(
                                        value: product.sId,
                                        child: Text(product.name ?? 'Unnamed Product'),
                                      ))
                                          .toList(),
                                    ],
                                  ),
                                ),
                              ],
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
                            'Creating Customer...',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () => _submitForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_rounded),
                          SizedBox(width: 12),
                          Text(
                            'Create Customer',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
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
        String? Function(String?)? validator,
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
          size: 22,
        ),
        filled: true,
        fillColor: theme.cardColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
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
          vertical: 16,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPersonTextField(
      TextEditingController controller,
      String label,
      IconData icon, [
        String? Function(String?)? validator,
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
          size: 20,
        ),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
      ),
      validator: validator,
    );
  }
}