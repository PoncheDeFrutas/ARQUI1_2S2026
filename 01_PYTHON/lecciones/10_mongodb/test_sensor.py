"""
Ejemplo 04: inserción de documentos en una colección.
Obteniendo datos aleatorios de sensores y guardándolos en MongoDB.
Esta es una simulación sobre como deberia actuar la parte de los sensores
en la raspberry pi, insertando un nuevo documento cada segundo.

Variables en .env:
  MONGODB_URI
  MONGODB_DB
  MONGODB_COLLECTION
"""

import os
import random
import time
from pprint import pprint

from dotenv import load_dotenv
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi


def get_client() -> MongoClient:
    uri = os.getenv("MONGODB_URI")
    if not uri:
        raise RuntimeError(
            "Falta MONGODB_URI en .env. Copia .env.example y completa tu cadena."
        )
    return MongoClient(uri, server_api=ServerApi("1"))


def main():
    # Cargar variables de .env
    load_dotenv()

    db_name = os.getenv("MONGODB_DB")
    col_name = os.getenv("MONGODB_COLLECTION")

    client = get_client()
    collection = client[db_name][col_name]

    while True:
        doc = {
            "sensor": f"raspi",
            "temp": round(random.uniform(20, 30), 1),
            "hum": random.randint(40, 70),
            "room": "lab",
        }
        collection.insert_one(doc)
        time.sleep(1)
        print(f"Documento insertado: {doc}")


if __name__ == "__main__":
    main()
