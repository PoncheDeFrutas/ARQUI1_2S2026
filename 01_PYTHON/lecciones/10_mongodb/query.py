"""
Ejemplo 03: consultas básicas a una colección.

Asume que ya hay documentos insertados (por ejemplo con example02_insert.py).

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


def get_collection():
    uri = os.getenv("MONGODB_URI")
    if not uri:
        raise RuntimeError(
            "Falta MONGODB_URI en .env. Copia .env.example y completa tu cadena."
        )
    db_name = os.getenv("MONGODB_DB")
    col_name = os.getenv("MONGODB_COLLECTION")
    client = MongoClient(uri, server_api=ServerApi("1"))
    return client[db_name][col_name]


def main():
    # Cargar variables de .env
    load_dotenv()

    col = get_collection()

    print("1) Listar todos los documentos")
    for doc in col.find():
        pprint(doc)

    print("\n2) Filtro simple: room == 'lab'")
    for doc in col.find({"room": "lab"}):
        pprint(doc)

    print("\n3) Proyección de campos: solo sensor y temp")
    for doc in col.find({}, {"_id": 0, "sensor": 1, "temp": 1}):
        pprint(doc)

    print("\n4) Ordenar por temperatura descendente")
    for doc in col.find().sort("temp", -1):
        pprint(doc)


if __name__ == "__main__":
    main()
