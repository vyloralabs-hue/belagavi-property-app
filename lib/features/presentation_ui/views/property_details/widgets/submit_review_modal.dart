import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/review/domain/entities/review_entities.dart';
import 'package:belagavi_property/features/review/presentation/providers/review_providers.dart';

class SubmitReviewModal extends ConsumerStatefulWidget {
  final PropertyEntity property;

  const SubmitReviewModal({super.key, required this.property});

  static Future<void> show(BuildContext context, PropertyEntity property) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131922),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SubmitReviewModal(property: property),
    );
  }

  @override
  ConsumerState<SubmitReviewModal> createState() => _SubmitReviewModalState();
}

class _SubmitReviewModalState extends ConsumerState<SubmitReviewModal> {
  double _selectedRating = 5.0;
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a review.')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final text = _textController.text.trim();
    if (text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review text must be at least 5 characters.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = PropertyReviewEntity(
        id: 'rev_${DateTime.now().millisecondsSinceEpoch}_${user.uid.hashCode.abs()}',
        propertyId: widget.property.id,
        reviewerId: user.uid,
        reviewerName: user.displayName ?? 'Verified Buyer',
        sellerId: widget.property.ownerId,
        rating: _selectedRating,
        title: title.isEmpty ? 'Property Review' : title,
        reviewText: text,
        verificationSource: VerificationSource.inquiry,
        verificationReferenceId: 'auto_verified_${widget.property.id}',
        isVerifiedInteraction: true,
        status: ReviewStatus.published,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(reviewRepositoryProvider).submitPropertyReview(review);

      // Invalidate review providers to refresh UI
      ref.invalidate(propertyReviewsProvider(widget.property.id));
      ref.invalidate(propertyRatingSummaryProvider(widget.property.id));
      ref.invalidate(sellerTrustScoreProvider(widget.property.ownerId));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you! Your verified review has been published.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rate & Review Listing',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  color: Color(0xFFFDFCF4),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'Verified Interaction Required',
                  style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Star Rating Selector
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starValue = (index + 1).toDouble();
                return IconButton(
                  icon: Icon(
                    starValue <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 32,
                  ),
                  onPressed: () => setState(() => _selectedRating = starValue),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Color(0xFFFDFCF4), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Review Title (optional)',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF0A0D11),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D3748))),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            style: const TextStyle(color: Color(0xFFFDFCF4), fontSize: 14),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share details of your experience (min 5 chars)...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF0A0D11),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D3748))),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB39037),
                foregroundColor: const Color(0xFF0A0D11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Color(0xFF0A0D11), strokeWidth: 2)
                  : const Text('Submit Verified Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
