#!/bin/sh

# Ejecuta el primer backup al arrancar el contenedor
echo "[$(date)] Ejecutando backup inicial al arrancar..."
/scripts/backup.sh

# Bucle infinito para programar las tareas
while true; do
  sleep 60
  
  # Obtiene hora y minuto actual
  MINUTO=$(date +%M)
  HORA=$(date +%H)
  
  # Ejecuta backup cada 2 horas (a los 00 minutos de horas pares)
  if [ "$MINUTO" = "00" ] && [ $((HORA % 2)) -eq 0 ]; then
    /scripts/backup.sh
  fi
  
  # Ejecuta limpieza cada 4 horas (a los 00 minutos de horas divisibles por 4)
  if [ "$MINUTO" = "00" ] && [ $((HORA % 4)) -eq 0 ]; then
    /scripts/cleaner.sh
  fi
done