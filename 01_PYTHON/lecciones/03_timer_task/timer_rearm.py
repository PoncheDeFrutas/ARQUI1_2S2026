import threading
import time
import RPi.GPIO as GPIO

LED_PIN = 21
PERIOD = 3

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(LED_PIN, GPIO.OUT, initial=GPIO.LOW)

stop_event = threading.Event()
led_state = False

def task():
    global led_state, stop_event
    if stop_event.is_set():
        return
    led_state = not led_state
    GPIO.output(LED_PIN, led_state)
    print(f"[Timer] LED {'ON' if led_state else 'OFF'}")

    # Rearmar el temporizador para la siguiente ejecución
    timer = threading.Timer(PERIOD, task)       # Crear un nuevo temporizador
    timer.daemon = True                         # Hacer que el temporizador sea un hilo daemon
    timer.start()

# Primer Arranque
timer = threading.Timer(PERIOD, task)       # Crear un nuevo temporizador
timer.daemon = True                         # Hacer que el temporizador sea un hilo daemon
timer.start()                               # Iniciar el temporizador

try:
    print("Timer rearmable cada 3 segundos")
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print ("Exiting...")
finally:
    stop_event.set()
    timer.cancel()
    GPIO.cleanup()
