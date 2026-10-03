#!/usr/bin/env bash
# Lance GitHub Copilot CLI (abonnement étudiant, modèle « auto ») sur une tâche.
# Même rôle que lancer_codex.sh : Claude écrit la fiche, Copilot code, Claude vérifie.
#
#   bash files/taches/lancer_copilot.sh 52 files/taches/52-....md
#
# Connexion : le jeton de gh (compte takwachkkkk, outil portable) sert de GH_TOKEN.
# Copilot n'a pas le droit de commiter ni de pousser (git commit / git push refusés).
# Si Copilot s'arrête sur une limite d'utilisation, le script attend 60 min et le
# relance sur la même tâche avec l'ordre de reprendre (6 relances au plus).

set -u
NUM="$1"
TACHE="$2"
cd "$(dirname "$0")/../.."

GH=/c/Users/takwa/tools/gh/bin/gh.exe
export GH_TOKEN="$("$GH" auth token)"

ORDRE="Exécute la tâche $TACHE en suivant files/taches/PROTOCOLE.md. Ne commite pas et ne pousse pas. N'applique aucune migration sur la vraie base (crée-les seulement). Écris ton rapport sous ## RAPPORT dans ce fichier."
REPRISE="Reprends la tâche $TACHE là où tu t'es arrêté : le code déjà modifié est dans l'arbre de travail, ne refais pas ce qui est fait. Suis files/taches/PROTOCOLE.md. Ne commite pas. N'applique aucune migration sur la vraie base. Écris ou complète ton rapport sous ## RAPPORT."

LOG="files/taches/copilot_${NUM}.log"
: > "$LOG"
ordre="$ORDRE"

essai=0
while [ "$essai" -lt 6 ]; do
  essai=$((essai + 1))
  echo "=== essai $essai — $(date '+%d/%m %H:%M') ===" | tee -a "$LOG"
  copilot -p "$ordre" --model auto --allow-all-tools \
    --deny-tool 'shell(git commit)' --deny-tool 'shell(git push)' \
    < /dev/null >> "$LOG" 2>&1
  code=$?

  if ! tail -n 40 "$LOG" | grep -qiE "rate limit|quota|usage limit|exceeded"; then
    echo "=== fin (code $code) — $(date '+%d/%m %H:%M') ===" | tee -a "$LOG"
    exit $code
  fi
  echo "=== limite atteinte ; reprise vers $(date -d '+60 min' '+%d/%m %H:%M') ===" | tee -a "$LOG"
  sleep 3600
  ordre="$REPRISE"
done

echo "=== abandon après 6 relances ===" | tee -a "$LOG"
exit 1
