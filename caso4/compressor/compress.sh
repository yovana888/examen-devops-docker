#!/bin/sh
LOG_DIR="/var/log/app"

while true; do
  echo "[$(date)] Buscando logs rotados para comprimir..."
  #Busca archivos cuyo nombre empiece con app.log. (los que fueron renombrados por el rotador).
  #! -name "*.gz": El signo ! Excluye los archivos que ya terminan en .gz
  find "$LOG_DIR" -maxdepth 1 -name "app.log.*" ! -name "*.gz" -type f | while read -r FILE; do
    #Comprime el archivo
    gzip "$FILE"
    #Le asigna permisos al nuevo archivo .gz
    chmod 644 "${FILE}.gz"
    echo "[$(date)] Archivo comprimido: ${FILE}.gz"
  done
  
  sleep 120
done