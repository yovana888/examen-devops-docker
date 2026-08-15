#!/bin/sh

echo "[$(date)] Iniciando limpieza de backups antiguos..."

# Mantiene únicamente el archivo más reciente de /backups y borra los demás
ls -1t /backups/backup_*.sql 2>/dev/null | tail -n +2 | xargs rm -f

echo "[$(date)] Limpieza completada. Solo se conserva el backup más reciente."