import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../models/subscription.dart';
import '../models/coupon.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with TickerProviderStateMixin {
  int selectedPlanIndex = 0;
  late AnimationController _pageController;
  late AnimationController _buttonController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  // API data
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Coupon functionality
  Coupon? _appliedCoupon;
  final TextEditingController _manualCouponController = TextEditingController();
  
  // Available coupons from API
  List<Coupon> _availableCoupons = [];
  bool _isLoadingCoupons = false;

  // Convert API subscriptions to UI plans
  List<SubscriptionPlan> get plans {
    if (_subscriptions.isEmpty) {
      // Fallback to default plans if API fails
      return [
        SubscriptionPlan(
          name: 'Basic',
          monthlyPrice: 99,
          isSelected: true,
          color: const Color(0xFF6B7280),
          gradient: [const Color(0xFF6B7280), const Color(0xFF9CA3AF)],
        ),
        SubscriptionPlan(
          name: 'Advanced',
          monthlyPrice: 199,
          isSelected: false,
          color: const Color(0xFF3B82F6),
          gradient: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
        ),
        SubscriptionPlan(
          name: 'Enterprise',
          monthlyPrice: 399,
          isSelected: false,
          isEnterprise: true,
          color: const Color(0xFF059669),
          gradient: [const Color(0xFF059669), const Color(0xFF10B981)],
        ),
      ];
    }

    return _subscriptions.asMap().entries.map((entry) {
      final index = entry.key;
      final subscription = entry.value;
      
      // Define colors based on plan name
      Color color;
      List<Color> gradient;
      
      switch (subscription.planName.toLowerCase()) {
        case 'basic':
          color = const Color(0xFF6B7280);
          gradient = [const Color(0xFF6B7280), const Color(0xFF9CA3AF)];
          break;
        case 'advanced':
          color = const Color(0xFF3B82F6);
          gradient = [const Color(0xFF3B82F6), const Color(0xFF60A5FA)];
          break;
        case 'enterprise':
          color = const Color(0xFF059669);
          gradient = [const Color(0xFF059669), const Color(0xFF10B981)];
          break;
        default:
          color = const Color(0xFF6B7280);
          gradient = [const Color(0xFF6B7280), const Color(0xFF9CA3AF)];
      }

      return SubscriptionPlan(
        name: subscription.planName,
        monthlyPrice: subscription.priceAsDouble.toInt(),
        isSelected: index == selectedPlanIndex,
        isEnterprise: subscription.planName.toLowerCase() == 'enterprise',
        color: color,
        gradient: gradient,
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.elasticOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _pageController.forward();
    _staggerController.forward();
    
    // Fetch subscriptions from API
    _fetchSubscriptions();
    
    // Fetch available coupons from API
    _fetchAvailableCoupons();
  }

  // Fetch subscriptions from API
  Future<void> _fetchSubscriptions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await ApiService.getSubscriptions();
      
      if (result['success'] == true) {
        setState(() {
          _subscriptions = List<Subscription>.from(result['subscriptions']);
          _isLoading = false;
        });
        
        // Debug: Print loaded subscriptions
        print('✅ [DEBUG] Loaded ${_subscriptions.length} subscriptions:');
        for (var sub in _subscriptions) {
          print('   - ${sub.planName}: ₹${sub.planPrice}/month (${sub.planDescription})');
        }
        
        // Show success message if subscriptions were loaded
        if (_subscriptions.isNotEmpty) {
          _showSubscriptionsLoadedMessage();
        }
      } else {
        setState(() {
          _errorMessage = result[ApiConstants.messageKey] ?? 'Failed to fetch subscriptions';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showSubscriptionsLoadedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_subscriptions.length} subscription plans loaded successfully!',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Fetch available coupons from API
  Future<void> _fetchAvailableCoupons() async {
    try {
      setState(() {
        _isLoadingCoupons = true;
      });

      final result = await ApiService.getAvailableCoupons();
      
      if (result['success'] == true) {
        setState(() {
          _availableCoupons = List<Coupon>.from(result['coupons']);
          _isLoadingCoupons = false;
        });
        
        // Debug: Print loaded coupons
        if (_availableCoupons.isNotEmpty) {
          print('✅ [DEBUG] Loaded ${_availableCoupons.length} available coupons:');
          for (var coupon in _availableCoupons) {
            print('   - ${coupon.couponCode}: ${coupon.discount}% off');
          }
        } else {
          print('ℹ️ [INFO] No coupons available at the moment');
        }
      } else {
        setState(() {
          _isLoadingCoupons = false;
        });
        print('❌ [ERROR] Failed to fetch coupons: ${result['message']}');
      }
    } catch (e) {
      setState(() {
        _isLoadingCoupons = false;
      });
      print('❌ [ERROR] Network error fetching coupons: ${e.toString()}');
    }
  }

  // Apply coupon directly from the available coupons list
  void _applyCouponDirectly(Coupon coupon) {
    setState(() {
      _appliedCoupon = coupon;
    });
    
    Navigator.pop(context);
    _showCouponAppliedSnackBar();
  }

  // Validate and apply coupon manually
  Future<void> _validateAndApplyCoupon(String couponCode) async {
    if (couponCode.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a coupon code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = await ApiService.validateCoupon(couponCode.trim());
      
      if (result['success'] == true && result['coupon'] != null) {
        setState(() {
          _appliedCoupon = result['coupon'] as Coupon;
        });
        
        _showCouponAppliedSnackBar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result[ApiConstants.messageKey] ?? 'Invalid coupon code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  void _handleSubscription() {
    if (_subscriptions.isNotEmpty && selectedPlanIndex < _subscriptions.length) {
      final selectedSubscription = _subscriptions[selectedPlanIndex];
      
      // Show subscription confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Subscribe to ${selectedSubscription.planName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are about to subscribe to the ${selectedSubscription.planName} plan.'),
              const SizedBox(height: 8),
              Text(
                'Price: ₹${selectedSubscription.planPrice}/month',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Features: ${selectedSubscription.planDescription}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processSubscription(selectedSubscription);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Subscribe'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid plan to subscribe'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _processSubscription(Subscription subscription) {
    // TODO: Implement actual subscription logic
    // This would typically involve calling a payment gateway or subscription API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscription to ${subscription.planName} plan initiated!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonController.dispose();
    _staggerController.dispose();
    _manualCouponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: _fetchSubscriptions,
            color: plans.isNotEmpty ? plans[0].color : const Color(0xFF3B82F6),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildPlanSelector(),
                  const SizedBox(height: 12),
                  _buildCurrentPlanCard(),
                  const SizedBox(height: 8),
                  _buildCouponCard(),
                  const SizedBox(height: 12),
                  _buildFeaturesList(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      toolbarHeight: 48,
       leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 16,
              color: Color(0xFF1F2937), 
            ),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(32, 32),
            ),
          ),
        ),
      title: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 15 * (1 - _fadeAnimation.value)),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                'Business Subscription Plans',
                style: TextStyle(
                  color: const Color(0xFF1F2937),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: GoogleFonts.openSans().fontFamily,
                ),
              ),
            ),
          );
        },
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh,
            size: 20,
            color: const Color(0xFF1F2937),
          ),
          onPressed: _fetchSubscriptions,
          tooltip: 'Refresh plans',
        ),
      ],
    );
  }

  Widget _buildPlanSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - _staggerController.value)),
                child: Opacity(
                  opacity: _staggerController.value,
                  child: const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 15 * (1 - _staggerController.value)),
                child: Opacity(
                  opacity: _staggerController.value,
                  child: Text(
                    'Select the perfect plan for your business needs',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          
          // Show loading or error state
          if (_isLoading)
            _buildLoadingState()
          else if (_errorMessage != null)
            _buildErrorState()
          else
            _buildPlansList(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                plans.isNotEmpty ? plans[0].color : const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading plans...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Failed to load plans',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _fetchSubscriptions,
              child: Text(
                'Retry',
                style: TextStyle(
                  color: plans.isNotEmpty ? plans[0].color : const Color(0xFF3B82F6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final delay = index * 0.08;
          final animation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: _staggerController,
            curve: Interval(delay, delay + 0.25, curve: Curves.easeOutCubic),
          ));

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.85 + (0.15 * animation.value),
                child: Opacity(
                  opacity: animation.value,
                  child: Container(
                    width: 110,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 6,
                      right: index == plans.length - 1 ? 0 : 6,
                    ),
                    child: _buildPlanCard(index),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = plans[index];
    final isSelected = selectedPlanIndex == index;
    
    // Get subscription data if available
    Subscription? subscription;
    if (_subscriptions.isNotEmpty && index < _subscriptions.length) {
      subscription = _subscriptions[index];
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
          for (int i = 0; i < plans.length; i++) {
            plans[i].isSelected = i == index;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: plan.gradient,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? plan.color.withOpacity(0.25)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isSelected ? 15 : 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: isSelected
              ? null
              : Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Plan name
              Text(
                plan.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Price
              Text(
                '₹${plan.monthlyPrice}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              // Per month text
              Text(
                '/month',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
        ));

        return Transform.translate(
          offset: Offset(0, 15 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.08),
                    const Color(0xFF059669).withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1F2937),
                          height: 1.3,
                        ),
                        children: [
                          const TextSpan(text: 'You are currently on the '),
                          TextSpan(
                            text: 'Act T Connect GST Invoice Free Plan',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF059669),
                            ),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: 'Learn More',
                            style: TextStyle(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCouponCard() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
        ));

        return Transform.translate(
          offset: Offset(0, 15 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: GestureDetector(
              onTap: () => _showCouponBottomSheet(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _appliedCoupon != null 
                      ? const Color(0xFF10B981).withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: _appliedCoupon != null
                      ? Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 1)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: _appliedCoupon != null
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: _appliedCoupon != null ? 12 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _appliedCoupon != null
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _appliedCoupon != null ? Icons.check_circle : Icons.percent,
                        color: _appliedCoupon != null 
                            ? const Color(0xFF10B981)
                            : const Color(0xFF3B82F6),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                                         Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             _appliedCoupon != null 
                                 ? 'Coupon Applied'
                                 : 'Apply Coupon Code',
                             style: TextStyle(
                               fontSize: 13,
                               fontWeight: FontWeight.w600,
                               color: _appliedCoupon != null
                                   ? const Color(0xFF10B981)
                                   : const Color(0xFF1F2937),
                             ),
                           ),
                           if (_appliedCoupon != null) ...[
                             const SizedBox(height: 2),
                             Text(
                               '${_appliedCoupon!.couponCode} - ${_appliedCoupon!.discount}% off',
                               style: TextStyle(
                                 fontSize: 11,
                                 color: const Color(0xFF10B981),
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ] else if (_isLoadingCoupons) ...[
                             const SizedBox(height: 2),
                             Text(
                               'Loading coupons...',
                               style: TextStyle(
                                 fontSize: 11,
                                 color: Colors.grey[500],
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                                                       ] else if (_availableCoupons.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${_availableCoupons.length} coupons available',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 2),
                              Text(
                                'No coupons available',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                         ],
                       ),
                     ),
                    if (_appliedCoupon != null)
                      GestureDetector(
                        onTap: _removeCoupon,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.red[400],
                            size: 14,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[600],
                          size: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCouponBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder: (context) => _buildCouponBottomSheet(),
    );
  }

    Widget _buildCouponBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'Enter Coupon Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          
          // Subtitle
          Text(
            'Enter your coupon code to get exclusive discounts',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Manual coupon input field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualCouponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    onSubmitted: (value) => _validateAndApplyCoupon(value),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    _validateAndApplyCoupon(_manualCouponController.text);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: plans[selectedPlanIndex].color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Close button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }



  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon removed successfully'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Calculate discounted price
  int _getDiscountedPrice() {
    final originalPrice = plans[selectedPlanIndex].monthlyPrice * 12;
    if (_appliedCoupon != null) {
      final discount = _appliedCoupon!.discountAsDouble;
      final discountedPrice = originalPrice - (originalPrice * discount / 100);
      return discountedPrice.round();
    }
    return originalPrice;
  }

  void _showCouponAppliedSnackBar() {
    if (_appliedCoupon != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Coupon ${_appliedCoupon!.couponCode} applied! ${_appliedCoupon!.discount}% discount',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildFeaturesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              final animation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _staggerController,
                curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
              ));

              return Transform.translate(
                offset: Offset(0, 15 * (1 - animation.value)),
                child: Opacity(
                  opacity: animation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Plan Features',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (_subscriptions.isNotEmpty && selectedPlanIndex < _subscriptions.length)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: plans[selectedPlanIndex].color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: plans[selectedPlanIndex].color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _subscriptions[selectedPlanIndex].planName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: plans[selectedPlanIndex].color,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          
          // Show features based on selected plan
          if (_subscriptions.isNotEmpty && selectedPlanIndex < _subscriptions.length)
            _buildSelectedPlanFeatures(_subscriptions[selectedPlanIndex])
          else
            _buildDefaultFeatures(),
        ],
      ),
    );
  }

  Widget _buildSelectedPlanFeatures(Subscription subscription) {
    final features = [
      {
        'icon': Icons.receipt_long,
        'title': 'Invoice Limit',
        'value': subscription.invoiceAddCount == 'unlimited' 
            ? 'Unlimited invoices/month' 
            : '${subscription.invoiceAddCount} invoices/month',
        'highlight': true,
      },
      {
        'icon': Icons.business,
        'title': 'Businesses',
        'value': subscription.businessAddCount == 'unlimited' 
            ? 'Unlimited businesses' 
            : '${subscription.businessAddCount} business${subscription.businessAddCount != '1' ? 'es' : ''}',
        'highlight': false,
      },
      {
        'icon': Icons.people,
        'title': 'Users',
        'value': subscription.userAddCount == 'unlimited' 
            ? 'Unlimited users' 
            : '${subscription.userAddCount} user${subscription.userAddCount != '1' ? 's' : ''}',
        'highlight': false,
      },
      {
        'icon': Icons.schedule,
        'title': 'Plan Validity',
        'value': subscription.planValidity == 'unlimited' 
            ? 'Unlimited' 
            : '${subscription.planValidity} days',
        'highlight': false,
      },
      {
        'icon': Icons.verified,
        'title': 'Plan Status',
        'value': subscription.planStatus.toUpperCase(),
        'highlight': false,
      },
      {
        'icon': Icons.description,
        'title': 'Plan Description',
        'value': subscription.planDescription,
        'highlight': false,
      },
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        final delay = 0.6 + (index * 0.05);
        
        return AnimatedBuilder(
          animation: _staggerController,
          builder: (context, child) {
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _staggerController,
              curve: Interval(delay, (delay + 0.15).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
            ));

            return Transform.translate(
              offset: Offset(0, 20 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: _buildFeatureItem(
                  icon: feature['icon'] as IconData,
                  title: feature['title'] as String,
                  description: feature['value'] as String,
                  showInfo: false,
                  isHighlighted: feature['highlight'] as bool,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildDefaultFeatures() {
    final defaultFeatures = [
      {
        'icon': Icons.receipt_long,
        'title': 'Invoice Limit',
        'description': 'Up to 100 invoices/month',
      },
      {
        'icon': Icons.business,
        'title': 'Businesses',
        'description': '1 business account',
      },
      {
        'icon': Icons.people,
        'title': 'Users',
        'description': '1 user account',
      },
      {
        'icon': Icons.schedule,
        'title': 'Plan Validity',
        'description': '30 days',
      },
      {
        'icon': Icons.description,
        'title': 'Features',
        'description': 'Basic CRM features',
      },
    ];

    return Column(
      children: defaultFeatures.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        final delay = 0.6 + (index * 0.05);
        
        return AnimatedBuilder(
          animation: _staggerController,
          builder: (context, child) {
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _staggerController,
              curve: Interval(delay, (delay + 0.15).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
            ));

            return Transform.translate(
              offset: Offset(0, 20 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: _buildFeatureItem(
                  icon: feature['icon'] as IconData,
                  title: feature['title'] as String,
                  description: feature['description'] as String,
                  showInfo: false,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }



    Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    bool showInfo = false,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF10B981).withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted ? Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: isHighlighted 
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.black.withOpacity(0.03),
            blurRadius: isHighlighted ? 8 : 6,
            offset: Offset(0, isHighlighted ? 2 : 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isHighlighted ? [
                  const Color(0xFF10B981).withOpacity(0.15),
                  const Color(0xFF059669).withOpacity(0.10),
                ] : [
                  const Color(0xFF3B82F6).withOpacity(0.12),
                  const Color(0xFF1D4ED8).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
                          child: Icon(
              icon,
              color: isHighlighted ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
              size: 16,
            ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isHighlighted ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                    height: 1.2,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
             padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _staggerController,
          builder: (context, child) {
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _staggerController,
              curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
            ));

            return Transform.translate(
              offset: Offset(0, 20 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${_getDiscountedPrice()} /year',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              if (_appliedCoupon != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '₹${plans[selectedPlanIndex].monthlyPrice * 12}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            'Billed annually',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_appliedCoupon != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${_appliedCoupon!.discount}% off with ${_appliedCoupon!.couponCode}',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _buttonScaleAnimation,
                          child: GestureDetector(
                            onTapDown: (_) => _buttonController.forward(),
                            onTapUp: (_) => _buttonController.reverse(),
                            onTapCancel: () => _buttonController.reverse(),
                            onTap: _isLoading ? null : _handleSubscription,
                            child: Container(
                              width: 140,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: plans[selectedPlanIndex].gradient,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: plans[selectedPlanIndex].color.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Subscribe Now',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(height: 6),
                        // Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     Container(
                        //       width: 16,
                        //       height: 16,
                        //       decoration: BoxDecoration(
                        //         gradient: LinearGradient(
                        //           begin: Alignment.topLeft,
                        //           end: Alignment.bottomRight,
                        //           colors: [
                        //             const Color(0xFF10B981),
                        //             const Color(0xFF059669),
                        //           ],
                        //         ),
                        //         shape: BoxShape.circle,
                        //       ),
                        //       child: const Center(
                        //         child: Text(
                        //           '100%',
                        //           style: TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 8,
                        //             fontWeight: FontWeight.w800,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     // const SizedBox(width: 6),
                        //     // RichText(
                        //     //   text: TextSpan(
                        //     //     style: TextStyle(
                        //     //       fontSize: 10,
                        //     //       color: Colors.grey[600],
                        //     //     ),
                        //     //     children: [
                        //     //       const TextSpan(text: '7 days moneyback guarantee '),
                        //     //       TextSpan(
                        //     //         text: 'Read Policy',
                        //     //         style: TextStyle(
                        //     //           color: const Color(0xFF10B981),
                        //     //           fontWeight: FontWeight.w600,
                        //     //         ),
                        //     //       ),
                        //     //     ],
                        //     //   ),
                        //     // ),
                        //   ],
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SubscriptionPlan {
  final String name;
  final int monthlyPrice;
  bool isSelected;
  final bool isEnterprise;
  final Color color;
  final List<Color> gradient;

  SubscriptionPlan({
    required this.name,
    required this.monthlyPrice,
    required this.isSelected,
    this.isEnterprise = false,
    required this.color,
    required this.gradient,
  });
} 