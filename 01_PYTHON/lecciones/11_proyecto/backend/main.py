import os
import subprocess
from pathlib import Path

from dotenv import load_dotenv
from flask import Flask, jsonify
from pymongo import DESCENDING
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

app = Flask(__name__)

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI")
MONGODB_DB = os.getenv("MONGODB_DB")
MONGODB_COLLECTION = os.getenv("MONGODB_COLLECTION")

BASE_DIR = Path(__file__).resolve().parent
TXT_PATH = BASE_DIR / "src" / "lecturas.txt"
OUTPUT_PATH = BASE_DIR / "src" / "output.txt"
PROGRAM_PATH = BASE_DIR / "build" / "src" / "08_rutina"

collection = None


def get_collection():
    global collection
    if collection is None:
        client = MongoClient(MONGODB_URI, server_api=ServerApi("1"))
        collection = client[MONGODB_DB][MONGODB_COLLECTION]
    return collection

@app.route("/")
def index():
    return "Hello, World!"

@app.route("/analizar", methods=["POST"])
def analizar():
    try:
        data = crear_txt()

        command = [str(PROGRAM_PATH)]
        if os.uname().machine not in {"aarch64", "arm64"}:
            command.insert(0, "qemu-aarch64")

        result = subprocess.run(
            command,
            cwd=BASE_DIR,
            capture_output=True,
            text=True,
            timeout=10
        )

        return jsonify({
            "documentos": data,
            "salida": OUTPUT_PATH.read_text(encoding="utf-8").strip()
            if result.returncode == 0 else result.stdout.strip(),
            "error": result.stderr.strip(),
            "codigo": result.returncode
        })


    except Exception as exc:
        return jsonify({
            "error": str(exc)
        }), 500


def crear_txt():
    documents = list(
        get_collection().find()
        .sort("temperature", DESCENDING)
        .limit(20)
    )

    documents.reverse()

    TXT_PATH.parent.mkdir(parents=True, exist_ok=True)

    with TXT_PATH.open("w", newline="", encoding="utf-8") as f:
        for doc in documents:
            temperature = doc["temperature"]
            if not isinstance(temperature, int) or isinstance(temperature, bool) or temperature < 0:
                raise ValueError("temperature debe ser un entero no negativo")
            f.write(f"{temperature}\n")
        f.write("$")

    return len(documents)


if __name__ == "__main__":
    app.run(debug=True, port=5000)
