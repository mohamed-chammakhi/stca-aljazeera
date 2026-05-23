from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0002_alter_user_role'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='date_creation',
            field=models.DateTimeField(default=django.utils.timezone.now),
        ),
    ]
