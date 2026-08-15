# Caso 3: Automatización de Respaldos PostgreSQL y Limpieza con Docker

Continuando con el **Caso 3**, se está automatizando el proceso de respaldo de una base de datos PostgreSQL en Docker Compose, además de gestionar la limpieza periódica de respaldos antiguos y subir las imágenes resultantes a Docker Hub.

---

## 📋 Estructura del Proyecto

Todos los archivos requeridos residen dentro del directorio `caso3/`:

```text
caso3/
├── Dockerfile.db
├── Dockerfile.backup
├── docker-compose.yml
├── init.sql
├── backup.sh
├── cleaner.sh
└── entrypoint.sh
```

---

## 🛠️ Archivos de Configuración Exactos

### 1. `backup.sh`
Genera un archivo `.sql` con la fecha y hora actual utilizando `pg_dump`:

```bash
#!/bin/sh

# Generar el nombre de archivo con la fecha/hora actual
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="/backups/backup_${TIMESTAMP}.sql"

# Exportar contraseña para que pg_dump no la pida interactivamente
export PGPASSWORD=${POSTGRES_PASSWORD}

# Realizar el dump de la base de datos 'escuela'
pg_dump -h db -U ${POSTGRES_USER} -d ${POSTGRES_DB} > "$BACKUP_FILE"

echo "[$(date)] Backup realizado exitosamente: $BACKUP_FILE"
```

### 2. `cleaner.sh`
Conserva únicamente el respaldo más reciente dentro de la carpeta `/backups` y borra los anteriores:

```bash
#!/bin/sh

echo "[$(date)] Iniciando limpieza de backups antiguos..."

# Mantiene únicamente el archivo más reciente de /backups y borra los demás
ls -1t /backups/backup_*.sql 2>/dev/null | tail -n +2 | xargs rm -f

echo "[$(date)] Limpieza completada. Solo se conserva el backup más reciente."
```

### 3. `entrypoint.sh`
Ejecuta el respaldo inicial al arrancar el contenedor y mantiene un ciclo (*while true*) para controlar la programación periódica de los scripts de respaldo y limpieza:

```bash
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
```

---

## 🐋 Configuración Docker Compose (`docker-compose.yml`)

```yaml
version: '3.8'

services:
  db:
    build:
      context: .
      dockerfile: Dockerfile.db
    container_name: postgres_db_container
    environment:
      POSTGRES_DB: escuela
      POSTGRES_USER: usuario_escuela
      POSTGRES_PASSWORD: password_seguro
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - red-escuela

  backup-cleaner:
    build:
      context: .
      dockerfile: Dockerfile.backup
    container_name: postgres_backup_container
    environment:
      POSTGRES_HOST: db
      POSTGRES_DB: escuela
      POSTGRES_USER: usuario_escuela
      POSTGRES_PASSWORD: password_seguro
    volumes:
      - backups_data:/backups
    depends_on:
      - db
    networks:
      - red-escuela

volumes:
  db_data:
  backups_data:

networks:
  red-escuela:
    driver: bridge
```

---

## 🚀 Despliegue y Verificación Local

1. **Construir y levantar el entorno:**
   ```bash
   docker compose up -d --build
   ```

2. **Verificar logs del respaldo inicial:**
   ```bash
   docker logs postgres_backup_container
   ```
   *Resultado esperable:*
   `[Sat Aug 15 06:28:11 UTC 2026] Backup realizado exitosamente: /backups/backup_20260815_062811.sql`

3. **Confirmar la creación del archivo en el contenedor:**
   ```bash
   docker exec -it postgres_backup_container ls -la /backups
   ```

---

## 📦 Publicación de Imágenes en Docker Hub

### 1. Iniciar sesión
```bash
docker login
```

### 2. Etiquetar (*Tag*) las imágenes
```bash
docker tag caso3-db:latest yovana888/caso3-db:v1
docker tag caso3-backup-cleaner:latest yovana888/caso3-backup-cleaner:v1
```

### 3. Subir (*Push*) a Docker Hub
```bash
docker push yovana888/caso3-db:v1
docker push yovana888/caso3-backup-cleaner:v1
```

---

## 🔗 Repositorios Públicos

- **Imagen Backup & Cleaner:** [yovana888/caso3-backup-cleaner](https://hub.docker.com/repository/docker/yovana888/caso3-backup-cleaner)
- **Imagen PostgreSQL DB:** [yovana888/caso3-db](https://hub.docker.com/repository/docker/yovana888/caso3-db/general)

Evidencias:
https://docs.google.com/document/d/1qdtS-zdRQQ0ma3GE1JxbD0RwakAV_ZXEOla7C4cuK4U/edit?usp=sharing