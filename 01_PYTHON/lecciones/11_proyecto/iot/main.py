from Sensores import *
from mongo import *
from mqtt import *
from Globals import shared

class main:
    def __init__(self):
        self.sensores = Sensores()
        self.mongo = mongodbu()
        self.mqtt = mqttClient()

    def setup(self):
        self.sensores.setup()
        self.mongo.setup()
        self.mqtt.setup()
        # setup de la conexion a mongo
        # setup de la conexion a mqtt

    def loop(self):
        try:
            while True:
                self.sensores.read()
                doc = {
                    "temperature": shared.temperature,
                    "humidity": shared.humidity,
                    "timestamp": time.time()
                }
                self.mongo.insert(doc)
                self.mqtt.publish(f"Temperature: {shared.temperature}, Humidity: {shared.humidity}")
                time.sleep(0.2)
        except KeyboardInterrupt:
            print("Programa terminado por el usuario.")
        finally:
            # Cerrar conexiones y limpiar recursos si es necesario
            # GPIO.cleanup()
            self.mqtt.disconnect()
            pass


if __name__ == "__main__":
    hola = main()
    hola.setup()
    hola.loop()
