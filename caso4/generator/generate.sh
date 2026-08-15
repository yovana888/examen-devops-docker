#!/bin/sh
mkdir -p /var/log/app

echo "[$(date)] Iniciando generador de logs..."

while true; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Registro de simulacion de trafico en la aplicacion." >> /var/log/app/app.log
  sleep 0.1
done