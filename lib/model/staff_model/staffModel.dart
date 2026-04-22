class StaffModel {
  bool? success;
  List<StaffData>? data;

  StaffModel({this.success, this.data});

  StaffModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <StaffData>[];
      // Handle both { data: [...] } and { data: { data: [...] } } or { data: { rows: [...] } }
      var list = [];
      if (json['data'] is List) {
        list = json['data'];
      } else if (json['data'] is Map) {
        list = json['data']['data'] ?? json['data']['rows'] ?? json['data']['items'] ?? [];
      }
      
      for (var v in list) {
        data!.add(StaffData.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StaffData {
  String? id;
  String? employeeName;
  String? empId;
  String? profileImage;
  String? fatherName;
  String? address;
  String? city;
  String? sex;
  String? email;
  String? phone;
  String? mobile;
  String? cnicNo;
  String? dateOfBirth;
  String? qualification;
  String? bloodGroup;
  String? department;
  String? designation;
  String? employeeType;
  String? hiringDate;
  String? dutyShift;
  String? bank;
  String? accountNumber;
  bool? enabled;
  String? status;

  StaffData({
    this.id,
    this.employeeName,
    this.empId,
    this.profileImage,
    this.fatherName,
    this.address,
    this.city,
    this.sex,
    this.email,
    this.phone,
    this.mobile,
    this.cnicNo,
    this.dateOfBirth,
    this.qualification,
    this.bloodGroup,
    this.department,
    this.designation,
    this.employeeType,
    this.hiringDate,
    this.dutyShift,
    this.bank,
    this.accountNumber,
    this.enabled,
    this.status,
  });

  StaffData.fromJson(Map<String, dynamic> item) {
    id = (item['id'] ?? item['_id'] ?? item['uuid'] ?? item['emp_id'] ?? '').toString();
    employeeName = item['employee_name'] ?? item['first_name'] ?? item['username'] ?? '';
    empId = item['emp_id'] ?? '';
    profileImage = item['profile_image'] ?? ''; 
    fatherName = item['father_name'] ?? '';
    address = item['address'] ?? '';
    city = item['city'] ?? '';
    sex = item['sex'] ?? '';
    email = item['email'] ?? '';
    phone = item['phone'] ?? '';
    mobile = item['mobile'] ?? '';
    cnicNo = item['cnic_no'] ?? '';
    dateOfBirth = item['date_of_birth'] != null ? item['date_of_birth'].toString().split('T')[0] : '';
    qualification = item['qualification'] ?? '';
    bloodGroup = item['blood_group'] ?? '';
    department = item['department'] ?? '';
    designation = item['designation'] ?? '';
    employeeType = item['employee_type'] ?? '';
    hiringDate = item['hiring_date'] != null ? item['hiring_date'].toString().split('T')[0] : '';
    dutyShift = item['duty_shift'] ?? '';
    bank = item['bank'] ?? '';
    accountNumber = item['account_number'] ?? '';
    enabled = item['enabled'] is bool 
        ? item['enabled'] 
        : (item['status']?.toString().toLowerCase() == 'active');
    status = item['status'] ?? (enabled == true ? 'active' : 'inactive');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_name'] = employeeName;
    data['emp_id'] = empId;
    data['profile_image'] = profileImage;
    data['father_name'] = fatherName;
    data['address'] = address;
    data['city'] = city;
    data['sex'] = sex;
    data['email'] = email;
    data['phone'] = phone;
    data['mobile'] = mobile;
    data['cnic_no'] = cnicNo;
    data['date_of_birth'] = dateOfBirth;
    data['qualification'] = qualification;
    data['blood_group'] = bloodGroup;
    data['department'] = department;
    data['designation'] = designation;
    data['employee_type'] = employeeType;
    data['hiring_date'] = hiringDate;
    data['duty_shift'] = dutyShift;
    data['bank'] = bank;
    data['account_number'] = accountNumber;
    data['enabled'] = enabled;
    data['status'] = status;
    return data;
  }
}
