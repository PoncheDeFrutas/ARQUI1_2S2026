# Frontend · Monitor ambiental

Muestra temperatura y humedad por MQTT, grafica las lecturas de la sesión, envía texto al IoT y solicita análisis al backend.

## Requisitos

- Node.js 24 y pnpm. Comprueba `node --version` y `pnpm --version`; si falta pnpm: `npm install -g pnpm`.
- Internet para MQTT y el [IoT](../iot/README.md) corriendo para recibir lecturas.
- El [backend](../backend/README.md) corriendo para ejecutar análisis.

## Preparación

Ejecuta los comandos desde `frontend/`:

```bash
pnpm install
test -f .env || cp .env.example .env
```

Revisa estos valores en `.env`:

```dotenv
VITE_MQTT_URL=wss://broker.emqx.io:8084/mqtt
VITE_MQTT_TOPIC=ARQUI1B_2026/test
VITE_API_BASE_URL=/api
BACKEND_URL=http://127.0.0.1:5000
```

El tópico debe coincidir con el de `iot/mqtt.py`. Si Flask corre en otra dirección, cambia `BACKEND_URL`. Reinicia Vite después de editar `.env`. Las variables `VITE_*` son públicas: no coloques contraseñas ni credenciales de MongoDB.

## Ejecutar

```bash
pnpm dev
```

Abre la dirección que muestra Vite, normalmente http://localhost:5173. Para usar todo el proyecto, deja tres terminales abiertas: una con el backend, otra con el IoT y otra con el frontend. Detén cada programa con `Ctrl+C`.

## Prueba rápida

1. Espera “Conectado” y comprueba que cambien temperatura y humedad cada ~2 segundos.
2. Cambia el intervalo entre 1, 5 y 15 minutos.
3. Escribe un mensaje y pulsa “Enviar mensaje”: debe aparecer como `Received message: ...` en la terminal del IoT.
4. Pulsa “Ejecutar análisis”: debe mostrar documentos, salida y código `0`.

El IoT actual simula sensores. Las gráficas solo conservan datos de esta sesión y se reinician al recargar. El análisis usa registros guardados en MongoDB, no el intervalo de las gráficas. El broker es público y el IoT no confirma la recepción de los mensajes.

Para comprobar el código:

```bash
pnpm test
pnpm lint
pnpm build
```

`build` genera `dist/`. Al desplegar, configura también el reenvío de `/api` al backend: el proxy de Vite es solo para desarrollo.

Si no llegan lecturas, revisa el tópico y la terminal del IoT; un error de MongoDB puede detener sus publicaciones. Si falla el análisis, revisa el backend y `BACKEND_URL`.
