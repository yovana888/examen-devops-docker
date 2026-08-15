#!/bin/sh

# Generar el nombre de archivo con la fecha/hora actual
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="/backups/backup_${TIMESTAMP}.sql"

# Exportar contraseña para que pg_dump no la pida interactivamente
export PGPASSWORD=${POSTGRES_PASSWORD}

# Realizar el dump de la base de datos 'escuela'
pg_dump -h db -U ${POSTGRES_USER} -d ${POSTGRES_DB} > "$BACKUP_FILE"

echo "[$(date)] Backup realizado exitosamente: $BACKUP_FILE"