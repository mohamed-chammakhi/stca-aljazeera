from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('notifications', '0002_alter_notification_section_alter_notification_type'),
    ]

    operations = [
        migrations.AlterField(
            model_name='notification',
            name='section',
            field=models.CharField(
                choices=[
                    ('ECHANTILLONS', 'Echantillons'),
                    ('EVALUATIONS', 'Evaluations'),
                    ('ANALYSES', 'Analyses'),
                    ('ACHATS', 'Achats'),
                    ('ACHATS_VALIDATION', 'Validation achats'),
                    ('SESSIONS', 'Sessions'),
                ],
                default='ECHANTILLONS',
                max_length=20,
            ),
        ),
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
                    ('NOUVELLE_SESSION', 'Nouvelle session'),
                ],
                max_length=40,
            ),
        ),
    ]
