# Caso 4: Gestión, Rotación, Compresión y Limpieza de Logs

Solución completa para el **Caso 4**, estructurando un flujo totalmente containerizado de administración de logs utilizando **Docker Compose**, **volúmenes persistentes** y **segmentación de red**.

---

## 📋 Estructura del Proyecto

Todos los archivos requeridos están organizados dentro del directorio `caso4/`:

```text
caso4/
├── docker-compose.yml
├── generator/
│   ├── Dockerfile
│   └── generate.sh
├── rotator/
│   ├── Dockerfile
│   └── rotate.sh
├── compressor/
│   ├── Dockerfile
│   └── compress.sh
└── cleaner/
    ├── Dockerfile
    └── clean.sh
```

---

## 🛠️ Detalle de Componentes y Código Fuente

### 1. `log-generator` (`generator/generate.sh` & `Dockerfile`)
Escribe líneas de registro continuamente dentro del volumen compartido en `/var/log/app/app.log`.

**`generator/generate.sh`**
```bash
#!/bin/sh
mkdir -p /var/log/app

echo "[$(date)] Iniciando generador de logs..."

while true; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Registro de simulacion de trafico y eventos en la aplicacion." >> /var/log/app/app.log
  sleep 0.1
done
```

**`generator/Dockerfile`**
```dockerfile
FROM alpine:3.24
WORKDIR /scripts
COPY generate.sh .
RUN chmod +x generate.sh
CMD ["./generate.sh"]
```

---

### 2. `log-rotator` (`rotator/rotate.sh` & `Dockerfile`)
Inspecciona el tamaño de `/var/log/app/app.log`. Si supera los **5MB**, le cambia el nombre añadiendo un *timestamp* (`app.log.YYYYMMDD_HHMMSS`) y genera un nuevo archivo `app.log` vacío con permisos `644`.

**`rotator/rotate.sh`**
```bash
#!/bin/sh
LOG_DIR="/var/log/app"
MAX_SIZE=$((5 * 1024 * 1024)) # 5MB en bytes

mkdir -p "$LOG_DIR"

while true; do
  if [ -f "$LOG_DIR/app.log" ]; then
    FILE_SIZE=$(stat -c%s "$LOG_DIR/app.log" 2>/dev/null || echo 0)
    
    if [ "$FILE_SIZE" -ge "$MAX_SIZE" ]; then
      TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      ROTATED_FILE="$LOG_DIR/app.log.$TIMESTAMP"
      
      mv "$LOG_DIR/app.log" "$ROTATED_FILE"
      touch "$LOG_DIR/app.log"
      chmod 644 "$LOG_DIR/app.log"
      
      echo "[$(date)] Log rotado exitosamente a: $ROTATED_FILE"
    fi
  fi
  
  sleep 60
done
```

**`rotator/Dockerfile`**
```dockerfile
FROM alpine:3.24
WORKDIR /scripts
COPY rotate.sh .
RUN chmod +x rotate.sh
CMD ["./rotate.sh"]
```

---

### 3. `log-compressor` (`compressor/compress.sh` & `Dockerfile`)
Busca cada 2 minutos aquellos logs que han sido rotados y no estén comprimidos (`app.log.*`), aplicándoles compresión `gzip` y manteniendo sus permisos.

**`compressor/compress.sh`**
```bash
#!/bin/sh
LOG_DIR="/var/log/app"

while true; do
  echo "[$(date)] Buscando logs rotados para comprimir..."
  
  find "$LOG_DIR" -maxdepth 1 -name "app.log.*" ! -name "*.gz" -type f | while read -r FILE; do
    gzip "$FILE"
    chmod 644 "${FILE}.gz"
    echo "[$(date)] Archivo comprimido: ${FILE}.gz"
  done
  
  sleep 120
done
```

**`compressor/Dockerfile`**
```dockerfile
FROM alpine:3.24
WORKDIR /scripts
COPY compress.sh .
RUN chmod +x compress.sh
CMD ["./compress.sh"]
```

---

### 4. `log-cleaner` (`cleaner/clean.sh` & `Dockerfile`)
Revisa el volumen cada 5 minutos y borra de forma definitiva aquellos archivos `.gz` con una antigüedad superior a **10 minutos**.

**`cleaner/clean.sh`**
```bash
#!/bin/sh
LOG_DIR="/var/log/app"

while true; do
  echo "[$(date)] Buscando logs comprimidos antiguos (>10 min)..."
  
  find "$LOG_DIR" -maxdepth 1 -name "app.log.*.gz" -type f -mmin +10 -exec rm -f {} \; -print | while read -r DELETED; do
    echo "[$(date)] Log eliminado por antigüedad: $DELETED"
  done
  
  sleep 300
done
```

**`cleaner/Dockerfile`**
```dockerfile
FROM alpine:3.24
WORKDIR /scripts
COPY clean.sh .
RUN chmod +x clean.sh
CMD ["./clean.sh"]
```

---

## 🐋 Definición de Docker Compose (`docker-compose.yml`)

El archivo integra los 4 servicios compartiendo un mismo **volumen nombrado (`log_data`)** y conectados a una **red aislada de tipo bridge (`log-network`)**, sin exponer puertos al exterior.

```yaml

services:
  log-generator:
    build:
      context: ./generator
    container_name: log-generator
    volumes:
      - log_data:/var/log/app
    networks:
      - log-network

  log-rotator:
    build:
      context: ./rotator
    container_name: log-rotator
    volumes:
      - log_data:/var/log/app
    depends_on:
      - log-generator
    networks:
      - log-network

  log-compressor:
    build:
      context: ./compressor
    container_name: log-compressor
    volumes:
      - log_data:/var/log/app
    depends_on:
      - log-rotator
    networks:
      - log-network

  log-cleaner:
    build:
      context: ./cleaner
    container_name: log-cleaner
    volumes:
      - log_data:/var/log/app
    depends_on:
      - log-compressor
    networks:
      - log-network

volumes:
  log_data:
    driver: local

networks:
  log-network:
    driver: bridge
```

---

## 🚀 Guía de Despliegue y Verificación

1. **Construir e Iniciar todos los contenedores:**
   ```bash
   docker compose up -d --build
   ```

2. **Verificar el estado de los contenedores:**
   ```bash
   docker compose ps
   ```

3. **Ver los archivos en tiempo real dentro del volumen compartido:**
   ```bash
   docker exec -it log-generator ls -lh /var/log/app
   ```

4. **Monitorear la actividad de cada proceso mediante logs:**
   ```bash
   # Logs del rotador
   docker logs -f log-rotator

   # Logs del compresor
   docker logs -f log-compressor

   # Logs del limpiador
   docker logs -f log-cleaner
   ```

5. **Detener y limpiar el entorno (incluyendo volúmenes):**
   ```bash
   docker compose down -v
   ```