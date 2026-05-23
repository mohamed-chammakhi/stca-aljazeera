from rest_framework import status
from rest_framework.test import APITestCase

from .models import User


class CurrentUserProfileApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email='collecteur@stca.tn',
            password='Test@12345',
            nom='Collecteur',
            prenom='Test',
            telephone='+216 20 000 000',
            role=User.Role.COLLECTEUR,
        )
        self.other_user = User.objects.create_user(
            email='direction@stca.tn',
            password='Test@12345',
            nom='Direction',
            prenom='Test',
            role=User.Role.DIRECTION,
        )
        self.client.force_authenticate(user=self.user)

    def test_current_user_profile_can_be_loaded(self):
        response = self.client.get('/api/users/me/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['email'], self.user.email)
        self.assertEqual(response.data['role'], User.Role.COLLECTEUR)

    def test_current_user_profile_can_update_allowed_fields(self):
        response = self.client.patch(
            '/api/users/me/',
            {
                'nom': 'Ben Salah',
                'prenom': 'Yassine',
                'telephone': '+216 22 111 222',
                'email': 'new.collecteur@stca.tn',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.nom, 'Ben Salah')
        self.assertEqual(self.user.prenom, 'Yassine')
        self.assertEqual(self.user.telephone, '+216 22 111 222')
        self.assertEqual(self.user.email, 'new.collecteur@stca.tn')
        self.assertEqual(response.data['role'], User.Role.COLLECTEUR)

    def test_current_user_profile_rejects_duplicate_email(self):
        response = self.client.patch(
            '/api/users/me/',
            {'email': self.other_user.email.upper()},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)

    def test_current_user_profile_rejects_protected_fields(self):
        response = self.client.patch(
            '/api/users/me/',
            {
                'role': User.Role.DIRECTION,
                'is_active': False,
                'password': 'NotAllowed123',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('role', response.data)
        self.assertIn('is_active', response.data)
        self.assertIn('password', response.data)
        self.user.refresh_from_db()
        self.assertEqual(self.user.role, User.Role.COLLECTEUR)
        self.assertTrue(self.user.is_active)


class DirectionUserManagementApiTests(APITestCase):
    def setUp(self):
        self.direction = User.objects.create_user(
            email='direction@stca.tn',
            password='Test@12345',
            nom='Direction',
            prenom='Takwa',
            role=User.Role.DIRECTION,
        )
        self.collecteur = User.objects.create_user(
            email='collecteur@stca.tn',
            password='Test@12345',
            nom='Collecteur',
            prenom='Test',
            role=User.Role.COLLECTEUR,
        )

    def test_direction_can_list_users(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.get('/api/users/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(response.data['count'], 2)

    def test_non_direction_cannot_list_users(self):
        self.client.force_authenticate(user=self.collecteur)

        response = self.client.get('/api/users/')

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_direction_can_create_user(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.post(
            '/api/users/',
            {
                'email': 'labo.new@stca.tn',
                'nom': 'Labo',
                'prenom': 'Nouveau',
                'role': User.Role.LABORATOIRE,
                'telephone': '+216 20 222 333',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        created = User.objects.get(email='labo.new@stca.tn')
        self.assertTrue(created.check_password('Test@12345'))
        self.assertEqual(response.data['role'], User.Role.LABORATOIRE)

    def test_direction_can_update_user(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.patch(
            f'/api/users/{self.collecteur.id}/',
            {
                'role': User.Role.DEGUSTATEUR,
                'telephone': '+216 55 444 333',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.collecteur.refresh_from_db()
        self.assertEqual(self.collecteur.role, User.Role.DEGUSTATEUR)
        self.assertEqual(self.collecteur.telephone, '+216 55 444 333')

    def test_direction_can_toggle_another_user_active_state(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.post(f'/api/users/{self.collecteur.id}/toggle-active/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.collecteur.refresh_from_db()
        self.assertFalse(self.collecteur.is_active)
        self.assertFalse(response.data['is_active'])

    def test_direction_cannot_toggle_own_active_state(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.post(f'/api/users/{self.direction.id}/toggle-active/')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.direction.refresh_from_db()
        self.assertTrue(self.direction.is_active)

    def test_direction_cannot_demote_or_deactivate_self_by_patch(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.patch(
            f'/api/users/{self.direction.id}/',
            {
                'role': User.Role.COLLECTEUR,
                'is_active': False,
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.direction.refresh_from_db()
        self.assertEqual(self.direction.role, User.Role.DIRECTION)
        self.assertTrue(self.direction.is_active)

    def test_direction_cannot_delete_self(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.delete(f'/api/users/{self.direction.id}/')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertTrue(User.objects.filter(pk=self.direction.pk).exists())
