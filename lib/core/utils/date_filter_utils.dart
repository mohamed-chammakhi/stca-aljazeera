import '../analyses/ligne_analyse_labo.dart';
import '../models/echantillon.dart' as gestion;
import '../models/echantillon_evaluation.dart' as evaluation;
import 'package:project3/core/widgets/search_date_filter_bar.dart';

DateTime? normaliserDateFiltre(Object? valeur) {
  if (valeur == null) return null;
  if (valeur is DateTime) {
    return DateTime(valeur.year, valeur.month, valeur.day);
  }

  final texte = valeur.toString().trim();
  if (texte.isEmpty) return null;

  final iso = DateTime.tryParse(texte);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);

  final datePart = texte.split(' ').first;
  final parts = datePart.split('/');
  if (parts.length != 3) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

bool dateCorrespondAuFiltre(Object? valeur, {DateTime? debut, DateTime? fin}) {
  if (debut == null && fin == null) return true;

  final date = normaliserDateFiltre(valeur);
  if (date == null) return false;

  final debutJour = normaliserDateFiltre(debut);
  final finJour = normaliserDateFiltre(fin);
  if (debutJour != null && finJour != null) {
    return !date.isBefore(debutJour) && !date.isAfter(finJour);
  }
  if (debutJour != null) return !date.isBefore(debutJour);
  if (finJour != null) return !date.isAfter(finJour);
  return true;
}

String? dateGestionEchantillon(
  gestion.Echantillon echantillon,
  DateFilterType type,
) {
  switch (type) {
    case DateFilterType.enregistrement:
      return echantillon.dateAjout;
    case DateFilterType.livraisonEchantillon:
      return echantillon.dateArriveeEchantillon;
    case DateFilterType.receptionPhysique:
      return echantillon.dateReceptionEchantillon;
    case DateFilterType.arriveeStock:
      return echantillon.dateLivraisonStock;
  }
}

String? dateEvaluationEchantillon(
  evaluation.Echantillon echantillon,
  DateFilterType type,
) {
  switch (type) {
    case DateFilterType.enregistrement:
      return echantillon.dateAjout;
    case DateFilterType.livraisonEchantillon:
      return echantillon.dateArriveeEchantillon;
    case DateFilterType.receptionPhysique:
      return echantillon.dateReceptionEchantillon;
    case DateFilterType.arriveeStock:
      return null;
  }
}

String? dateAnalyseLabo(LigneAnalyseLabo analyse, DateFilterType type) {
  switch (type) {
    case DateFilterType.enregistrement:
      return analyse.dateAjout;
    case DateFilterType.livraisonEchantillon:
      return analyse.dateArriveeEchantillon;
    case DateFilterType.receptionPhysique:
      return analyse.dateReceptionEchantillon;
    case DateFilterType.arriveeStock:
      return null;
  }
}
