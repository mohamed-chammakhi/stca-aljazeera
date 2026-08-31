from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('echantillons', '0010_echantillon_budget_negociation_max_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='echantillon',
            name='remarque_collecteur',
            field=models.TextField(blank=True, default=''),
        ),
    ]
