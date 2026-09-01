from Sensores import *
from mongo import *
from Globals import shared

class main:
    def __init__(self):
        self.sensores = Sensores()
        self.mongo = mongodbu()

    def setup(self):
        self.sensores.setup()
        self.mongo.setup()
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
                time.sleep(0.2)
        except KeyboardInterrupt:
            print("Programa terminado por el usuario.")
        finally:
            # Cerrar conexiones y limpiar recursos si es necesario
            # GPIO.cleanup()
            pass


if __name__ == "__main__":
    hola = main()
    hola.setup()
    hola.loop()
