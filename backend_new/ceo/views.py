from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Count
from django.utils import timezone
from datetime import timedelta
from echantillons.models import Echantillon


def _month_start(base_dt, months_back):
    month = base_dt.month - months_back
    year = base_dt.year
    while month <= 0:
        month += 12
        year -= 1
    return base_dt.replace(year=year, month=month, day=1, hour=0, minute=0, second=0, microsecond=0)


class CeoDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        now = timezone.now()
        thirty_days_ago = now - timedelta(days=30)

        kpis = {
            'total': Echantillon.objects.count(),
            'receptionnes': Echantillon.objects.filter(statut_collecteur='receptionne').count(),
            'en_negociation': Echantillon.objects.filter(statut_collecteur='en_negociation').count(),
            'achat_confirme': Echantillon.objects.filter(statut_collecteur='achat_confirme').count(),
            'refuses': Echantillon.objects.filter(statut_ceo='refuse').count(),
        }

        performance_collecteurs = list(
            Echantillon.objects
            .filter(date_ajout__gte=thirty_days_ago, collecteur__isnull=False)
            .values('collecteur__nom', 'collecteur__prenom')
            .annotate(nb=Count('id'))
            .order_by('-nb')[:5]
        )

        evolution_achats = []
        for i in range(5, -1, -1):
            month_start = _month_start(now, i)
            if month_start.month == 12:
                month_end = month_start.replace(year=month_start.year + 1, month=1)
            else:
                month_end = month_start.replace(month=month_start.month + 1)
            count = Echantillon.objects.filter(
                statut_collecteur='achat_confirme',
                date_ajout__gte=month_start,
                date_ajout__lt=month_end
            ).count()
            evolution_achats.append({
                'label': month_start.strftime('%b %Y'),
                'count': count
            })

        return Response({
            'kpis': kpis,
            'performance_collecteurs': performance_collecteurs,
            'evolution_achats': evolution_achats,
        })
