from rest_framework import status
from rest_framework.test import APITestCase

from notifications.models import Notification
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
            role=User.Role.CHEF_DEGUSTATION,
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
                'date': '2099-05-20',
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

        detail = self.client.get(f"/api/sessions/{data['id']}/")
        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        self.assertEqual(detail.json()['nombre_echantillons_prevus'], 4)

    def test_chef_created_session_is_planned_immediately(self):
        self.authenticate(self.chef)

        response = self.client.post(
            '/api/sessions/',
            {
                'titre': 'Session Chef',
                'date': '2099-05-21',
                'heure': '10:00',
                'lieu': 'Salle B',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.json()['statut'], SessionDegustation.Statut.PLANIFIEE)

    def test_session_creation_requires_only_title_date_and_time(self):
        self.authenticate(self.degustateur)

        response = self.client.post(
            '/api/sessions/',
            {
                'titre': 'Session minimale',
                'date': '2099-05-21',
                'heure': '10:00',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data = response.json()
        self.assertEqual(data['lieu'], '')
        self.assertEqual(data['notes'], '')

    def test_session_creation_rejects_missing_required_fields(self):
        self.authenticate(self.degustateur)

        response = self.client.post('/api/sessions/', {'lieu': 'Salle A'}, format='json')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('titre', response.json())
        self.assertIn('date', response.json())
        self.assertIn('heure', response.json())

    def test_chef_can_approve_and_refuse_pending_sessions(self):
        pending = SessionDegustation.objects.create(
            titre='Session a valider',
            date='2099-05-22',
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
            date='2099-05-23',
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
            date='2099-05-24',
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
            date='2099-05-25',
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

    def test_pending_session_is_visible_only_to_creator_and_chef(self):
        pending = SessionDegustation.objects.create(
            titre='Session privee',
            date='2099-06-01',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.degustateur,
        )

        self.authenticate(self.other_degustateur)
        list_response = self.client.get('/api/sessions/')
        detail_response = self.client.get(f'/api/sessions/{pending.id}/')
        self.assertEqual(list_response.json().get('results', list_response.json()), [])
        self.assertEqual(detail_response.status_code, status.HTTP_404_NOT_FOUND)

        self.authenticate(self.degustateur)
        self.assertEqual(self.client.get(f'/api/sessions/{pending.id}/').status_code, status.HTTP_200_OK)

        self.authenticate(self.chef)
        self.assertEqual(self.client.get(f'/api/sessions/{pending.id}/').status_code, status.HTTP_200_OK)

    def test_approved_visibility_uses_participants_or_all_panel_without_participants(self):
        with_participant = SessionDegustation.objects.create(
            titre='Session participants',
            date='2099-06-02',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.chef,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )
        with_participant.participants.add(self.degustateur)
        without_participant = SessionDegustation.objects.create(
            titre='Session ouverte',
            date='2099-06-03',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.chef,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )

        self.authenticate(self.other_degustateur)
        response = self.client.get('/api/sessions/')
        titles = {item['titre'] for item in response.json().get('results', response.json())}

        self.assertNotIn(with_participant.titre, titles)
        self.assertIn(without_participant.titre, titles)

    def test_refused_session_is_visible_only_to_creator_not_chef(self):
        refused = SessionDegustation.objects.create(
            titre='Session refusee',
            date='2099-06-04',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.degustateur,
            statut=SessionDegustation.Statut.REFUSEE,
        )

        self.authenticate(self.degustateur)
        creator_response = self.client.get(f'/api/sessions/{refused.id}/')
        self.assertEqual(creator_response.status_code, status.HTTP_200_OK)
        self.assertEqual(creator_response.json()['statut'], SessionDegustation.Statut.REFUSEE)

        self.authenticate(self.chef)
        self.assertEqual(self.client.get(f'/api/sessions/{refused.id}/').status_code, status.HTTP_404_NOT_FOUND)

    def test_only_creator_can_update_or_delete_session(self):
        session = SessionDegustation.objects.create(
            titre='Session protegee createur',
            date='2099-06-05',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.degustateur,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )
        self.authenticate(self.chef)

        update_response = self.client.patch(
            f'/api/sessions/{session.id}/',
            {'titre': 'Modification interdite'},
            format='json',
        )
        delete_response = self.client.delete(f'/api/sessions/{session.id}/')

        self.assertEqual(update_response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(delete_response.status_code, status.HTTP_403_FORBIDDEN)
        session.refresh_from_db()
        self.assertEqual(session.titre, 'Session protegee createur')

    def test_degustateur_date_change_on_approved_session_returns_to_pending(self):
        session = SessionDegustation.objects.create(
            titre='Session a revalider',
            date='2099-06-06',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.degustateur,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )
        Notification.objects.all().delete()
        self.authenticate(self.degustateur)

        response = self.client.patch(
            f'/api/sessions/{session.id}/',
            {'date': '2099-06-07'},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        session.refresh_from_db()
        self.assertEqual(session.statut, SessionDegustation.Statut.EN_ATTENTE_VALIDATION)
        self.assertTrue(Notification.objects.filter(destinataire=self.chef).exists())

    def test_degustateur_non_date_change_keeps_approved_status(self):
        session = SessionDegustation.objects.create(
            titre='Session conservee',
            date='2099-06-08',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.degustateur,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )
        self.authenticate(self.degustateur)

        response = self.client.patch(
            f'/api/sessions/{session.id}/',
            {'titre': 'Session conservee modifiee'},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        session.refresh_from_db()
        self.assertEqual(session.statut, SessionDegustation.Statut.PLANIFIEE)

    def test_chef_edit_keeps_planned_status(self):
        session = SessionDegustation.objects.create(
            titre='Session chef',
            date='2099-06-09',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.chef,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )
        self.authenticate(self.chef)

        response = self.client.patch(
            f'/api/sessions/{session.id}/',
            {'date': '2099-06-10'},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        session.refresh_from_db()
        self.assertEqual(session.statut, SessionDegustation.Statut.PLANIFIEE)

    def test_creation_and_update_reject_past_datetime(self):
        self.authenticate(self.degustateur)
        create_response = self.client.post(
            '/api/sessions/',
            {'titre': 'Passe', 'date': '2020-01-01', 'heure': '08:00'},
            format='json',
        )
        self.assertEqual(create_response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("La date et l'heure doivent être dans le futur", str(create_response.json()))

        session = SessionDegustation.objects.create(
            titre='Future',
            date='2099-06-11',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.degustateur,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )
        update_response = self.client.patch(
            f'/api/sessions/{session.id}/',
            {'date': '2020-01-01', 'heure': '08:00'},
            format='json',
        )
        self.assertEqual(update_response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_past_session_displays_finished_and_blocks_presence(self):
        session = SessionDegustation.objects.create(
            titre='Session passee',
            date='2020-01-01',
            heure='08:00',
            lieu='Salle A',
            cree_par=self.chef,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )
        self.authenticate(self.degustateur)

        detail = self.client.get(f'/api/sessions/{session.id}/')
        presence = self.client.post(f'/api/sessions/{session.id}/confirmer_presence/')

        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        self.assertEqual(detail.json()['statut'], SessionDegustation.Statut.TERMINEE)
        self.assertFalse(detail.json()['can_confirmer_presence'])
        self.assertEqual(presence.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(presence.json()['detail'], 'Cette session est déjà passée.')

    def test_approval_notifies_members_and_creator_but_not_actor(self):
        session = SessionDegustation.objects.create(
            titre='Session approbation',
            date='2099-06-12',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.degustateur,
        )
        session.participants.add(self.other_degustateur)
        Notification.objects.all().delete()
        self.authenticate(self.chef)

        response = self.client.post(f'/api/sessions/{session.id}/approuver/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        recipients = set(Notification.objects.values_list('destinataire_id', flat=True))
        self.assertIn(self.other_degustateur.id, recipients)
        self.assertIn(self.degustateur.id, recipients)
        self.assertNotIn(self.chef.id, recipients)

    def test_refusal_notifies_creator_only(self):
        session = SessionDegustation.objects.create(
            titre='Session refus',
            date='2099-06-13',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.degustateur,
        )
        session.participants.add(self.other_degustateur)
        Notification.objects.all().delete()
        self.authenticate(self.chef)

        response = self.client.post(f'/api/sessions/{session.id}/refuser/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(list(Notification.objects.values_list('destinataire_id', flat=True)), [self.degustateur.id])

    def test_approved_update_and_delete_notify_members_except_actor(self):
        session = SessionDegustation.objects.create(
            titre='Session cycle',
            date='2099-06-14',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.chef,
            statut=SessionDegustation.Statut.PLANIFIEE,
        )
        session.participants.add(self.degustateur, self.other_degustateur)
        Notification.objects.all().delete()
        self.authenticate(self.chef)

        update_response = self.client.patch(
            f'/api/sessions/{session.id}/',
            {'notes': 'Notes modifiees'},
            format='json',
        )

        self.assertEqual(update_response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            set(Notification.objects.values_list('destinataire_id', flat=True)),
            {self.degustateur.id, self.other_degustateur.id},
        )

        Notification.objects.all().delete()
        delete_response = self.client.delete(f'/api/sessions/{session.id}/')
        self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(
            set(Notification.objects.values_list('destinataire_id', flat=True)),
            {self.degustateur.id, self.other_degustateur.id},
        )

    def test_pending_update_and_delete_notify_only_chef(self):
        session = SessionDegustation.objects.create(
            titre='Session pending',
            date='2099-06-15',
            heure='09:00',
            lieu='Salle A',
            cree_par=self.degustateur,
        )
        session.participants.add(self.other_degustateur)
        Notification.objects.all().delete()
        self.authenticate(self.degustateur)

        update_response = self.client.patch(
            f'/api/sessions/{session.id}/',
            {'notes': 'Notes pending'},
            format='json',
        )
        self.assertEqual(update_response.status_code, status.HTTP_200_OK)
        self.assertEqual(list(Notification.objects.values_list('destinataire_id', flat=True)), [self.chef.id])

        Notification.objects.all().delete()
        delete_response = self.client.delete(f'/api/sessions/{session.id}/')
        self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(list(Notification.objects.values_list('destinataire_id', flat=True)), [self.chef.id])
