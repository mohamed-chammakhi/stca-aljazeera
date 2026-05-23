from rest_framework import status
from rest_framework.test import APITestCase

from echantillons.models import Echantillon
from users.models import User

from .models import EvaluationOrganoleptique


class EvaluationOrganoleptiqueApiTests(APITestCase):
    def setUp(self):
        self.degustateur = User.objects.create_user(
            email='degustateur.eval@example.com',
            password='Test@12345',
            nom='Degustateur',
            prenom='One',
            role=User.Role.DEGUSTATEUR,
        )
        self.other_degustateur = User.objects.create_user(
            email='degustateur.other@example.com',
            password='Test@12345',
            nom='Degustateur',
            prenom='Two',
            role=User.Role.DEGUSTATEUR,
        )
        self.collecteur = User.objects.create_user(
            email='collecteur.eval@example.com',
            password='Test@12345',
            nom='Collecteur',
            prenom='User',
            role=User.Role.COLLECTEUR,
        )
        self.sample = Echantillon.objects.create(
            reference_bouteille='EV-001',
            collecteur=self.collecteur,
            gouvernorat='Sfax',
            delegation='Sfax Sud',
            variete='Chemlali',
            recu_physiquement=True,
        )

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

    def test_degustateur_can_create_own_evaluation(self):
        self.authenticate(self.degustateur)

        response = self.client.post(
            '/api/evaluations/',
            {
                'echantillon': str(self.sample.id),
                'fruite': '4.0',
                'classification': 'extra_vierge',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        evaluation = EvaluationOrganoleptique.objects.get(id=response.json()['id'])
        self.assertEqual(evaluation.degustateur, self.degustateur)
        self.sample.refresh_from_db()
        self.assertEqual(
            self.sample.statut_degustateur,
            Echantillon.StatutDegustateur.EN_COURS,
        )

    def test_evaluation_requires_physical_reception(self):
        pending = Echantillon.objects.create(
            reference_bouteille='EV-002',
            collecteur=self.collecteur,
            gouvernorat='Sfax',
            variete='Chemlali',
            recu_physiquement=False,
        )
        self.authenticate(self.degustateur)

        response = self.client.post(
            '/api/evaluations/',
            {'echantillon': str(pending.id), 'fruite': '3.0'},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_degustateur_lists_only_own_evaluations(self):
        own = EvaluationOrganoleptique.objects.create(
            echantillon=self.sample,
            degustateur=self.degustateur,
            fruite='4.0',
        )
        EvaluationOrganoleptique.objects.create(
            echantillon=self.sample,
            degustateur=self.other_degustateur,
            fruite='2.0',
        )
        self.authenticate(self.degustateur)

        response = self.client.get('/api/evaluations/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        results = data.get('results', data)
        ids = {item['id'] for item in results}
        self.assertEqual(ids, {str(own.id)})

    def test_submitted_evaluation_is_read_only(self):
        evaluation = EvaluationOrganoleptique.objects.create(
            echantillon=self.sample,
            degustateur=self.degustateur,
            fruite='4.0',
            statut=EvaluationOrganoleptique.Statut.SOUMIS,
        )
        self.authenticate(self.degustateur)

        response = self.client.patch(
            f'/api/evaluations/{evaluation.id}/',
            {'fruite': '7.0'},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        evaluation.refresh_from_db()
        self.assertEqual(str(evaluation.fruite), '4.0')

    def test_collecteur_cannot_create_evaluation(self):
        self.authenticate(self.collecteur)

        response = self.client.post(
            '/api/evaluations/',
            {'echantillon': str(self.sample.id), 'fruite': '4.0'},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
