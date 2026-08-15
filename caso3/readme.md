# Sistema de PostgreSQL con Backup Automático y Limpieza con Docker

Se implementa una solución automatizada en contenedores basada en PostgreSQL que inicializa una base de datos mediante un script SQL personalizado, genera respaldos automáticos periódicos y gestiona la limpieza de backups antiguos usando tareas programadas con `cron`.

---

## 1. Inicialización de la Base de Datos

Se creó una imagen personalizada de PostgreSQL a partir de `postgres:15-alpine` que copia automáticamente el script `init.sql` al directorio especial `/docker-entrypoint-initdb.d/`.

### Archivos creados:

* **`init.sql`**: Define la estructura inicial e inserta los datos de prueba.
* **`Dockerfile.db`**: Construye la imagen customizada de PostgreSQL.

```dockerfile
FROM postgres:15-alpine
COPY init.sql /docker-entrypoint-initdb.d/
```

---

## 2. Comandos de Construcción y Prueba Inicial

### Construir la imagen de la base de datos custom:
```bash
docker build -f Dockerfile.db -t postgres-custom .
```

### Desplegar el contenedor de prueba:
```bash
docker run -d --name test-db-container  -e POSTGRES_DB=escuela   -e POSTGRES_PASSWORD=postgres   -p 5432:5432   postgres-custom
```

---

## 3. Verificación de Datos Inicializados

Para comprobar que el script `init.sql` se ejecutó correctamente al iniciar el contenedor, se realiza una consulta a la tabla `alumnos`:

```bash
docker exec -it test-db-container psql -U postgres -d escuela -c "SELECT * FROM alumnos;"
```

**Resultado obtenido:**

```plain
 id |     nombre     |        email        |       fecha_registro       
----+----------------+---------------------+----------------------------
  1 | Juan Perez     | juan@escuela.com    | 2026-08-15 05:24:54.447472
  2 | Maria Lopez    | maria@escuela.com   | 2026-08-15 05:24:54.447472
  3 | Carlos Sanchez | carlos@escuela.com  | 2026-08-15 05:24:54.447472
  4 | Ana Torres     | ana@escuela.com     | 2026-08-15 05:24:54.447472
  5 | Luis Ramirez   | luis@escuela.com    | 2026-08-15 05:24:54.447472
(5 rows)
```