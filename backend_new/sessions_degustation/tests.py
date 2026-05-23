from rest_framework import status
from rest_framework.test import APITestCase

from .models import SessionDegustation
from users.models import User


class SessionDegustationApiTests(APITestCase):
    def setUp(self):
        self.degustateur = User.objects.create_user(
            email='degustateur.sessions@example.com',
            password='Test@12345',
            nom='Degustateur',
            prenom='One',
            role=User.Role.DEGUSTATEUR,
        )
        self.other_degustateur = User.objects.create_user(
            email='degustateur.sessions.other@example.com',
            password='Test@12345',
            nom='Degustateur',
            prenom='Two',
            role=User.Role.DEGUSTATEUR,
        )
        self.chef = User.objects.create_user(
            email='chef.sessions@example.com',
            password='Test@12345',
            nom='Chef',
            prenom='Panel',
            role=User.Role.CHEF_PANEL,
        )
        self.collecteur = User.objects.create_user(
            email='collecteur.sessions@example.com',
            password='Test@12345',
            nom='Collecteur',
            prenom='User',
            role=User.Role.COLLECTEUR,
        )

    def authenticate(self, user):
        self.client.force_authenticate(user=user)

    def test_degustateur_created_session_waits_for_chef_validation(self):
        self.authenticate(self.degustateur)

        response = self.client.post(
            '/api/sessions/',
            {
                'titre': 'Session Chemlali',
                'date': '2026-05-20',
                'heure': '09:00',
                'lieu': 'Salle A',
                'participant_ids': [str(self.other_degustateur.id)],
                'nombre_echantillons_prevus': 4,
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data = response.json()
        self.assertEqual(data['statut'], SessionDegustation.Statut.EN_ATTENTE_VALIDATION)
        self.assertEqual(data['created_by'], str(self.degustateur.id))
        self.assertEqual(data['participant_ids'], [str(self.other_degustateur.id)])
        self.assertEqual(data['nombre_echantillons_prevus'], 4)

    def test_chef_created_session_is_planned_immediately(self):
        self.authenticate(self.chef)

        response = self.client.post(
            '/api/sessions/',
            {
                'titre': 'Session Chef',
                'date': '2026-05-21',
                'heure': '10:00',
                'lieu': 'Salle B',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.json()['statut'], SessionDegustation.Statut.PLANIFIEE)

    def test_chef_can_approve_and_refuse_pending_sessions(self):
        pending = SessionDegustation.objects.create(
            titre='Session a valider',
            date='2026-05-22',
            heure='11:00',
            lieu='Salle C',
            cree_par=self.degustateur,
        )
        self.authenticate(self.chef)

        approve = self.client.post(f'/api/sessions/{pending.id}/approuver/')
        self.assertEqual(approve.status_code, status.HTTP_200_OK)
        pending.refresh_from_db()
        self.assertEqual(pending.statut, SessionDegustation.Statut.PLANIFIEE)

        second_pending = SessionDegustation.objects.create(
            titre='Session a refuser',
            date='2026-05-23',
            heure='14:00',
            lieu='Salle D',
            cree_par=self.degustateur,
        )
        refuse = self.client.post(f'/api/sessions/{second_pending.id}/refuser/')
        self.assertEqual(refuse.status_code, status.HTTP_200_OK)
        second_pending.refresh_from_db()
        self.assertEqual(second_pending.statut, SessionDegustation.Statut.REFUSEE)

    def test_non_chef_cannot_approve_session(self):
        pending = SessionDegustation.objects.create(
            titre='Session protegee',
            date='2026-05-24',
            heure='09:00',
            lieu='Salle E',
            cree_par=self.degustateur,
        )
        self.authenticate(self.degustateur)

        response = self.client.post(f'/api/sessions/{pending.id}/approuver/')

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_participant_can_confirm_presence(self):
        session = SessionDegustation.objects.create(
            titre='Session presence',
            date='2026-05-25',
            heure='09:30',
            lieu='Salle F',
            cree_par=self.chef,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )
        session.participants.add(self.degustateur)
        self.authenticate(self.degustateur)

        response = self.client.post(f'/api/sessions/{session.id}/confirmer_presence/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        session.refresh_from_db()
        self.assertTrue(session.presences_confirmees.filter(id=self.degustateur.id).exists())
        self.assertEqual(response.json()['confirmed_participant_ids'], [str(self.degustateur.id)])

    def test_collecteur_cannot_list_sessions(self):
        self.authenticate(self.collecteur)

        response = self.client.get('/api/sessions/')

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
