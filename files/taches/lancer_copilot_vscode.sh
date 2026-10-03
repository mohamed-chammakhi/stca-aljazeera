#!/usr/bin/env bash
# Envoie une tâche à GitHub Copilot Chat dans la fenêtre VS Code ouverte (mode agent),
# puis attend que Copilot écrive son rapport (« ## RAPPORT ») dans la fiche.
# L'utilisatrice voit Copilot travailler dans le panneau Chat ; si VS Code demande
# d'autoriser une commande, il faut cliquer « Continuer » / « Autoriser ».
#
#   bash files/taches/lancer_copilot_vscode.sh 52 files/taches/52-....md
#
# Variante sans fenêtre : lancer_copilot.sh (Copilot CLI).

set -u
NUM="$1"
TACHE="$2"
cd "$(dirname "$0")/../.."

ORDRE="Exécute la tâche project3/$TACHE en suivant project3/files/taches/PROTOCOLE.md. Interdit : git commit, git push, toute migration appliquée sur la vraie base (crée-les seulement), ML Kit. Quand tu as fini, écris ton rapport sous une ligne « ## RAPPORT » à la fin de project3/$TACHE (ce qui est fait, fichiers touchés, ce qui n'est pas testé), puis termine la ligne finale par « FIN RAPPORT »."

LOG="files/taches/copilot_${NUM}.log"
echo "=== envoyé à Copilot VS Code — $(date '+%d/%m %H:%M') ===" | tee "$LOG"
(cd .. && code chat -r -m agent -a "project3/$TACHE" "$ORDRE") >> "$LOG" 2>&1

# Attente du rapport (6 h au plus).
fin=$(( $(date +%s) + 21600 ))
while [ "$(date +%s)" -lt "$fin" ]; do
  if grep -q "FIN RAPPORT" "$TACHE"; then
    echo "=== rapport reçu — $(date '+%d/%m %H:%M') ===" | tee -a "$LOG"
    exit 0
  fi
  sleep 30
done
echo "=== pas de rapport après 6 h ===" | tee -a "$LOG"
exit 1
