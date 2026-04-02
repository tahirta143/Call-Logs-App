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
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 infoTile("🏢 Company", companyName),
//                 infoTile("👤 Person", personName),
//                 infoTile("📦 Product", m.product?.name ?? "N/A"),
//                 infoTile("🧑‍💼 Staff", staffName),
//
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.call, color: Colors.green),
//                       onPressed: () =>
//                           _launchPhone(phoneNumber, companyName, staffName),
//                     ),
//                     IconButton(
//                       icon: Image.asset("assets/images/whatsapp.jpeg",
//                           width: 30, height: 30),
//                       onPressed: () =>
//                           _launchWhatsApp(phoneNumber, companyName, staffName),
//                     ),
//                   ],
//                 ),
//
//                 const Divider(height: 30, thickness: 1),
//                 const Text("Meeting Type",
//                     style:
//                     TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//
//                 buildRadio("Follow Up"),
//                 buildRadio("Not Interested"),
//                 buildRadio("Already Installed"),
//                 buildRadio("Phone Responded"),
//
//                 if (selectedTimeline == "Follow Up") ...[
//                   const SizedBox(height: 12),
//                   const Text("Next Follow-up Date",
//                       style:
//                       TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                   ElevatedButton(
//                     onPressed: pickDate,
//                     child: Text(selectedDate == null
//                         ? "Select Date"
//                         : DateFormat('yyyy-MM-dd').format(selectedDate!)),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text("Next Follow-up Time",
//                       style:
//                       TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                   ElevatedButton(
//                     onPressed: pickTime,
//                     child: Text(selectedTime == null
//                         ? "Select Time"
//                         : selectedTime!.format(context)),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text("Visit Details",
//                       style:
//                       TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                   TextField(
//                     controller: detailsController,
//                     maxLines: 3,
//                     decoration: const InputDecoration(
//                       hintText: "Enter details...",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ],
//
//                 const SizedBox(height: 30),
//                 Center(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.save),
//                     label: const Text("Save Changes"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF5B86E5),
//                       foregroundColor: Colors.white,
//                     ),
//                     onPressed: () async {
//                       if (selectedTimeline == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text("Please select a meeting type")),
//                         );
//                         return;
//                       }
//
//                       await provider.updateMeeting(
//                         id: m.id!,
//                         timeline: selectedTimeline!,
//                         companyName: companyName,
//                         personId: m.person?.id ?? '',
//                         productId: m.product?.id ?? '',
//                         staffId: m.person?.assignedStaff?.id ?? '',
//                         nextDate: selectedDate != null
//                             ? DateFormat('yyyy-MM-dd').format(selectedDate!)
//                             : null,
//                         nextTime: selectedTime != null
//                             ? selectedTime!.format(context)
//                             : null,
//                         details: detailsController.text,
//                         designation: "Manager",
//                         detailsOption: "Visit Done",
//                         referenceProvidedBy: "Customer",
//                         contactMethod: "Phone",
//                       );
//
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text("✅ Meeting updated successfully")),
//                         );
//                         Navigator.pop(context);
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           if (_isSending)
//             Container(
//               color: Colors.black45,
//               child: const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildRadio(String label) => RadioListTile<String>(
//     value: label,
//     groupValue: selectedTimeline,
//     title: Text(label),
//     onChanged: (value) => setState(() => selectedTimeline = value),
//   );
//
//   Widget infoTile(String title, String value) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         Flexible(child: Text(value)),
//       ],
//     ),
//   );
// }
//
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Provider/MeetingProvider/NoDateMeetingProvider.dart';
import '../../model/AllMeetingModel.dart';

class EditMeetingScreen extends StatefulWidget {
  final MeetingData meeting;

  const EditMeetingScreen({super.key, required this.meeting});

  @override
  State<EditMeetingScreen> createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends State<EditMeetingScreen> {
  String? selectedTimeline;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedContactMethod;
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  bool _isSending = false;
  bool _isLoadingLocation = false;

  // 🔹 Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 🔹 Get current location and address
  Future<String> _getCurrentAddress() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")),
        );
        return "Location services disabled";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "Permission denied";
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return "Location permission permanently denied";
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.first;
      final address =
          "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";

      final fullLocation =
          "📍 Lat: ${position.latitude}, Lng: ${position.longitude}\n$address";

      setState(() => locationController.text = fullLocation);
      return address;
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
      return "Unable to fetch location";
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  // 🔹 Send API call log when Call / WhatsApp button pressed
  Future<void> _postMeetingCall({
    required String mode,
    required String customerName,
    required String phoneNumber,
    required String staffName,
  }) async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No token found. Please login again.")),
      );
      return;
    }

    setState(() => _isSending = true);

    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);
    final time = DateFormat('hh:mm a').format(now);
    final location = await _getCurrentAddress();

    final Map<String, dynamic> body = {
      "customerName": customerName,
      "phoneNumber": phoneNumber,
      "staffName": staffName,
      "date": date,
      "time": time,
      "mode": mode,
      "location": location,
    };

    try {
      final response = await http.post(
        Uri.parse("https://call-logs-backend.onrender.com/api/meeting-calls"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Meeting call logged successfully!");
      } else {
        debugPrint("❌ Failed to log meeting call: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error sending meeting call: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  // 🔹 Launch Phone dialer
  Future<void> _launchPhone(
      String phoneNumber, String companyName, String staffName) async {
    await _postMeetingCall(
      mode: "Call",
      customerName: companyName,
      phoneNumber: phoneNumber,
      staffName: staffName,
    );

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    }
  }

  // 🔹 Launch WhatsApp
  Future<void> _launchWhatsApp(
      String phoneNumber, String companyName, String staffName) async {
    await _postMeetingCall(
      mode: "WhatsApp",
      customerName: companyName,
      phoneNumber: phoneNumber,
      staffName: staffName,
    );

    var cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) cleaned = '92${cleaned.substring(1)}';
    final Uri whatsappUri = Uri.parse("https://wa.me/$cleaned");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  // 🔹 Pick date for Follow-up
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => selectedDate = picked);
    }
  }

  // 🔹 Pick time for Follow-up
  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => selectedTime = picked);
    }
  }

  // 🔹 Save meeting updates
  // Future<void> _saveMeeting(BuildContext context) async {
  //   if (selectedTimeline == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text("Please select a meeting type"),
  //         backgroundColor: Theme.of(context).colorScheme.error,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final provider = Provider.of<NoDateMeetingProvider>(context, listen: false);
  //   final m = widget.meeting;
  //
  //   setState(() => _isSending = true);
  //
  //   try {
  //     await provider.updateMeeting(
  //       id: m.id!,
  //       timeline: selectedTimeline!,
  //       companyName: m.companyName ?? '',
  //       personId: m.person?.id ?? '',
  //       productId: m.product?.id ?? '',
  //       staffId: m.person?.assignedStaff?.id ?? '',
  //       nextDate: selectedDate != null
  //           ? DateFormat('yyyy-MM-dd').format(selectedDate!)
  //           : null,
  //       nextTime: selectedTime != null
  //           ? selectedTime!.format(context)
  //           : null,
  //       details: detailsController.text,
  //       designation: "Manager",
  //       detailsOption: "Visit Done",
  //       referenceProvidedBy: "Customer",
  //       contactMethod: "Phone",
  //     );
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('Meeting updated successfully'),
  //           backgroundColor: Colors.green,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //         ),
  //       );
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to update meeting: $e'),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isSending = false);
  //     }
  //   }
  // }


  Future<void> _saveMeeting(BuildContext context) async {
    if (selectedTimeline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a meeting type"),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    final provider = Provider.of<NoDateMeetingProvider>(context, listen: false);
    final m = widget.meeting;

    setState(() => _isSending = true);

    try {
      // ✅ درست enum values استعمال کریں
      String designation = "Manager";
      String action = "";
      String contactMethod = "";
      String reference = "";

      // ✅ ہر status کے لیے الگ values
      if (selectedTimeline == "Follow Up") {
        designation = "Manager";
        action = "Send Profile"; // ✅ صحیح action
        contactMethod = "By Phone"; // ✅ "Phone" کی جگہ "By Phone"
        reference = "Customer";
      } else if (selectedTimeline == "Not Interested") {
        designation = "";
        action = "";
        contactMethod = "By Phone";
        reference = "";
      } else if (selectedTimeline == "Already Installed") {
        designation = "";
        action = "";
        contactMethod = "By Phone";
        reference = "";
      } else if (selectedTimeline == "Phone Responded") {
        designation = "";
        action = "";
        contactMethod = "By Phone";
        reference = "";
      }

      await provider.updateMeeting(
        id: m.id!,
        timeline: selectedTimeline!,
        companyName: m.companyName ?? '',
        personId: m.person?.id ?? '',
        productId: m.product?.id ?? '',
        staffId: m.person?.assignedStaff?.id ?? '',
        nextDate: selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : null,
        nextTime: selectedTime != null
            ? selectedTime!.format(context)
            : null,
        details: detailsController.text,
        designation: designation,
        detailsOption: action, // ✅ action کو detailsOption کے طور پر بھیجیں
        referenceProvidedBy: reference,
        contactMethod: contactMethod, // ✅ درست contactMethod
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Meeting updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update meeting: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final m = widget.meeting;

    final companyName = m.companyName ?? "Unknown";
    final personName = (m.person?.persons.isNotEmpty ?? false)
        ? m.person!.persons.first.fullName ?? "Unknown"
        : "Unknown";
    final phoneNumber = (m.person?.persons.isNotEmpty ?? false)
        ? m.person!.persons.first.phoneNumber ?? ""
        : "";
    final staffName = m.person?.assignedStaff?.username ?? "Unassigned";
    final productName = m.product?.name ?? "N/A";

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            elevation: 4,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Update Meeting',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  // Meeting Information Card
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
                            'Meeting Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Company Name
                          _buildInfoRow(
                            icon: Icons.business_rounded,
                            label: 'Company',
                            value: companyName,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),

                          // Contact Person
                          _buildInfoRow(
                            icon: Icons.person_rounded,
                            label: 'Contact Person',
                            value: personName,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),

                          // Product
                          _buildInfoRow(
                            icon: Icons.inventory_2_rounded,
                            label: 'Product',
                            value: productName,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),

                          // Staff
                          _buildInfoRow(
                            icon: Icons.engineering_rounded,
                            label: 'Assigned Staff',
                            value: staffName,
                            theme: theme,
                          ),
                          const SizedBox(height: 20),

                          // Contact Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Call Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () => _launchPhone(phoneNumber, companyName, staffName),
                                  icon: Icon(
                                    Icons.call_rounded,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                  tooltip: 'Make Call',
                                ),
                              ),
                              const SizedBox(width: 20),

                              // WhatsApp Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF25D366).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () => _launchWhatsApp(phoneNumber, companyName, staffName),
                                  icon: Image.asset(
                                    "assets/images/whatsapp.jpeg",
                                    width: 24,
                                    height: 24,
                                  ),
                                  tooltip: 'Open WhatsApp',
                                ),
                              ),
                              const SizedBox(width: 20),

                              // Location Button
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: _getCurrentAddress,
                                  icon: _isLoadingLocation
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                      : Icon(
                                    Icons.location_on_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                  tooltip: 'Get Current Location',
                                ),
                              ),
                            ],
                          ),

                          if (locationController.text.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                locationController.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Meeting Type Card
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
                            'Meeting Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Status Options
                          Column(
                            children: [
                              _buildStatusOption(
                                value: 'Follow Up',
                                label: 'Follow Up',
                                icon: Icons.update_rounded,
                                theme: theme,
                              ),
                              _buildStatusOption(
                                value: 'Not Interested',
                                label: 'Not Interested',
                                icon: Icons.disabled_by_default_rounded,
                                theme: theme,
                              ),
                              _buildStatusOption(
                                value: 'Already Installed',
                                label: 'Already Installed',
                                icon: Icons.check_circle_outline_rounded,
                                theme: theme,
                              ),
                              _buildStatusOption(
                                value: 'Phone Responded',
                                label: 'Phone Responded',
                                icon: Icons.phone_callback_rounded,
                                theme: theme,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Follow-up Details (Conditional)
                  if (selectedTimeline == 'Follow Up') ...[
                    const SizedBox(height: 24),
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
                              'Follow-up Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Date Picker
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Follow-up Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () => _pickDate(context),
                                    leading: Icon(
                                      Icons.calendar_today_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                    title: Text(
                                      selectedDate == null
                                          ? 'Select Date'
                                          : DateFormat('EEEE, MMMM d, yyyy').format(selectedDate!),
                                      style: TextStyle(
                                        color: selectedDate == null
                                            ? Colors.grey[500]
                                            : isDarkMode ? Colors.white : Colors.grey[800],
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Time Picker
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Follow-up Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () => _pickTime(context),
                                    leading: Icon(
                                      Icons.access_time_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                    title: Text(
                                      selectedTime == null
                                          ? 'Select Time'
                                          : selectedTime!.format(context),
                                      style: TextStyle(
                                        color: selectedTime == null
                                            ? Colors.grey[500]
                                            : isDarkMode ? Colors.white : Colors.grey[800],
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Visit Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: detailsController,
                                    maxLines: 4,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.grey[800],
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter meeting details...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                        // EditMeetingScreen میں یہ variable شامل کریں


// Build method میں، Follow-up Details section میں یہ شامل کریں:
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Method',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonFormField<String>(
                                value: selectedContactMethod ?? 'By Phone',
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Select contact method',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                ),
                                items: [
                                  'By Phone',
                                  'By Visit',
                                  'By WhatsApp',
                                  'By Email',
                                ].map((method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() => selectedContactMethod = value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Save Button
                  _isSending
                      ? Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Updating Meeting...',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveMeeting(context),
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
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOption({
    required String value,
    required String label,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isSelected = selectedTimeline == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.grey[300]!,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedTimeline,
        title: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
        activeColor: theme.colorScheme.primary,
        onChanged: (value) {
          setState(() => selectedTimeline = value);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// lib/utils/meeting_constants.dart

class MeetingConstants {
  // Valid contact methods for backend
  static const List<String> validContactMethods = [
    "By Phone",
    "By Visit",
    "By WhatsApp",
    "By Email",
  ];

  // Valid actions for backend
  static const List<String> validActions = [
    "Send Profile",
    "Visit Done",
    "Call Done",
    "Quotation Sent",
    "Sample Provided",
    "Demo Given",
  ];

  // Frontend to backend mapping
  static String getBackendContactMethod(String frontendMethod) {
    switch (frontendMethod.toLowerCase()) {
      case 'phone':
      case 'call':
        return 'By Phone';
      case 'visit':
        return 'By Visit';
      case 'whatsapp':
        return 'By WhatsApp';
      case 'email':
        return 'By Email';
      default:
        return 'By Phone'; // default
    }
  }
}