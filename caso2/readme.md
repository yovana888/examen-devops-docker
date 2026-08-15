# Modificación y Despliegue de Imagen Docker (Flask)

Procedimiento para descargar una imagen de Docker Hub, acceder a su código fuente, realizar modificaciones mediante (*Bind Mount*) y publicar la versión actualizada

---

## 1. Descarga de la Imagen Original

Descargamos la imagen original desde el repositorio público en Docker Hub:

* **Repositorio origen:** `fercdevv/scale-flask`

```bash
docker pull fercdevv/scale-flask
```

---

## 2. Ejecución del Contenedor Inicial

Levantamos un contenedor basado en la imagen descargada, mapeando el puerto `5000` del host con el puerto interno de la aplicación Flask:

```bash
docker run -d --name scale-flask-container -p 5000:5000 fercdevv/scale-flask
```

---

## 3. Exploración del Código Fuente

Navegamos a la carpeta del proyecto local (`caso2`) e ingresamos al contenedor activo mediante una terminal interactiva para verificar la estructura de archivos en `/app`:

```bash
cd caso2
docker exec -it scale-flask-container bash
```

Dentro del contenedor, verificamos los archivos del proyecto:

```bash
ls -la
```

**Resultado obtenido:**
```plain
Dockerfile  app.py  requirements.txt
```

Salimos del contenedor:

```bash
exit
```

---

## 4. Extracción y Modificación del Archivo `app.py`

Copiamos el archivo `app.py` desde el contenedor hacia la máquina local/host para editarlo cómodamente desde el entorno de desarrollo:

```bash
docker cp scale-flask-container:/app/app.py ./app.py
```

*Se realizan las modificaciones requeridas en el archivo `app.py` local (actualización del mensaje de respuesta con Apellidos, Nombre y Fecha).*

Posteriormente, eliminamos el contenedor en ejecución previo para reconfigurarlo:

```bash
docker rm -f scale-flask-container
```

---

## 5. Montaje de Volumen (Bind Mount) y Verificación

Volvemos a desplegar el contenedor vinculando el archivo local `app.py` mediante un *Bind Mount* para aplicar los cambios sin necesidad de reconstruir la imagen completa:

```bash
docker run -d --name scale-flask-container -p 5000:5000 -v $(pwd)/app.py:/app/app.py fercdevv/scale-flask
```

Verificamos el correcto funcionamiento en el navegador accediendo a `http://localhost:5000`.

---

## 6. Generación y Publicación de la Nueva Imagen

### Autenticación en Docker Hub
Iniciamos sesión en Docker Hub con la cuenta personal:

```bash
docker login -u yovana888
```

### Creación del Snapshot (Commit)
Generamos una nueva imagen de Docker a partir del contenedor con los cambios aplicados:

```bash
docker commit scale-flask-container yovana888/scale-flask:v1
```

### Subida a Docker Hub (Push)
Publicamos la nueva imagen etiquetada en el repositorio remoto:

```bash
docker push yovana888/scale-flask:v1
```

---

## 7. Enlaces de Referencia

* **Imagen Base Original:** [fercdevv/scale-flask](https://hub.docker.com/repository/docker/fercdevv/scale-flask/general)
* **Nueva Imagen Publicada:** [yovana888/scale-flask](https://hub.docker.com/repository/docker/yovana888/scale-flask/general)
