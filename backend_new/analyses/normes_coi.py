"""Les 28 parametres du rapport d'analyse et les seuils COI.

Miroir Python de lib/core/analyses/normes_coi.dart. Les cles doivent rester
identiques des deux cotes : ce sont aussi les noms des colonnes en base.

/!\ Le rapport papier n'imprime AUCUNE norme : il ne donne que les valeurs
mesurees. Les seuils viennent donc de la norme COI, pas du document.
"""

from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from typing import Mapping, Optional


@dataclass(frozen=True)
class Parametre:
    """Un parametre mesure du rapport."""

    cle: str
    label: str
    unite: str = ''
    min: Optional[float] = None
    max: Optional[float] = None
    # Contrainte que deux bornes ne savent pas exprimer (le stigmasterol doit
    # rester sous le campesterol). Verifiee par conformite(), qui a acces aux
    # autres valeurs.
    relation: Optional[str] = None

    @property
    def a_une_norme(self) -> bool:
        return self.min is not None or self.max is not None or self.relation is not None


# ── Tableau 1 — resultats principaux ────────────────────────────────────────
PARAMETRES_PRINCIPAUX = (
    Parametre('acidite', 'Acidite libre', '% ac. oleique', max=0.80),
    Parametre('indice_peroxyde', 'Indice de peroxyde', 'meqO2/kg', max=20.0),
    Parametre('k232', 'K232', max=2.50),
    Parametre('k270', 'K270', max=0.22),
    Parametre('delta_k', 'Delta-K', max=0.01),
    Parametre('humidite', 'Humidite et matieres volatiles', '%', max=0.20),
    Parametre('impuretes', 'Impuretes insolubles', '%', max=0.10),
    Parametre('ecn42', 'Ecart ECN42 (reel / theorique)', max=0.20),
)

# ── Tableau 2 — composition en sterols (% des sterols totaux) ───────────────
STEROLS = (
    Parametre('cholesterol', 'Cholesterol', '%', max=0.50),
    Parametre('brassicasterol', 'Brassicasterol', '%', max=0.10),
    Parametre('campesterol', 'Campesterol', '%', max=4.00),
    Parametre('stigmasterol', 'Stigmasterol', '%', relation='< campesterol'),
    Parametre('beta_sitosterol_apparent', 'Beta-sitosterol apparent', '%', min=93.00),
    Parametre('delta_7_stigmastenol', 'Delta7-stigmastenol', '%', max=0.50),
    # Le COI ne fixe pas de limite pour ce sterol : il est releve, pas juge.
    Parametre('delta_7_avenasterol', 'Delta7-avenasterol', '%'),
    Parametre('erythrodiol_uvaol', 'Erythrodiol et uvaol', '%', max=4.50),
)

# ── Tableau 3 — esters methyliques d'acides gras (%) ────────────────────────
ACIDES_GRAS = (
    Parametre('acide_palmitique', 'Acide palmitique (C16:0)', '%', min=7.50, max=20.00),
    Parametre('acide_palmitoleique', 'Acide palmitoleique (C16:1)', '%', min=0.30, max=3.50),
    Parametre('acide_heptadecanoique', 'Acide heptadecanoique (C17:0)', '%', max=0.40),
    Parametre('acide_heptadecenoique', 'Acide heptadecenoique (C17:1)', '%', max=0.60),
    Parametre('acide_stearique', 'Acide stearique (C18:0)', '%', min=0.50, max=5.00),
    Parametre('acide_oleique', 'Acide oleique (C18:1)', '%', min=55.00, max=83.00),
    Parametre('acide_linoleique', 'Acide linoleique (C18:2)', '%', min=2.50, max=21.00),
    Parametre('acide_linolenique', 'Acide linolenique (C18:3)', '%', max=1.00),
    Parametre('acide_arachidique', 'Acide arachidique (C20:0)', '%', max=0.60),
    Parametre('acide_gadoleique', 'Acide gadoleique (C20:1)', '%', max=0.50),
    Parametre('trans_c18_1', 'Isomeres trans C18:1', '%', max=0.05),
    Parametre('trans_c18_2_c18_3', 'Isomeres trans C18:2 et C18:3', '%', max=0.05),
)

TABLEAUX = (PARAMETRES_PRINCIPAUX, STEROLS, ACIDES_GRAS)

TOUS_PARAMETRES = tuple(p for tableau in TABLEAUX for p in tableau)

PAR_CLE = {p.cle: p for p in TOUS_PARAMETRES}

# Les quatre valeurs sans lesquelles une analyse ne peut pas etre soumise :
# ce sont celles qui decident du classement COI.
PARAMETRES_OBLIGATOIRES = ('acidite', 'indice_peroxyde', 'k232', 'k270')


def lire_decimal(valeur) -> Optional[float]:
    """Lit un nombre saisi ou imprime.

    Le rapport du laboratoire ecrit ses decimales avec une virgule ("0,30").
    Les deux notations doivent aboutir au meme nombre.
    """
    if valeur is None:
        return None
    if isinstance(valeur, (int, float, Decimal)):
        return float(valeur)
    texte = str(valeur).strip().replace(',', '.').replace(' ', '')
    if not texte:
        return None
    try:
        return float(Decimal(texte))
    except (InvalidOperation, ValueError):
        return None


def conformite(
    parametre: Parametre,
    valeur: Optional[float],
    valeurs: Mapping[str, Optional[float]] = (),
) -> Optional[bool]:
    """Ce parametre respecte-t-il la norme COI ?

    Rend None quand la question ne se pose pas : valeur non saisie, ou
    parametre sans seuil (le Delta7-avenasterol est releve, jamais juge).
    """
    valeur = lire_decimal(valeur)
    if valeur is None or not parametre.a_une_norme:
        return None

    if parametre.cle == 'stigmasterol':
        campesterol = lire_decimal(dict(valeurs).get('campesterol'))
        if campesterol is None:
            return None
        return valeur < campesterol

    if parametre.min is not None and valeur < parametre.min:
        return False
    if parametre.max is not None and valeur > parametre.max:
        return False
    return True


def parametres_hors_normes(valeurs: Mapping[str, Optional[float]]):
    """Les parametres saisis qui sortent de la norme."""
    return [
        p
        for p in TOUS_PARAMETRES
        if conformite(p, valeurs.get(p.cle), valeurs) is False
    ]


def classification_coi(valeurs: Mapping[str, Optional[float]]) -> Optional[str]:
    """Classement COI deduit des valeurs saisies.

    Rend None tant que les quatre parametres obligatoires ne sont pas tous
    renseignes.

    Le classement reste fonde sur les quatre grandeurs de degradation. Les
    sterols et les acides gras servent a detecter un melange ou une fraude, pas
    a mesurer la qualite : ils alimentent l'alerte "hors normes", jamais le
    classement.
    """
    acidite = lire_decimal(valeurs.get('acidite'))
    peroxyde = lire_decimal(valeurs.get('indice_peroxyde'))
    k232 = lire_decimal(valeurs.get('k232'))
    k270 = lire_decimal(valeurs.get('k270'))

    if None in (acidite, peroxyde, k232, k270):
        return None

    if acidite <= 0.80 and peroxyde <= 20 and k232 <= 2.50 and k270 <= 0.22:
        return 'Extra Vierge'
    if acidite <= 2.00 and peroxyde <= 20 and k232 <= 2.60 and k270 <= 0.25:
        return 'Vierge'
    return 'Lampante'
