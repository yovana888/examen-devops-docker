from flask import Flask
from datetime import datetime
import os

app = Flask(__name__)

@app.route('/')
def hello():
    # Muestra el ID del contenedor para verificar el balanceo de carga
    container_id = os.uname()[1]
    # Obtener fecha y hora de hoy
    today = datetime.now()
    return f"Hello, World: Yovana Velasquez Cruz from container {container_id} - today {today}"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)