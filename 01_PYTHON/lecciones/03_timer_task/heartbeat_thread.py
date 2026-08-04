import time
import threading
import RPi.GPIO as GPIO


# void setup()
LED_PIN = 21
PERIOD = 0.5 #segundos

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(LED_PIN, GPIO.OUT, initial=GPIO.LOW)

stop_event = threading.Event()

def heartbeat():
    state = False
    while not stop_event.is_set():
        state = not state
        GPIO.output(LED_PIN, state)
        time.sleep(PERIOD)

thread = threading.Thread(target=heartbeat, daemon=True)
thread.start()

try:
    print("Presiona Ctrl+C para salir...")
    while True:
        print("Haciendo otras cosas en el hilo principal...")
        time.sleep(1)
except KeyboardInterrupt:
    print("Saliendo...")
finally:
    stop_event.set()
    thread.join()
    GPIO.cleanup()
