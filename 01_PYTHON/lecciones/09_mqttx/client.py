import time
import paho.mqtt.client as mqtt

BROKER = "broker.emqx.io"
PORT = 1883

client = mqtt.Client()

client.connect(BROKER, PORT)
client.loop_start()

print("Conectado al broker")

time.sleep(2)

client.disconnect()
client.loop_stop()

print("Desconectado")
