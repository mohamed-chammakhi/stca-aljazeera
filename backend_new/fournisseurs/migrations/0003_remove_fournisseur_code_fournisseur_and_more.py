from django.db import migrations, models


def _unique_temporary_code(Fournisseur, base):
    prefix = (base or 'FRN')[:14] or 'FRN'
    index = 1
    while True:
        candidate = f'{prefix}-{index:03d}'[:20]
        if not Fournisseur.objects.filter(code_fournisseur=candidate).exists():
            return candidate
        index += 1


def fill_supplier_locations_and_split(apps, schema_editor):
    Fournisseur = apps.get_model('fournisseurs', 'Fournisseur')
    Echantillon = apps.get_model('echantillons', 'Echantillon')

    for supplier in Fournisseur.objects.all().order_by('id'):
        samples = list(Echantillon.objects.filter(fournisseur=supplier))
        if not samples:
            supplier.region = supplier.region or ''
            supplier.delegation = supplier.delegation or ''
            supplier.save(update_fields=['region', 'delegation'])
            continue

        groups = {}
        for sample in samples:
            key = ((sample.gouvernorat or '').strip(), (sample.delegation or '').strip())
            groups.setdefault(key, []).append(sample.id)

        first = True
        for (region, delegation), sample_ids in groups.items():
            if first:
                supplier.region = region
                supplier.delegation = delegation
                supplier.save(update_fields=['region', 'delegation'])
                first = False
                continue

            target = (
                Fournisseur.objects
                .filter(nom__iexact=supplier.nom, region__iexact=region, delegation__iexact=delegation)
                .exclude(pk=supplier.pk)
                .first()
            )
            if target is None:
                target = Fournisseur.objects.create(
                    code_fournisseur=_unique_temporary_code(
                        Fournisseur,
                        getattr(supplier, 'code_fournisseur', '') or supplier.nom,
                    ),
                    nom=supplier.nom,
                    region=region,
                    delegation=delegation,
                    telephone=supplier.telephone,
                    email=supplier.email,
                    adresse=supplier.adresse,
                    notes=supplier.notes,
                    date_premiere_contact=supplier.date_premiere_contact,
                )
            Echantillon.objects.filter(id__in=sample_ids).update(fournisseur=target)


class Migration(migrations.Migration):

    dependencies = [
        ('fournisseurs', '0002_fournisseur_code_fournisseur_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='fournisseur',
            name='delegation',
            field=models.CharField(blank=True, max_length=100),
        ),
        migrations.RunPython(fill_supplier_locations_and_split, migrations.RunPython.noop),
        migrations.RemoveField(
            model_name='fournisseur',
            name='code_fournisseur',
        ),
    ]
