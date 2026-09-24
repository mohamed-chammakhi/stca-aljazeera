import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BandeauDemonstration extends StatelessWidget {
  final VoidCallback onReessayer;

  const BandeauDemonstration({super.key, required this.onReessayer});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kChipBgOrange,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kStatusOrange)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: kStatusOrange,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Données de démonstration — serveur injoignable',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onReessayer,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
              style: TextButton.styleFrom(
                foregroundColor: kStatusOrange,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErreurChargement extends StatelessWidget {
  final VoidCallback onReessayer;
  final String message;

  const ErreurChargement({
    super.key,
    required this.onReessayer,
    this.message = 'Impossible de charger les données.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: kRed, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kDark, fontSize: 14),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReessayer,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
              style: OutlinedButton.styleFrom(foregroundColor: kGreen),
            ),
          ],
        ),
      ),
    );
  }
}

/// Place le bandeau ou l'erreur de chargement autour du contenu d'un écran.
class VueResultatService extends StatelessWidget {
  final Widget child;
  final bool estDemonstration;
  final Object? erreur;
  final VoidCallback onReessayer;
  final Future<void> Function()? onRefresh;
  final Color couleurRafraichissement;

  const VueResultatService({
    super.key,
    required this.child,
    required this.estDemonstration,
    required this.erreur,
    required this.onReessayer,
    this.onRefresh,
    this.couleurRafraichissement = kGreen,
  });

  @override
  Widget build(BuildContext context) {
    final contenu = erreur == null
        ? child
        : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: ErreurChargement(onReessayer: onReessayer),
              ),
            ],
          );

    return Column(
      children: [
        if (estDemonstration)
          BandeauDemonstration(onReessayer: onReessayer),
        Expanded(
          child: onRefresh == null
              ? contenu
              : RefreshIndicator(
                  color: couleurRafraichissement,
                  onRefresh: onRefresh!,
                  child: contenu,
                ),
        ),
      ],
    );
  }
}
