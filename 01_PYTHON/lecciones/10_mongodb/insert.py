"""
Ejemplo 02: inserción de documentos en una colección.

Variables en .env:
  MONGODB_URI
  MONGODB_DB
  MONGODB_COLLECTION
"""

import os
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

    # Datos de ejemplo
    docs = [
        {"sensor": "raspi-01", "temp": 23.5, "room": "lab"},
        {"sensor": "raspi-02", "temp": 22.1, "room": "lab"},
        {"sensor": "esp32-01", "room": "oficina"},
        {"Asensor": "esp32-02", "temp": 26.3, "room": "oficina"},
    ]

    result = collection.insert_many(docs)
    print(f"Insertados {len(result.inserted_ids)} documentos en {db_name}.{col_name}")
    pprint(result.inserted_ids)


if __name__ == "__main__":
    main()
