import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invoice_app/screens/about_screen.dart';
import 'package:invoice_app/screens/business_profile_screen.dart';
import 'package:invoice_app/screens/create_invoice.dart';
import 'package:invoice_app/screens/create_purchase_screen.dart';
import 'package:invoice_app/screens/dashboard.dart';
import 'package:invoice_app/screens/invite_earn_screen.dart';
import 'package:invoice_app/screens/invoice_settings.dart';
import 'package:invoice_app/screens/login_screen.dart';
import 'package:invoice_app/screens/main_screen.dart';
import 'package:invoice_app/screens/menu_managment.dart';
import 'package:invoice_app/screens/sales_report.dart';
import 'package:invoice_app/screens/settings.dart';
import 'package:invoice_app/screens/splash_screen.dart';
import 'package:invoice_app/screens/subscription_screen.dart';
import 'package:invoice_app/screens/account_settings.dart';
import 'package:invoice_app/screens/reminder_settings_screen.dart';
import 'package:invoice_app/screens/otp_verification_screen.dart';
import 'package:invoice_app/screens/complete_profile_screen.dart';
import 'package:invoice_app/screens/purchase_screen.dart';
import 'package:invoice_app/screens/upload_bill_screen.dart';
import 'package:invoice_app/screens/manage_companies_screen.dart';
import 'package:invoice_app/screens/add_item_screen.dart';
import 'package:invoice_app/screens/create_item_screen.dart';
import 'package:invoice_app/screens/business_gst_settings_screen.dart';

void main() {
  runApp(RestaurantInvoiceApp());
}

class RestaurantInvoiceApp extends StatefulWidget {
  @override
  _RestaurantInvoiceAppState createState() => _RestaurantInvoiceAppState();
}

class _RestaurantInvoiceAppState extends State<RestaurantInvoiceApp> {
  ThemeMode _themeMode = ThemeMode.light;

  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Invoice App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        fontFamily: GoogleFonts.openSans().fontFamily,
        textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
        primarySwatch: MaterialColor(primaryColor.value, {
          50: primaryColor.withOpacity(0.1),
          100: primaryColor.withOpacity(0.2),
          200: primaryColor.withOpacity(0.3),
          300: primaryColor.withOpacity(0.4),
          400: primaryColor.withOpacity(0.5),
          500: primaryColor,
          600: secondaryColor,
          700: secondaryColor.withOpacity(0.8),
          800: secondaryColor.withOpacity(0.6),
          900: secondaryColor.withOpacity(0.4),
        }),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: Colors.white,
          background: const Color(0xFFFAFBFC),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.openSans(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          labelStyle: GoogleFonts.openSans(),
          hintStyle: GoogleFonts.openSans(),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        fontFamily: GoogleFonts.openSans().fontFamily,
        textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
        primarySwatch: MaterialColor(primaryColor.value, {
          50: primaryColor.withOpacity(0.1),
          100: primaryColor.withOpacity(0.2),
          200: primaryColor.withOpacity(0.3),
          300: primaryColor.withOpacity(0.4),
          400: primaryColor.withOpacity(0.5),
          500: primaryColor,
          600: secondaryColor,
          700: secondaryColor.withOpacity(0.8),
          800: secondaryColor.withOpacity(0.6),
          900: secondaryColor.withOpacity(0.4),
        }),
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: Colors.grey[900]!,
          background: Colors.black,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          labelStyle: GoogleFonts.openSans(),
          hintStyle: GoogleFonts.openSans(),
        ),
      ),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(),
        '/home': (context) => HomeDashboard(onThemeToggle: _toggleTheme),
        '/sales-report': (context) => SalesReportScreen(),
        '/create-invoice': (context) => const CreateInvoiceScreen(),
        '/invoice-preview': (context) => InvoicePreviewScreen(),
        '/invoice-settings': (context) => InvoiceSettingsScreen(),
        '/invite-earn': (context) => const InviteEarnScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/account-settings': (context) => const AccountSettingsScreen(),
        '/reminder-settings': (context) => const ReminderSettingsScreen(),
        '/about': (context) => const AboutScreen(),
        '/business-profile': (context) => const BusinessProfileScreen(),
        '/otp-verification': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          return OTPVerificationScreen(phoneNumber: args ?? '');
        },
        '/complete-profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          return CompleteProfileScreen(phoneNumber: args ?? '');
        },
        '/settings':
            (context) => SettingsScreen(
              onThemeToggle: _toggleTheme,
              themeMode: _themeMode,
            ),
        '/purchase': (context) => const PurchaseScreen(),
        '/upload-bill': (context) => const UploadBillScreen(),
        '/create-purchase': (context) => const CreatePurchaseScreen(),
        '/manage-companies': (context) => const ManageCompaniesScreen(),
        '/add-item': (context) => const AddItemScreen(),
        '/create-item': (context) => const CreateItemScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
