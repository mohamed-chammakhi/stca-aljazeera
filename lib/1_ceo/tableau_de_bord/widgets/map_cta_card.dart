import 'package:flutter/material.dart';

const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);

/// CTA banner that navigates to the coverage map.
class MapCtaCard extends StatelessWidget {
  const MapCtaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Carte de couverture — en cours de développement'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 64,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: _dark),
              Image.asset(
                'assets/img/continents.png',
                fit: BoxFit.cover,
                color: Colors.white.withValues(alpha: 0.14),
                colorBlendMode: BlendMode.srcIn,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Carte de couverture',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Délégations visitées par vos collecteurs',
                            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white.withValues(alpha: 0.45)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
