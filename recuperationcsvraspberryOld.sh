#!/bin/bash

# Variables
RPI_USER="johann"
RPI_HOST="88.174.193.236"
RPI_PORT=2221
RPI_KEY="/home/johann/.ssh/id_rsa_rpi_cron"  # clé SSH sans passphrase
RPI_DIR="/home/johann/developpement/monitoring"
LOCAL_TMP="/home/johann/developpement/monitoring/raspberrytemp"
LOCAL_OUT="/home/johann/developpement/monitoring/etatressourceraspberry.csv"

# Créer le dossier temporaire si nécessaire
mkdir -p "$LOCAL_TMP"

# Copier tous les CSV depuis le Raspberry
scp -i "$RPI_KEY" -P $RPI_PORT "$RPI_USER@$RPI_HOST:$RPI_DIR/*.csv" "$LOCAL_TMP/"

# Vérifier qu'il y a des fichiers
shopt -s nullglob
csv_files=("$LOCAL_TMP"/*.csv)
if [ ${#csv_files[@]} -eq 0 ]; then
    echo "Aucun CSV à fusionner"
    exit 0
fi

# Fusionner les fichiers en conservant l'en-tête une seule fois
HEADER=$(head -n 1 "${csv_files[0]}")
{
    echo "$HEADER"
    for f in "${csv_files[@]}"; do
        tail -n +2 "$f"
    done
} > "$LOCAL_OUT"

# Nettoyer le dossier temporaire
rm -f "$LOCAL_TMP"/*.csv

