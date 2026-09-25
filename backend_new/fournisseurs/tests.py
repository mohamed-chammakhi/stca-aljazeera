from rest_framework import status
from rest_framework.test import APITestCase

from users.models import User
from echantillons.models import Echantillon

from .models import Fournisseur


class FournisseurApiTests(APITestCase):
    def setUp(self):
        self.collector = User.objects.create_user(
            email='fournisseur.collecteur@example.com',
            password='Test@12345',
            nom='Collecteur',
            prenom='User',
            role=User.Role.COLLECTEUR,
        )
        self.direction = User.objects.create_user(
            email='fournisseur.direction@example.com',
            password='Test@12345',
            nom='Direction',
            prenom='User',
            role=User.Role.DIRECTION,
        )
        self.degustateur = User.objects.create_user(
            email='fournisseur.degustateur@example.com',
            password='Test@12345',
            nom='Degustateur',
            prenom='User',
            role=User.Role.DEGUSTATEUR,
        )
        self.collector_b = User.objects.create_user(
            email='fournisseur.collecteur.b@example.com',
            password='Test@12345',
            nom='CollecteurB',
            prenom='User',
            role=User.Role.COLLECTEUR,
        )

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

    def results(self, response):
        data = response.json()
        return data.get('results', data)

    def test_collector_can_create_supplier(self):
        self.authenticate(self.collector)

        response = self.client.post(
            '/api/fournisseurs/',
            {
                'code_fournisseur': 'SF-42',
                'nom': 'Fournisseur Sfax',
                'region': 'Sfax',
                'telephone': '22111222',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(Fournisseur.objects.filter(code_fournisseur='SF-42').exists())

    def test_direction_can_read_but_not_create_supplier(self):
        Fournisseur.objects.create(code_fournisseur='NB-07', nom='Fournisseur Nabeul')
        self.authenticate(self.direction)

        read = self.client.get('/api/fournisseurs/')
        create = self.client.post(
            '/api/fournisseurs/',
            {'code_fournisseur': 'DIR-1', 'nom': 'Direction Supplier'},
            format='json',
        )

        self.assertEqual(read.status_code, status.HTTP_200_OK)
        self.assertEqual(create.status_code, status.HTTP_403_FORBIDDEN)

    def test_collector_supplier_suggestions_are_limited_to_own_samples(self):
        supplier_a = Fournisseur.objects.create(
            code_fournisseur='A-001',
            nom='Fournisseur A',
        )
        supplier_b = Fournisseur.objects.create(
            code_fournisseur='B-001',
            nom='Fournisseur B',
        )
        Echantillon.objects.create(
            reference_bouteille='A-REF',
            fournisseur=supplier_a,
            collecteur=self.collector,
            gouvernorat='Sfax',
        )
        Echantillon.objects.create(
            reference_bouteille='B-REF',
            fournisseur=supplier_b,
            collecteur=self.collector_b,
            gouvernorat='Nabeul',
        )

        self.authenticate(self.collector)
        collector_response = self.client.get('/api/fournisseurs/')

        self.authenticate(self.degustateur)
        degustateur_response = self.client.get('/api/fournisseurs/')

        self.assertEqual(collector_response.status_code, status.HTTP_200_OK)
        self.assertEqual(degustateur_response.status_code, status.HTTP_200_OK)
        collector_names = {item['nom'] for item in self.results(collector_response)}
        degustateur_names = {item['nom'] for item in self.results(degustateur_response)}
        self.assertEqual(collector_names, {'Fournisseur A'})
        self.assertIn('Fournisseur A', degustateur_names)
        self.assertIn('Fournisseur B', degustateur_names)
