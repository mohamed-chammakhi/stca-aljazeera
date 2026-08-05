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
            role=User.Role.DEGUSTATEUR,
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

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

    def test_user_can_send_message_and_sender_is_forced_from_token(self):
        self.authenticate(self.sender)

        response = self.client.post(
            '/api/messages/',
            {
                'expediteur': str(self.other.id),
                'destinataire': str(self.recipient.id),
                'contenu': 'Bonjour',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        message = Message.objects.get(id=response.json()['id'])
        self.assertEqual(message.expediteur, self.sender)
        self.assertEqual(message.destinataire, self.recipient)
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
