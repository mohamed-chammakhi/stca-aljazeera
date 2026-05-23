from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from echantillons.models import Echantillon
from users.models import User

from .models import AnalyseLabo


class AnalyseLaboApiTests(APITestCase):
    def setUp(self):
        self.lab = User.objects.create_user(
            email='labo@example.com',
            password='Test@12345',
            nom='Labo',
            prenom='Technicien',
            role=User.Role.LABORATOIRE,
        )
        self.direction = User.objects.create_user(
            email='direction@example.com',
            password='Test@12345',
            nom='Direction',
            prenom='User',
            role=User.Role.DIRECTION,
        )
        self.collecteur = User.objects.create_user(
            email='collecteur@example.com',
            password='Test@12345',
            nom='Collecteur',
            prenom='User',
            role=User.Role.COLLECTEUR,
        )
        self.received = Echantillon.objects.create(
            reference_bouteille='B-001',
            collecteur=self.collecteur,
            gouvernorat='Sfax',
            variete='Chemlali',
            quantite_estimee='20L',
            recu_physiquement=True,
            date_arrivee_echantillon=timezone.now(),
        )
        self.not_received = Echantillon.objects.create(
            reference_bouteille='B-002',
            collecteur=self.collecteur,
            gouvernorat='Sousse',
            recu_physiquement=False,
        )

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

    def results(self, response):
        data = response.json()
        return data.get('results', data)

    def test_lab_sees_only_physically_received_samples(self):
        self.authenticate(self.lab)

        response = self.client.get('/api/analyses/echantillons/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = {item['id'] for item in self.results(response)}
        self.assertIn(str(self.received.id), ids)
        self.assertNotIn(str(self.not_received.id), ids)

    def test_lab_can_create_analysis_for_received_sample(self):
        self.authenticate(self.lab)

        response = self.client.post(
            '/api/analyses/',
            {
                'echantillon': str(self.received.id),
                'statut': AnalyseLabo.Statut.EN_COURS,
                'acidite': '0.420',
                'indice_peroxyde': '8.500',
                'k232': '1.900',
                'k270': '0.140',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.received.refresh_from_db()
        self.assertEqual(self.received.statut_labo, Echantillon.StatutLabo.EN_COURS)
        self.assertEqual(AnalyseLabo.objects.get().technicien, self.lab)

    def test_lab_cannot_create_analysis_for_unreceived_sample(self):
        self.authenticate(self.lab)

        response = self.client.post(
            '/api/analyses/',
            {
                'echantillon': str(self.not_received.id),
                'statut': AnalyseLabo.Statut.EN_COURS,
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_submitted_analysis_is_read_only(self):
        self.authenticate(self.lab)
        analyse = AnalyseLabo.objects.create(
            echantillon=self.received,
            technicien=self.lab,
            statut=AnalyseLabo.Statut.EN_COURS,
            acidite='0.300',
        )

        submit = self.client.post(f'/api/analyses/{analyse.id}/soumettre/')
        self.assertEqual(submit.status_code, status.HTTP_200_OK)
        self.received.refresh_from_db()
        self.assertEqual(self.received.statut_labo, Echantillon.StatutLabo.SOUMIS)

        patch = self.client.patch(
            f'/api/analyses/{analyse.id}/',
            {'acidite': '0.900'},
            format='json',
        )
        delete = self.client.delete(f'/api/analyses/{analyse.id}/')

        self.assertEqual(patch.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(delete.status_code, status.HTTP_400_BAD_REQUEST)

    def test_direction_can_read_but_not_create_lab_analysis(self):
        self.authenticate(self.direction)

        read = self.client.get('/api/analyses/echantillons/')
        create = self.client.post(
            '/api/analyses/',
            {'echantillon': str(self.received.id)},
            format='json',
        )

        self.assertEqual(read.status_code, status.HTTP_200_OK)
        self.assertEqual(create.status_code, status.HTTP_403_FORBIDDEN)
