from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('echantillons', '0007_remove_echantillon_ref_echantillon_numero_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='echantillon',
            name='date_livraison_stock_fin',
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
