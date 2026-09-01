import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/legal_notice_entities.dart';
import '../providers/legal_notice_providers.dart';

/// Single-Column Mobile-First Legal Notice Listing Wizard per CTO Master Directive
class AddLegalNoticeView extends ConsumerStatefulWidget {
  const AddLegalNoticeView({super.key});

  @override
  ConsumerState<AddLegalNoticeView> createState() => _AddLegalNoticeViewState();
}

class _AddLegalNoticeViewState extends ConsumerState<AddLegalNoticeView> {
  int _currentStep = 0; // 0 to 8 (9 steps)
  bool _isSubmitted = false;
  bool _isDraftSaved = false;
  final ImagePicker _picker = ImagePicker();

  // Step 1: Legal Notice Type
  LegalNoticeType _selectedNoticeType = LegalNoticeType.purchaseNotice;

  // Step 2: Property Identification & Location (Link existing or Manual)
  final TextEditingController _linkedPropertyIdController =
      TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String _category = 'Residential';
  final String _propertyType = 'Apartment';
  final TextEditingController _cityController = TextEditingController(
    text: 'Belagavi',
  );
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _surveyNumberController = TextEditingController();

  // Step 3: Parties Involved
  final TextEditingController _buyerNameController = TextEditingController();
  final TextEditingController _buyerAdvocateController =
      TextEditingController();
  final TextEditingController _sellerNameController = TextEditingController();

  // Step 4: Transaction & Notice Info
  String _transactionType = 'Purchase';
  final TextEditingController _agreedValueController = TextEditingController();
  final TextEditingController _effectiveDateController =
      TextEditingController();
  final TextEditingController _objectionPeriodController =
      TextEditingController(text: '14 Days');

  // Step 5: Full Notice Text & Public Summary
  final TextEditingController _publicSummaryController =
      TextEditingController();
  final TextEditingController _noticeFullTextController =
      TextEditingController();

  // Step 6: Real Photos
  final List<String> _propertyPhotos = [];
  final List<String> _photoLabels = [];
  final String _selectedPhotoLabel = 'Property Site Photo';

  // Step 7: Real Legal Documents (Private by Default)
  final List<String> _attachedDocuments = [];
  final List<String> _documentLabels = [];
  final String _selectedDocLabel = 'Public Notice Scan / Clipping';
  final bool _isDocumentPrivate = true;
  final bool _canAddDocumentsLater = true;

  // Step 8: Publication Information
  final TextEditingController _newspaperNameController =
      TextEditingController();
  final TextEditingController _editionController = TextEditingController(
    text: 'Belagavi Edition',
  );
  final TextEditingController _pageNumberController = TextEditingController();
  final TextEditingController _advocateFirmController = TextEditingController();

  // Step 9: Authorized Contact (Private)
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  String _contactRole = 'Buyer / Purchaser';

  static const List<String> _transactionTypesList = [
    'Purchase',
    'Sale',
    'Agreement to Sell',
    'Public Title Search Notice',
    'Objection / Claim Notice',
    'Commercial Lease',
    'Family Partition Deed',
    'Gift / Settlement Deed',
    'Cancellation Notice',
  ];

  static const List<String> _contactRolesList = [
    'Buyer / Purchaser',
    'Seller / Landowner',
    'Legal Advocate / Counsel',
    'Authorized Representative',
    'Claimant / Objector',
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthGate();
  }

  void _checkAuthGate() {
    final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();
    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthDialog();
      });
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text(
              'Authentication Required',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'You must be signed in to publish or record a Property Legal Notice.\n\nPlease log in to proceed.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/legal-notices');
              }
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(
                '/auth?redirect=${Uri.encodeComponent(AppRoutes.addLegalNotice)}',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In / Register'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _linkedPropertyIdController.dispose();
    _titleController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    _surveyNumberController.dispose();
    _buyerNameController.dispose();
    _buyerAdvocateController.dispose();
    _sellerNameController.dispose();
    _agreedValueController.dispose();
    _effectiveDateController.dispose();
    _objectionPeriodController.dispose();
    _publicSummaryController.dispose();
    _noticeFullTextController.dispose();
    _newspaperNameController.dispose();
    _editionController.dispose();
    _pageNumberController.dispose();
    _advocateFirmController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickRealPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _propertyPhotos.add(picked.path);
          _photoLabels.add(_selectedPhotoLabel);
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<void> _pickRealDocument() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked != null) {
        setState(() {
          _attachedDocuments.add(picked.path);
          _documentLabels.add(_selectedDocLabel);
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to attach document: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  void _onNext() async {
    if (_currentStep < 8) {
      if (_currentStep == 1 &&
          (_titleController.text.trim().isEmpty ||
              _localityController.text.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property Title and Locality required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep++);
    } else {
      if (_contactPhoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact Phone is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await _handleSubmit(isDraft: false);
    }
  }

  Future<void> _handleSubmit({required bool isDraft}) async {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ??
        AuthSessionStorageHelper.getUserUid() ??
        'usr_${DateTime.now().millisecondsSinceEpoch}';

    final noticeEntity = TransactionLegalNoticeEntity(
      id: 'not_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: _linkedPropertyIdController.text.trim().isNotEmpty
          ? _linkedPropertyIdController.text.trim()
          : 'prop_not_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'Legal Notice Record',
      category: _category,
      propertyType: _propertyType,
      city: _cityController.text.trim().isNotEmpty
          ? _cityController.text.trim()
          : 'Belagavi',
      locality: _localityController.text.trim().isNotEmpty
          ? _localityController.text.trim()
          : 'Belagavi',
      buyerName: _buyerNameController.text.trim().isNotEmpty
          ? _buyerNameController.text.trim()
          : 'Party Buyer',
      sellerName: _sellerNameController.text.trim().isNotEmpty
          ? _sellerNameController.text.trim()
          : 'Party Seller',
      contactName: _contactNameController.text.trim().isNotEmpty
          ? _contactNameController.text.trim()
          : 'Authorized Contact',
      contactPhone: _contactPhoneController.text.trim(),
      contactRole: _contactRole,
      transactionType: _transactionType,
      agreedValue: _agreedValueController.text.trim().isNotEmpty
          ? _agreedValueController.text.trim()
          : null,
      noticeType: _selectedNoticeType,
      publicNoticeSummary: _publicSummaryController.text.trim().isNotEmpty
          ? _publicSummaryController.text.trim()
          : null,
      noticeFullText: _noticeFullTextController.text.trim().isNotEmpty
          ? _noticeFullTextController.text.trim()
          : null,
      publicationInfo: _newspaperNameController.text.trim().isNotEmpty
          ? NoticePublicationEntity(
              newspaperName: _newspaperNameController.text.trim(),
              edition: _editionController.text.trim(),
              pageNumber: _pageNumberController.text.trim().isNotEmpty
                  ? _pageNumberController.text.trim()
                  : null,
              advocateFirm: _advocateFirmController.text.trim().isNotEmpty
                  ? _advocateFirmController.text.trim()
                  : null,
            )
          : null,
      photoUrls: _propertyPhotos,
      documentUrls: _attachedDocuments,
      photoLabels: _photoLabels,
      documentLabels: _documentLabels,
      isDocumentPrivate: _isDocumentPrivate,
      canAddDocumentsLater: _canAddDocumentsLater,
      verificationStatus: isDraft
          ? LegalNoticeStatus.draft
          : LegalNoticeStatus.underReview,
      recordedBy: currentUserId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(legalNoticeRepositoryProvider);
    final result = await repo.createLegalNotice(
      noticeEntity,
      authenticatedUserId: currentUserId,
    );

    result.fold(
      (failure) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
      },
      (created) {
        ref.read(legalNoticesNotifierProvider.notifier).loadLegalNotices();
        if (mounted)
          setState(() {
            if (isDraft) {
              _isDraftSaved = true;
            } else {
              _isSubmitted = true;
            }
          });
      },
    );
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else if (context.canPop())
      context.pop();
    else
      context.go('/legal-notices');
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) return _buildSuccessScreen(context);
    if (_isDraftSaved) return _buildDraftSavedScreen(context);

    return Scaffold(
      backgroundColor: AppDesignSystem.scaffoldBg(context),
      appBar: AppBar(
        title: const Text(
          'Record Property Legal Notice',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppDesignSystem.surfaceBg(context),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppDesignSystem.textP(context),
          ),
          onPressed: _onBack,
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _handleSubmit(isDraft: true),
            icon: const Icon(
              Icons.save_outlined,
              size: 14,
              color: Color(0xFF0284C7),
            ),
            label: const Text(
              'Save Draft',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStepBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(context, _currentStep),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildNavigationButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBar(BuildContext context) {
    final progress = (_currentStep + 1) / 9;
    return Container(
      color: AppDesignSystem.surfaceBg(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of 9',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${(progress * 100).toInt()}%'),
            ],
          ),
          LinearProgressIndicator(
            value: progress,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, int step) {
    return switch (step) {
      0 => _buildStep1NoticeType(context),
      1 => _buildStep2PropertyIdentification(context),
      2 => _buildStep3Parties(context),
      3 => _buildStep4TransactionDetails(context),
      4 => _buildStep5NoticeText(context),
      5 => _buildStep6RealPhotos(context),
      6 => _buildStep7RealDocuments(context),
      7 => _buildStep8PublicationInfo(context),
      8 => _buildStep9ReviewAndSubmit(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildStep1NoticeType(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Legal Notice Type (16 Types)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<LegalNoticeType>(
          initialValue: _selectedNoticeType,
          items: LegalNoticeType.values
              .take(16)
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.title, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(
            () => _selectedNoticeType = v ?? LegalNoticeType.purchaseNotice,
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2PropertyIdentification(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Property Title / Identifier *',
          'e.g. 3 BHK Villa in Tilakwadi',
          _titleController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _category,
                items:
                    ['Residential', 'Plots & Layouts', 'Commercial', 'Raw Land']
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) =>
                    setState(() => _category = v ?? 'Residential'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField('City', 'Belagavi', _cityController),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Locality / Area *',
          'e.g. Tilakwadi, Shahapur, Camp',
          _localityController,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Survey / CTS No.',
          'e.g. CTS No. 4412/A',
          _surveyNumberController,
        ),
      ],
    );
  }

  Widget _buildStep3Parties(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Buyer / Purchaser Name',
          'e.g. Amit Patil',
          _buyerNameController,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          'Buyer Advocate / Firm',
          'e.g. Adv. Kulkarni & Associates',
          _buyerAdvocateController,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Seller / Vendor Name',
          'e.g. Suresh Desai',
          _sellerNameController,
        ),
      ],
    );
  }

  Widget _buildStep4TransactionDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _transactionType,
          items: _transactionTypesList
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(t, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _transactionType = v ?? 'Purchase'),
          decoration: const InputDecoration(
            labelText: 'Transaction Type',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Agreed / Declared Value',
          'e.g. ₹65,00,000',
          _agreedValueController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Notice Date',
                'e.g. 2026-03-01',
                _effectiveDateController,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                'Objection Window',
                '14 Days',
                _objectionPeriodController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5NoticeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Public Notice Summary *',
          'Brief summary of notice to public / interested parties',
          _publicSummaryController,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Full Notice Text (Optional)',
          'Paste entire text of newspaper / legal notice...',
          _noticeFullTextController,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildStep6RealPhotos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Site Photos (Camera / Gallery)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickRealPhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickRealPhoto(ImageSource.gallery),
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: Color(0xFF0284C7),
                ),
                label: const Text(
                  'From Gallery',
                  style: TextStyle(color: Color(0xFF0284C7)),
                ),
              ),
            ),
          ],
        ),
        if (_propertyPhotos.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._propertyPhotos.asMap().entries.map(
            (e) => ListTile(
              dense: true,
              leading: const Icon(Icons.image, color: Colors.blue),
              title: Text(
                'Photo #${e.key + 1}',
                style: const TextStyle(fontSize: 12),
              ),
              subtitle: Text(
                e.value.split(RegExp(r'[\\/]')).last,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red,
                ),
                onPressed: () =>
                    setState(() => _propertyPhotos.removeAt(e.key)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep7RealDocuments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Privacy Notice: Legal notice clippings and deeds are kept private and accessible only to moderators.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF)),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickRealDocument,
          icon: const Icon(Icons.attach_file, size: 16),
          label: const Text('Attach Notice Scan / PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
          ),
        ),
        if (_attachedDocuments.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._attachedDocuments.asMap().entries.map(
            (e) => ListTile(
              dense: true,
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(
                'Document #${e.key + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                e.value.split(RegExp(r'[\\/]')).last,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red,
                ),
                onPressed: () =>
                    setState(() => _attachedDocuments.removeAt(e.key)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep8PublicationInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Newspaper / Gazette Name',
          'e.g. Tarun Bharat / Vijayavani / Times of India',
          _newspaperNameController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Edition',
                'Belagavi Edition',
                _editionController,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                'Page No.',
                'e.g. 5',
                _pageNumberController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Advocate / Law Firm',
          'e.g. Patil & Associates, Belagavi',
          _advocateFirmController,
        ),
      ],
    );
  }

  Widget _buildStep9ReviewAndSubmit(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Contact Person *',
          'Your full name',
          _contactNameController,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Contact Phone *',
          'e.g. +91 94801 22334',
          _contactPhoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _contactRole,
          items: _contactRolesList
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: (v) =>
              setState(() => _contactRole = v ?? 'Buyer / Purchaser'),
          decoration: const InputDecoration(
            labelText: 'Your Standing',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF93C5FD)),
          ),
          child: const Text(
            'STATUTORY NOTICE DECLARATION\n'
            'I confirm that this notice is published in good faith for title verification and due diligence purposes.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF1E40AF),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _onBack,
              child: const Text('Back'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
            ),
            child: Text(
              _currentStep == 8 ? 'Submit Legal Notice' : 'Continue →',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AppDesignSystem.textP(context),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: AppDesignSystem.textP(context), fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppDesignSystem.textS(context),
              fontSize: 12,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: AppDesignSystem.inputBg(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppDesignSystem.borderCol(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppDesignSystem.borderCol(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0284C7),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.scaffoldBg(context),
      appBar: AppBar(
        title: const Text('Legal Notice Submitted'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF16A34A),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Legal Notice Recorded Successfully',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Your property legal notice has been recorded and submitted to the platform registry. Supporting private attachments are protected.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppDesignSystem.textS(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/legal-notices'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Return to Legal Notice Hub'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraftSavedScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.scaffoldBg(context),
      appBar: AppBar(
        title: const Text('Draft Saved'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.save_outlined,
                color: Color(0xFF0284C7),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Legal Notice Draft Saved',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Your legal notice draft has been saved. You can complete and submit it whenever you are ready.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppDesignSystem.textS(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/legal-notices'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Return to Legal Notice Hub'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
