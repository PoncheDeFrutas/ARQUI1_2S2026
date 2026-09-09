export interface Reading {
  timestamp: number
  temperature: number
  humidity: number
}

export interface ChartPoint {
  timestamp: number
  temperature: number | null
  humidity: number | null
}

export const STALE_MS = 10_000
export const HISTORY_MS = 60 * 60 * 1000
export const MAX_READINGS = 2000

const number = '([+-]?(?:\\d+(?:\\.\\d+)?|\\.\\d+))'
const readingPattern = new RegExp(
  `^Temperature:\\s*${number},\\s*Humidity:\\s*${number}$`,
)

export function parseReading(
  payload: string,
  timestamp: number,
): Reading | null {
  if (payload.length > 1024 || !Number.isFinite(timestamp)) return null
  const match = readingPattern.exec(payload.trim())
  if (!match) return null
  const temperature = Number(match[1])
  const humidity = Number(match[2])
  if (
    !Number.isFinite(temperature) ||
    !Number.isFinite(humidity) ||
    humidity < 0 ||
    humidity > 100
  )
    return null
  return { timestamp, temperature, humidity }
}

export function pruneReadings(readings: Reading[], now: number): Reading[] {
  const cutoff = now - HISTORY_MS
  if (
    readings.length <= MAX_READINGS &&
    (!readings.length || readings[0].timestamp >= cutoff)
  )
    return readings
  // ponytail: buffer de 2.000 muestras; usar agregación si se necesita historial más largo.
  return readings
    .filter((reading) => reading.timestamp >= cutoff)
    .slice(-MAX_READINGS)
}

export function chartPoints(
  readings: Reading[],
  start: number,
  now: number,
): ChartPoint[] {
  const points: ChartPoint[] = []
  let previous: Reading | undefined
  for (const reading of readings) {
    if (reading.timestamp < start || reading.timestamp > now) continue
    if (previous && reading.timestamp - previous.timestamp > STALE_MS) {
      points.push({
        timestamp: previous.timestamp + 1,
        temperature: null,
        humidity: null,
      })
    }
    points.push(reading)
    previous = reading
  }
  return points
}

export interface AnalysisResult {
  documentos: number
  salida: string
  error: string
  codigo: number
}

export function isAnalysisResult(value: unknown): value is AnalysisResult {
  if (typeof value !== 'object' || value === null) return false
  const data = value as Record<string, unknown>
  return (
    Number.isInteger(data.documentos) &&
    Number(data.documentos) >= 0 &&
    typeof data.salida === 'string' &&
    typeof data.error === 'string' &&
    Number.isInteger(data.codigo)
  )
}

export function readConfig(env: Record<string, string | undefined>) {
  const url = env.VITE_MQTT_URL?.trim() || ''
  const topic = env.VITE_MQTT_TOPIC?.trim() || ''
  const api = env.VITE_API_BASE_URL?.trim().replace(/\/$/, '') || ''
  const errors: string[] = []
  try {
    const parsed = new URL(url)
    if (
      !['ws:', 'wss:'].includes(parsed.protocol) ||
      !parsed.hostname ||
      parsed.username ||
      parsed.password
    )
      throw new Error()
  } catch {
    errors.push('VITE_MQTT_URL debe ser una dirección ws:// o wss:// válida.')
  }
  if (!topic || /[+#]/.test(topic) || topic.includes('\0'))
    errors.push('VITE_MQTT_TOPIC debe indicar un tópico sin comodines.')
  try {
    const parsed = new URL(api, 'http://localhost')
    if (
      (!api.startsWith('/') && !/^https?:\/\//.test(api)) ||
      api.startsWith('//') ||
      /\s/.test(api) ||
      !['http:', 'https:'].includes(parsed.protocol) ||
      parsed.username ||
      parsed.password ||
      parsed.search ||
      parsed.hash
    )
      throw new Error()
  } catch {
    errors.push('VITE_API_BASE_URL debe ser /api o una dirección HTTP válida.')
  }
  return { url, topic, api, error: errors.join(' ') }
}
