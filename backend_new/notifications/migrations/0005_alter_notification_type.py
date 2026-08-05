from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('notifications', '0004_alter_notification_type'),
    ]

    operations = [
        migrations.AlterField(
            model_name='notification',
            name='type',
            field=models.CharField(
                choices=[
                    ('NOUVEL_ECHANTILLON', 'Nouvel echantillon'),
                    ('ECHANTILLON_MODIFIE', 'Echantillon modifie'),
                    ('ECHANTILLON_SUPPRIME', 'Echantillon supprime'),
                    ('ECHANTILLON_RECU', 'Echantillon recu physiquement'),
                    ('PREMIERE_EVALUATION', 'Premiere evaluation soumise'),
                    ('EVALUATION_SOUMISE', 'Evaluation soumise'),
                    ('TOUTES_EVALUATIONS', 'Toutes les evaluations soumises'),
                    ('ANALYSE_SOUMISE', 'Analyse laboratoire soumise'),
                    ('ACHAT_CONFIRME', 'Achat confirme'),
                    ('proposition_achat_attente', "Proposition d'achat en attente"),
                    ('ANALYSE_URGENTE', 'Analyse urgente demandee'),
                    ('EVALUATION_URGENTE', 'Evaluation urgente demandee'),
                    ('NOUVELLE_SESSION', 'Nouvelle session'),
                    ('NEGOCIATION_A_REVOIR', 'Negociation a revoir'),
                ],
                max_length=40,
            ),
        ),
    ]
