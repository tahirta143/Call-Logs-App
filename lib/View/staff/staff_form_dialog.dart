import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinity/compoents/app_theme.dart';
import 'package:infinity/model/staff_model/staffModel.dart';
import 'package:provider/provider.dart';
import '../../Provider/staff/StaffProvider.dart';
import '../../compoents/app_button.dart';
import '../../compoents/app_text_field.dart';
import '../../constants/api_config.dart';
import '../../Provider/auth/access_control_provider.dart';
import '../../constants/permission_keys.dart';

class StaffFormDialog extends StatefulWidget {
  final StaffData? staff;

  const StaffFormDialog({super.key, this.staff});

  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nameController;
  late TextEditingController fatherNameController;
  late TextEditingController cnicController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController qualificationController;
  late TextEditingController deptController;
  late TextEditingController desigController;
  late TextEditingController bankController;
  late TextEditingController accountController;
  late TextEditingController hiringDateController;
  late TextEditingController dobController;

  String? selectedGender;
  String? selectedEmployeeType;
  String? selectedShift;
  String? selectedBloodGroup;
  bool isEnabled = true;

  @override
  void initState() {
    super.initState();
    
    // Clear any previously selected image if this is a NEW staff entry
    if (widget.staff == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<StaffProvider>(context, listen: false).clearImage();
      });
    }

    final s = widget.staff;
    nameController = TextEditingController(text: s?.employeeName ?? '');
    fatherNameController = TextEditingController(text: s?.fatherName ?? '');
    cnicController = TextEditingController(text: s?.cnicNo ?? '');
    emailController = TextEditingController(text: s?.email ?? '');
    mobileController = TextEditingController(text: s?.mobile ?? '');
    phoneController = TextEditingController(text: s?.phone ?? '');
    addressController = TextEditingController(text: s?.address ?? '');
    cityController = TextEditingController(text: s?.city ?? '');
    qualificationController = TextEditingController(text: s?.qualification ?? '');
    deptController = TextEditingController(text: s?.department ?? '');
    desigController = TextEditingController(text: s?.designation ?? '');
    bankController = TextEditingController(text: s?.bank ?? '');
    accountController = TextEditingController(text: s?.accountNumber ?? '');
    hiringDateController = TextEditingController(text: s?.hiringDate ?? '');
    dobController = TextEditingController(text: s?.dateOfBirth ?? '');
    
    selectedGender = s?.sex?.isNotEmpty == true ? s!.sex : 'Male';
    selectedEmployeeType = s?.employeeType?.isNotEmpty == true ? s!.employeeType : 'Permanent';
    selectedShift = s?.dutyShift?.isNotEmpty == true ? s!.dutyShift : 'Morning';
    selectedBloodGroup = s?.bloodGroup;
    isEnabled = s?.enabled ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    fatherNameController.dispose();
    cnicController.dispose();
    emailController.dispose();
    mobileController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    qualificationController.dispose();
    deptController.dispose();
    desigController.dispose();
    bankController.dispose();
    accountController.dispose();
    hiringDateController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<StaffProvider>(context, listen: false);
    
    final Map<String, String> data = {
      'employee_name': nameController.text.trim(),
      'father_name': fatherNameController.text.trim(),
      'cnic_no': cnicController.text.trim(),
      'email': emailController.text.trim(),
      'mobile': mobileController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'city': cityController.text.trim(),
      'qualification': qualificationController.text.trim(),
      'department': deptController.text.trim(),
      'designation': desigController.text.trim(),
      'bank': bankController.text.trim(),
      'account_number': accountController.text.trim(),
      'hiring_date': hiringDateController.text.trim(),
      'date_of_birth': dobController.text.trim(),
      'sex': selectedGender ?? '',
      'employee_type': selectedEmployeeType ?? '',
      'duty_shift': selectedShift ?? '',
      'blood_group': selectedBloodGroup ?? '',
      'enabled': isEnabled.toString(),
      'status': isEnabled ? 'active' : 'inactive',
    };

    bool success;
    if (widget.staff == null) {
      success = await provider.uploadStaff(employeeData: data);
    } else {
      success = await provider.updateStaff(
        id: widget.staff!.id!,
        employeeData: data,
        image: provider.selectedImage,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.staff == null ? 'Staff added successfully' : 'Staff updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final provider = Provider.of<StaffProvider>(context);
    final acp = Provider.of<AccessControlProvider>(context);
    final canDelete = acp.canDelete(PermissionKeys.employee);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(widget.staff == null ? Iconsax.user_add : Iconsax.user_edit, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  widget.staff == null ? 'Add New Staff' : 'Edit Staff Member',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // Scrollable Content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Image Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 2),
                              color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                            ),
                            child: ClipOval(
                              child: provider.selectedImage != null
                                  ? Image.file(provider.selectedImage!, fit: BoxFit.cover)
                                  : (widget.staff?.profileImage?.isNotEmpty == true
                                      ? Image.network(ApiConfig.getImageUrl(widget.staff!.profileImage), fit: BoxFit.cover)
                                      : const Icon(Iconsax.user, size: 40, color: Colors.grey)),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => provider.pickImage(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                                child: const Icon(Iconsax.camera, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sections
                    _buildSectionTitle('Personal Information'),
                    AppTextField(controller: nameController, label: 'Full Name', icon: Iconsax.user, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    AppTextField(controller: fatherNameController, label: "Father's Name", icon: Iconsax.user_octagon),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: cnicController, label: 'CNIC No', icon: Iconsax.personalcard)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Gender', ['Male', 'Female', 'Other'], selectedGender, (v) => setState(() => selectedGender = v))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker(context, 'Date of Birth', dobController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Blood Group', ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], selectedBloodGroup, (v) => setState(() => selectedBloodGroup = v))),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle('Contact Details'),
                    AppTextField(controller: emailController, label: 'Email', icon: Iconsax.sms, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: mobileController, label: 'Mobile', icon: Iconsax.mobile, keyboardType: TextInputType.phone)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: phoneController, label: 'Phone', icon: Iconsax.call, keyboardType: TextInputType.phone)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(controller: addressController, label: 'Address', icon: Iconsax.location),
                    const SizedBox(height: 16),
                    AppTextField(controller: cityController, label: 'City', icon: Iconsax.buildings_2),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Professional Details'),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: deptController, label: 'Department', icon: Iconsax.category)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: desigController, label: 'Designation', icon: Iconsax.briefcase)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('Employee Type', ['Permanent', 'Contract', 'Intern'], selectedEmployeeType, (v) => setState(() => selectedEmployeeType = v))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Duty Shift', ['Morning', 'Evening', 'Night'], selectedShift, (v) => setState(() => selectedShift = v))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(context, 'Hiring Date', hiringDateController),
                    const SizedBox(height: 16),
                    AppTextField(controller: qualificationController, label: 'Qualification', icon: Iconsax.teacher),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Banking Information'),
                    AppTextField(controller: bankController, label: 'Bank Name', icon: Iconsax.bank),
                    const SizedBox(height: 16),
                    AppTextField(controller: accountController, label: 'Account Number', icon: Iconsax.card),

                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Account Enabled', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Allow this staff member to login'),
                      value: isEnabled,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (v) => setState(() => isEnabled = v),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Footer Actions
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.staff != null && canDelete)
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(context, provider),
                    icon: const Icon(Iconsax.trash, color: Colors.red),
                    tooltip: 'Delete Staff',
                  ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    press: provider.isLoading ? () {} : _submit,
                    title: provider.isLoading ? 'Saving...' : (widget.staff == null ? 'Add Staff' : 'Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor.withOpacity(0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StaffProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${widget.staff!.employeeName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation
              final success = await provider.DeleteStaff(widget.staff!.id!);
              if (success && mounted) {
                Navigator.pop(context); // Close form
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              hint: Text('Select $label', style: const TextStyle(fontSize: 13)),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
            }
          },
          child: AbsorbPointer(
            child: AppTextField(
              controller: controller,
              label: label,
              icon: Iconsax.calendar,
            ),
          ),
        ),
      ],
    );
  }
}
