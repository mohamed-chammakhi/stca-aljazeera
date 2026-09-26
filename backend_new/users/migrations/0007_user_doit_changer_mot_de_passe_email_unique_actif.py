from django.db import migrations, models
from django.db.models import Q


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0006_user_date_suppression'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='email',
            field=models.EmailField(max_length=254),
        ),
        migrations.AddField(
            model_name='user',
            name='doit_changer_mot_de_passe',
            field=models.BooleanField(default=False),
        ),
        migrations.AddConstraint(
            model_name='user',
            constraint=models.UniqueConstraint(
                condition=Q(date_suppression__isnull=True),
                fields=('email',),
                name='users_email_unique_compte_non_supprime',
            ),
        ),
    ]
