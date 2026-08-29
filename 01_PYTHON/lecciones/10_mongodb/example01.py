"""
Ejemplo 01: conexión y ping a MongoDB usando variables de entorno.

Requiere un archivo `.env` en este directorio con:
  MONGODB_URI=<cadena de conexión>
"""

import os

from dotenv import load_dotenv
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi


def main():
    load_dotenv()
    uri = os.getenv("MONGODB_URI")
    if not uri:
        raise RuntimeError(
            "Falta MONGODB_URI en .env. Copia .env.example y completa tu cadena."
        )

    client = MongoClient(uri, server_api=ServerApi("1"))

    # Ping para verificar que la conexión funciona
    try:
        client.admin.command("ping")
        print("Ping exitoso: conexión establecida con MongoDB.")
    except Exception as exc:
        print(f"Error al conectar: {exc}")


if __name__ == "__main__":
    main()
