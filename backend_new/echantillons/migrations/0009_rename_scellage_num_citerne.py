from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('echantillons', '0008_echantillon_date_livraison_stock_fin'),
    ]

    operations = [
        migrations.RenameField(
            model_name='echantillon',
            old_name='scellage',
            new_name='num_citerne',
        ),
    ]
