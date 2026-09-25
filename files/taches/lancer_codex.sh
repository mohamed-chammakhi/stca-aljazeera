#!/usr/bin/env bash
# Lance Codex sur une tâche et gère sa limite d'utilisation tout seul.
#
#   bash files/taches/lancer_codex.sh 47 files/taches/47-audit-cablage-bout-en-bout.md
#
# Si Codex s'arrête sur « usage limit … try again at <heure> », le script attend
# jusqu'à cette heure + 5 min (60 min si l'heure est illisible), puis relance Codex
# sur la même tâche avec l'ordre de reprendre. Il s'arrête quand Codex finit sans
# limite (ou après 12 relances). Claude est prévenu à la fin et vérifie.

set -u
NUM="$1"
TACHE="$2"
cd "$(dirname "$0")/../.."

# L'exécutable de l'extension VS Code : la commande `codex` globale est cassée
# (téléchargement interrompu le 26/09/2026).
CODEX=$(ls -d /c/Users/takwa/.vscode/extensions/openai.chatgpt-*/bin/windows-x86_64/codex.exe 2>/dev/null | tail -1)
[ -z "$CODEX" ] && CODEX=codex

ORDRE="Exécute la tâche $TACHE en suivant files/taches/PROTOCOLE.md. Ne commite pas. N'applique aucune migration sur la vraie base (crée-les seulement). Écris ton rapport sous ## RAPPORT dans ce fichier."
REPRISE="Reprends la tâche $TACHE là où tu t'es arrêté : le code déjà modifié est dans l'arbre de travail, ne refais pas ce qui est fait. Suis files/taches/PROTOCOLE.md. Ne commite pas. N'applique aucune migration sur la vraie base. Écris ou complète ton rapport sous ## RAPPORT."

LOG="files/taches/codex_${NUM}.log"
: > "$LOG"
ordre="$ORDRE"

for essai in $(seq 1 12); do
  echo "=== essai $essai — $(date '+%d/%m %H:%M') ===" | tee -a "$LOG"
  "$CODEX" exec -C . -s workspace-write -o "files/taches/codex_${NUM}.txt" "$ordre" < /dev/null >> "$LOG" 2>&1
  code=$?

  if ! tail -n 40 "$LOG" | grep -qiE "usage limit|rate limit"; then
    echo "=== fin (code $code) — $(date '+%d/%m %H:%M') ===" | tee -a "$LOG"
    exit $code
  fi

  heure=$(tail -n 40 "$LOG" | grep -oiE "try again at [^.]*" | tail -1 | sed -E 's/try again at //I')
  cible=$(date -d "$heure" +%s 2>/dev/null)
  maintenant=$(date +%s)
  if [ -n "$cible" ] && [ "$cible" -lt "$maintenant" ]; then
    cible=$((cible + 86400))   # « 3:05 AM » déjà passé aujourd'hui → demain
  fi
  [ -z "$cible" ] && cible=$((maintenant + 3600))
  cible=$((cible + 300))
  echo "=== limite atteinte ; reprise vers $(date -d @"$cible" '+%d/%m %H:%M') ===" | tee -a "$LOG"
  while [ "$(date +%s)" -lt "$cible" ]; do sleep 60; done
  ordre="$REPRISE"
done

echo "=== abandon après 12 relances ===" | tee -a "$LOG"
exit 1
