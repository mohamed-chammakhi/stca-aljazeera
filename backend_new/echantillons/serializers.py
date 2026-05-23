from rest_framework import serializers

from fournisseurs.models import Fournisseur

from .models import Echantillon


class EchantillonSerializer(serializers.ModelSerializer):
    # Read-only display fields — Flutter expects these alongside the FK ids
    fournisseur_nom  = serializers.SerializerMethodField(read_only=True)
    code_fournisseur = serializers.CharField(required=False, allow_blank=True, write_only=True)
    collecteur_nom   = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Echantillon
        fields = [
            'id', 'numero', 'reference_bouteille',
            'fournisseur', 'fournisseur_nom', 'code_fournisseur',
            'collecteur', 'collecteur_nom',
            'gouvernorat', 'delegation', 'cite',
            'variete', 'scellage', 'quantite_estimee', 'image_url',
            'statut_collecteur', 'statut_degustateur', 'statut_labo', 'statut_ceo',
            'recu_physiquement', 'date_arrivee_echantillon',
            'budget_negociation', 'quantite_cible_t', 'camion_reserve',
            'note_interne', 'raison_refus',
            'prix_final',
            'stock_arrive', 'date_livraison_stock', 'date_livraison_stock_fin',
            'classification', 'remarques',
            'edit_history',
            'date_ajout', 'updated_at',
        ]
        read_only_fields = ['id', 'numero', 'collecteur', 'edit_history', 'date_ajout', 'updated_at']

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['code_fournisseur'] = self.get_code_fournisseur(instance)
        return data

    def to_internal_value(self, data):
        # Carry an optional supplier name through so `_resolve_fournisseur`
        # can match by name without it ever being mis-stored as the code.
        # OCR pre-fill sends the supplier name in `fournisseur_nom`; users
        # who type a name into the single legacy code field are handled in
        # `_resolve_fournisseur` via the looks-like-a-name heuristic.
        if hasattr(data, 'get'):
            raw = data.get('fournisseur_nom') or ''
            self._extra_fournisseur_nom = raw.strip() if isinstance(raw, str) else ''
        else:
            self._extra_fournisseur_nom = ''
        return super().to_internal_value(data)

    def validate(self, attrs):
        if not self.instance and not attrs.get('reference_bouteille'):
            raise serializers.ValidationError(
                {'reference_bouteille': ['La reference bouteille est obligatoire.']}
            )
        return attrs

    def _resolve_fournisseur(self, validated_data):
        code = (validated_data.pop('code_fournisseur', None) or '').strip()
        nom_input = getattr(self, '_extra_fournisseur_nom', '').strip()

        # The collector dialog has a single "Nom / Code fournisseur" field.
        # If a user typed a NAME into it (e.g. "issa rached") treat it as
        # the name instead of fabricating a code. Only space-containing
        # inputs trigger this — single-word inputs stay as codes to keep
        # legacy behaviour for short alphanumeric supplier codes.
        looks_like_name = code and ' ' in code
        if looks_like_name and not nom_input:
            nom_input = code
            code = ''

        region = validated_data.get('gouvernorat', '')

        if code:
            existing = Fournisseur.objects.filter(code_fournisseur__iexact=code).first()
            if existing:
                validated_data['fournisseur'] = existing
                return validated_data
            # No supplier with that code yet. Prefer creating with the name
            # we have; only fall back to using the code as the name if no
            # name was provided (legacy behaviour kept as last resort).
            validated_data['fournisseur'] = Fournisseur.objects.create(
                code_fournisseur=code,
                nom=nom_input or code,
                region=region,
            )
            return validated_data

        if nom_input:
            validated_data['fournisseur'] = self._supplier_by_name_or_create(
                nom_input, region
            )
            return validated_data

        validated_data['fournisseur'] = None
        return validated_data

    @staticmethod
    def _supplier_by_name_or_create(nom, region):
        existing = Fournisseur.objects.filter(nom__iexact=nom).first()
        if existing:
            return existing
        return EchantillonSerializer._create_supplier_with_generated_code(nom, region)

    @staticmethod
    def _create_supplier_with_generated_code(nom, region):
        from django.db import IntegrityError
        base = Fournisseur.objects.filter(code_fournisseur__startswith='F-').count()
        for attempt in range(10):
            code = f'F-{base + 1 + attempt:04d}'
            try:
                return Fournisseur.objects.create(
                    code_fournisseur=code,
                    nom=nom,
                    region=region,
                )
            except IntegrityError:
                continue
        import uuid
        return Fournisseur.objects.create(
            code_fournisseur=f'F-{uuid.uuid4().hex[:6].upper()}',
            nom=nom,
            region=region,
        )

    def create(self, validated_data):
        validated_data = self._resolve_fournisseur(validated_data)
        return super().create(validated_data)

    def update(self, instance, validated_data):
        validated_data = self._resolve_fournisseur(validated_data)
        return super().update(instance, validated_data)

    def get_fournisseur_nom(self, obj):
        return obj.fournisseur.nom if obj.fournisseur else None

    def get_code_fournisseur(self, obj):
        return obj.fournisseur.code_fournisseur if obj.fournisseur else None

    def get_collecteur_nom(self, obj):
        if obj.collecteur:
            return f"{obj.collecteur.prenom} {obj.collecteur.nom}"
        return None
