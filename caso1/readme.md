# Docker - Redes Bridge y Volumen Compartido

## 1. Creación de las redes Bridge

Se crearon 3 redes de tipo `bridge`:

```bash
docker network create yovana_velasquez_1
docker network create yovana_velasquez_2
docker network create yovana_velasquez_3
```

### Distribución de contenedores

- **Red 1**
  - yovana_velasquez_container_1
  - yovana_velasquez_container_2

- **Red 2**
  - yovana_velasquez_container_2
  - yovana_velasquez_container_3

- **Red 3**
  - yovana_velasquez_container_4

---

## 2. Creación de los contenedores

### Red 1

```bash
docker run -d --name yovana_velasquez_container_1 --network yovana_velasquez_1 nginx
docker run -d --name yovana_velasquez_container_2 --network yovana_velasquez_1 nginx
```

### Red 2

Se conecta el contenedor 2 a la segunda red:

```bash
docker network connect yovana_velasquez_2 yovana_velasquez_container_2
docker run -d --name yovana_velasquez_container_3 --network yovana_velasquez_2 nginx
```

### Red 3

```bash
docker run -d --name yovana_velasquez_container_4 --network yovana_velasquez_3 nginx
```

---

## 3. Verificación de las redes

```bash
docker inspect yovana_velasquez_1
docker inspect yovana_velasquez_2
docker inspect yovana_velasquez_3
```

---

## 4. Creación del volumen

Se creó un único volumen que será compartido por todos los contenedores:

```bash
docker volume create yovana_velasquez_volumen
```

---

## 5. Creación de los contenedores con el volumen

Primero se eliminaron los contenedores anteriores:

```bash
docker rm -f yovana_velasquez_container_1 \
yovana_velasquez_container_2 \
yovana_velasquez_container_3 \
yovana_velasquez_container_4
```

Luego se crearon nuevamente utilizando el volumen compartido:

```bash
docker run -d --name yovana_velasquez_container_1 \
--network yovana_velasquez_1 \
-v yovana_velasquez_volumen:/datos nginx

docker run -d --name yovana_velasquez_container_2 \
--network yovana_velasquez_1 \
-v yovana_velasquez_volumen:/datos nginx
```

Se conecta el contenedor 2 a la segunda red:

```bash
docker network connect yovana_velasquez_2 yovana_velasquez_container_2
```

Se crean los contenedores restantes:

```bash
docker run -d --name yovana_velasquez_container_3 \
--network yovana_velasquez_2 \
-v yovana_velasquez_volumen:/datos nginx

docker run -d --name yovana_velasquez_container_4 \
--network yovana_velasquez_3 \
-v yovana_velasquez_volumen:/datos nginx
```

---

## 6. Verificación del volumen

Se verifica que el volumen esté asociado a cada contenedor:

```bash
docker inspect yovana_velasquez_container_1
docker inspect yovana_velasquez_container_2
docker inspect yovana_velasquez_container_3
docker inspect yovana_velasquez_container_4
```

---

## 7. Creación de archivos en cada contenedor

Cada contenedor utiliza el mismo volumen montado en `/datos`.

### Contenedor 1

```bash
docker exec -it yovana_velasquez_container_1 sh
cd /datos
echo "Hola desde el contenedor 1" > archivo_container_1.txt
exit
```

### Contenedor 2

```bash
docker exec -it yovana_velasquez_container_2 sh
cd /datos
echo "Hola desde el contenedor 2" > archivo_container_2.txt
exit
```

### Contenedor 3

```bash
docker exec -it yovana_velasquez_container_3 sh
cd /datos
echo "Hola desde el contenedor 3" > archivo_container_3.txt
exit
```

### Contenedor 4

```bash
docker exec -it yovana_velasquez_container_4 sh
cd /datos
echo "Hola desde el contenedor 4" > archivo_container_4.txt
exit
```

---

## 8. Verificación del volumen compartido

Para comprobar que todos los contenedores utilizan el mismo volumen:

```bash
docker exec yovana_velasquez_container_1 ls /datos
docker exec yovana_velasquez_container_2 ls /datos
docker exec yovana_velasquez_container_3 ls /datos
docker exec yovana_velasquez_container_4 ls /datos
```

Los cuatro contenedores deberán visualizar los archivos:

```text
archivo_container_1.txt
archivo_container_2.txt
archivo_container_3.txt
archivo_container_4.txt
```

Evidencias:
https://docs.google.com/document/d/1qdtS-zdRQQ0ma3GE1JxbD0RwakAV_ZXEOla7C4cuK4U/edit?usp=sharing