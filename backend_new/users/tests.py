from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework_simplejwt.tokens import RefreshToken

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


class ChangePasswordApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email='password@stca.tn',
            password='Ancien@123',
            nom='Mot',
            prenom='Passe',
            role=User.Role.COLLECTEUR,
        )

    def test_change_password_requires_authentication(self):
        response = self.client.post(
            '/api/users/me/changer-mot-de-passe/',
            {
                'ancien_mot_de_passe': 'Ancien@123',
                'nouveau_mot_de_passe': 'Nouveau@456',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_change_password_checks_old_password_and_keeps_jwt_valid(self):
        access = str(RefreshToken.for_user(self.user).access_token)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')

        response = self.client.post(
            '/api/users/me/changer-mot-de-passe/',
            {
                'ancien_mot_de_passe': 'Ancien@123',
                'nouveau_mot_de_passe': 'Nouveau@456',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertFalse(self.user.check_password('Ancien@123'))
        self.assertTrue(self.user.check_password('Nouveau@456'))

        same_token_response = self.client.get('/api/users/me/')
        self.assertEqual(same_token_response.status_code, status.HTTP_200_OK)
        self.assertEqual(same_token_response.data['id'], str(self.user.id))

    def test_change_password_rejects_wrong_old_password(self):
        self.client.force_authenticate(user=self.user)

        response = self.client.post(
            '/api/users/me/changer-mot-de-passe/',
            {
                'ancien_mot_de_passe': 'Erreur@123',
                'nouveau_mot_de_passe': 'Nouveau@456',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            response.data,
            {
                'code': 'password_incorrect',
                'detail': 'Mot de passe actuel incorrect.',
            },
        )
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password('Ancien@123'))

    def test_change_password_rejects_each_invalid_new_password_rule(self):
        self.client.force_authenticate(user=self.user)

        for invalid_password in ('Ab@1', 'Nouveau@', 'Nouveau1'):
            with self.subTest(password=invalid_password):
                response = self.client.post(
                    '/api/users/me/changer-mot-de-passe/',
                    {
                        'ancien_mot_de_passe': 'Ancien@123',
                        'nouveau_mot_de_passe': invalid_password,
                    },
                    format='json',
                )
                self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn('nouveau_mot_de_passe', response.data)

    def test_change_password_rejects_same_password(self):
        self.client.force_authenticate(user=self.user)

        response = self.client.post(
            '/api/users/me/changer-mot-de-passe/',
            {
                'ancien_mot_de_passe': 'Ancien@123',
                'nouveau_mot_de_passe': 'Ancien@123',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            response.data['detail'],
            "Le nouveau mot de passe doit être différent de l'ancien.",
        )


class PanelMemberApiTests(APITestCase):
    def setUp(self):
        self.degustateur = User.objects.create_user(
            email='degustateur@stca.tn',
            password='Test@12345',
            nom='Chammakhi',
            prenom='Ichrak',
            role=User.Role.DEGUSTATEUR,
        )
        self.chef = User.objects.create_user(
            email='chef@stca.tn',
            password='Test@12345',
            nom='Chef',
            prenom='Panel',
            role=User.Role.CHEF_DEGUSTATION,
        )
        self.inactive_degustateur = User.objects.create_user(
            email='inactive.degustateur@stca.tn',
            password='Test@12345',
            nom='Inactive',
            prenom='Panel',
            role=User.Role.DEGUSTATEUR,
            is_active=False,
        )
        self.collecteur = User.objects.create_user(
            email='collecteur.panel@stca.tn',
            password='Test@12345',
            nom='Collecteur',
            prenom='HorsPanel',
            role=User.Role.COLLECTEUR,
        )
        User.objects.create_user(
            email='direction.panel@stca.tn',
            password='Test@12345',
            nom='Direction',
            prenom='HorsPanel',
            role=User.Role.DIRECTION,
        )
        User.objects.create_user(
            email='labo.panel@stca.tn',
            password='Test@12345',
            nom='Labo',
            prenom='HorsPanel',
            role=User.Role.LABORATOIRE,
        )

    def test_panel_members_requires_authentication(self):
        response = self.client.get('/api/users/panel-members/')

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_authenticated_user_can_list_active_panel_members_only(self):
        self.client.force_authenticate(user=self.collecteur)

        response = self.client.get('/api/users/panel-members/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = {item['id'] for item in response.data['results']}
        self.assertIn(str(self.degustateur.id), ids)
        self.assertIn(str(self.chef.id), ids)
        self.assertNotIn(str(self.inactive_degustateur.id), ids)
        self.assertEqual(len(ids), 2)

        first = response.data['results'][0]
        self.assertIn('membre_depuis', first)
        self.assertIn('est_en_ligne', first)
        self.assertNotIn('email', first)


class UserManagementApiTests(APITestCase):
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
        self.chef = User.objects.create_user(
            email='chef.users@stca.tn',
            password='Test@12345',
            nom='Chef',
            prenom='Panel',
            role=User.Role.CHEF_DEGUSTATION,
        )
        self.degustateur = User.objects.create_user(
            email='degustateur.users@stca.tn',
            password='Test@12345',
            nom='Degustateur',
            prenom='Simple',
            role=User.Role.DEGUSTATEUR,
        )

    def test_direction_can_list_users(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.get('/api/users/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(response.data['count'], 4)

    def test_chef_can_list_users(self):
        self.client.force_authenticate(user=self.chef)

        response = self.client.get('/api/users/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(response.data['count'], 4)

    def test_degustateur_cannot_list_users(self):
        self.client.force_authenticate(user=self.degustateur)

        response = self.client.get('/api/users/')

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_chef_can_create_user(self):
        self.client.force_authenticate(user=self.chef)

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

    def test_direction_cannot_create_user(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.post(
            '/api/users/',
            {
                'email': 'forbidden.create@stca.tn',
                'nom': 'Interdit',
                'prenom': 'Direction',
                'role': User.Role.LABORATOIRE,
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_direction_and_chef_can_retrieve_user_details(self):
        self.client.force_authenticate(user=self.direction)
        direction_response = self.client.get(f'/api/users/{self.collecteur.id}/')

        self.client.force_authenticate(user=self.chef)
        chef_response = self.client.get(f'/api/users/{self.collecteur.id}/')

        self.assertEqual(direction_response.status_code, status.HTTP_200_OK)
        self.assertEqual(chef_response.status_code, status.HTTP_200_OK)
        self.assertEqual(direction_response.data['id'], str(self.collecteur.id))
        self.assertEqual(chef_response.data['id'], str(self.collecteur.id))
        self.assertFalse(User.objects.filter(email='forbidden.create@stca.tn').exists())

    def test_chef_can_update_user(self):
        self.client.force_authenticate(user=self.chef)

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

    def test_direction_cannot_update_or_delete_user(self):
        self.client.force_authenticate(user=self.direction)

        update_response = self.client.patch(
            f'/api/users/{self.collecteur.id}/',
            {'telephone': '+216 90 000 000'},
            format='json',
        )
        delete_response = self.client.delete(f'/api/users/{self.collecteur.id}/')

        self.assertEqual(update_response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(delete_response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertTrue(User.objects.filter(pk=self.collecteur.pk).exists())

    def test_chef_can_delete_direction_account(self):
        self.client.force_authenticate(user=self.chef)

        response = self.client.delete(f'/api/users/{self.direction.id}/')

        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(User.objects.filter(pk=self.direction.pk).exists())

    def test_chef_can_toggle_another_user_active_state(self):
        self.client.force_authenticate(user=self.chef)

        response = self.client.post(f'/api/users/{self.collecteur.id}/toggle-active/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.collecteur.refresh_from_db()
        self.assertFalse(self.collecteur.is_active)
        self.assertFalse(response.data['is_active'])

    def test_direction_cannot_toggle_user_active_state(self):
        self.client.force_authenticate(user=self.direction)

        response = self.client.post(f'/api/users/{self.collecteur.id}/toggle-active/')

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.collecteur.refresh_from_db()
        self.assertTrue(self.collecteur.is_active)

    def test_chef_cannot_toggle_own_active_state(self):
        self.client.force_authenticate(user=self.chef)

        response = self.client.post(f'/api/users/{self.chef.id}/toggle-active/')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.chef.refresh_from_db()
        self.assertTrue(self.chef.is_active)

    def test_chef_cannot_demote_or_deactivate_self_by_patch(self):
        self.client.force_authenticate(user=self.chef)

        response = self.client.patch(
            f'/api/users/{self.chef.id}/',
            {
                'role': User.Role.COLLECTEUR,
                'is_active': False,
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.chef.refresh_from_db()
        self.assertEqual(self.chef.role, User.Role.CHEF_DEGUSTATION)
        self.assertTrue(self.chef.is_active)

    def test_chef_cannot_delete_self(self):
        self.client.force_authenticate(user=self.chef)

        response = self.client.delete(f'/api/users/{self.chef.id}/')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertTrue(User.objects.filter(pk=self.chef.pk).exists())
