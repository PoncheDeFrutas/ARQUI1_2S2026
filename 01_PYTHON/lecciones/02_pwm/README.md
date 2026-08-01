# Lección 02: PWM

## Objetivo

Usar PWM para generar tonos en un buzzer pasivo y controlar la posición de un servo.

## Materiales y conexión

- Raspberry Pi y buzzer pasivo o servo.
- Señal: GPIO12 (pin físico 32).
- GND del componente y de la Raspberry Pi deben estar conectados.

Para el servo, usa una fuente de 5 V adecuada si el consumo supera lo que puede suministrar la Raspberry Pi; no alimentes el servo desde un GPIO.

## Ejecutar

```bash
uv run lecciones/02_pwm/buzzer_tones.py
uv run lecciones/02_pwm/servo_sweep.py
```

## Ejemplos

- `buzzer_tones.py`: reproduce una secuencia de frecuencias.
- `servo_sweep.py`: recorre aproximadamente de 0° a 180° y regresa.

## Resultado esperado

El buzzer reproduce cuatro tonos; el servo hace un barrido continuo. Ajusta `DUTY_MIN` y `DUTY_MAX` si el recorrido físico de tu servo lo requiere.
