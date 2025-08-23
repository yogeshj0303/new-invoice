import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../models/business_profile.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);
  
  // Transaction data
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoadingTransactions = false;
  String? _transactionError;
  
  // Business profile data
  BusinessProfile? _businessProfile;
  bool _isLoadingBusinessProfile = false;
  String? _businessProfileError;

  // Search
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadBusinessProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load business profile from API
  Future<void> _loadBusinessProfile() async {
    setState(() {
      _isLoadingBusinessProfile = true;
      _businessProfileError = null;
    });

    try {
      final result = await ApiService.getBusinessProfile();
      
      if (result['success'] == true) {
        setState(() {
          _businessProfile = result['businessProfile'];
          _isLoadingBusinessProfile = false;
        });
      } else {
        setState(() {
          _businessProfileError = result[ApiConstants.messageKey] ?? 'Failed to load business profile';
          _isLoadingBusinessProfile = false;
        });
      }
    } catch (e) {
      setState(() {
        _businessProfileError = 'Error loading business profile: $e';
        _isLoadingBusinessProfile = false;
      });
    }
  }

  // Load transactions from API
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoadingTransactions = true;
      _transactionError = null;
    });

    try {
      final result = await ApiService.getTransactions();
      
      if (result['success'] == true) {
        setState(() {
          _allTransactions = result['transactions'] ?? [];
          _filteredTransactions = List.from(_allTransactions);
          _isLoadingTransactions = false;
        });
        _applyFilters();
      } else {
        setState(() {
          _transactionError = result[ApiConstants.messageKey] ?? 'Failed to load transactions';
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      setState(() {
        _transactionError = 'Error loading transactions: $e';
        _isLoadingTransactions = false;
      });
    }
  }

  // Apply search and sorting
  void _applyFilters() {
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        // Search filter
        if (_searchController.text.isNotEmpty) {
          final searchTerm = _searchController.text.toLowerCase();
          return transaction.customerName.toLowerCase().contains(searchTerm) ||
                 transaction.invoice.id.toString().toLowerCase().contains(searchTerm) ||
                 transaction.invoice.totalAmount.contains(searchTerm);
        }
        
        return true;
      }).toList();

      // Always sort by date with latest first
      _filteredTransactions.sort((a, b) {
        final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
        final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
        return dateB.compareTo(dateA); // Latest first
      });
    });
  }



  // Get business name to display
  String _getBusinessName() {
    if (_isLoadingBusinessProfile) {
      return 'Loading...';
    }
    if (_businessProfileError != null) {
      return 'Business Name';
    }
    if (_businessProfile != null && _businessProfile!.businessName.isNotEmpty) {
      final name = _businessProfile!.businessName;
      if (name.length > 20) {
        return '${name.substring(0, 17)}...';
      }
      return name;
    }
    return 'Business Name';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transactions',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: primaryColor,
                  fontFamily: GoogleFonts.openSansTextTheme(
                    Theme.of(context).textTheme,
                  ).bodyMedium?.fontFamily,
                ),
              ),
              if (_businessProfile != null)
                Text(
                  _getBusinessName(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
                     actions: [
             Container(
               margin: EdgeInsets.only(right: 8),
               child: Material(
                 color: Colors.transparent,
                 child: InkWell(
                   onTap: _loadTransactions,
                   borderRadius: BorderRadius.circular(8),
                   child: Container(
                     padding: EdgeInsets.all(10),
                     decoration: BoxDecoration(
                       color: primaryColor.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(
                         color: primaryColor.withOpacity(0.2),
                         width: 1,
                       ),
                     ),
                     child: Icon(
                       Icons.refresh_rounded,
                       color: primaryColor,
                       size: 20,
                     ),
                   ),
                 ),
               ),
             ),
           ],
          shape: null,
          flexibleSpace: Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.18),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadTransactions(),
            _loadBusinessProfile(),
          ]);
        },
        color: primaryColor,
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 12),
                  

                ],
              ),
            ),
            
            // Transactions List
            Expanded(
              child: _buildTransactionsList(),
            ),
          ],
        ),
      ),
    );
  }

  // Build transactions list
  Widget _buildTransactionsList() {
    if (_isLoadingTransactions) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: primaryColor),
              SizedBox(height: 16),
              Text(
                'Loading transactions...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_transactionError != null) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[400],
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to load transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                _transactionError!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTransactions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

          if (_filteredTransactions.isEmpty) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                                 Icon(
                   _searchController.text.isNotEmpty
                       ? Icons.search_off
                       : Icons.receipt_long_outlined,
                   color: Colors.grey[400],
                   size: 48,
                 ),
                 SizedBox(height: 16),
                 Text(
                   _searchController.text.isNotEmpty
                       ? 'No transactions match your search'
                       : 'No transactions found',
                   style: TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.w600,
                     color: Colors.grey[600],
                   ),
                 ),
                 SizedBox(height: 8),
                 Text(
                   _searchController.text.isNotEmpty
                       ? 'Try adjusting your search terms'
                       : 'Your transactions will appear here once you create invoices',
                   style: TextStyle(
                     fontSize: 14,
                     color: Colors.grey[500],
                   ),
                   textAlign: TextAlign.center,
                 ),
                 if (_searchController.text.isNotEmpty) ...[
                   SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () {
                       setState(() {
                         _searchController.clear();
                       });
                       _applyFilters();
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: primaryColor,
                       foregroundColor: Colors.white,
                     ),
                     child: Text('Clear Search'),
                   ),
                 ],
              ],
            ),
          ),
        );
      }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return Column(
          children: [
            _TransactionItem(
              transaction: transaction,
              isTablet: false,
              businessProfile: _businessProfile,
              onRefresh: _loadTransactions,
            ),
            SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

// Transaction item widget (reusing from dashboard)
class _TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final bool isTablet;
  final BusinessProfile? businessProfile;
  final VoidCallback onRefresh;

  const _TransactionItem({
    required this.transaction,
    required this.isTablet,
    this.businessProfile,
    required this.onRefresh,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green[700]!;
      case 'unpaid':
        return Colors.red[700]!;
      case 'overdue':
        return Colors.orange[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '${difference} day(s) ago';
      } else {
        return '${date.day} ${_getMonthName(date.month)}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              transaction: transaction,
              businessProfile: businessProfile,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer name and click indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.customerName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
              ],
            ),
            SizedBox(height: 8),
            
            // Invoice details and amount/status row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${transaction.invoice.id}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDate(transaction.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹ ${transaction.invoice.totalAmount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    PopupMenuButton<String>(
                      onSelected: (String newStatus) async {
                        final updatedTransaction = await ApiService.updateTransactionStatus(
                          transaction.id,
                          newStatus.toLowerCase(),
                        );
                        if (updatedTransaction['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Status updated to ${newStatus.toUpperCase()}')),
                          );
                          onRefresh();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update status: ${updatedTransaction['message'] ?? 'Unknown error'}')),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'paid',
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Paid'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'unpaid',
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red[700],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Unpaid'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'overdue',
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.orange[700],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Overdue'),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transaction.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getStatusColor(transaction.status).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              transaction.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _getStatusColor(transaction.status),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 12,
                              color: _getStatusColor(transaction.status),
                            ),
                          ],
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
    );
  }
}
