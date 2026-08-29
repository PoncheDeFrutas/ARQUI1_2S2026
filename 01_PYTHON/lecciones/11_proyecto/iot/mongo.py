import os
from Globals import shared

from dotenv import load_dotenv
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi


class mongodbu:
    def __init__(self):
        load_dotenv()

        self.uri = os.getenv("MONGODB_URI")
        self.db_name = os.getenv("MONGODB_DB")
        self.col_name = os.getenv("MONGODB_COLLECTION")
        self.col = None

    def setup(self):
        if not self.uri:
            raise RuntimeError(
                "Falta MONGODB_URI en .env. Copia .env.example y completa tu cadena."
            )
        self.client = MongoClient(self.uri, server_api=ServerApi("1"))
        self.col = self.client[self.db_name][self.col_name]

    def insert(self, doc):
        if self.col is None:
            raise RuntimeError("La colección no está configurada. Llama a setup() primero.")
        self.col.insert_one(doc)
