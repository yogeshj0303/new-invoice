// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class BusinessGstSettingsScreen extends StatefulWidget {
//   const BusinessGstSettingsScreen({super.key});

//   @override
//   State<BusinessGstSettingsScreen> createState() => _BusinessGstSettingsScreenState();
// }

// class _BusinessGstSettingsScreenState extends State<BusinessGstSettingsScreen> {
//   // Theme colors
//   static const Color primaryColor = Color(0xFF2E3085);
//   static const Color secondaryColor = Color(0xFF4E4AA8);
  
//   // Form controllers
//   final TextEditingController _businessNameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _gstController = TextEditingController();
//   final TextEditingController _panController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _tdsTcsController = TextEditingController();
  
//   // Selected values
//   String _selectedIndustryType = 'Electrical works';
//   String _selectedBusinessType = 'Wholesaler';

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with sample data as shown in the image
//     _businessNameController.text = 'vggggyggyy';
//     _phoneController.text = '8085042656';
//     _emailController.text = 'yashshaft@gmail.com';
//     _addressController.text = 'Block no 9, south avenue, Shahpura, Bhopal, Madhya Pradesh';
//   }

//   @override
//   void dispose() {
//     _businessNameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _gstController.dispose();
//     _panController.dispose();
//     _addressController.dispose();
//     _tdsTcsController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion(
//       value: SystemUiOverlayStyle(
//         statusBarColor: Colors.white,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: primaryColor),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text(
//             'Business & GST Settings',
//             style: TextStyle(
//               color: Color(0xFF1A1A1A),
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           actions: [
//             Row(
//               children: [
//                 Icon(Icons.add, color: primaryColor, size: 20),
//                 const SizedBox(width: 4),
//                 Text(
//                   'Add New Business',
//                   style: TextStyle(
//                     color: primaryColor,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//               ],
//             ),
//           ],
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildUploadLogoSection(),
//               const SizedBox(height: 16),
//               _buildCompactInfoRow(
//                 icon: Icons.phone,
//                 label: 'Business Phone Number',
//                 value: _phoneController.text,
//                 onTap: () => _showBottomSheet('Business Phone Number', _phoneController, Icons.phone),
//               ),
//               const SizedBox(height: 12),
//               _buildCompactInfoRow(
//                 icon: Icons.email,
//                 label: 'Business Email',
//                 value: _emailController.text,
//                 onTap: () => _showBottomSheet('Business Email', _emailController, Icons.email),
//               ),
//               const SizedBox(height: 12),
//               _buildCompactInfoRow(
//                 icon: Icons.receipt,
//                 label: 'GST Number',
//                 value: _gstController.text.isEmpty ? 'Not entered' : _gstController.text,
//                 onTap: () => _showBottomSheet('GST Number', _gstController, Icons.receipt),
//               ),
//               const SizedBox(height: 12),
//               _buildCompactInfoRow(
//                 icon: Icons.badge,
//                 label: 'PAN Number',
//                 value: _panController.text.isEmpty ? 'Not entered' : _panController.text,
//                 onTap: () => _showBottomSheet('PAN Number', _panController, Icons.badge),
//               ),
//               const SizedBox(height: 12),
//               _buildCompactInfoRow(
//                 icon: Icons.business,
//                 label: 'Business Address',
//                 value: _addressController.text,
//                 onTap: () => _showBottomSheet('Business Address', _addressController, Icons.business),
//                 isMultiline: true,
//               ),
//               const SizedBox(height: 12),
//               _buildCompactInfoRow(
//                 icon: Icons.percent,
//                 label: 'TDS/TCS',
//                 value: _tdsTcsController.text.isEmpty ? 'Not entered' : _tdsTcsController.text,
//                 onTap: () => _showBottomSheet('TDS/TCS', _tdsTcsController, Icons.percent),
//               ),
//               const SizedBox(height: 12),
//               _buildCompactInfoRow(
//                 icon: Icons.category,
//                 label: 'Industry Type',
//                 value: _selectedIndustryType,
//                 onTap: () => _showSelectionBottomSheet('Industry Type', [
//                   'Electrical works',
//                   'Construction',
//                   'Manufacturing',
//                   'Retail',
//                   'Services',
//                   'Other'
//                 ], (value) {
//                   setState(() {
//                     _selectedIndustryType = value;
//                   });
//                 }),
//               ),
//               const SizedBox(height: 12),
//               _buildCompactInfoRow(
//                 icon: Icons.store,
//                 label: 'Business Type',
//                 value: _selectedBusinessType,
//                 onTap: () => _showSelectionBottomSheet('Business Type', [
//                   'Wholesaler',
//                   'Retailer',
//                   'Manufacturer',
//                   'Service Provider',
//                   'Distributor',
//                   'Other'
//                 ], (value) {
//                   setState(() {
//                     _selectedBusinessType = value;
//                   });
//                 }),
//               ),
//               const SizedBox(height: 12),
//               _buildCompactInfoRow(
//                 icon: Icons.add_circle_outline,
//                 label: 'Add Business Details',
//                 value: 'Add additional business information such as MSME number, Website etc.',
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Navigate to additional business details')),
//                   );
//                 },
//                 isMultiline: true,
//                 showArrow: true,
//               ),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUploadLogoSection() {
//     return Row(
//       children: [
//         Container(
//           width: 70,
//           height: 70,
//           decoration: BoxDecoration(
//             color: Colors.grey[100],
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.upload,
//                 color: primaryColor,
//                 size: 20,
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 'Upload Logo',
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Business Name',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1A1A1A),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               TextField(
//                 controller: _businessNameController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter business name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(6),
//                     borderSide: BorderSide(color: Colors.grey[300]!),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(6),
//                     borderSide: BorderSide(color: Colors.grey[300]!),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(6),
//                     borderSide: BorderSide(color: primaryColor),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                   isDense: true,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCompactInfoRow({
//     required IconData icon,
//     required String label,
//     required String value,
//     required VoidCallback onTap,
//     bool isMultiline = false,
//     bool showArrow = true,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//         decoration: BoxDecoration(
//           color: Colors.grey[50],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[200]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 icon,
//                 color: primaryColor,
//                 size: 16,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1A1A1A),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     value,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w400,
//                     ),
//                     maxLines: isMultiline ? 2 : 1,
//                     overflow: isMultiline ? TextOverflow.ellipsis : null,
//                   ),
//                 ],
//               ),
//             ),
//             if (showArrow)
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: primaryColor,
//                 size: 14,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showBottomSheet(String title, TextEditingController controller, IconData icon) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             left: 20,
//             right: 20,
//             top: 20,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(icon, color: primaryColor, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: controller,
//                 decoration: InputDecoration(
//                   hintText: 'Enter $title',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: primaryColor, width: 2),
//                   ),
//                 ),
//                 maxLines: title == 'Business Address' ? 3 : 1,
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     setState(() {});
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Save',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showSelectionBottomSheet(String title, List<String> options, Function(String) onSelect) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close),
//                     ),
//                   ],
//                 ),
//               ),
//               Flexible(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: options.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(options[index]),
//                       onTap: () {
//                         onSelect(options[index]);
//                         Navigator.pop(context);
//                       },
//                       trailing: options[index] == (title == 'Industry Type' ? _selectedIndustryType : _selectedBusinessType)
//                           ? Icon(Icons.check, color: primaryColor)
//                           : null,
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
