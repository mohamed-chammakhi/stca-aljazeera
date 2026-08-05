"""
PR-48 — classification sensorielle interne.

  - fruite_vert (booleen) -> type_fruite (vert / vert_mur / mur)
  - ajout de la classe interne et de ses champs de tracabilite
"""
from django.db import migrations, models


def bool_vers_type_fruite(apps, schema_editor):
    Evaluation = apps.get_model('evaluations', 'EvaluationOrganoleptique')
    Evaluation.objects.filter(fruite_vert=True).update(type_fruite='vert')
    Evaluation.objects.filter(fruite_vert=False).update(type_fruite='mur')


def type_fruite_vers_bool(apps, schema_editor):
    Evaluation = apps.get_model('evaluations', 'EvaluationOrganoleptique')
    Evaluation.objects.filter(type_fruite='mur').update(fruite_vert=False)
    Evaluation.objects.exclude(type_fruite='mur').update(fruite_vert=True)


class Migration(migrations.Migration):

    dependencies = [
        ('evaluations', '0004_alter_evaluationorganoleptique_soumis_le'),
    ]

    operations = [
        migrations.AddField(
            model_name='evaluationorganoleptique',
            name='type_fruite',
            field=models.CharField(
                choices=[('vert', 'Vert'), ('vert_mur', 'Vert-mûr'), ('mur', 'Mûr')],
                default='vert',
                max_length=10,
            ),
        ),
        migrations.RunPython(bool_vers_type_fruite, type_fruite_vers_bool),
        migrations.RemoveField(
            model_name='evaluationorganoleptique',
            name='fruite_vert',
        ),
        migrations.AddField(
            model_name='evaluationorganoleptique',
            name='classe_interne',
            field=models.CharField(
                blank=True,
                choices=[
                    ('extra_a_plus', 'Extra A+'),
                    ('extra_a', 'Extra A'),
                    ('extra_b_plus', 'Extra B+'),
                    ('extra_b', 'Extra B'),
                    ('extra_b_moins', 'Extra B−'),
                    ('extra_c', 'Extra C'),
                    ('extra_desequilibre', 'Extra déséquilibrée'),
                ],
                max_length=20,
            ),
        ),
        migrations.AddField(
            model_name='evaluationorganoleptique',
            name='classe_interne_manuelle',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='evaluationorganoleptique',
            name='classe_interne_motif',
            field=models.CharField(blank=True, max_length=200),
        ),
        migrations.AddField(
            model_name='evaluationorganoleptique',
            name='classe_interne_choisie_le',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='evaluationorganoleptique',
            name='profil_non_harmonieux',
            field=models.BooleanField(default=False),
        ),
    ]
