import 'package:equatable/equatable.dart';
import '../entities/property_entities.dart';

class PropertyChecklistItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isMandatory;
  final bool isCompleted;

  const PropertyChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    this.isMandatory = true,
    this.isCompleted = false,
  });

  PropertyChecklistItem copyWith({bool? isCompleted}) {
    return PropertyChecklistItem(
      id: id,
      title: title,
      description: description,
      isMandatory: isMandatory,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

class PropertyChecklistTemplate extends Equatable {
  static const String legalDisclaimer = 'Informational checklist only, not formal legal verification or legal advice.';

  final PropertyCategory category;
  final String title;
  final List<PropertyChecklistItem> items;

  const PropertyChecklistTemplate({
    required this.category,
    required this.title,
    required this.items,
  });

  @override
  List<Object?> get props => [category, title, items];
}

class PropertyChecklistService {
  /// Get default checklist template by property category
  static PropertyChecklistTemplate getTemplateForCategory(PropertyCategory category) {
    switch (category) {
      case PropertyCategory.residential:
        return const PropertyChecklistTemplate(
          category: PropertyCategory.residential,
          title: 'Residential Purchase Due-Diligence Checklist',
          items: [
            PropertyChecklistItem(id: 'res_1', title: 'Registered Sale Deed / Title Deed', description: 'Verify chain of ownership for minimum 30 years.'),
            PropertyChecklistItem(id: 'res_2', title: 'Encumbrance Certificate (EC)', description: 'Ensure nil encumbrance from the Sub-Registrar office for minimum 15 years.'),
            PropertyChecklistItem(id: 'res_3', title: 'Khata Certificate & Extract', description: 'Verify A-Khata or municipal revenue registration in seller name.'),
            PropertyChecklistItem(id: 'res_4', title: 'Approved Building Plan & OC', description: 'Confirm layout sanctions from BUDA / City Corporation.'),
            PropertyChecklistItem(id: 'res_5', title: 'Latest Property Tax Receipts', description: 'Confirm all municipal property taxes are paid up to date.'),
          ],
        );

      case PropertyCategory.plotLand:
      case PropertyCategory.land:
        return const PropertyChecklistTemplate(
          category: PropertyCategory.plotLand,
          title: 'Plot & Land Due-Diligence Checklist',
          items: [
            PropertyChecklistItem(id: 'plot_1', title: 'Non-Agricultural (NA) Order', description: 'Verify DC conversion order from agricultural to residential/commercial.'),
            PropertyChecklistItem(id: 'plot_2', title: 'Town Planning / BUDA Layout Sanction', description: 'Ensure approved layout map with open spaces and road demarcation.'),
            PropertyChecklistItem(id: 'plot_3', title: 'Survey Map & Boundary Demarcation (Tippani / PT Sheet)', description: 'Physically verify coordinates and approach road width.'),
            PropertyChecklistItem(id: 'plot_4', title: 'Encumbrance Certificate (Form 15)', description: 'Verify clear title without pending mortgages or bank attachments.'),
            PropertyChecklistItem(id: 'plot_5', title: 'RTC / Pahani Records', description: 'Verify owner name and tenancy/cultivation column status.'),
          ],
        );

      case PropertyCategory.commercial:
        return const PropertyChecklistTemplate(
          category: PropertyCategory.commercial,
          title: 'Commercial Property Checklist',
          items: [
            PropertyChecklistItem(id: 'com_1', title: 'Commercial Zone Sanction Order', description: 'Ensure zoning allows commercial business activity.'),
            PropertyChecklistItem(id: 'com_2', title: 'Fire NOC & Safety Approvals', description: 'Verify safety clearances for multi-story commercial structure.'),
            PropertyChecklistItem(id: 'com_3', title: 'Occupancy Certificate (OC)', description: 'Confirm completion and municipal clearance for occupancy.'),
            PropertyChecklistItem(id: 'com_4', title: 'Power & Water Load Sanction', description: 'Verify sanctioned power capacity from HESCOM.'),
          ],
        );

      default:
        return const PropertyChecklistTemplate(
          category: PropertyCategory.other,
          title: 'General Property Verification Checklist',
          items: [
            PropertyChecklistItem(id: 'gen_1', title: 'Identity Verification of Seller', description: 'Match Aadhaar/PAN with registered property documents.'),
            PropertyChecklistItem(id: 'gen_2', title: 'Original Document Inspection', description: 'Physically inspect original title documents before advance.'),
          ],
        );
    }
  }
}
