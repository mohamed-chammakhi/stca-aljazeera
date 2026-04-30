import '../../utilisateurs/models/echantillon_ceo_view.dart';

class CollecteurGroup {
  final String? collecteurNom;
  final String? collecteurId;
  final List<EchantillonCeoView> echantillons;

  CollecteurGroup({
    this.collecteurNom,
    this.collecteurId,
    required this.echantillons,
  });

  bool get isInterne => collecteurNom == null;
  String get displayName => collecteurNom ?? 'Ajoutés en interne';
}
