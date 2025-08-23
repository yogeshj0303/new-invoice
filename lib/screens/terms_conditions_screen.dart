import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/terms_service.dart';
import '../services/theme_service.dart';
import '../services/contact_service.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  List<String> currentTerms = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with terms service data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final termsService = Provider.of<TermsService>(context, listen: false);
      termsService.initialize().then((_) {
        setState(() {
          currentTerms = List.from(termsService.terms);
        });
      });
    });
  }

  void _showTermsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TermsBottomSheet(
        currentTerms: currentTerms,
        onTermsUpdated: (newTerms) {
          setState(() {
            currentTerms = newTerms;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<TermsService, ThemeService, ContactService>(
      builder: (context, termsService, themeService, contactService, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: themeService.primaryColor, size: 18),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ),
            title: Text(
              'Terms & Conditions',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: GoogleFonts.openSans().fontFamily,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: Colors.grey[200]),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Template Preview Section
                        Text(
                          'Template Preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: GoogleFonts.openSans().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Invoice Template Preview with Terms
                        Center(
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 3.0,
                            child: Container(
                              width: 400,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header (simplified for preview)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(3),
                                        topRight: Radius.circular(3),
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      color: themeService.primaryColor,
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                    child: const Icon(
                                                      Icons.business,
                                                      color: Colors.white,
                                                      size: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        contactService.companyName,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: themeService.primaryColor,
                                                          letterSpacing: 0.2,
                                                        ),
                                                      ),
                                                      Text(
                                                        contactService.companyDescription,
                                                        style: TextStyle(
                                                          fontSize: 7,
                                                          color: Colors.grey[700],
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Invoice details placeholder
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(2),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Invoice No.',
                                                style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const Text(
                                                'INV-001',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2E3085),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Terms & Conditions Section
                                  if (currentTerms.isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey[300]!,
                                            width: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Terms & Conditions:',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          ...currentTerms.map((term) => Padding(
                                            padding: const EdgeInsets.only(bottom: 1),
                                            child: Text(
                                              term,
                                              style: TextStyle(
                                                fontSize: 6,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          )).toList(),
                                        ],
                                      ),
                                    ),

                                  // Footer
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(3),
                                        bottomRight: Radius.circular(3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Thank you for your business!',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2E3085),
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                contactService.companyName,
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Current Terms Display
                        Text(
                          'Current Terms & Conditions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: GoogleFonts.openSans().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: currentTerms.isEmpty
                              ? Text(
                                  'No terms and conditions set. Click "Customize Terms" to add some.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...currentTerms.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final term = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${index + 1}. ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: themeService.primaryColor,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                term,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Customize Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showTermsBottomSheet,
                            icon: const Icon(Icons.edit),
                            label: const Text('Customize Terms & Conditions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeService.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              
                              try {
                                await termsService.updateTerms(currentTerms);
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Terms & conditions saved successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                  // Navigate back after a short delay to show the SnackBar
                                  Future.delayed(const Duration(milliseconds: 1500), () {
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  });
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error saving terms: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeService.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TermsBottomSheet extends StatefulWidget {
  final List<String> currentTerms;
  final Function(List<String>) onTermsUpdated;

  const _TermsBottomSheet({
    required this.currentTerms,
    required this.onTermsUpdated,
  });

  @override
  State<_TermsBottomSheet> createState() => _TermsBottomSheetState();
}

class _TermsBottomSheetState extends State<_TermsBottomSheet> {
  late List<String> editableTerms;
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    editableTerms = List.from(widget.currentTerms);
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers.clear();
    for (String term in editableTerms) {
      _controllers.add(TextEditingController(text: term));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewTerm() {
    setState(() {
      editableTerms.add('');
      _controllers.add(TextEditingController());
    });
  }

  void _removeTerm(int index) {
    if (editableTerms.length > 1) {
      setState(() {
        editableTerms.removeAt(index);
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  void _updateTerm(int index, String value) {
    setState(() {
      editableTerms[index] = value;
    });
  }

  void _applyChanges() {
    final validTerms = editableTerms
        .where((term) => term.trim().isNotEmpty)
        .map((term) => term.trim())
        .toList();
    
    widget.onTermsUpdated(validTerms);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customize Terms & Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: GoogleFonts.openSans().fontFamily,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Quick Presets
              Text(
                'Quick Presets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TermsService.termsPresets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final preset = entry.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        editableTerms = List.from(preset);
                        _initializeControllers();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeService.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: themeService.primaryColor),
                      ),
                      child: Text(
                        'Preset ${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeService.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Custom Terms Editor
              Text(
                'Custom Terms',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Terms List
              ...editableTerms.asMap().entries.map((entry) {
                final index = entry.key;
                final term = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            labelText: 'Term ${index + 1}',
                            hintText: 'Enter term and condition',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: themeService.primaryColor, width: 2),
                            ),
                          ),
                          onChanged: (value) => _updateTerm(index, value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeTerm(index),
                        icon: Icon(Icons.remove_circle, color: Colors.red[400]),
                        tooltip: 'Remove term',
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              // Add New Term Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addNewTerm,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Term'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeService.primaryColor,
                    side: BorderSide(color: themeService.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeService.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
