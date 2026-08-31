from django.db import migrations, models
from django.db.models import F


def copy_existing_reception_dates(apps, schema_editor):
    Echantillon = apps.get_model('echantillons', 'Echantillon')
    Echantillon.objects.using(schema_editor.connection.alias).filter(
        recu_physiquement=True
    ).update(
        date_reception_echantillon=F('date_arrivee_echantillon')
    )


class Migration(migrations.Migration):

    dependencies = [
        ('echantillons', '0012_remove_echantillon_edit_history'),
    ]

    operations = [
        migrations.AddField(
            model_name='echantillon',
            name='date_reception_echantillon',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.RunPython(
            copy_existing_reception_dates,
            migrations.RunPython.noop,
        ),
    ]
