import time

import paho.mqtt.client as mqtt
from paho.mqtt.enums import CallbackAPIVersion
from paho.mqtt.subscribeoptions import SubscribeOptions

class mqttClient:
    def __init__(self):
        self.broker = "broker.emqx.io"
        self.port = 1883
        self.topic = "ARQUI1B_2026/test"
        self.client = mqtt.Client(
            CallbackAPIVersion.VERSION2,
            protocol=mqtt.MQTTv5,
        )
        self.lastSend = 0

    def setup(self):
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message

        self.client.connect(self.broker, self.port)

        self.client.loop_start()

    def on_connect(self, client, userdata, flags, rc, properties):
        if rc == 0:
            print("Connected to MQTT Broker!")

            options = SubscribeOptions(
                qos=0,
                noLocal=False,
            )

            client.subscribe(
                self.topic,
                options=options
            )


    def on_message(self, client, userdata, msg):
        print(f"Received message: {msg.payload.decode()} on topic {msg.topic}")

    def publish(self, message):
        current_time = time.time()

        if current_time - self.lastSend > 2:
            self.lastSend = current_time
            result = self.client.publish(self.topic, message)
            status = result[0]
            if status == 0:
                print(f"Sent message: {message} to topic: {self.topic}")
            else:
                print(f"Failed to send message to topic {self.topic}")
            self.lastSend = current_time


    def disconnect(self):
        self.client.loop_stop()
        self.client.disconnect()
        print("Disconnected from MQTT Broker")

