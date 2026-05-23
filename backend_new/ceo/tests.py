from decimal import Decimal
from datetime import timedelta

from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from analyses.models import AnalyseLabo
from echantillons.models import Echantillon
from fournisseurs.models import Fournisseur
from users.models import User


class CeoDashboardApiTests(APITestCase):
    def setUp(self):
        self.direction = User.objects.create_user(
            email='direction.dashboard@example.com',
            password='Test@12345',
            nom='Direction',
            prenom='User',
            role=User.Role.DIRECTION,
        )
        self.collecteur = User.objects.create_user(
            email='collecteur.dashboard@example.com',
            password='Test@12345',
            nom='Collector',
            prenom='One',
            role=User.Role.COLLECTEUR,
        )
        self.other_collecteur = User.objects.create_user(
            email='collecteur.dashboard.other@example.com',
            password='Test@12345',
            nom='Collector',
            prenom='Two',
            role=User.Role.COLLECTEUR,
        )
        self.lab = User.objects.create_user(
            email='lab.dashboard@example.com',
            password='Test@12345',
            nom='Lab',
            prenom='Tech',
            role=User.Role.LABORATOIRE,
        )
        self.supplier = Fournisseur.objects.create(
            code_fournisseur='SUP-CEO-1',
            nom='Domaine Test',
            region='Sfax',
        )

        self.received = Echantillon.objects.create(
            reference_bouteille='REF-CEO-001',
            fournisseur=self.supplier,
            collecteur=self.collecteur,
            gouvernorat='Sfax',
            variete='Chemlali',
            recu_physiquement=True,
            statut_collecteur=Echantillon.StatutCollecteur.RECEPTIONNE,
            statut_degustateur=Echantillon.StatutDegustateur.EN_COURS,
        )
        self.negotiation = Echantillon.objects.create(
            reference_bouteille='REF-CEO-002',
            fournisseur=self.supplier,
            collecteur=self.collecteur,
            gouvernorat='Sfax',
            variete='Chetoui',
            statut_collecteur=Echantillon.StatutCollecteur.EN_NEGOCIATION,
            statut_ceo=Echantillon.StatutCEO.EN_NEGOCIATION,
        )
        self.purchase = Echantillon.objects.create(
            reference_bouteille='REF-CEO-003',
            fournisseur=self.supplier,
            collecteur=self.collecteur,
            gouvernorat='Sfax',
            variete='Oueslati',
            statut_collecteur=Echantillon.StatutCollecteur.ACHAT_CONFIRME,
            statut_ceo=Echantillon.StatutCEO.ACHAT_CONFIRME,
            prix_final=Decimal('1200.50'),
            stock_arrive=True,
            classification=Echantillon.Classification.EXTRA_VIERGE,
        )
        self.urgent = Echantillon.objects.create(
            reference_bouteille='REF-CEO-004',
            collecteur=self.other_collecteur,
            gouvernorat='Nabeul',
            variete='Arbequina',
            recu_physiquement=True,
            statut_collecteur=Echantillon.StatutCollecteur.RECEPTIONNE,
            statut_degustateur=Echantillon.StatutDegustateur.SOUMIS,
            statut_ceo=Echantillon.StatutCEO.SELECTIONNE,
        )
        self.refused = Echantillon.objects.create(
            reference_bouteille='REF-CEO-005',
            collecteur=self.other_collecteur,
            gouvernorat='Beja',
            variete='Zalmati',
            statut_ceo=Echantillon.StatutCEO.REFUSE,
        )
        AnalyseLabo.objects.create(
            echantillon=self.purchase,
            technicien=self.lab,
            statut=AnalyseLabo.Statut.SOUMIS,
        )

        old_date = timezone.now() - timedelta(days=3)
        Echantillon.objects.filter(id=self.urgent.id).update(updated_at=old_date)

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

    def test_dashboard_is_direction_only(self):
        self.authenticate(self.collecteur)

        response = self.client.get('/api/ceo/dashboard/')

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_dashboard_returns_kpis_pipeline_and_aggregations(self):
        self.authenticate(self.direction)

        response = self.client.get('/api/ceo/dashboard/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()

        self.assertEqual(data['echantillons_total'], 5)
        self.assertEqual(data['achats_confirmes'], 1)
        self.assertEqual(data['stocks_arrives'], 1)
        self.assertEqual(data['evaluations_en_attente'], 1)
        self.assertEqual(data['analyses_soumises'], 1)

        self.assertEqual(data['pipeline']['receptionne'], 3)
        self.assertEqual(data['pipeline']['en_negociation'], 1)
        self.assertEqual(data['pipeline']['achat_confirme'], 1)
        self.assertEqual(data['pipeline']['refuse'], 1)

        self.assertEqual(data['kpis']['investissement_total'], 1200.5)
        self.assertEqual(data['stock'], {'en_transit': 0, 'recu': 1})
        self.assertEqual(data['classifications']['extra_vierge'], 1)
        self.assertEqual(data['fournisseurs'][0]['nom'], 'Domaine Test')
        self.assertEqual(data['fournisseurs'][0]['achats'], 1)
        self.assertEqual(data['performance_collecteurs'][0]['samples'], 3)
        self.assertEqual(data['decisions_urgentes'][0]['id'], str(self.urgent.id))
        self.assertGreaterEqual(data['decisions_urgentes'][0]['jours_en_attente'], 3)
        self.assertEqual(len(data['evolution_achats']), 6)

    def test_dashboard_date_filters_use_sample_creation_date(self):
        old_date = timezone.now() - timedelta(days=40)
        Echantillon.objects.filter(id=self.purchase.id).update(date_ajout=old_date)
        self.authenticate(self.direction)
        start = (timezone.now() - timedelta(days=7)).date().isoformat()

        response = self.client.get(f'/api/ceo/dashboard/?date_debut={start}')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data['echantillons_total'], 4)
        self.assertEqual(data['achats_confirmes'], 0)
        self.assertEqual(data['analyses_soumises'], 0)
