import { useEffect, useRef, useState } from 'react'
import mqtt from 'mqtt'
import type { MqttClient } from 'mqtt'
import { parseReading, pruneReadings, readConfig } from './telemetry'
import type { Reading } from './telemetry'

export const config = readConfig(import.meta.env)
export type Connection = 'connecting' | 'connected' | 'reconnecting' | 'error'

export function useTelemetry() {
  const client = useRef<MqttClient | null>(null)
  const [connection, setConnection] = useState<Connection>('connecting')
  const [error, setError] = useState('')
  const [readings, setReadings] = useState<Reading[]>([])
  const [latest, setLatest] = useState<Reading | null>(null)
  const [count, setCount] = useState(0)
  const [startedAt] = useState(Date.now)
  const [now, setNow] = useState(Date.now)

  useEffect(() => {
    const timer = window.setInterval(() => {
      const time = Date.now()
      setNow(time)
      setReadings((previous) => pruneReadings(previous, time))
    }, 1000)
    return () => window.clearInterval(timer)
  }, [])

  useEffect(() => {
    if (config.error) return
    let active = true
    const connection = mqtt.connect(config.url, {
      protocolVersion: 5,
      clean: true,
      reconnectPeriod: 2000,
      connectTimeout: 10_000,
      queueQoSZero: false,
      resubscribe: false,
    })
    client.current = connection
    connection.on('connect', () => {
      if (!active) return
      connection.subscribe(
        config.topic,
        { qos: 0, nl: true },
        (err, granted) => {
          if (!active) return
          if (err || !granted?.length || granted.some((item) => item.qos > 2)) {
            setConnection('error')
            setError(
              'No se pudo escuchar el tópico. Revisa su configuración y recarga la página.',
            )
            return
          }
          setConnection('connected')
          setError('')
        },
      )
    })
    connection.on('reconnect', () => {
      if (active) setConnection('reconnecting')
    })
    connection.on('close', () => {
      if (active) setConnection('reconnecting')
    })
    connection.on('error', () => {
      if (!active) return
      setConnection('error')
      setError(
        'No se pudo conectar al broker. Revisa tu conexión; volveremos a intentarlo.',
      )
    })
    connection.on('message', (topic, payload, packet) => {
      if (
        !active ||
        topic !== config.topic ||
        packet.retain ||
        payload.length > 1024
      )
        return
      const reading = parseReading(payload.toString(), Date.now())
      if (!reading) return
      setReadings((previous) =>
        pruneReadings([...previous, reading], reading.timestamp),
      )
      setLatest(reading)
      setNow(reading.timestamp)
      setCount((previous) => previous + 1)
    })
    return () => {
      active = false
      client.current = null
      connection.end(true)
    }
  }, [])

  async function sendMessage(text: string) {
    const message = text.trim()
    if (!message || message.length > 500)
      throw new Error('Escribe un mensaje de 1 a 500 caracteres.')
    const current = client.current
    if (!current?.connected || connection !== 'connected')
      throw new Error('Espera a que se restablezca la conexión para enviar.')
    await new Promise<void>((resolve, reject) => {
      const timeout = window.setTimeout(
        () =>
          reject(
            new Error('No se pudo completar el envío. Revisa la conexión.'),
          ),
        10_000,
      )
      current.publish(
        config.topic,
        message,
        { qos: 0, retain: false },
        (err) => {
          window.clearTimeout(timeout)
          if (err)
            reject(
              new Error('No se pudo enviar el mensaje. Inténtalo de nuevo.'),
            )
          else resolve()
        },
      )
    })
  }

  return {
    connection,
    error,
    readings,
    latest,
    count,
    startedAt,
    now,
    sendMessage,
  }
}
