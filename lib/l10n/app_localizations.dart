import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'E-Commerce App'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get orderPlaced;

  /// No description provided for @orderFailed.
  ///
  /// In en, this message translates to:
  /// **'Order failed. Please try again.'**
  String get orderFailed;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @youAreOnline.
  ///
  /// In en, this message translates to:
  /// **'You are online now'**
  String get youAreOnline;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get youAreOffline;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @appWillRestart.
  ///
  /// In en, this message translates to:
  /// **'The app will restart to apply the language change.'**
  String get appWillRestart;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login to access your profile'**
  String get pleaseLogin;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get noNewNotifications;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'unread notification'**
  String get unreadNotifications;

  /// No description provided for @unreadNotificationsPlural.
  ///
  /// In en, this message translates to:
  /// **'unread notifications'**
  String get unreadNotificationsPlural;

  /// No description provided for @businessTips.
  ///
  /// In en, this message translates to:
  /// **'Business Tips'**
  String get businessTips;

  /// No description provided for @startSmallScaleSmart.
  ///
  /// In en, this message translates to:
  /// **'Start Small, Scale Smart'**
  String get startSmallScaleSmart;

  /// No description provided for @embraceTechnology.
  ///
  /// In en, this message translates to:
  /// **'Embrace Technology'**
  String get embraceTechnology;

  /// No description provided for @atlassianPlaybook.
  ///
  /// In en, this message translates to:
  /// **'Atlassian Playbook'**
  String get atlassianPlaybook;

  /// No description provided for @byChristopher.
  ///
  /// In en, this message translates to:
  /// **'by Christopher D.'**
  String get byChristopher;

  /// No description provided for @byKatalina.
  ///
  /// In en, this message translates to:
  /// **'by Katalina C.'**
  String get byKatalina;

  /// No description provided for @byFlorian.
  ///
  /// In en, this message translates to:
  /// **'by Florian M.'**
  String get byFlorian;

  /// No description provided for @personalStatistics.
  ///
  /// In en, this message translates to:
  /// **'Personal statistics'**
  String get personalStatistics;

  /// No description provided for @tipsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tips\ncompleted'**
  String get tipsCompleted;

  /// No description provided for @tipsInProgress.
  ///
  /// In en, this message translates to:
  /// **'Tips\nin progress'**
  String get tipsInProgress;

  /// No description provided for @learnMoreWayFaster.
  ///
  /// In en, this message translates to:
  /// **'Learn more way faster'**
  String get learnMoreWayFaster;

  /// No description provided for @leanMore.
  ///
  /// In en, this message translates to:
  /// **'Lean more'**
  String get leanMore;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Kigali, kg 34 st...'**
  String get location;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'RWF'**
  String get cartTotal;

  /// No description provided for @stockRemaining.
  ///
  /// In en, this message translates to:
  /// **'Stock remaining:'**
  String get stockRemaining;

  /// No description provided for @noStockAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stock available'**
  String get noStockAvailable;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'What are u looking for ?'**
  String get searchHint;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @popularProducts.
  ///
  /// In en, this message translates to:
  /// **'Popular Products'**
  String get popularProducts;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @seeAllProducts.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAllProducts;

  /// No description provided for @loadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Loading products...'**
  String get loadingProducts;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @errorLoadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Error loading products:'**
  String get errorLoadingProducts;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailable;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found for'**
  String get noProductsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or check spelling'**
  String get tryDifferentKeywords;

  /// No description provided for @sampleProductsAdded.
  ///
  /// In en, this message translates to:
  /// **'Sample products added successfully!'**
  String get sampleProductsAdded;

  /// No description provided for @someProductsFailed.
  ///
  /// In en, this message translates to:
  /// **'Some products failed to add. Check console for details.'**
  String get someProductsFailed;

  /// No description provided for @addSampleProducts.
  ///
  /// In en, this message translates to:
  /// **'Add Sample Products'**
  String get addSampleProducts;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Search results for'**
  String get searchResultsFor;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'found'**
  String get found;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop now'**
  String get shopNow;

  /// No description provided for @payLater.
  ///
  /// In en, this message translates to:
  /// **'Pay Later !'**
  String get payLater;

  /// No description provided for @bigSale.
  ///
  /// In en, this message translates to:
  /// **'Big Sale'**
  String get bigSale;

  /// No description provided for @upTo70Off.
  ///
  /// In en, this message translates to:
  /// **'Up to 70% Off'**
  String get upTo70Off;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @freshTrendy.
  ///
  /// In en, this message translates to:
  /// **'Fresh & Trendy'**
  String get freshTrendy;

  /// No description provided for @percentOff.
  ///
  /// In en, this message translates to:
  /// **'52% Off'**
  String get percentOff;

  /// No description provided for @cannotAddMoreThan.
  ///
  /// In en, this message translates to:
  /// **'Cannot add more than'**
  String get cannotAddMoreThan;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @startShoppingToSeeOrders.
  ///
  /// In en, this message translates to:
  /// **'Start shopping to see your orders here'**
  String get startShoppingToSeeOrders;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @moreItems.
  ///
  /// In en, this message translates to:
  /// **'more items'**
  String get moreItems;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
