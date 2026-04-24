import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinity/compoents/app_theme.dart';
import 'package:infinity/model/staff_model/staffModel.dart';
import 'package:provider/provider.dart';
import '../../Provider/staff/StaffProvider.dart';
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
  late TextEditingController softwareUsernameController;
  late TextEditingController softwarePasswordController;
  late TextEditingController confirmPasswordController;

  String? selectedGender;
  String? selectedEmployeeType;
  String? selectedShift;
  String? selectedBloodGroup;
  String? selectedDept;
  String? selectedDesig;
  String? selectedBank;
  bool isEnabled = true;
  bool createSoftwareUser = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

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
    softwareUsernameController = TextEditingController(text: s?.softwareUsername ?? '');
    softwarePasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    
    selectedGender = s?.sex?.isNotEmpty == true ? s!.sex : 'Male';
    selectedEmployeeType = s?.employeeType;
    selectedShift = s?.dutyShift;
    selectedBloodGroup = s?.bloodGroup;
    selectedDept = s?.department;
    selectedDesig = s?.designation;
    selectedBank = s?.bank;
    isEnabled = s?.enabled ?? true;

    // Load options
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StaffProvider>(context, listen: false).loadSetupOptions();
    });
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
    softwareUsernameController.dispose();
    softwarePasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (createSoftwareUser) {
      if (softwarePasswordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.orange));
        return;
      }
    }

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
      'department': selectedDept ?? deptController.text.trim(),
      'designation': selectedDesig ?? desigController.text.trim(),
      'bank': selectedBank ?? bankController.text.trim(),
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

    if (createSoftwareUser) {
      data['software_username'] = softwareUsernameController.text.trim();
      data['software_password'] = softwarePasswordController.text;
      data['create_software_user'] = 'true';
    }

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
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<StaffProvider>(context);
    final acp = Provider.of<AccessControlProvider>(context);
    final canDelete = acp.canDelete(PermissionKeys.employee);
    final canUpdate = acp.canUpdate(PermissionKeys.employee);
    final canCreate = acp.canCreate(PermissionKeys.employee);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
        child: Container(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                  border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.staff == null ? Iconsax.user_add : Iconsax.user_edit, color: AppTheme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.staff == null ? 'Add New Staff' : 'Edit Staff Member', 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          Text(widget.staff == null ? 'Register a new employee in the system' : 'Update the existing employee profile',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[600])),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Scrollable Content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
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
                              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 2),
                              color: isDark ? Colors.white10 : Colors.grey.shade100,
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
                    AppTextField(controller: nameController, label: 'Full Name', icon: Iconsax.user, isRequired: true, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    AppTextField(controller: fatherNameController, label: "Father's Name", icon: Iconsax.user_octagon),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: cnicController, label: 'CNIC No', icon: Iconsax.personalcard, isRequired: true, validator: (v) => v!.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Gender', ['Male', 'Female', 'Other'], selectedGender, (v) => setState(() => selectedGender = v), isRequired: true)),
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
                    AppTextField(controller: emailController, label: 'Email', icon: Iconsax.sms, keyboardType: TextInputType.emailAddress, isRequired: true, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: mobileController, label: 'Mobile', icon: Iconsax.mobile, keyboardType: TextInputType.phone)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: phoneController, label: 'Phone', icon: Iconsax.call, keyboardType: TextInputType.phone, isRequired: true, validator: (v) => v!.isEmpty ? 'Required' : null)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(controller: addressController, label: 'Address', icon: Iconsax.location, isRequired: true, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    AppTextField(controller: cityController, label: 'City', icon: Iconsax.buildings_2, isRequired: true, validator: (v) => v!.isEmpty ? 'Required' : null),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Professional Details'),
                        IconButton(
                          icon: Icon(Iconsax.refresh, size: 18, color: AppTheme.primaryColor),
                          onPressed: () => provider.loadSetupOptions(),
                          tooltip: 'Reload options',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('Department', provider.departments.isEmpty ? ['Management', 'Sales', 'Technical', 'HR', 'Account'] : provider.departments, selectedDept, (v) => setState(() => selectedDept = v), isRequired: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Designation', provider.designations.isEmpty ? ['Manager', 'Developer', 'Salesperson', 'Engineer', 'Clerk'] : provider.designations, selectedDesig, (v) => setState(() => selectedDesig = v), isRequired: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('Employee Type', provider.employeeTypes.isEmpty ? ['Permanent', 'Contract', 'Intern'] : provider.employeeTypes, selectedEmployeeType, (v) => setState(() => selectedEmployeeType = v), isRequired: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Duty Shift', provider.dutyShifts.isEmpty ? ['Morning', 'Evening', 'Night'] : provider.dutyShifts, selectedShift, (v) => setState(() => selectedShift = v), isRequired: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(context, 'Hiring Date', hiringDateController),
                    const SizedBox(height: 16),
                    AppTextField(controller: qualificationController, label: 'Qualification', icon: Iconsax.teacher),

                    _buildSectionTitle('Bank Info'),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('Bank', provider.banks.isEmpty ? ['HBL', 'UBL', 'MCB', 'Allied Bank', 'Meezan Bank'] : provider.banks, selectedBank, (v) => setState(() => selectedBank = v), isRequired: true)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: accountController, label: 'Account Number', icon: Iconsax.card, isRequired: true, validator: (v) => v!.isEmpty ? 'Required' : null)),
                      ],
                    ),

                    if (widget.staff == null) ...[
                      const SizedBox(height: 32),
                      _buildSectionTitle('Software Access'),
                      CheckboxListTile(
                        title: const Text('Create Software User', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Check this to create a login account for this staff'),
                        value: createSoftwareUser,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (v) => setState(() => createSoftwareUser = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (createSoftwareUser) ...[
                        const SizedBox(height: 16),
                        AppTextField(controller: softwareUsernameController, label: 'Username', icon: Iconsax.user, isRequired: true, validator: (v) => createSoftwareUser && v!.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: softwarePasswordController, 
                          label: 'Password', 
                          icon: Iconsax.key, 
                          obscureText: obscurePassword, 
                          icons: obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                          onToggleVisibility: () => setState(() => obscurePassword = !obscurePassword),
                          isRequired: true, 
                          validator: (v) => createSoftwareUser && v!.isEmpty ? 'Required' : null
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: confirmPasswordController, 
                          label: 'Confirm Password', 
                          icon: Iconsax.key, 
                          obscureText: obscureConfirmPassword, 
                          icons: obscureConfirmPassword ? Iconsax.eye : Iconsax.eye_slash,
                          onToggleVisibility: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                          isRequired: true, 
                          validator: (v) => createSoftwareUser && v!.isEmpty ? 'Required' : null
                        ),
                      ],
                    ],

                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Account Enabled', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Allow this staff member to login'),
                      value: isEnabled,
                      activeColor: AppTheme.primaryColor,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: (v) => setState(() => isEnabled = v),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  if (widget.staff != null && canDelete)
                    IconButton(
                      onPressed: provider.isLoading ? null : () => _showDeleteConfirmation(context, provider),
                      icon: const Icon(Iconsax.trash, color: Colors.red, size: 20),
                      tooltip: 'Delete Staff',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: (widget.staff == null ? canCreate : canUpdate) && !provider.isLoading
                        ? _submit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(widget.staff == null ? 'Create Staff' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor.withValues(alpha: 0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StaffProvider provider) {
    AppTheme.showAnimatedDialog(
      context: context,
      child: AlertDialog(
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

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged, {bool isRequired = false}) {
    final provider = Provider.of<StaffProvider>(context, listen: false);
    final isLoading = provider.isSetupLoading && items.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            if (isRequired) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
            if (isLoading) ...[
              const SizedBox(width: 8),
              const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5)),
            ],
          ],
        ),
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
              hint: Text(isLoading ? 'Loading...' : 'Select $label', style: const TextStyle(fontSize: 13)),
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
