import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

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

  final List<SubscriptionPlan> plans = [
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonController.dispose();
    _staggerController.dispose();
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
           SizedBox(
             height: 100, // Increased from 80 to 100 for better spacing
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
                           width: 110, // Increased from 100 to 110 for better content display
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
           ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = plans[index];
    final isSelected = selectedPlanIndex == index;

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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
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
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.percent,
                        color: Color(0xFF3B82F6),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Apply Coupon Code',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
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
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
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
      child: SafeArea(
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
              'Apply Coupon Code',
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
            const SizedBox(height: 20),
            
            // Coupon input field
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Icon(
                    Icons.confirmation_number,
                    color: Colors.grey[400],
                    size: 18,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Apply button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: plans[selectedPlanIndex].gradient,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: plans[selectedPlanIndex].color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // TODO: Implement coupon validation logic
                    Navigator.pop(context);
                    _showCouponAppliedSnackBar();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Text(
                      'Apply Coupon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCouponAppliedSnackBar() {
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
            const Expanded(
              child: Text(
                'Coupon applied successfully!',
                style: TextStyle(
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
                  child: const Text(
                                         'Plan Features',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w700,
                       color: Color(0xFF1F2937),
                     ),
                  ),
                ),
              );
            },
          ),
                     const SizedBox(height: 12),
                     ...List.generate(5, (index) {
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
                       icon: _getFeatureIcon(index),
                       title: _getFeatureTitle(index),
                       description: _getFeatureDescription(index),
                       showInfo: false,
                     ),
                   ),
                 );
               },
             );
           }),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(int index) {
    switch (index) {
      case 0:
        return Icons.star_border;
      case 1:
        return Icons.star_half;
      case 2:
        return Icons.star;
      case 3:
        return Icons.support_agent;
      case 4:
        return Icons.workspace_premium;
      default:
        return Icons.check;
    }
  }

  String _getFeatureTitle(int index) {
    switch (index) {
      case 0:
        return 'Basic Plan Features';
      case 1:
        return 'Advanced Plan Features';
      case 2:
        return 'Enterprise Plan Features';
      case 3:
        return 'Customer Support';
      case 4:
        return 'Additional Benefits';
      default:
        return 'Feature';
    }
  }

  String _getFeatureDescription(int index) {
    switch (index) {
      case 0:
        return 'Up to 100 invoices/month, 1 business, 1 user, basic CRM features';
      case 1:
        return 'Up to 1000 invoices/month, 3 businesses, 5 users, advanced CRM';
      case 2:
        return 'Unlimited invoices, unlimited businesses, unlimited users, full CRM suite';
      case 3:
        return 'Email support, priority support, dedicated account manager';
      case 4:
        return 'API access, custom integrations, advanced analytics, white-label options';
      default:
        return '';
    }
  }

    Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    bool showInfo = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
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
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.12),
                  const Color(0xFF1D4ED8).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
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
                          Text(
                            '₹${plans[selectedPlanIndex].monthlyPrice * 12} /year',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'Billed annually',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
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
                              child: const Center(
                                child: Text(
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