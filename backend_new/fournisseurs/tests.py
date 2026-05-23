from rest_framework import status
from rest_framework.test import APITestCase

from users.models import User

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

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

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
