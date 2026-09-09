import assert from 'node:assert/strict'
import test from 'node:test'
import {
  chartPoints,
  HISTORY_MS,
  isAnalysisResult,
  MAX_READINGS,
  parseReading,
  pruneReadings,
  readConfig,
  STALE_MS,
} from '../src/telemetry.ts'

test('solo las mediciones válidas del protocolo actual llegan a las gráficas', () => {
  assert.deepEqual(parseReading('Temperature: 25, Humidity: 50', 100), {
    temperature: 25,
    humidity: 50,
    timestamp: 100,
  })
  assert.deepEqual(parseReading(' Temperature: -2.5, Humidity: 99.5\n', 100), {
    temperature: -2.5,
    humidity: 99.5,
    timestamp: 100,
  })
  for (const text of [
    'Hola IoT',
    '',
    'Temperature: NaN, Humidity: 50',
    'Temperature: Infinity, Humidity: 50',
    'Temperature: 25, Humidity: 101',
    'Temperature: 25, Humidity: -1',
    'Temperature: 25, Humidity: 50 extra',
    'x'.repeat(1025),
  ]) {
    assert.equal(parseReading(text, 100), null, text)
  }
  assert.equal(parseReading('Temperature: 25, Humidity: 50', NaN), null)
  assert.ok(parseReading('Temperature: 0, Humidity: 0', 0))
  assert.ok(parseReading('Temperature: 30, Humidity: 100', 0))
})

test('el historial conserva como máximo una hora y 2.000 muestras sin mutar el original', () => {
  const now = HISTORY_MS + 10_000
  const readings = Array.from({ length: MAX_READINGS + 5 }, (_, index) => ({
    timestamp: now - 2500 + index,
    temperature: 25,
    humidity: 50,
  }))
  const bounded = pruneReadings(readings, now)
  assert.equal(bounded.length, MAX_READINGS)
  assert.equal(bounded[0], readings[5])
  assert.equal(readings.length, MAX_READINGS + 5)
  assert.equal(pruneReadings(bounded, now), bounded)
  const boundary = { ...readings[0], timestamp: now - HISTORY_MS }
  assert.deepEqual(
    pruneReadings(
      [{ ...boundary, timestamp: boundary.timestamp - 1 }, boundary],
      now,
    ),
    [boundary],
  )
  assert.deepEqual(pruneReadings(bounded, now + HISTORY_MS + 1), [])
})

test('el tiempo real determina la ventana y los huecos de la señal', () => {
  const reading = (timestamp) => ({ timestamp, temperature: 25, humidity: 50 })
  const points = chartPoints(
    [reading(0), reading(2000), reading(2000 + STALE_MS + 1)],
    0,
    20_000,
  )
  assert.equal(points.length, 4)
  assert.deepEqual(points[2], {
    timestamp: 2001,
    temperature: null,
    humidity: null,
  })
  assert.deepEqual(
    chartPoints([reading(0), reading(2000), reading(20_001)], 1000, 20_000),
    [reading(2000)],
  )
  assert.deepEqual(chartPoints([], 0, 1000), [])
  assert.equal(
    chartPoints([reading(0), reading(STALE_MS)], 0, STALE_MS).length,
    2,
  )
})

test('se validan la configuración pública y las respuestas del backend', () => {
  const env = {
    VITE_MQTT_URL: 'wss://broker.emqx.io:8084/mqtt',
    VITE_MQTT_TOPIC: 'ARQUI1B_2026/test',
    VITE_API_BASE_URL: '/api/',
  }
  assert.equal(readConfig(env).error, '')
  assert.equal(readConfig(env).api, '/api')
  assert.match(readConfig({}).error, /VITE_MQTT_URL/)
  assert.match(
    readConfig({ ...env, VITE_MQTT_URL: 'mqtt://localhost:1883' }).error,
    /VITE_MQTT_URL/,
  )
  assert.match(
    readConfig({ ...env, VITE_MQTT_TOPIC: 'test/#' }).error,
    /VITE_MQTT_TOPIC/,
  )
  assert.match(
    readConfig({ ...env, VITE_API_BASE_URL: '//example.com' }).error,
    /VITE_API_BASE_URL/,
  )
  const result = { documentos: 20, salida: 'Suma: 600', error: '', codigo: 0 }
  assert.equal(isAnalysisResult(result), true)
  assert.equal(isAnalysisResult({ ...result, codigo: 1, error: 'Fallo' }), true)
  for (const invalid of [
    null,
    [],
    'ok',
    { error: 'fallo' },
    { ...result, documentos: -1 },
    { ...result, codigo: '0' },
  ])
    assert.equal(isAnalysisResult(invalid), false)
})
