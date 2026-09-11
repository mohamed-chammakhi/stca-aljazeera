from rest_framework import status
from rest_framework.test import APITestCase

from users.models import User

from .models import Message


class MessageApiTests(APITestCase):
    def setUp(self):
        self.sender = User.objects.create_user(
            email='sender.messages@example.com',
            password='Test@12345',
            nom='Sender',
            prenom='User',
            role=User.Role.COLLECTEUR,
        )
        self.recipient = User.objects.create_user(
            email='recipient.messages@example.com',
            password='Test@12345',
            nom='Recipient',
            prenom='User',
            role=User.Role.CHEF_DEGUSTATION,
        )
        self.other = User.objects.create_user(
            email='other.messages@example.com',
            password='Test@12345',
            nom='Other',
            prenom='User',
            role=User.Role.COLLECTEUR,
        )
        self.direction = User.objects.create_user(
            email='direction.messages@example.com',
            password='Test@12345',
            nom='Direction',
            prenom='User',
            role=User.Role.DIRECTION,
        )
        self.degustateur = User.objects.create_user(
            email='degustateur.messages@example.com',
            password='Test@12345',
            nom='Degustateur',
            prenom='User',
            role=User.Role.DEGUSTATEUR,
        )
        self.laboratoire = User.objects.create_user(
            email='labo.messages@example.com',
            password='Test@12345',
            nom='Labo',
            prenom='User',
            role=User.Role.LABORATOIRE,
        )

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

    def test_user_can_send_message_and_sender_is_forced_from_token(self):
        self.authenticate(self.sender)

        response = self.client.post(
            '/api/messages/',
            {
                'expediteur': str(self.other.id),
                'destinataire': str(self.direction.id),
                'contenu': 'Bonjour',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        message = Message.objects.get(id=response.json()['id'])
        self.assertEqual(message.expediteur, self.sender)
        self.assertEqual(message.destinataire, self.direction)
        self.assertFalse(message.lu)

    def test_user_lists_only_sent_or_received_messages(self):
        own_sent = Message.objects.create(
            expediteur=self.sender,
            destinataire=self.recipient,
            contenu='Sent',
        )
        own_received = Message.objects.create(
            expediteur=self.recipient,
            destinataire=self.sender,
            contenu='Received',
        )
        Message.objects.create(
            expediteur=self.recipient,
            destinataire=self.other,
            contenu='Hidden',
        )
        self.authenticate(self.sender)

        response = self.client.get('/api/messages/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        results = response.json().get('results', response.json())
        ids = {item['id'] for item in results}
        self.assertEqual(ids, {str(own_sent.id), str(own_received.id)})
        self.assertIn('is_read', results[0])
        self.assertIn('horodatage', results[0])

    def test_only_recipient_can_mark_message_as_read(self):
        message = Message.objects.create(
            expediteur=self.sender,
            destinataire=self.recipient,
            contenu='A lire',
        )

        self.authenticate(self.sender)
        sender_response = self.client.patch(f'/api/messages/{message.id}/lire/')
        self.assertEqual(sender_response.status_code, status.HTTP_404_NOT_FOUND)

        self.authenticate(self.recipient)
        recipient_response = self.client.patch(f'/api/messages/{message.id}/lire/')

        self.assertEqual(recipient_response.status_code, status.HTTP_200_OK)
        message.refresh_from_db()
        self.assertTrue(message.lu)
        self.assertIsNotNone(message.lu_le)
        self.assertTrue(recipient_response.json()['is_read'])

    def test_cannot_send_message_to_self(self):
        self.authenticate(self.sender)

        response = self.client.post(
            '/api/messages/',
            {
                'destinataire': str(self.sender.id),
                'contenu': 'Moi-meme',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_allowed_contact_matrix_can_send_messages(self):
        scenarios = [
            (self.sender, self.recipient),
            (self.sender, self.direction),
            (self.recipient, self.sender),
            (self.recipient, self.direction),
            (self.direction, self.sender),
            (self.direction, self.recipient),
        ]

        for expediteur, destinataire in scenarios:
            with self.subTest(expediteur=expediteur.role, destinataire=destinataire.role):
                self.authenticate(expediteur)
                response = self.client.post(
                    '/api/messages/',
                    {
                        'destinataire': str(destinataire.id),
                        'contenu': 'Bonjour',
                    },
                    format='json',
                )

                self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_roles_without_messaging_cannot_send_messages(self):
        for expediteur in (self.degustateur, self.laboratoire):
            with self.subTest(role=expediteur.role):
                self.authenticate(expediteur)
                response = self.client.post(
                    '/api/messages/',
                    {
                        'destinataire': str(self.direction.id),
                        'contenu': 'Bonjour',
                    },
                    format='json',
                )

                self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn("Vous n'avez pas de messagerie.", str(response.json()))

    def test_collector_cannot_send_message_to_another_collector(self):
        self.authenticate(self.sender)

        response = self.client.post(
            '/api/messages/',
            {
                'destinataire': str(self.other.id),
                'contenu': 'Bonjour',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('Vous ne pouvez pas ecrire a ce contact.', str(response.json()))

    def test_contacts_list_for_collector_and_empty_for_degustateur(self):
        inactive_direction = User.objects.create_user(
            email='inactive.direction.messages@example.com',
            password='Test@12345',
            nom='Inactive',
            prenom='User',
            role=User.Role.DIRECTION,
            is_active=False,
        )
        self.authenticate(self.sender)

        response = self.client.get('/api/messages/contacts/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = [item['id'] for item in response.json()]
        self.assertEqual(ids, [str(self.direction.id), str(self.recipient.id)])
        self.assertNotIn(str(self.other.id), ids)
        self.assertNotIn(str(inactive_direction.id), ids)
        self.assertEqual(set(response.json()[0].keys()), {'id', 'nom', 'prenom', 'role'})

        self.authenticate(self.degustateur)
        empty_response = self.client.get('/api/messages/contacts/')

        self.assertEqual(empty_response.status_code, status.HTTP_200_OK)
        self.assertEqual(empty_response.json(), [])

    def test_unread_count_only_counts_unread_received_messages(self):
        Message.objects.create(
            expediteur=self.recipient,
            destinataire=self.sender,
            contenu='Non lu recu',
        )
        Message.objects.create(
            expediteur=self.recipient,
            destinataire=self.sender,
            contenu='Lu recu',
            lu=True,
        )
        Message.objects.create(
            expediteur=self.sender,
            destinataire=self.recipient,
            contenu='Envoye non lu',
        )
        self.authenticate(self.sender)

        response = self.client.get('/api/messages/non-lus/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.json(), {'total': 1})
