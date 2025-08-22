import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calculator_screen.dart';
import '../services/api_service.dart';
import '../models/transaction.dart';
import '../constants/api_constants.dart';

// Placeholder for other screens
class HomeDashboard extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const HomeDashboard({super.key, required this.onThemeToggle});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);
  
  // Transaction data
  List<Transaction> _transactions = [];
  bool _isLoadingTransactions = false;
  String? _transactionError;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
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
          _transactions = result['transactions'] ?? [];
          _isLoadingTransactions = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: GestureDetector(
            onTap: () => _showBusinessBottomSheet(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BusinessName',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.1,
                    color: primaryColor,
                    fontFamily:
                        GoogleFonts.openSansTextTheme(
                          Theme.of(context).textTheme,
                        ).bodyMedium?.fontFamily,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: primaryColor, size: 20),
              ],
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalculatorScreen()),
              ),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.calculate, color: primaryColor, size: 22),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/invite-earn'),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.card_giftcard, color: primaryColor, size: 22),
              ),
            ),
            GestureDetector(
              onTap: () => _showContactUsDialog(context),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.contact_support,
                  color: primaryColor,
                  size: 22,
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
        onRefresh: _loadTransactions,
        color: primaryColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Trial Expiration Banner ---
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/subscription');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      // Star icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.star,
                          color: Colors.amber[700],
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      // Main content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Your Free Trial is expired',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '0 Days Left',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Your Trial has expired, You cannot create any documents. Please subscribe for unlimited use.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // --- Top Row Cards Section (Invoices, Purchase) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TopRowCard(
                    icon: Icons.receipt_long,
                    title: 'Invoices',
                    color: Color(0xFFFF6B35), // Vibrant orange background
                    onTap:
                        () => Navigator.pushNamed(context, '/create-invoice'),
                  ),
                  SizedBox(width: 16), // Consistent spacing
                  _TopRowCard(
                    icon: Icons.shopping_cart,
                    title: 'Purchase',
                    color: Color(0xFF4CAF50), // Vibrant green background
                    onTap: () => Navigator.pushNamed(context, '/purchase'),
                  ),
                ],
              ),
              SizedBox(height: 18),

              // --- Dashboard Cards Section (2x2 grid) ---
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.3,
                children: [
                  // To Collect Card (Green)
                  _CompactDashboardCard(
                    icon: null,
                    title: '',
                    value: _getTotalToCollect(),
                    color: Colors.green[100]!,
                    subtitle: 'To Collect',
                    small: true,
                    rightArrow: true,
                    valueColor: Colors.green[900],
                    showArrow: true,
                    arrowDirection: 'down',
                    primaryColor: primaryColor,
                  ),
                  // This week's sale Card (Blue Theme)
                  _CompactDashboardCard(
                    icon: null,
                    title: '',
                    value: _getWeeklySales(),
                    color: Color(0xFFE3F2FD), // Light blue background
                    subtitle: "This week's sale",
                    small: true,
                    rightArrow: true,
                    valueColor: Color(0xFF1565C0), // Dark blue text
                    primaryColor: Color(0xFF1565C0),
                  ),
                  // Total Balance Card (Purple Theme)
                  _CompactDashboardCard(
                    icon: null,
                    title: '',
                    value: _getTotalBalance(),
                    color: Color(0xFFF3E5F5), // Light purple background
                    subtitle: 'Cash + Bank Balance',
                    small: true,
                    rightArrow: true,
                    valueColor: Color(0xFF7B1FA2), // Dark purple text
                    primaryColor: Color(0xFF7B1FA2),
                  ),
                  // Reports Card (Teal Theme)
                  _CompactDashboardCard(
                    icon: null,
                    title: '',
                    value: 'Reports',
                    color: Color(0xFFE0F2F1), // Light teal background
                    subtitle: 'Sales, Party, GST...',
                    small: true,
                    rightArrow: true,
                    valueColor: Color(0xFF00695C), // Dark teal text
                    primaryColor: Color(0xFF00695C),
                  ),
                ],
              ),
              SizedBox(height: 18),

              // Transactions Section Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'LAST 365 DAYS',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: _loadTransactions,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: primaryColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Transactions List
              _buildTransactionsList(isTablet),
            ],
          ),
        ),
        ),
      ),
    );
  }

  // Calculate weekly sales from transactions
  String _getWeeklySales() {
    if (_transactions.isEmpty) return '₹ 0';
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    double totalSales = 0;
    for (final transaction in _transactions) {
      try {
        final transactionDate = DateTime.parse(transaction.date);
        if (transactionDate.isAfter(weekStart.subtract(Duration(days: 1))) && 
            transactionDate.isBefore(weekEnd.add(Duration(days: 1)))) {
          totalSales += double.tryParse(transaction.invoice.totalAmount) ?? 0;
        }
      } catch (e) {
        // Skip invalid dates
        continue;
      }
    }
    
    return '₹ ${totalSales.toStringAsFixed(0)}';
  }

  // Calculate total amount to collect from transactions
  String _getTotalToCollect() {
    if (_transactions.isEmpty) return '₹ 0';
    
    double totalToCollect = 0;
    for (final transaction in _transactions) {
      if (transaction.status.toLowerCase() == 'unpaid' || 
          transaction.status.toLowerCase() == 'overdue') {
        totalToCollect += double.tryParse(transaction.invoice.totalAmount) ?? 0;
      }
    }
    
    return '₹ ${totalToCollect.toStringAsFixed(0)}';
  }

  // Calculate total balance from transactions
  String _getTotalBalance() {
    if (_transactions.isEmpty) return '₹ 0';
    
    double totalBalance = 0;
    for (final transaction in _transactions) {
      if (transaction.status.toLowerCase() == 'paid') {
        totalBalance += double.tryParse(transaction.invoice.amountReceived) ?? 0;
      }
    }
    
    return '₹ ${totalBalance.toStringAsFixed(0)}';
  }

  // Build transactions list
  Widget _buildTransactionsList(bool isTablet) {
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

    if (_transactions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: Colors.grey[400],
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'No transactions found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your transactions will appear here once you create invoices',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _transactions.take(5).map((transaction) {
        return Column(
          children: [
            _TransactionItem(
              transaction: transaction,
              isTablet: isTablet,
            ),
            SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  void _showBusinessBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BusinessBottomSheet(),
    );
  }

  void _showContactUsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Talk To Our Expert',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Description text
                Text(
                  'Need help getting started or have questions about features, setup, or business support?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20),
                // Speak With Expert option
                _ContactOption(
                  icon: Icons.phone,
                  title: 'Speak With Expert',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Implement phone call functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling expert...')),
                    );
                  },
                ),
                SizedBox(height: 12),
                // Chat With Expert option
                _ContactOption(
                  icon: Icons.chat,
                  title: 'Chat With Expert',
                  isWhatsApp: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Implement WhatsApp chat functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening WhatsApp chat...')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}

// Update _CompactDashboardCard to support arrow indicators
class _TopRowCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _TopRowCard({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  State<_TopRowCard> createState() => _TopRowCardState();
}

class _TopRowCardState extends State<_TopRowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width:
                  MediaQuery.of(context).size.width *
                  0.44, // Slightly wider for better proportions
              height: 110, // Slightly shorter for better proportions
              decoration: BoxDecoration(
                color: Colors.white, // Clean white background
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.12 : 0.08),
                    blurRadius: _isPressed ? 24 : 20,
                    offset: Offset(0, _isPressed ? 6 : 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.06 : 0.04),
                    blurRadius: _isPressed ? 10 : 8,
                    offset: Offset(0, _isPressed ? 3 : 2),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(_isPressed ? 0.18 : 0.12),
                  width: _isPressed ? 1.2 : 1,
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular icon container with professional styling
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [widget.color, widget.color.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(
                            _isPressed ? 0.35 : 0.25,
                          ),
                          blurRadius: _isPressed ? 10 : 8,
                          offset: Offset(0, _isPressed ? 3 : 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),

                  // Title and arrow in same row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title text with professional styling
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            letterSpacing: 0.2,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Professional arrow indicator
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[_isPressed ? 150 : 100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey[_isPressed ? 700 : 600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactDashboardCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String value;
  final Color color;
  final String? subtitle;
  final bool small;
  final bool rightArrow;
  final Color? valueColor;
  final bool showArrow;
  final String arrowDirection;
  final Color primaryColor;
  final bool showIcon;

  const _CompactDashboardCard({
    this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
    this.small = false,
    this.rightArrow = false,
    this.valueColor,
    this.showArrow = false,
    this.arrowDirection = 'down',
    required this.primaryColor,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final double valueSize = small ? 15 : 18;
    final double subtitleSize = small ? 10 : 12;
    final double paddingV = small ? 10 : 16;
    final double paddingH = small ? 10 : 16;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1.2),
      ),
      padding: EdgeInsets.symmetric(vertical: paddingV, horizontal: paddingH),
      constraints: BoxConstraints(minHeight: 72),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon && icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? color,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: subtitleSize,
                          fontWeight:
                              (subtitle == 'To Collect' || subtitle == 'To Pay')
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                          color:
                              subtitle == 'To Collect'
                                  ? Colors.green[700]
                                  : subtitle == 'To Pay'
                                  ? Colors.red[700]
                                  : valueColor?.withOpacity(0.8) ??
                                      primaryColor.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showArrow) ...[
                        SizedBox(width: 4),
                        Icon(
                          arrowDirection == 'down'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 12,
                          color:
                              subtitle == 'To Collect'
                                  ? Colors.green[700]
                                  : Colors.red[700],
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (rightArrow)
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
        ],
      ),
    );
  }
}

class _BusinessBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Change Business',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
          // Instructional text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Choose the business you want to see the data',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 12),
          // Business list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        'B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Business Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to edit business
                    },
                    child: Text(
                      'EDIT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E3085),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          // Add new business button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF2E3085),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Add New Business',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isWhatsApp;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isWhatsApp = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              child:
                  isWhatsApp
                      ? Icon(Icons.message, color: Colors.green[600], size: 20)
                      : Icon(icon, color: Colors.black87, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New widget for invoice transaction items
class _InvoiceTransactionItem extends StatelessWidget {
  final String customerName;
  final String invoiceNumber;
  final String dueDate;
  final String amount;
  final String status;
  final bool isTablet;

  const _InvoiceTransactionItem({
    required this.customerName,
    required this.invoiceNumber,
    required this.dueDate,
    required this.amount,
    required this.status,
    required this.isTablet,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer name
          Text(
            customerName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          // Invoice details and amount/status row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoiceNumber,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 2),
                    Text(
                      dueDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          // Action buttons - only show if transaction is not paid
          if (status.toLowerCase() != 'paid') ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Handle Record Manually action
                    },
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Record Manually',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Handle Share Payment Link action
                    },
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message, size: 14, color: Colors.green[600]),
                          SizedBox(width: 4),
                          Text(
                            'Share Payment Link',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// New widget for transaction items using API data
class _TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final bool isTablet;

  const _TransactionItem({
    required this.transaction,
    required this.isTablet,
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer name
          Text(
            transaction.customerName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
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
                    SizedBox(height: 8),
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      transaction.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(transaction.status),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          // Action buttons - only show if transaction is not paid
          if (transaction.status.toLowerCase() != 'paid') ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Handle Record Manually action
                    },
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Record Manually',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Handle Share Payment Link action
                    },
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message, size: 14, color: Colors.green[600]),
                          SizedBox(width: 4),
                          Text(
                            'Share Payment Link',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
