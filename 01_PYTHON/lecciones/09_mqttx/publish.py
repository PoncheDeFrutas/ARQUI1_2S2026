import time

import paho.mqtt.publish as publish

BROKER = "broker.emqx.io"
TOPIC = "ARQUI1B_2026/test"


message = f"Hola MQTTX {time.strftime('%H:%M:%S')}"

publish.single(
    TOPIC,
    payload=message,
    hostname=BROKER,
    port=1883,
)

print(f"Mensaje enviado: {message}")
