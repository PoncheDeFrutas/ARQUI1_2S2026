import time

import paho.mqtt.client as mqtt
from paho.mqtt.enums import CallbackAPIVersion
from paho.mqtt.subscribeoptions import SubscribeOptions

BROKER = "broker.emqx.io"
PORT = 1883
TOPIC = "ARQUI1B_2026/test"


def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        print("Conectado")

        options = SubscribeOptions(
            qos=0,
            noLocal=True,
        )

        client.subscribe(
            TOPIC,
            options=options,
        )


def on_message(client, userdata, message):
    print(f"Recibido: {message.payload.decode()}")


client = mqtt.Client(
    CallbackAPIVersion.VERSION2,
    protocol=mqtt.MQTTv5,
)

client.on_connect = on_connect
client.on_message = on_message

client.reconnect_delay_set(1, 30)

client.connect(BROKER, PORT)
client.loop_start()

try:
    counter = 0

    while True:
        client.publish(
            TOPIC,
            f"Ping {counter}",
        )

        counter += 1
        time.sleep(2)

except KeyboardInterrupt:
    print("\nSaliendo...")

finally:
    client.disconnect()
    client.loop_stop()
