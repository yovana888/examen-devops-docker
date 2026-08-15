#!/bin/sh
LOG_DIR="/var/log/app"
MAX_SIZE=$((5 * 1024 * 1024)) # 5MB en bytes

mkdir -p "$LOG_DIR"

while true; do
  if [ -f "$LOG_DIR/app.log" ]; then
    #Obtiene el tamaño del archivo en bytes. (stat -c%s: Muestra únicamente el peso en bytes)
    FILE_SIZE=$(stat -c%s "$LOG_DIR/app.log" 2>/dev/null || echo 0)
    
    if [ "$FILE_SIZE" -ge "$MAX_SIZE" ]; then
      #Genera la fecha y hora actual con el formato
      TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      #Crea la ruta y el nuevo nombre del archivo rotado (ejemplo: /var/log/app/app.log.20260815_084500)
      ROTATED_FILE="$LOG_DIR/app.log.$TIMESTAMP"
      
      #Renombra el archivo app.log pesado con el nuevo nombre que incluye la fecha.
      mv "$LOG_DIR/app.log" "$ROTATED_FILE"
      #Crea inmediatamente un nuevo archivo app.log totalmente vacío.
      touch "$LOG_DIR/app.log"
      #Le asignanamos permisos de lectura y escritura
      chmod 644 "$LOG_DIR/app.log"
      
      echo "[$(date)] Log rotado exitosamente a: $ROTATED_FILE"
    fi
  fi
  
  sleep 60
done