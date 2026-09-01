enum AppLanguage {
  english(code: 'en', name: 'English', nativeName: 'English'),
  hindi(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
  marathi(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
  kannada(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ');

  final String code;
  final String name;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  static AppLanguage fromCode(String code) {
    final norm = code.toLowerCase().trim();
    return AppLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == norm,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Pure local localization engine for Belagavi Property.
/// ZERO AI translation API dependency. All strings are stored in local resources.
class AppLocalizations {
  final AppLanguage language;

  const AppLocalizations(this.language);

  static const Map<String, Map<AppLanguage, String>> _localizedStrings = {
    // App & Header
    'app_title': {
      AppLanguage.english: 'Belagavi Property',
      AppLanguage.hindi: 'बेलगावी प्रॉपर्टी',
      AppLanguage.marathi: 'बेळगाव प्रॉपर्टी',
      AppLanguage.kannada: 'ಬೆಳಗಾವಿ ಪ್ರಾಪರ್ಟಿ',
    },
    'tagline': {
      AppLanguage.english: 'Belagavi Real Estate & Property Discovery',
      AppLanguage.hindi: 'बेलगावी रियल एस्टेट और संपत्ति खोज',
      AppLanguage.marathi: 'बेळगाव रिअल इस्टेट आणि मालमत्ता शोध',
      AppLanguage.kannada: 'ಬೆಳಗಾವಿ ರಿಯಲ್ ಎಸ್ಟೇಟ್ ಮತ್ತು ಆಸ್ತಿ ಹುಡುಕಾಟ',
    },
    'search_placeholder': {
      AppLanguage.english: 'Search properties in Belagavi, Tilakwadi, Camp...',
      AppLanguage.hindi: 'बेलगावी, तिलकवाड़ी, कैंप में संपत्ति खोजें...',
      AppLanguage.marathi: 'बेळगाव, टिळकवाडी, कॅम्पमध्ये मालमत्ता शोधा...',
      AppLanguage.kannada: 'ಬೆಳಗಾವಿ, ತಿಲಕವಾಡಿ, ಕ್ಯಾಂಪ್‌ನಲ್ಲಿ ಆಸ್ತಿ ಹುಡುಕಿ...',
    },
    'select_location': {
      AppLanguage.english: 'Select Location',
      AppLanguage.hindi: 'स्थान चुनें',
      AppLanguage.marathi: 'स्थान निवडा',
      AppLanguage.kannada: 'ಸ್ಥಳ ಆಯ್ಕೆಮಾಡಿ',
    },
    'select_language': {
      AppLanguage.english: 'Select Language',
      AppLanguage.hindi: 'भाषा चुनें',
      AppLanguage.marathi: 'भाषा निवडा',
      AppLanguage.kannada: 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',
    },
    'india_entry': {
      AppLanguage.english: 'Belagavi & India Listings',
      AppLanguage.hindi: 'बेलगावी और भारत लिस्टिंग',
      AppLanguage.marathi: 'बेळगाव आणि भारत लिस्टिंग',
      AppLanguage.kannada: 'ಬೆಳಗಾವಿ ಮತ್ತು ಭಾರತ ಆಸ್ತಿಗಳು',
    },
    'international_entry': {
      AppLanguage.english: 'International Listings',
      AppLanguage.hindi: 'अंतरराष्ट्रीय लिस्टिंग',
      AppLanguage.marathi: 'आंतरराष्ट्रीय लिस्टिंग',
      AppLanguage.kannada: 'ಅಂತರರಾಷ್ಟ್ರೀಯ ಆಸ್ತಿಗಳು',
    },
    'properties_count_format': {
      AppLanguage.english: '{count} properties in {location}',
      AppLanguage.hindi: '{location} में {count} संपत्तियां',
      AppLanguage.marathi: '{location} मध्ये {count} मालमत्ता',
      AppLanguage.kannada: '{location}ನಲ್ಲಿ {count} ಆಸ್ತಿಗಳು',
    },
    'no_properties_found': {
      AppLanguage.english: 'No properties found in {location}',
      AppLanguage.hindi: '{location} में कोई संपत्ति नहीं मिली',
      AppLanguage.marathi: '{location} मध्ये कोणतीही मालमत्ता सापडली नाही',
      AppLanguage.kannada: '{location}ನಲ್ಲಿ ಯಾವುದೇ ಆಸ್ತಿ ಕಂಡುಬಂದಿಲ್ಲ',
    },

    // Navigation & Tabs
    'nav_home': {
      AppLanguage.english: 'Home',
      AppLanguage.hindi: 'होम',
      AppLanguage.marathi: 'होम',
      AppLanguage.kannada: 'ಹೋಮ್',
    },
    'nav_search': {
      AppLanguage.english: 'Search',
      AppLanguage.hindi: 'खोजें',
      AppLanguage.marathi: 'शोधा',
      AppLanguage.kannada: 'ಹುಡುಕಿ',
    },
    'nav_post_property': {
      AppLanguage.english: 'Post Property',
      AppLanguage.hindi: 'संपत्ति पोस्ट करें',
      AppLanguage.marathi: 'मालमत्ता पोस्ट करा',
      AppLanguage.kannada: 'ಆಸ್ತಿ ಪ್ರಕಟಿಸಿ',
    },
    'nav_invest': {
      AppLanguage.english: 'Invest',
      AppLanguage.hindi: 'निवेश',
      AppLanguage.marathi: 'गुंतवणूक',
      AppLanguage.kannada: 'ಹೂಡಿಕೆ',
    },
    'nav_legal_notice': {
      AppLanguage.english: 'Legal Notice',
      AppLanguage.hindi: 'कानूनी नोटिस',
      AppLanguage.marathi: 'कायदेशीर नोटीस',
      AppLanguage.kannada: 'ಕಾನ್ಫಿಡೆನ್ಶಿಯಲ್ ಲೀಗಲ್',
    },
    'nav_profile': {
      AppLanguage.english: 'Profile',
      AppLanguage.hindi: 'प्रोफाइल',
      AppLanguage.marathi: 'प्रोफाइल',
      AppLanguage.kannada: 'ಪ್ರೊಫೈಲ್',
    },

    // Filters & Categories
    'filter_all': {
      AppLanguage.english: 'All',
      AppLanguage.hindi: 'सभी',
      AppLanguage.marathi: 'सर्व',
      AppLanguage.kannada: 'ಎಲ್ಲವೂ',
    },
    'filter_buy': {
      AppLanguage.english: 'Buy',
      AppLanguage.hindi: 'खरीदें',
      AppLanguage.marathi: 'खरेदी करा',
      AppLanguage.kannada: 'ಖರೀದಿಸಿ',
    },
    'filter_rent': {
      AppLanguage.english: 'Rent',
      AppLanguage.hindi: 'किराया',
      AppLanguage.marathi: 'भाडे',
      AppLanguage.kannada: 'ಬಾಡಿಗೆ',
    },
    'filter_lease': {
      AppLanguage.english: 'Lease',
      AppLanguage.hindi: 'लीज',
      AppLanguage.marathi: 'लीज',
      AppLanguage.kannada: 'ಲೀಸ್',
    },
    'filter_commercial': {
      AppLanguage.english: 'Commercial',
      AppLanguage.hindi: 'व्यावसायिक',
      AppLanguage.marathi: 'व्यावसायिक',
      AppLanguage.kannada: 'ವಾಣಿಜ್ಯ',
    },
    'filter_plots': {
      AppLanguage.english: 'Plots & Land',
      AppLanguage.hindi: 'प्लाट और भूमि',
      AppLanguage.marathi: 'प्लॉट आणि जमीन',
      AppLanguage.kannada: 'ಪ್ಲಾಟ್‌ಗಳು ಮತ್ತು ಭೂಮಿ',
    },
    'residential': {
      AppLanguage.english: 'Residential',
      AppLanguage.hindi: 'आवासीय',
      AppLanguage.marathi: 'निवासी',
      AppLanguage.kannada: 'ವಸತಿ',
    },
    'post_property': {
      AppLanguage.english: 'Post Property FREE',
      AppLanguage.hindi: 'मुफ्त संपत्ति पोस्ट करें',
      AppLanguage.marathi: 'मोफत मालमत्ता पोस्ट करा',
      AppLanguage.kannada: 'ಉಚಿತ ಆಸ್ತಿ ಪ್ರಕಟಿಸಿ',
    },

    // Status Display Labels (Never change DB keys)
    'status_draft': {
      AppLanguage.english: 'Draft (Unsubmitted)',
      AppLanguage.hindi: 'ड्राफ्ट (अप्रकाशित)',
      AppLanguage.marathi: 'मसुदा (अप्रकाशित)',
      AppLanguage.kannada: 'ಕರಡು (ಅಪ್ರಕಟಿತ)',
    },
    'status_pending_verification': {
      AppLanguage.english: 'Pending Verification',
      AppLanguage.hindi: 'सत्यापन लंबित',
      AppLanguage.marathi: 'पडताळणी प्रलंबित',
      AppLanguage.kannada: 'ಪರಿಶೀಲನೆ ಬಾಕಿ',
    },
    'status_active': {
      AppLanguage.english: 'Active & Verified',
      AppLanguage.hindi: 'सक्रिय और सत्यापित',
      AppLanguage.marathi: 'सक्रिय आणि पडताळलेले',
      AppLanguage.kannada: 'ಸಕ್ರಿಯ ಮತ್ತು ಪರಿಶೀಲಿಸಲಾಗಿದೆ',
    },
    'status_rejected': {
      AppLanguage.english: 'Rejected / Incomplete',
      AppLanguage.hindi: 'अस्वीकृत / अधूरा',
      AppLanguage.marathi: 'नाकारले / अपूर्ण',
      AppLanguage.kannada: 'ನಿರಾಕರಿಸಲಾಗಿದೆ / ಅಸಂಪೂರ್ಣ',
    },
    'status_archived': {
      AppLanguage.english: 'Archived',
      AppLanguage.hindi: 'आर्काइव किया गया',
      AppLanguage.marathi: 'आर्काइव्ह केले',
      AppLanguage.kannada: 'ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ',
    },
    'status_sold': {
      AppLanguage.english: 'Sold / Rented',
      AppLanguage.hindi: 'बेचा / किराए पर दिया',
      AppLanguage.marathi: 'विकले / भाड्याने दिले',
      AppLanguage.kannada: 'ಮಾರಾಟವಾಗಿದೆ / ಬಾಡಿಗೆಗೆ ನೀಡಲಾಗಿದೆ',
    },

    // Actions & Moderation
    'hideListing': {
      AppLanguage.english: 'Hide Listing',
      AppLanguage.hindi: 'लिस्टिंग छिपाएं',
      AppLanguage.marathi: 'लिस्टिंग लपवा',
      AppLanguage.kannada: 'ಪಟ್ಟಿಯನ್ನು ಮರೆಮಾಡಿ',
    },
    'makeListingLive': {
      AppLanguage.english: 'Make Live',
      AppLanguage.hindi: 'लाइव करें',
      AppLanguage.marathi: 'थेट करा',
      AppLanguage.kannada: 'ಲೈವ್ ಮಾಡಿ',
    },
    'putOnHold': {
      AppLanguage.english: 'Put On Hold',
      AppLanguage.hindi: 'होल्ड पर रखें',
      AppLanguage.marathi: 'होल्डवर ठेवा',
      AppLanguage.kannada: 'ತಡೆಹಿಡಿಯಿರಿ',
    },
    'restoreListing': {
      AppLanguage.english: 'Restore Listing',
      AppLanguage.hindi: 'पुनर्स्थापित करें',
      AppLanguage.marathi: 'पुनर्संचयित करा',
      AppLanguage.kannada: 'ಮರುಸ್ಥಾಪಿಸಿ',
    },
    'listingHidden': {
      AppLanguage.english: 'HIDDEN FROM PUBLIC',
      AppLanguage.hindi: 'सार्वजनिक रूप से छिपा हुआ',
      AppLanguage.marathi: 'सार्वजनिक लपविलेले',
      AppLanguage.kannada: 'ಸಾರ್ವಜನಿಕವಾಗಿ ಮರೆಮಾಡಲಾಗಿದೆ',
    },
    'listingOnHold': {
      AppLanguage.english: 'ON HOLD',
      AppLanguage.hindi: 'होल्ड पर',
      AppLanguage.marathi: 'होल्डवर',
      AppLanguage.kannada: 'ತಡೆಹಿಡಿಯಲಾಗಿದೆ',
    },
    'moderation': {
      AppLanguage.english: 'Moderation & Visibility',
      AppLanguage.hindi: 'मॉडरेशन और दृश्यता',
      AppLanguage.marathi: 'मॉडर्नेशन आणि दृश्यमानता',
      AppLanguage.kannada: 'ಮಾಡರೇಶನ್ ಮತ್ತು ಗೋಚರತೆ',
    },
    'markDisputed': {
      AppLanguage.english: 'Mark Disputed',
      AppLanguage.hindi: 'विवादित चिह्नित करें',
      AppLanguage.marathi: 'विवादित म्हणून चिन्हांकित करा',
      AppLanguage.kannada: 'ವಿವಾದಾಸ್ಪದ ಎಂದು ಗುರುತಿಸಿ',
    },
    'archiveProperty': {
      AppLanguage.english: 'Archive Property',
      AppLanguage.hindi: 'संपत्ति आर्काइव करें',
      AppLanguage.marathi: 'मालमत्ता आर्काइव्ह करा',
      AppLanguage.kannada: 'ಆಸ್ತಿಯನ್ನು ಆರ್ಕೈವ್ ಮಾಡಿ',
    },

    // Contact & Messaging
    'contactOwner': {
      AppLanguage.english: 'Contact Owner / Seller',
      AppLanguage.hindi: 'मालिक / विक्रेता से संपर्क करें',
      AppLanguage.marathi: 'मालक / विक्रेत्याशी संपर्क साधा',
      AppLanguage.kannada: 'ಮালিকರನ್ನು ಸಂಪರ್ಕಿಸಿ',
    },
    'call': {
      AppLanguage.english: 'Call',
      AppLanguage.hindi: 'कॉल करें',
      AppLanguage.marathi: 'कॉल करा',
      AppLanguage.kannada: 'ಕಾಲ್ ಮಾಡಿ',
    },
    'whatsapp': {
      AppLanguage.english: 'WhatsApp',
      AppLanguage.hindi: 'व्हाट्सएप',
      AppLanguage.marathi: 'व्हॉट्सअॅप',
      AppLanguage.kannada: 'ವಾಟ್ಸಾಪ್',
    },
    'message': {
      AppLanguage.english: 'Message',
      AppLanguage.hindi: 'संदेश',
      AppLanguage.marathi: 'संदेश',
      AppLanguage.kannada: 'ಸಂದೇಶ',
    },
    'viewDetails': {
      AppLanguage.english: 'View Details',
      AppLanguage.hindi: 'विवरण देखें',
      AppLanguage.marathi: 'तपशील पाहा',
      AppLanguage.kannada: 'ವಿವರಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
    },

    // Investment Module
    'investWithUs': {
      AppLanguage.english: 'Invest With Us',
      AppLanguage.hindi: 'हमारे साथ निवेश करें',
      AppLanguage.marathi: 'आमच्यासोबत गुंतवणूक करा',
      AppLanguage.kannada: 'ನಮ್ಮೊಂದಿಗೆ ಹೂಡಿಕೆ ಮಾಡಿ',
    },
    'belagaviPropertyLLP': {
      AppLanguage.english: 'BELAGAVI PROPERTY LLP',
      AppLanguage.hindi: 'बेलगावी प्रॉपर्टी एलएलपी',
      AppLanguage.marathi: 'बेळगाव प्रॉपर्टी एलएलपी',
      AppLanguage.kannada: 'ಬೆಳಗಾವಿ ಪ್ರಾಪರ್ಟಿ ಎಲ್‌ಎಲ್‌ಪಿ',
    },
    'registerInterest': {
      AppLanguage.english: 'Register Investment Interest',
      AppLanguage.hindi: 'निवेश की रुचि दर्ज करें',
      AppLanguage.marathi: 'गुंतवणुकीची आवड नोंदवा',
      AppLanguage.kannada: 'ಹೂಡಿಕೆ ಆಸಕ್ತಿಯನ್ನು ನೋಂದಾಯಿಸಿ',
    },
    'indicativeProfitSharing': {
      AppLanguage.english: 'Indicative Profit Sharing',
      AppLanguage.hindi: 'सांकेतिक लाभ साझाकरण',
      AppLanguage.marathi: 'संकेतात्मक नफा भागीदारी',
      AppLanguage.kannada: 'ಸೂಚಕ ಲಾಭ ಹಂಚಿಕೆ',
    },
    'investmentDisclaimer': {
      AppLanguage.english: 'Investment Assistance Notice: Belagavi Property LLP facilitates project information. Past performance does not guarantee future results.',
      AppLanguage.hindi: 'निवेश सहायता सूचना: बेलगावी प्रॉपर्टी एलएलपी परियोजना की जानकारी की सुविधा प्रदान करता है। पिछला प्रदर्शन भविष्य के परिणामों की गारंटी नहीं देता है।',
      AppLanguage.marathi: 'गुंतवणूक साहाय्य सूचना: बेळगाव प्रॉपर्टी एलएलपी प्रकल्प माहितीची सोय करते. भूतकाळातील कामगिरी भविष्यातील निकालांची हमी देत नाही.',
      AppLanguage.kannada: 'ಹೂಡಿಕೆ ನೆರವು ಸೂಚನೆ: ಬೆಳಗಾವಿ ಪ್ರಾಪರ್ಟಿ ಎಲ್‌ಎಲ್‌ಪಿ ಯೋಜನೆ ಮಾಹಿತಿಯನ್ನು ಒದಗಿಸುತ್ತದೆ.',
    },

    // Legal Notice & Dispute Assistance Module
    'legalNoticeHubTitle': {
      AppLanguage.english: 'Legal Notice & Dispute Hub',
      AppLanguage.hindi: 'कानूनी नोटिस और विवाद हब',
      AppLanguage.marathi: 'कायदेशीर नोटीस आणि विवाद केंद्र',
      AppLanguage.kannada: 'ಕಾನ್ಫಿಡೆನ್ಶಿಯಲ್ ಲೀಗಲ್ ನೋಟಿಸ್ ಹಬ್',
    },
    'disputeMattersTab': {
      AppLanguage.english: 'Dispute Matters',
      AppLanguage.hindi: 'विवाद मामले',
      AppLanguage.marathi: 'विवाद प्रकरणे',
      AppLanguage.kannada: 'ವಿವಾದ ಪ್ರಕರಣಗಳು',
    },
    'publicNoticesTab': {
      AppLanguage.english: 'Public Notices',
      AppLanguage.hindi: 'सार्वजनिक नोटिस',
      AppLanguage.marathi: 'सार्वजनिक नोटीस',
      AppLanguage.kannada: 'ಸಾರ್ವಜನಿಕ ನೋಟಿಸ್‌ಗಳು',
    },
    'buyerDueDiligenceTab': {
      AppLanguage.english: 'Buyer Due Diligence',
      AppLanguage.hindi: 'क्रेता उचित जांच',
      AppLanguage.marathi: 'खरेदीदार योग्य तपासणी',
      AppLanguage.kannada: 'ಖರೀದಿದಾರರ ಶ್ರದ್ಧೆ ಪರಿಶೀಲನೆ',
    },
    'sellerComplianceTab': {
      AppLanguage.english: 'Seller Compliance',
      AppLanguage.hindi: 'विक्रेता अनुपालन',
      AppLanguage.marathi: 'विक्रेता अनुपालन',
      AppLanguage.kannada: 'ಮಾರಾಟಗಾರರ ಅನುಸರಣೆ',
    },
    'startNoticeWizard': {
      AppLanguage.english: '+ Start Notice / Dispute',
      AppLanguage.hindi: '+ नोटिस / विवाद शुरू करें',
      AppLanguage.marathi: '+ नोटीस / विवाद सुरू करा',
      AppLanguage.kannada: '+ ನೋಟಿಸ್ / ವಿವಾದ ಪ್ರಾರಂಭಿಸಿ',
    },
    'activeLegalMatters': {
      AppLanguage.english: 'Active Legal Matters',
      AppLanguage.hindi: 'सक्रिय कानूनी मामले',
      AppLanguage.marathi: 'सक्रिय कायदेशीर प्रकरणे',
      AppLanguage.kannada: 'ಸಕ್ರಿಯ ಕಾನೂನು ಪ್ರಕರಣಗಳು',
    },
    'newDisputeWizard': {
      AppLanguage.english: 'New Dispute Wizard',
      AppLanguage.hindi: 'नया विवाद विजार्ड',
      AppLanguage.marathi: 'नवीन विवाद विजार्ड',
      AppLanguage.kannada: 'ಹೊಸ ವಿವಾದ ವಿಸಾರ್ಡ್',
    },
    'noActiveMatters': {
      AppLanguage.english: 'No Active Dispute Matters',
      AppLanguage.hindi: 'कोई सक्रिय विवाद मामला नहीं है',
      AppLanguage.marathi: 'कोणतेही सक्रिय विवाद प्रकरण नाही',
      AppLanguage.kannada: 'ಯಾವುದೇ ಸಕ್ರಿಯ ವಿವಾದ ಪ್ರಕರಣವಿಲ್ಲ',
    },
    'startGuidedWizardDesc': {
      AppLanguage.english: 'Start a 16-step guided wizard for tenancy default, agreement default, deposit refund, or builder delay notice.',
      AppLanguage.hindi: 'किरायेदारी डिफ़ॉल्ट, समझौता डिफ़ॉल्ट, जमा रिफंड, या बिल्डर देरी नोटिस के लिए 16-चरणीय निर्देशित विजार्ड शुरू करें।',
      AppLanguage.marathi: 'भाडेकरू डीफॉल्ट, करार डीफॉल्ट, ठेव परतावा किंवा बिल्डर विलंब नोटिसीसाठी 16-पायऱ्यांचा मार्गदर्शित विजार्ड सुरू करा.',
      AppLanguage.kannada: 'ಬಾಡಿಗೆ ಡಿಫಾಲ್ಟ್, ಒಪ್ಪಂದ ಡಿಫಾಲ್ಟ್, ಠೇವಣಿ ಮರುಪಾವತಿ, ಅಥವಾ ಬಿಲ್ಡರ್ ವಿಳಂಬ ನೋಟಿಸ್‌ಗಾಗಿ 16-ಹಂತದ ಮಾರ್ಗದರ್ಶಿ ವಿಸಾರ್ಡ್ ಪ್ರಾರಂಭಿಸಿ.',
    },

    // Profile & Settings
    'myProperties': {
      AppLanguage.english: 'My Properties',
      AppLanguage.hindi: 'मेरी लिस्टिंग',
      AppLanguage.marathi: 'माझ्या मालमत्ता',
      AppLanguage.kannada: 'ನನ್ನ ಆಸ್ತಿಗಳು',
    },
    'ownerDashboard': {
      AppLanguage.english: 'Owner Dashboard',
      AppLanguage.hindi: 'मालिक का डैशबोर्ड',
      AppLanguage.marathi: 'मालकाचे डॅशबोर्ड',
      AppLanguage.kannada: 'ಮೂಲ ಮಾಲೀಕರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
    },
    'appLanguageSetting': {
      AppLanguage.english: 'App Language',
      AppLanguage.hindi: 'ऐप की भाषा',
      AppLanguage.marathi: 'अ‍ॅपची भाषा',
      AppLanguage.kannada: 'ಆ್ಯಪ್ ಭಾಷೆ',
    },
    'accountSettings': {
      AppLanguage.english: 'Account & Settings',
      AppLanguage.hindi: 'खाता और सेटिंग्स',
      AppLanguage.marathi: 'खाते आणि सेटिंग्ज',
      AppLanguage.kannada: 'ಖಾತೆ ಮತ್ತು ಸಂಯೋಜನೆಗಳು',
    },

    // Dialogs & Validations
    'requiredField': {
      AppLanguage.english: 'This field is required',
      AppLanguage.hindi: 'यह फ़ील्ड आवश्यक है',
      AppLanguage.marathi: 'हे क्षेत्र आवश्यक आहे',
      AppLanguage.kannada: 'ಈ ಕ್ಷೇತ್ರ ಅಗತ್ಯವಿದೆ',
    },
    'invalidPhone': {
      AppLanguage.english: 'Please enter a valid 10-digit phone number',
      AppLanguage.hindi: 'कृपया एक मान्य 10-अंकीय फोन नंबर दर्ज करें',
      AppLanguage.marathi: 'कृपया वैध १०-अंकी फोन नंबर प्रविष्ट करा',
      AppLanguage.kannada: 'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ 10-ಅಂಕಿಗಳ ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
    },
    'cancel': {
      AppLanguage.english: 'Cancel',
      AppLanguage.hindi: 'रद्द करें',
      AppLanguage.marathi: 'रद्द करा',
      AppLanguage.kannada: 'ರದ್ದುಗೊಳಿಸಿ',
    },
    'confirm': {
      AppLanguage.english: 'Confirm',
      AppLanguage.hindi: 'पुष्टि करें',
      AppLanguage.marathi: 'निश्चित करा',
      AppLanguage.kannada: 'ಖಚಿತಪಡಿಸಿ',
    },
    'save': {
      AppLanguage.english: 'Save',
      AppLanguage.hindi: 'सहेजें',
      AppLanguage.marathi: 'जतन करा',
      AppLanguage.kannada: 'ಉಳಿಸಿ',
    },

    // Charts & Analytics
    'chartPropertiesCount': {
      AppLanguage.english: 'Properties Count',
      AppLanguage.hindi: 'संपत्तियों की संख्या',
      AppLanguage.marathi: 'मालमत्तांची संख्या',
      AppLanguage.kannada: 'ಆಸ್ತಿಗಳ ಸಂಖ್ಯೆ',
    },
    'chartViewsOverTime': {
      AppLanguage.english: 'Views Over Time',
      AppLanguage.hindi: 'समय के साथ विचार',
      AppLanguage.marathi: 'कालावधीनुसार व्ह्यूज',
      AppLanguage.kannada: 'ಸಮಯದೊಂದಿಗೆ ವೀಕ್ಷಣೆಗಳು',
    },
  };

  String translate(String key, {Map<String, String>? params}) {
    final langMap = _localizedStrings[key];
    String text = langMap?[language] ?? langMap?[AppLanguage.english] ?? key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }

    return text;
  }

  String formatPropertyCount(int count, String locationName) {
    if (count == 0) {
      return translate('no_properties_found', params: {'location': locationName});
    }
    final formattedCount = count.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return translate('properties_count_format', params: {
      'count': formattedCount,
      'location': locationName,
    });
  }
}
