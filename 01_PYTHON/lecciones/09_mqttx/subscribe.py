import paho.mqtt.client as mqtt
from paho.mqtt.enums import CallbackAPIVersion

BROKER = "broker.emqx.io"
PORT = 1883
TOPIC = "ARQUI1B_2026/test"


def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        print("Conectado al broker")
        client.subscribe(TOPIC)
        print(f"Suscrito a {TOPIC}")
    else:
        print(f"Error de conexión: {reason_code}")


def on_message(client, userdata, message):
    print(f"Mensaje recibido: {message.payload.decode()}")


client = mqtt.Client(CallbackAPIVersion.VERSION2)

client.on_connect = on_connect
client.on_message = on_message

client.connect(BROKER, PORT)

try:
    client.loop_forever()
except KeyboardInterrupt:
    print("\nSaliendo...")
    client.disconnect()
