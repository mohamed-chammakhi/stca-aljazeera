from django.db import migrations, models


OLD_ROLE = 'chef_panel'
NEW_ROLE = 'chef_degustation'


def forwards(apps, schema_editor):
    """Repoint existing chef_panel accounts at the renamed chef_degustation role."""
    User = apps.get_model('users', 'User')
    User.objects.filter(role=OLD_ROLE).update(role=NEW_ROLE)


def backwards(apps, schema_editor):
    User = apps.get_model('users', 'User')
    User.objects.filter(role=NEW_ROLE).update(role=OLD_ROLE)


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0003_user_date_creation'),
    ]

    operations = [
        migrations.RunPython(forwards, backwards),
        migrations.AlterField(
            model_name='user',
            name='role',
            field=models.CharField(
                choices=[
                    ('direction', 'Direction'),
                    ('collecteur', 'Collecteur'),
                    ('degustateur', 'Dégustateur'),
                    ('laboratoire', 'Laboratoire'),
                    ('chef_degustation', 'Chef de Dégustation'),
                    ('responsable_financier', 'Responsable Financier'),
                ],
                max_length=25,
            ),
        ),
    ]
