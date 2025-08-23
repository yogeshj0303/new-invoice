import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../services/digital_signature_service.dart';
import '../services/theme_service.dart';
import 'invoice_template_screen.dart';

class DigitalSignatureScreen extends StatefulWidget {
  const DigitalSignatureScreen({super.key});

  @override
  State<DigitalSignatureScreen> createState() => _DigitalSignatureScreenState();
}

class _DigitalSignatureScreenState extends State<DigitalSignatureScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back,color: ThemeService.defaultPrimaryColor,),
        ),
        backgroundColor: Colors.white,
        title: Text('Digital Signature',style: TextStyle(fontFamily: GoogleFonts.openSans().fontFamily,),),
        foregroundColor: Colors.white,
        actions: [
          Consumer<DigitalSignatureService>(
            builder: (context, signatureService, child) {
              if (signatureService.hasSignature) {
                return IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _showRemoveDialog,
                  tooltip: 'Remove Signature',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer2<DigitalSignatureService, ThemeService>(
        builder: (context, signatureService, themeService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Status
                _buildCurrentStatus(signatureService),
                const SizedBox(height: 16),
                
                // Signature Options
                _buildSignatureOptions(),
                const SizedBox(height: 16),
                
                // Live Preview
                _buildInvoiceTemplatePreview(signatureService, themeService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStatus(DigitalSignatureService signatureService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DigitalSignatureConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                signatureService.hasSignature ? Icons.check_circle : Icons.info,
                color: signatureService.hasSignature ? Colors.green : Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DigitalSignatureConstants.primaryColor,
                      ),
                    ),
                    Text(
                      signatureService.displayText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
                      if (signatureService.hasSignature) ...[
              const SizedBox(height: 12),
              Container(
                height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: DigitalSignatureConstants.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  signatureService.signature!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignatureOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signature Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DigitalSignatureConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        // Hand-drawn Signature
        _buildOptionCard(
          icon: Icons.edit,
          title: 'Create Signature by Hand',
          description: 'Draw your signature using touch or mouse',
          onTap: _showHandSignatureDialog,
        ),
        
        const SizedBox(height: 8),
        
        // Camera Import
        _buildOptionCard(
          icon: Icons.camera_alt,
          title: 'Import from Camera',
          description: 'Take a photo of your signature',
          onTap: _importFromCamera,
        ),
        
        const SizedBox(height: 8),
        
        // Gallery Import
        _buildOptionCard(
          icon: Icons.photo_library,
          title: 'Import from Gallery',
          description: 'Select signature from your photos',
          onTap: _importFromGallery,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: DigitalSignatureConstants.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DigitalSignatureConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: DigitalSignatureConstants.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceTemplatePreview(
    DigitalSignatureService signatureService,
    ThemeService themeService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Preview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DigitalSignatureConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: DigitalSignatureConstants.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InvoiceTemplate(
              items: [
                {'name': 'Sample Item 1', 'qty': 2, 'price': 100.0, 'unit': 'PCS'},
                {'name': 'Sample Item 2', 'qty': 1, 'price': 150.0, 'unit': 'PCS'},
              ],
              subtotal: 350.0,
              discount: 35.0,
              tax: 42.0,
              additionalCharges: [],
              additionalChargesTotal: 0.0,
              roundoff: 0.0,
              total: 357.0,
              invoiceNumber: '001',
              date: DateTime.now(),
              customerName: 'Sample Customer',
              customerPhone: '+91 98765 43210',
              notes: '',
              paymentType: 'Cash',
              amountReceived: 400.0,
              primaryColor: themeService.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showHandSignatureDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHandSignatureBottomSheet(),
    );
  }

  Widget _buildHandSignatureBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Create Your Signature',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DigitalSignatureConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Draw your signature below',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Signature area
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: DigitalSignatureConstants.borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _signatureController.clear();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: DigitalSignatureConstants.primaryColor),
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: DigitalSignatureConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveHandSignature,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DigitalSignatureConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Save Signature',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveHandSignature() async {
    if (_signatureController.isNotEmpty) {
      final signature = await _signatureController.toPngBytes();
      if (signature != null) {
        final signatureService = Provider.of<DigitalSignatureService>(context, listen: false);
        await signatureService.updateSignature(signature, 'hand');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signature saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw a signature first'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _importFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        
        final signatureService = Provider.of<DigitalSignatureService>(context, listen: false);
        await signatureService.updateSignature(imageBytes, 'camera');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signature imported from camera successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing from camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        
        final signatureService = Provider.of<DigitalSignatureService>(context, listen: false);
        await signatureService.updateSignature(imageBytes, 'gallery');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signature imported from gallery successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing from gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRemoveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Signature'),
        content: const Text('Are you sure you want to remove your digital signature?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final signatureService = Provider.of<DigitalSignatureService>(context, listen: false);
              await signatureService.removeSignature();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signature removed successfully'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
