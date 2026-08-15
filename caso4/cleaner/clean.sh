#!/bin/sh
LOG_DIR="/var/log/app"

while true; do
  echo "[$(date)] Buscando logs comprimidos antiguos (>10 min)..."
  #-name "app.log.*.gz": Filtra solo los archivos de logs que ya están comprimidos.
  #-mmin +10: (El filtro de tiempo) Busca archivos cuya fecha de última modificación sea de hace más de 10 minutos
  #-exec rm -f {} \;: Ejecuta el comando de eliminación (rm -f) sobre cada archivo encontrado.
  find "$LOG_DIR" -maxdepth 1 -name "app.log.*.gz" -type f -mmin +10 -exec rm -f {} \; -print | while read -r DELETED; do
    echo "[$(date)] Log eliminado por antigüedad: $DELETED"
  done
  
  sleep 300
done