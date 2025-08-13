import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayoutHistoryScreen extends StatefulWidget {
  const PayoutHistoryScreen({super.key});

  @override
  State<PayoutHistoryScreen> createState() => _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends State<PayoutHistoryScreen> {
  // App theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: primaryColor,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ),
        title: Text(
          'Payout History',
          style: TextStyle(
            color: primaryColor,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: GoogleFonts.openSans().fontFamily,
          ),
        ),
        centerTitle: true,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.18),
            width: 1.0,
          ),
        ),
      ),
                    body: _buildEmptyState(),
    );
  }



  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.history_rounded,
              color: primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
                     Text(
             'You have not made any payouts yet',
             style: TextStyle(
               color: Colors.grey[600],
               fontSize: 14,
               fontWeight: FontWeight.w400,
             ),
             textAlign: TextAlign.center,
           ),
        ],
      ),
    );
  }


} 