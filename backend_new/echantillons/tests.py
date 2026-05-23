from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from fournisseurs.models import Fournisseur
from notifications.models import Notification
from users.models import User

from .models import Echantillon


class CollectorEchantillonApiTests(APITestCase):
    def setUp(self):
        self.collector = User.objects.create_user(
            email='collecteur1@example.com',
            password='Test@12345',
            nom='Collecteur',
            prenom='One',
            role=User.Role.COLLECTEUR,
        )
        self.other_collector = User.objects.create_user(
            email='collecteur2@example.com',
            password='Test@12345',
            nom='Collecteur',
            prenom='Two',
            role=User.Role.COLLECTEUR,
        )
        self.direction = User.objects.create_user(
            email='direction2@example.com',
            password='Test@12345',
            nom='Direction',
            prenom='User',
            role=User.Role.DIRECTION,
        )
        self.degustateur = User.objects.create_user(
            email='degustateur.reception@example.com',
            password='Test@12345',
            nom='Degustateur',
            prenom='User',
            role=User.Role.DEGUSTATEUR,
        )

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

    def results(self, response):
        data = response.json()
        return data.get('results', data)

    def create_sample(self, collecteur, **extra):
        data = {
            'reference_bouteille': 'B-001',
            'collecteur': collecteur,
            'gouvernorat': 'Sfax',
            'delegation': 'Sfax Sud',
            'variete': 'Chemlali',
        }
        data.update(extra)
        return Echantillon.objects.create(**data)

    def test_collector_only_lists_own_samples(self):
        own = self.create_sample(self.collector, reference_bouteille='OWN')
        other = self.create_sample(self.other_collector, reference_bouteille='OTHER')
        self.authenticate(self.collector)

        response = self.client.get('/api/echantillons/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = {item['id'] for item in self.results(response)}
        self.assertIn(str(own.id), ids)
        self.assertNotIn(str(other.id), ids)

    def test_collector_can_create_sample_with_supplier_code(self):
        self.authenticate(self.collector)

        response = self.client.post(
            '/api/echantillons/',
            {
                'reference_bouteille': 'CHEM-001',
                'code_fournisseur': 'SF-42',
                'gouvernorat': 'Sfax',
                'delegation': 'Sfax Sud',
                'variete': 'Chemlali',
                'quantite_estimee': '20L',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data = response.json()
        self.assertTrue(data['numero'])
        self.assertEqual(data['code_fournisseur'], 'SF-42')
        sample = Echantillon.objects.get(id=data['id'])
        self.assertEqual(sample.collecteur, self.collector)
        self.assertEqual(sample.fournisseur.code_fournisseur, 'SF-42')
        self.assertTrue(Fournisseur.objects.filter(code_fournisseur='SF-42').exists())

    def test_direction_cannot_create_collector_sample(self):
        self.authenticate(self.direction)

        response = self.client.post(
            '/api/echantillons/',
            {
                'reference_bouteille': 'DIR-001',
                'gouvernorat': 'Sfax',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_delete_blocked_after_physical_reception(self):
        sample = self.create_sample(
            self.collector,
            recu_physiquement=True,
            date_arrivee_echantillon=timezone.now(),
        )
        self.authenticate(self.collector)

        response = self.client.delete(f'/api/echantillons/{sample.id}/')

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertTrue(Echantillon.objects.filter(id=sample.id).exists())

    def test_collector_purchase_action_submits_proposal_only_when_in_negotiation(self):
        sample = self.create_sample(
            self.collector,
            statut_collecteur=Echantillon.StatutCollecteur.EN_NEGOCIATION,
            statut_ceo=Echantillon.StatutCEO.EN_NEGOCIATION,
            quantite_cible_t='40',
        )
        self.authenticate(self.collector)
        Notification.objects.all().delete()

        response = self.client.post(
            f'/api/echantillons/{sample.id}/confirmer-achat/',
            {'prix_final': '14.50 TND/L', 'camion_reserve': 'TU-1234'},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        sample.refresh_from_db()
        self.assertEqual(sample.statut_collecteur, Echantillon.StatutCollecteur.EN_NEGOCIATION)
        self.assertEqual(sample.statut_ceo, Echantillon.StatutCEO.EN_NEGOCIATION)
        self.assertEqual(str(sample.budget_negociation), '14.50')
        self.assertEqual(str(sample.prix_final), '14.50')
        notification = Notification.objects.get(
            destinataire=self.direction,
            type=Notification.Type.PROPOSITION_ACHAT_ATTENTE,
        )
        self.assertEqual(notification.section, Notification.Section.ACHATS_VALIDATION)
        self.assertEqual(notification.echantillon, sample)

    def test_direction_lists_purchase_proposals_awaiting_validation(self):
        awaiting = self.create_sample(
            self.collector,
            reference_bouteille='PROP-A',
            statut_collecteur=Echantillon.StatutCollecteur.EN_NEGOCIATION,
            statut_ceo=Echantillon.StatutCEO.EN_NEGOCIATION,
            budget_negociation='8.20',
        )
        self.create_sample(
            self.collector,
            reference_bouteille='NEGOTIATION-ONLY',
            statut_collecteur=Echantillon.StatutCollecteur.EN_NEGOCIATION,
            statut_ceo=Echantillon.StatutCEO.EN_NEGOCIATION,
        )
        self.create_sample(
            self.collector,
            reference_bouteille='REFUSED-PROP',
            statut_collecteur=Echantillon.StatutCollecteur.EN_NEGOCIATION,
            statut_ceo=Echantillon.StatutCEO.REFUSE,
            budget_negociation='8.00',
        )
        self.authenticate(self.direction)

        response = self.client.get('/api/echantillons/?statut=en_negociation&proposition_soumise=true')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = {item['id'] for item in self.results(response)}
        self.assertEqual(ids, {str(awaiting.id)})

    def test_direction_lists_decided_purchase_proposals(self):
        confirmed = self.create_sample(
            self.collector,
            statut_collecteur=Echantillon.StatutCollecteur.ACHAT_CONFIRME,
            statut_ceo=Echantillon.StatutCEO.ACHAT_CONFIRME,
        )
        refused = self.create_sample(
            self.collector,
            statut_collecteur=Echantillon.StatutCollecteur.EN_NEGOCIATION,
            statut_ceo=Echantillon.StatutCEO.REFUSE,
            raison_refus='Prix trop eleve',
        )
        self.create_sample(self.collector)
        self.authenticate(self.direction)

        response = self.client.get('/api/echantillons/?statut__in=achat_confirme,refuse')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = {item['id'] for item in self.results(response)}
        self.assertEqual(ids, {str(confirmed.id), str(refused.id)})

    def test_direction_confirms_purchase_proposal(self):
        sample = self.create_sample(
            self.collector,
            statut_collecteur=Echantillon.StatutCollecteur.EN_NEGOCIATION,
            statut_ceo=Echantillon.StatutCEO.EN_NEGOCIATION,
            budget_negociation='8.20',
        )
        self.authenticate(self.direction)
        Notification.objects.all().delete()

        response = self.client.post(f'/api/echantillons/{sample.id}/confirmer-achat/', {}, format='json')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        sample.refresh_from_db()
        self.assertEqual(sample.statut_collecteur, Echantillon.StatutCollecteur.ACHAT_CONFIRME)
        self.assertEqual(sample.statut_ceo, Echantillon.StatutCEO.ACHAT_CONFIRME)
        self.assertFalse(sample.stock_arrive)
        self.assertTrue(
            Notification.objects.filter(
                destinataire=self.direction,
                type=Notification.Type.ACHAT_CONFIRME,
                echantillon=sample,
            ).exists()
        )

    def test_direction_refuses_purchase_proposal_with_reason(self):
        sample = self.create_sample(
            self.collector,
            statut_collecteur=Echantillon.StatutCollecteur.EN_NEGOCIATION,
            statut_ceo=Echantillon.StatutCEO.EN_NEGOCIATION,
            budget_negociation='8.20',
        )
        self.authenticate(self.direction)

        response = self.client.post(
            f'/api/echantillons/{sample.id}/refuser-achat/',
            {'raison_refus': 'Prix trop eleve'},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        sample.refresh_from_db()
        self.assertEqual(sample.statut_ceo, Echantillon.StatutCEO.REFUSE)
        self.assertEqual(sample.raison_refus, 'Prix trop eleve')

    def test_degustateur_can_confirm_physical_reception(self):
        sample = self.create_sample(self.collector, recu_physiquement=False)
        self.authenticate(self.degustateur)

        response = self.client.post(
            f'/api/echantillons/{sample.id}/confirmer-reception/',
            {},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        sample.refresh_from_db()
        self.assertTrue(sample.recu_physiquement)
        self.assertIsNotNone(sample.date_arrivee_echantillon)
