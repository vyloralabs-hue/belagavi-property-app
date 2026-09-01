import 'package:flutter_riverpod/legacy.dart';

enum InvestmentLanguage {
  english('en', 'English'),
  hindi('hi', 'हिंदी'),
  kannada('kn', 'ಕನ್ನಡ'),
  marathi('mr', 'मराठी');

  final String code;
  final String label;
  const InvestmentLanguage(this.code, this.label);
}

class InvestmentLocalizations {
  final InvestmentLanguage language;

  const InvestmentLocalizations(this.language);

  static final Map<InvestmentLanguage, Map<String, String>> _localizedValues = {
    InvestmentLanguage.english: {
      'title': 'Invest With Us',
      'legalEntity': 'BELAGAVI PROPERTY LLP',
      'subtitle': 'Project-Specific Land & Property Opportunities',
      'projectSpecific': 'Project-Specific Investment Only',
      'projectSpecificDesc':
          'Every investment is associated with a specific disclosed project schedule and is not an automatic investment in general business assets.',
      'fundUtilisation': 'Fund Utilisation',
      'fundUtilisationDesc':
          'Project funds are allocated strictly for identified land acquisition, NA opportunities, and approved development as defined in the executed project agreement.',
      'profitSharing': 'Profit Participation',
      'profitSharingDesc':
          'Investor participation is based on the agreed share of actual Net Project Profit after successful project completion and sale.',
      'noGuaranteedReturns': 'No Guaranteed Returns Warning',
      'noGuaranteedReturnsDesc':
          'Investment returns are not guaranteed. Commercial outcomes depend on real-estate market conditions, demand, legal title clearance, regulatory approvals, and force majeure factors.',
      'transparency': 'Record Transparency',
      'transparencyDesc':
          'BELAGAVI PROPERTY LLP maintains project records and provides relevant updates to investors according to agreement terms.',
      'documents': 'Investor Document Center',
      'acknowledgement': 'Investor Risk Acknowledgement',
      'submitEnquiry': 'Submit Investment Enquiry',
      'legalDisclaimer':
          'Investment in real estate involves risk. No fixed, minimum, assured or guaranteed return is promised. Any profit participation depends on the actual commercial outcome of the identified project and the terms of the executed agreement. Users should independently obtain professional legal, tax and financial advice.',
      'governingLaw': 'Governing Law: Laws of India',
      'jurisdiction':
          'Jurisdiction: Competent courts at Belagavi, Karnataka, India',
      'exploreProjects': 'View Identified Projects',
      'howItWorks': 'How Project Investment Works',
      'paymentModes':
          'Accepted Payment Modes: Bank Transfer (NEFT/RTGS), Cheque, UPI',
      'paymentSafety':
          'Payment instructions, if applicable, will be provided through the applicable verified project documentation and authorised process.',
      'legalReviewPendingWarning':
          'Publication of an investment opportunity requires Founder/legal review of the applicable structure and documents.',
      'ack1': 'I understand this is a project-specific opportunity.',
      'ack2': 'I understand returns/profit are not guaranteed.',
      'ack3':
          'I understand actual project results may differ from expectations.',
      'ack4':
          'I understand project, market, legal, approval and execution risks exist.',
      'ack5':
          'I understand the applicable project agreement controls final commercial and legal terms.',
      'ack6':
          'I have had the opportunity to review applicable disclosures and documents.',
      'ack7':
          'I understand submitting an enquiry does not itself constitute an investment, acceptance, allotment, partnership, or contractual commitment unless separately executed under the applicable agreement.',
    },
    InvestmentLanguage.hindi: {
      'title': 'हमारे साथ निवेश करें',
      'legalEntity': 'बेलगावी प्रॉपर्टी एलएलपी',
      'subtitle': 'परियोजना-विशिष्ट भूमि और संपत्ति के अवसर',
      'projectSpecific': 'केवल परियोजना-विशिष्ट निवेश',
      'projectSpecificDesc':
          'प्रत्येक निवेश एक विशिष्ट घोषित परियोजना अनुसूची से जुड़ा है और सामान्य व्यावसायिक संपत्तियों में स्वचालित निवेश नहीं है।',
      'fundUtilisation': 'निधि उपयोग',
      'fundUtilisationDesc':
          'परियोजना निधि का उपयोग निष्पादित परियोजना समझौते के अनुसार भूमि अधिग्रहण और स्वीकृत विकास के लिए किया जाता है।',
      'profitSharing': 'लाभ सहभागिता',
      'profitSharingDesc':
          'निवेशक की भागीदारी परियोजना के सफल समापन और बिक्री के बाद वास्तविक शुद्ध परियोजना लाभ के सहमत हिस्से पर आधारित है।',
      'noGuaranteedReturns': 'कोई गारंटीकृत रिटर्न नहीं की चेतावनी',
      'noGuaranteedReturnsDesc':
          'निवेश रिटर्न की गारंटी नहीं है। व्यावसायिक परिणाम अचल संपत्ति बाजार की स्थितियों, मांग, कानूनी मंजूरी और नियामक स्वीकृतियों पर निर्भर करते हैं।',
      'transparency': 'पारदर्शिता एवं रिकॉर्ड',
      'transparencyDesc':
          'बेलगावी प्रॉपर्टी एलएलपी परियोजना के रिकॉर्ड बनाए रखती है और समझौते की शर्तों के अनुसार निवेशकों को अपडेट प्रदान करती है।',
      'documents': 'निवेशक दस्तावेज़ केंद्र',
      'acknowledgement': 'निवेशक जोखिम स्वीकृति',
      'submitEnquiry': 'निवेश पूछताछ जमा करें',
      'legalDisclaimer':
          'अचल संपत्ति में निवेश में जोखिम शामिल है। किसी भी निश्चित, न्यूनतम या गारंटीकृत रिटर्न का वादा नहीं किया जाता है। लाभ सहभागिता परियोजना के वास्तविक व्यावसायिक परिणाम पर निर्भर करती है।',
      'governingLaw': 'शासी कानून: भारत के कानून',
      'jurisdiction':
          'क्षेत्राधिकार: बेलगावी, कर्नाटक, भारत में सक्षम न्यायालय',
      'exploreProjects': 'चिह्नित परियोजनाएं देखें',
      'howItWorks': 'परियोजना निवेश कैसे काम करता है',
      'paymentModes': 'स्वीकृत भुगतान मोड: बैंक ट्रांसफर (NEFT/RTGS), चेक, UPI',
      'paymentSafety':
          'भुगतान निर्देश, यदि लागू हो, लागू सत्यापित परियोजना प्रलेखन और अधिकृत प्रक्रिया के माध्यम से प्रदान किए जाएंगे।',
      'legalReviewPendingWarning':
          'निवेश अवसर के प्रकाशन के लिए लागू संरचना और दस्तावेजों की संस्थापक/कानूनी समीक्षा की आवश्यकता होती है।',
      'ack1': 'मैं समझता हूं कि यह एक परियोजना-विशिष्ट अवसर है।',
      'ack2': 'मैं समझता हूं कि रिटर्न/लाभ की गारंटी नहीं है।',
      'ack3': 'मैं समझता हूं कि वास्तविक परिणाम उम्मीदों से भिन्न हो सकते हैं।',
      'ack4':
          'मैं समझता हूं कि परियोजना, बाजार, कानूनी और निष्पादन जोखिम मौजूद हैं।',
      'ack5':
          'मैं समझता हूं कि लागू परियोजना समझौता अंतिम शर्तों को नियंत्रित करता है।',
      'ack6': 'मुझे लागू प्रकटीकरणों की समीक्षा करने का अवसर मिला है।',
      'ack7':
          'मैं समझता हूं कि पूछताछ जमा करने से स्वतः निवेश, आवंटन या संविदात्मक प्रतिबद्धता नहीं बनती है।',
    },
    InvestmentLanguage.kannada: {
      'title': 'ನಮ್ಮೊಂದಿಗೆ ಹೂಡಿಕೆ ಮಾಡಿ',
      'legalEntity': 'ಬೆಳಗಾವಿ ಪ್ರಾಪರ್ಟಿ ಎಲ್‌ಎಲ್‌ಪಿ',
      'subtitle': 'ಯೋಜನೆ-ನಿರ್ದಿಷ್ಟ ಜಮೀನು ಮತ್ತು ಆಸ್ತಿ ಅವಕಾಶಗಳು',
      'projectSpecific': 'ಯೋಜನೆ-ನಿರ್ದಿಷ್ಟ ಹೂಡಿಕೆ ಮಾತ್ರ',
      'projectSpecificDesc':
          'ಪ್ರತಿಯೊಂದು ಹೂಡಿಕೆಯು ನಿರ್ದಿಷ್ಟ ಯೋಜನಾ ವೇಳಾಪಟ್ಟಿಗೆ ಒಳಪಟ್ಟಿರುತ್ತದೆ ಮತ್ತು ಸಾಮಾನ್ಯ ವ್ಯವಹಾರ ಆಸ್ತಿಗಳಲ್ಲಿ ಸ್ವಯಂಚಾಲಿತ ಹೂಡಿಕೆಯಲ್ಲ.',
      'fundUtilisation': 'ನಿಧಿ ಬಳಕೆ',
      'fundUtilisationDesc':
          'ಯೋಜನಾ ಒಪ್ಪಂದದ ಪ್ರಕಾರ ಜಮೀನು ಖರೀದಿ ಮತ್ತು ಅಭಿವೃದ್ಧಿಗೆ ಮಾತ್ರ ಹೂಡಿಕೆ ನಿಧಿಯನ್ನು ಬಳಸಲಾಗುತ್ತದೆ.',
      'profitSharing': 'ಲಾಭ ಹಂಚಿಕೆ',
      'profitSharingDesc':
          'ಯೋಜನೆಯ ಯಶಸ್ವಿ ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ ಮತ್ತು ಮಾರಾಟದ ನಂತರದ ನೈಜ ನಿವ್ವಳ ಯೋಜನಾ ಲಾಭದ ಆಧಾರದ ಮೇಲೆ ಹೂಡಿಕೆದಾರರ ಲಾಭದ ಪಾಲು ನಿರ್ಧರಿಸಲಾಗುತ್ತದೆ.',
      'noGuaranteedReturns': 'ಖಾತರಿಪಡಿಸಿದ ರಿಟರ್ನ್ಸ್ ಇಲ್ಲ ಎಂಬ ಎಚ್ಚರಿಕೆ',
      'noGuaranteedReturnsDesc':
          'ಹೂಡಿಕೆಯ ರಿಟರ್ನ್ಸ್‌ಗೆ ಯಾವುದೇ ಖಾತರಿ ಇರುವುದಿಲ್ಲ. ಫಲಿತಾಂಶಗಳು ರಿಯಲ್ ಎಸ್ಟೇಟ್ ಮಾರುಕಟ್ಟೆ ಪರಿಸ್ಥಿತಿಗಳು ಮತ್ತು ಕಾನೂನು ಅನುಮೋದನೆಗಳ ಮೇಲೆ ಅವಲಂಬಿತವಾಗಿವೆ.',
      'transparency': 'ದಾಖಲೆ ಪಾರದರ್ಶಕತೆ',
      'transparencyDesc':
          'ಬೆಳಗಾವಿ ಪ್ರಾಪರ್ಟಿ ಎಲ್‌ಎಲ್‌ಪಿ ಯೋಜನೆಯ ದಾಖಲೆಗಳನ್ನು ನಿರ್ವಹಿಸುತ್ತದೆ ಮತ್ತು ಒಪ್ಪಂದದ ನಿಯಮಗಳ ಪ್ರಕಾರ ಮಾಹಿತಿ ನೀಡುತ್ತದೆ.',
      'documents': 'ಹೂಡಿಕೆದಾರರ ದಾಖಲೆ ಕೇಂದ್ರ',
      'acknowledgement': 'ಹೂಡಿಕೆದಾರರ ಅಪಾಯದ ಸ್ವೀಕಾರ',
      'submitEnquiry': 'ಹೂಡಿಕೆ ವಿಚಾರಣೆ ಸಲ್ಲಿಸಿ',
      'legalDisclaimer':
          'ರಿಯಲ್ ಎಸ್ಟೇಟ್ ಹೂಡಿಕೆಯಲ್ಲಿ ಅಪಾಯ ಸೇರಿದೆ. ಯಾವುದೇ ನಿರ್ದಿಷ್ಟ ಅಥವಾ ಖಾತರಿಪಡಿಸಿದ ಲಾಭದ ಭರವಸೆ ನೀಡಲಾಗುವುದಿಲ್ಲ.',
      'governingLaw': 'ಆಡಳಿತ ಕಾನೂನು: ಭಾರತದ ಕಾನೂನುಗಳು',
      'jurisdiction': 'ನ್ಯಾಯವ್ಯಾಪ್ತಿ: ಬೆಳಗಾವಿ, ಕರ್ನಾಟಕ, ಭಾರತದ ನ್ಯಾಯಾಲಯಗಳು',
      'exploreProjects': 'ಗುರುತಿಸಲಾದ ಯೋಜನೆಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
      'howItWorks': 'ಯೋಜನಾ ಹೂಡಿಕೆ ಹೇಗೆ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ',
      'paymentModes':
          'ಸ್ವೀಕರಿಸಲಾದ ಪಾವತಿ ವಿಧಾನಗಳು: ಬ್ಯಾಂಕ್ ವರ್ಗಾವಣೆ (NEFT/RTGS), ಚೆಕ್, UPI',
      'paymentSafety':
          'ಪಾವತಿ ಸೂಚನೆಗಳನ್ನು ಅಧಿಕೃತ ಯೋಜನಾ ದಾಖಲೆಗಳು ಮತ್ತು ಪ್ರಕ್ರಿಯೆಯ ಮೂಲಕ ಒದಗಿಸಲಾಗುತ್ತದೆ.',
      'legalReviewPendingWarning':
          'ಹೂಡಿಕೆ ಅವಕಾಶದ ಪ್ರಕಟಣೆಗೆ ಕಾನೂನು ಪರಿಶೀಲನೆ ಅಗತ್ಯವಿದೆ.',
      'ack1': 'ಇದು ಯೋಜನೆ-ನಿರ್ದಿಷ್ಟ ಅವಕಾಶ ಎಂದು ನಾನು ಅರ್ಥಮಾಡಿಕೊಂಡಿದ್ದೇನೆ.',
      'ack2': 'ಲಾಭಕ್ಕೆ ಯಾವುದೇ ಖಾತರಿ ಇಲ್ಲ ಎಂದು ನಾನು ಅರ್ಥಮಾಡಿಕೊಂಡಿದ್ದೇನೆ.',
      'ack3':
          'ನೈಜ ಫಲಿತಾಂಶಗಳು ನಿರೀಕ್ಷೆಗಳಿಗಿಂತ ಭಿನ್ನವಾಗಿರಬಹುದು ಎಂದು ನಾನು ಅರ್ಥಮಾಡಿಕೊಂಡಿದ್ದೇನೆ.',
      'ack4':
          'ಮಾರುಕಟ್ಟೆ ಮತ್ತು ಕಾನೂನು ಅಪಾಯಗಳು ಇವೆ ಎಂದು ನಾನು ಅರ್ಥಮಾಡಿಕೊಂಡಿದ್ದೇನೆ.',
      'ack5':
          'ಯೋಜನಾ ಒಪ್ಪಂದವು ಅಂತಿಮ ನಿಯಮಗಳನ್ನು ನಿಯಂತ್ರಿಸುತ್ತದೆ ಎಂದು ನಾನು ಅರ್ಥಮಾಡಿಕೊಂಡಿದ್ದೇನೆ.',
      'ack6': 'ದಾಖಲೆಗಳನ್ನು ಪರಿಶೀಲಿಸಲು ನನಗೆ ಅವಕಾಶ ಸಿಕ್ಕಿದೆ.',
      'ack7':
          'ವಿಚಾರಣೆ ಸಲ್ಲಿಸುವುದರಿಂದ ನೇರ ಹೂಡಿಕೆ ಅಥವಾ ಒಪ್ಪಂದವಾಗುವುದಿಲ್ಲ ಎಂದು ನಾನು ಅರ್ಥಮಾಡಿಕೊಂಡಿದ್ದೇನೆ.',
    },
    InvestmentLanguage.marathi: {
      'title': 'आमच्यासोबत गुंतवणूक करा',
      'legalEntity': 'बेळगाव प्रॉपर्टी एलएलपी',
      'subtitle': 'प्रकल्प-विशिष्ट जमीन आणि मालमत्ता संधी',
      'projectSpecific': 'केवळ प्रकल्प-विशिष्ट गुंतवणूक',
      'projectSpecificDesc':
          'प्रत्येक गुंतवणूक ही एका विशिष्ट घोषित प्रकल्प वेळापत्रकाशी जोडलेली असते आणि सामान्य व्यावसायिक मालमत्तेतील स्वयंचलित गुंतवणूक नसते.',
      'fundUtilisation': 'निधी वापर',
      'fundUtilisationDesc':
          'प्रकल्प करारातील अटींनुसार जमीन संपादन आणि विकासासाठीच निधी वापरला जातो.',
      'profitSharing': 'नफा सहभाग',
      'profitSharingDesc':
          'गुंतवणूकदारांचा सहभाग प्रकल्प यशस्वीपणे पूर्ण झाल्यानंतर आणि विक्री झाल्यानंतर प्रत्यक्ष निव्वळ नफ्याच्या ठरलेल्या भागावर आधारित असतो.',
      'noGuaranteedReturns': 'हमी परतावा नाही अशी चेतावणी',
      'noGuaranteedReturnsDesc':
          'गुंतवणूक परताव्याची कोणतीही हमी दिली जात नाही. व्यावसायिक परिणाम रिअल इस्टेट मार्केट परिस्थिती आणि कायदेशीर मंजुरींवर अवलंबून असतात.',
      'transparency': 'पारदर्शकता आणि नोंदी',
      'transparencyDesc':
          'बेळगाव प्रॉपर्टी एलएलपी प्रकल्पाच्या नोंदी ठेवते आणि कराराच्या अटींनुसार गुंतवणूकदारांना अपडेट्स प्रदान करते.',
      'documents': 'गुंतवणूकदार दस्तऐवज केंद्र',
      'acknowledgement': 'गुंतवणूकदार जोखीम स्वीकृती',
      'submitEnquiry': 'गुंतवणूक चौकशी सबमिट करा',
      'legalDisclaimer':
          'रिअल इस्टेटमधील गुंतवणुकीत जोखीम असते. कोणताही निश्चित किंवा हमी परतावा दिला जात नाही. नफा सहभाग हा प्रकल्पाच्या प्रत्यक्ष निकालावर अवलंबून असतो.',
      'governingLaw': 'शासकीय कायदा: भारताचे कायदे',
      'jurisdiction':
          'न्यायक्षेत्र: बेळगाव, कर्नाटक, भारत येथील सक्षम न्यायालये',
      'exploreProjects': 'नियुक्त प्रकल्प पहा',
      'howItWorks': 'प्रकल्प गुंतवणूक कशी काम करते',
      'paymentModes':
          'स्वीकृत पेमेंट पद्धती: बँक ट्रान्सफर (NEFT/RTGS), चेक, UPI',
      'paymentSafety':
          'पेमेंट सूचना, लागू असल्यास, अधिकृत प्रकल्प दस्तऐवज आणि प्रक्रियेद्वारे प्रदान केल्या जातील.',
      'legalReviewPendingWarning':
          'गुंतवणूक संधीच्या प्रकाशनासाठी कायदेशीर पुनरावलोकन आवश्यक आहे.',
      'ack1': 'मला समजते की ही एक प्रकल्प-विशिष्ट संधी आहे.',
      'ack2': 'मला समजते की परताव्याची कोणतीही हमी नाही.',
      'ack3': 'मला समजते की प्रत्यक्ष निकाल अपेक्षांपेक्षा भिन्न असू शकतात.',
      'ack4': 'मला समजते की बाजार आणि कायदेशीर जोखीम अस्तित्वात आहेत.',
      'ack5': 'मला समजते की प्रकल्प करार अंतिम अटींवर नियंत्रण ठेवतो.',
      'ack6': 'मला लागू दस्तऐवजांचे पुनरावलोकन करण्याची संधी मिळाली आहे.',
      'ack7':
          'मला समजते की चौकशी सबमिट केल्याने स्वयंचलित गुंतवणूक किंवा करार होत नाही.',
    },
  };

  String text(String key) {
    return _localizedValues[language]?[key] ??
        _localizedValues[InvestmentLanguage.english]![key] ??
        key;
  }
}

class InvestmentLanguageNotifier extends StateNotifier<InvestmentLanguage> {
  InvestmentLanguageNotifier() : super(InvestmentLanguage.english);

  InvestmentLanguage get currentLanguage => state;

  void setLanguage(InvestmentLanguage lang) {
    state = lang;
  }
}

final investmentLanguageProvider =
    StateNotifierProvider<InvestmentLanguageNotifier, InvestmentLanguage>((
      ref,
    ) {
      return InvestmentLanguageNotifier();
    });
