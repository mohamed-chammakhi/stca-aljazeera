from rest_framework import status
from rest_framework.test import APITestCase
from django.db import connection
from django.db.migrations.executor import MigrationExecutor
from django.test import TransactionTestCase

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
        self.chef = User.objects.create_user(
            email='fournisseur.chef@example.com',
            password='Test@12345',
            nom='Chef',
            prenom='User',
            role=User.Role.CHEF_DEGUSTATION,
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
                'nom': 'Fournisseur Sfax',
                'region': 'Sfax',
                'delegation': 'Sfax Sud',
                'telephone': '22111222',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(
            Fournisseur.objects.filter(
                nom='Fournisseur Sfax',
                region='Sfax',
                delegation='Sfax Sud',
            ).exists()
        )

    def test_direction_can_read_but_not_create_supplier(self):
        Fournisseur.objects.create(nom='Fournisseur Nabeul', region='Nabeul')
        self.authenticate(self.direction)

        read = self.client.get('/api/fournisseurs/')
        create = self.client.post(
            '/api/fournisseurs/',
            {'nom': 'Direction Supplier'},
            format='json',
        )

        self.assertEqual(read.status_code, status.HTTP_200_OK)
        self.assertEqual(create.status_code, status.HTTP_403_FORBIDDEN)

    def test_collector_supplier_suggestions_are_limited_to_own_samples(self):
        supplier_a = Fournisseur.objects.create(
            nom='Fournisseur A',
            region='Sfax',
            delegation='Sfax Sud',
        )
        supplier_b = Fournisseur.objects.create(
            nom='Fournisseur B',
            region='Nabeul',
            delegation='Korba',
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

        self.authenticate(self.chef)
        chef_response = self.client.get('/api/fournisseurs/')
        self.assertEqual(chef_response.status_code, status.HTTP_200_OK)
        chef_names = {item['nom'] for item in self.results(chef_response)}
        self.assertIn('Fournisseur A', chef_names)
        self.assertIn('Fournisseur B', chef_names)


class FournisseurLocationMigrationTests(TransactionTestCase):
    code_field = 'code_' + 'fournisseur'
    migrate_from = [
        ('fournisseurs', '0002_fournisseur_' + code_field + '_and_more'),
    ]
    migrate_to = [
        ('fournisseurs', '0003_remove_fournisseur_' + code_field + '_and_more'),
    ]

    def setUp(self):
        super().setUp()
        self.executor = MigrationExecutor(connection)
        self.executor.migrate(self.migrate_from)
        old_apps = self.executor.loader.project_state(self.migrate_from).apps
        FournisseurOld = old_apps.get_model('fournisseurs', 'Fournisseur')

        supplier = FournisseurOld.objects.create(
            **{self.code_field: 'HAMI', 'nom': 'hami'},
        )
        Echantillon.objects.create(
            reference_bouteille='HAMI-GABES',
            fournisseur_id=supplier.id,
            gouvernorat='Gabes',
            delegation='El Hamma',
        )
        Echantillon.objects.create(
            reference_bouteille='HAMI-SFAX',
            fournisseur_id=supplier.id,
            gouvernorat='Sfax',
            delegation='Sakiet Ezzit',
        )

    def tearDown(self):
        executor = MigrationExecutor(connection)
        executor.migrate(executor.loader.graph.leaf_nodes())
        super().tearDown()

    def test_migration_splits_one_supplier_by_sample_locations(self):
        self.executor.loader.build_graph()
        self.executor.migrate(self.migrate_to)
        new_apps = self.executor.loader.project_state(self.migrate_to).apps
        FournisseurNew = new_apps.get_model('fournisseurs', 'Fournisseur')

        suppliers = FournisseurNew.objects.filter(nom__iexact='hami')
        self.assertEqual(suppliers.count(), 2)
        self.assertTrue(
            suppliers.filter(region='Gabes', delegation='El Hamma').exists()
        )
        self.assertTrue(
            suppliers.filter(region='Sfax', delegation='Sakiet Ezzit').exists()
        )
        self.assertEqual(
            Echantillon.objects.get(
                reference_bouteille='HAMI-GABES',
            ).fournisseur.region,
            'Gabes',
        )
        self.assertEqual(
            Echantillon.objects.get(
                reference_bouteille='HAMI-SFAX',
            ).fournisseur.region,
            'Sfax',
        )
