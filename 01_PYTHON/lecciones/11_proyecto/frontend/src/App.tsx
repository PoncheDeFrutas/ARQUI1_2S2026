import { useEffect, useRef, useState } from 'react'
import type { FormEvent } from 'react'
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import { chartPoints, isAnalysisResult, STALE_MS } from './telemetry'
import type { AnalysisResult, ChartPoint, Reading } from './telemetry'
import { config, useTelemetry } from './useTelemetry'
import './App.css'

const timeFormat = new Intl.DateTimeFormat('es-GT', {
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
  hour12: false,
})
const shortTimeFormat = new Intl.DateTimeFormat('es-GT', {
  hour: '2-digit',
  minute: '2-digit',
  hour12: false,
})
const decimalFormat = new Intl.NumberFormat('es-GT', {
  maximumFractionDigits: 1,
  minimumFractionDigits: 1,
})
const connectionLabels = {
  connecting: 'Conectando',
  connected: 'Conectado',
  reconnecting: 'Reconectando',
  error: 'Sin conexión',
}

function WaveMark() {
  return (
    <svg
      width="25"
      height="25"
      viewBox="0 0 28 28"
      fill="none"
      aria-hidden="true"
    >
      <path
        d="M2 15h4l3-8 5 15 4-18 3 11h5"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function MeasurementChart({
  metric,
  latest,
  points,
  start,
  now,
  stale,
}: {
  metric: 'temperature' | 'humidity'
  latest: Reading | null
  points: ChartPoint[]
  start: number
  now: number
  stale: boolean
}) {
  const temperature = metric === 'temperature'
  const title = temperature ? 'Temperatura' : 'Humedad relativa'
  const unit = temperature ? '°C' : '%'
  const color = temperature ? 'var(--temperature)' : 'var(--humidity)'
  const values = points.flatMap((point) =>
    point[metric] === null ? [] : [point[metric] as number],
  )
  return (
    <section
      className={`measurement ${metric}`}
      aria-labelledby={`${metric}-title`}
    >
      <div className="measurement-heading">
        <div>
          <h3 id={`${metric}-title`}>
            <span className="series-mark" />
            {title}
          </h3>
          <p className={`measurement-value ${stale ? 'is-stale' : ''}`}>
            {latest ? decimalFormat.format(latest[metric]) : '—'}
            <span>{unit}</span>
          </p>
        </div>
        <div className="measurement-range">
          <span>En esta ventana</span>
          <p>
            Mín.{' '}
            <b>
              {values.length ? decimalFormat.format(Math.min(...values)) : '—'}
            </b>
            <span className="range-separator">/</span>Máx.{' '}
            <b>
              {values.length ? decimalFormat.format(Math.max(...values)) : '—'}
            </b>
          </p>
        </div>
      </div>
      <div
        className="chart-container"
        role="group"
        aria-label={`${title} a lo largo del tiempo, en ${unit}`}
      >
        <ResponsiveContainer width="100%" height="100%" minWidth={0}>
          <LineChart
            data={points}
            margin={{ top: 12, right: 12, bottom: 0, left: 0 }}
            accessibilityLayer
          >
            <CartesianGrid
              vertical={false}
              stroke="var(--grid)"
              strokeDasharray="3 5"
            />
            <XAxis
              dataKey="timestamp"
              type="number"
              domain={[start, now]}
              allowDataOverflow
              tickFormatter={(value: number) => shortTimeFormat.format(value)}
              tick={{ fill: 'var(--muted)', fontSize: 11 }}
              axisLine={false}
              tickLine={false}
              tickMargin={12}
              minTickGap={45}
            />
            <YAxis
              width={38}
              domain={temperature ? ['auto', 'auto'] : [0, 100]}
              tick={{ fill: 'var(--muted)', fontSize: 11 }}
              axisLine={false}
              tickLine={false}
              tickCount={4}
            />
            <Tooltip
              isAnimationActive={false}
              labelFormatter={(value) => timeFormat.format(Number(value))}
              formatter={(value) => [
                `${decimalFormat.format(Number(value))} ${unit}`,
                title,
              ]}
              contentStyle={{
                background: '#14243A',
                border: '1px solid #38516E',
                borderRadius: 8,
                color: '#E7EFF8',
                fontSize: 12,
              }}
              labelStyle={{ color: '#9CAEC5', marginBottom: 5 }}
              cursor={{ stroke: 'var(--muted)', strokeDasharray: '3 3' }}
            />
            <Line
              type="linear"
              dataKey={metric}
              name={title}
              stroke={color}
              strokeWidth={2}
              dot={
                values.length === 1
                  ? { r: 4, fill: color, strokeWidth: 0 }
                  : false
              }
              activeDot={{ r: 4, strokeWidth: 3, stroke: 'var(--surface)' }}
              connectNulls={false}
              isAnimationActive={false}
            />
          </LineChart>
        </ResponsiveContainer>
        {!values.length && (
          <div className="chart-empty">
            <span className="empty-line" />
            <p>
              {latest
                ? 'Sin lecturas en este intervalo'
                : 'Esperando la primera lectura'}
            </p>
            <span>
              {latest
                ? 'Las nuevas mediciones aparecerán aquí.'
                : 'Inicia el programa IoT para ver la señal.'}
            </span>
          </div>
        )}
      </div>
    </section>
  )
}

function MessagePanel({
  connected,
  sendMessage,
}: {
  connected: boolean
  sendMessage: (text: string) => Promise<void>
}) {
  const [message, setMessage] = useState('')
  const [sending, setSending] = useState(false)
  const [feedback, setFeedback] = useState('')
  const [failed, setFailed] = useState(false)
  const [history, setHistory] = useState<
    { id: string; text: string; timestamp: number; failed: boolean }[]
  >([])
  const pending = useRef(false)
  const sequence = useRef(0)

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (pending.current) return
    const text = message.trim()
    if (!text || text.length > 500 || !connected) return
    pending.current = true
    setSending(true)
    setFeedback('')
    let failed = false
    try {
      await sendMessage(text)
      setFeedback('Enviado, sin confirmación del IoT.')
      setMessage('')
    } catch (error) {
      failed = true
      setFeedback(
        error instanceof Error
          ? error.message
          : 'No se pudo enviar el mensaje.',
      )
    } finally {
      setFailed(failed)
      const entry = {
        id: String(++sequence.current),
        text,
        timestamp: Date.now(),
        failed,
      }
      setHistory((previous) => [entry, ...previous].slice(0, 30))
      pending.current = false
      setSending(false)
    }
  }

  return (
    <section className="panel message-panel" aria-labelledby="messages-title">
      <div className="panel-heading">
        <span className="eyebrow">Canal de salida</span>
        <svg
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          aria-hidden="true"
        >
          <path
            d="m4 4 16 8-16 8 3-8-3-8Zm3 8h13"
            stroke="currentColor"
            strokeWidth="1.5"
            strokeLinejoin="round"
          />
        </svg>
      </div>
      <h2 id="messages-title">Habla con tu IoT</h2>
      <p className="panel-description">
        Envía un texto y recíbelo en la consola de tu programa.
      </p>
      <form onSubmit={submit}>
        <div className="field-label">
          <label htmlFor="message">Mensaje</label>
          <span>{message.length}/500</span>
        </div>
        <textarea
          id="message"
          value={message}
          onChange={(event) => setMessage(event.target.value)}
          maxLength={500}
          rows={3}
          placeholder="Hola desde la estación…"
          aria-describedby="channel-note message-feedback"
          disabled={sending}
        />
        <button
          className="button button-primary"
          disabled={!connected || !message.trim() || sending}
          type="submit"
        >
          <span>{sending ? 'Enviando…' : 'Enviar mensaje'}</span>
          <span aria-hidden="true">↗</span>
        </button>
      </form>
      <p
        id="message-feedback"
        className={`feedback ${failed ? 'feedback-error' : ''}`}
        role="status"
      >
        {feedback ||
          (!connected ? 'Conecta con el broker para enviar mensajes.' : '')}
      </p>
      <p id="channel-note" className="channel-note">
        <span aria-hidden="true">ⓘ</span> Canal público. No envíes información
        sensible.
      </p>
      <div className="message-history">
        <div className="history-heading">
          <h3>Últimos envíos</h3>
          <span>{String(history.length).padStart(2, '0')}</span>
        </div>
        {history.length ? (
          <ol>
            {history.map((entry) => (
              <li key={entry.id}>
                <span
                  className={`history-arrow ${entry.failed ? 'failed' : ''}`}
                  aria-hidden="true"
                >
                  {entry.failed ? '!' : '↗'}
                </span>
                <div>
                  <p>{entry.text}</p>
                  <span>
                    {entry.failed ? 'No enviado' : 'Sin confirmación del IoT'}
                  </span>
                </div>
                <time dateTime={new Date(entry.timestamp).toISOString()}>
                  {timeFormat.format(entry.timestamp)}
                </time>
              </li>
            ))}
          </ol>
        ) : (
          <p className="history-empty">
            Tu primer mensaje empieza aquí.
            <br />
            <span>Los envíos aparecerán en esta lista.</span>
          </p>
        )}
      </div>
    </section>
  )
}

function AnalysisPanel() {
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<AnalysisResult | null>(null)
  const [error, setError] = useState('')
  const request = useRef<AbortController | null>(null)
  useEffect(() => () => request.current?.abort(), [])

  async function analyze() {
    if (request.current || config.error) return
    const controller = new AbortController()
    request.current = controller
    setLoading(true)
    setError('')
    setResult(null)
    const timeout = window.setTimeout(() => controller.abort(), 30_000)
    try {
      const response = await fetch(`${config.api}/analizar`, {
        method: 'POST',
        signal: controller.signal,
      })
      const data: unknown = await response.json().catch(() => {
        throw new Error(
          `El backend devolvió una respuesta no válida (HTTP ${response.status}).`,
        )
      })
      if (!response.ok) {
        const detail =
          data &&
          typeof data === 'object' &&
          'error' in data &&
          typeof data.error === 'string'
            ? data.error
            : 'No se pudo ejecutar el análisis.'
        throw new Error(`HTTP ${response.status}: ${detail}`)
      }
      if (!isAnalysisResult(data))
        throw new Error(
          'La respuesta del backend no contiene los campos esperados.',
        )
      setResult(data)
      if (data.codigo !== 0)
        setError(
          `El análisis terminó con código ${data.codigo}. Revisa el error del programa.`,
        )
    } catch (error) {
      setError(
        controller.signal.aborted
          ? 'El backend no respondió en 30 segundos. Comprueba su estado antes de reintentar.'
          : error instanceof TypeError
            ? 'No se pudo contactar al backend. Comprueba que esté ejecutándose.'
            : error instanceof Error
              ? error.message
              : 'No se pudo ejecutar el análisis.',
      )
    } finally {
      window.clearTimeout(timeout)
      request.current = null
      setLoading(false)
    }
  }

  return (
    <section className="panel analysis-panel" aria-labelledby="analysis-title">
      <div className="panel-heading">
        <span className="eyebrow">Procesamiento</span>
        <span className="tag">Backend</span>
      </div>
      <h2 id="analysis-title">Una mirada a los datos</h2>
      <p className="panel-description">
        Analiza hasta 20 registros de MongoDB seleccionados por temperatura.
      </p>
      <button
        type="button"
        className="button button-secondary"
        onClick={analyze}
        disabled={loading || !!config.error}
      >
        <span>{loading ? 'Analizando…' : 'Ejecutar análisis'}</span>
        <span aria-hidden="true">{loading ? '◌' : '→'}</span>
      </button>
      <p className="analysis-note">
        Usa los datos guardados, independientemente del intervalo de las
        gráficas.
      </p>
      <div
        role="status"
        className={error ? 'analysis-error' : 'analysis-status'}
      >
        {error ||
          (loading
            ? 'Esperando la respuesta del backend…'
            : result
              ? 'Análisis completado.'
              : '')}
      </div>
      {result && (
        <div className="analysis-result">
          <div>
            <span>
              Documentos <b>{result.documentos}</b>
            </span>
            <span>
              Código <b>{result.codigo}</b>
            </span>
          </div>
          <h3>Salida</h3>
          <pre>{result.salida || 'Sin salida.'}</pre>
          {result.error && (
            <>
              <h3>Error del programa</h3>
              <pre className="feedback-error">{result.error}</pre>
            </>
          )}
        </div>
      )}
    </section>
  )
}

function App() {
  const {
    connection,
    error,
    readings,
    latest,
    count,
    startedAt,
    now,
    sendMessage,
  } = useTelemetry()
  const [minutes, setMinutes] = useState(5)
  const start = now - minutes * 60_000
  const points = chartPoints(readings, start, now)
  const stale = !latest || now - latest.timestamp > STALE_MS
  const connected = connection === 'connected' && !config.error
  const age = latest
    ? Math.max(0, Math.floor((now - latest.timestamp) / 1000))
    : null
  const ageLabel =
    age === null
      ? 'Esperando datos'
      : age < 60
        ? `Hace ${age} s`
        : age < 3600
          ? `Hace ${Math.floor(age / 60)} min`
          : `Hace ${Math.floor(age / 3600)} h`
  const sensorStatus = !latest
    ? now - startedAt > STALE_MS
      ? 'Sin lecturas recientes'
      : 'Esperando al sensor'
    : stale
      ? 'Sin lecturas recientes'
      : 'Recibiendo lecturas'

  return (
    <>
      <a className="skip-link" href="#main">
        Saltar al contenido
      </a>
      <header className="site-header">
        <div className="header-inner">
          <a className="brand" href="#main" aria-label="Atmósfera, inicio">
            <span className="brand-mark">
              <WaveMark />
            </span>
            <span>
              atmósfera<span className="brand-caption">MONITOR AMBIENTAL</span>
            </span>
          </a>
          <div className="header-status">
            <span
              className={`connection-badge ${connected ? 'online' : 'offline'}`}
              role="status"
            >
              <span className="status-dot" />
              {config.error ? 'Sin configurar' : connectionLabels[connection]}
            </span>
            <span className="header-protocol">MQTT / LIVE</span>
          </div>
        </div>
      </header>
      <main id="main" className="page-shell">
        <div className="page-intro">
          <div>
            <p className="eyebrow intro-eyebrow">
              Laboratorio IoT <span>/</span> Arquitectura de computadores
            </p>
            <h1>
              El pulso del ambiente<span>.</span>
            </h1>
            <p>Observa cada cambio. Conecta con tu dispositivo.</p>
          </div>
          <div className="simulation-note">
            <span className="simulation-icon" aria-hidden="true">
              ∿
            </span>
            <div>
              <strong>Sensores simulados</strong>
              <span>Datos del programa IoT actual</span>
            </div>
          </div>
        </div>
        {config.error && (
          <div className="notice" role="alert">
            <strong>Revisa la configuración</strong>
            <p>{config.error} Actualiza .env y reinicia Vite.</p>
          </div>
        )}
        {!config.error && error && (
          <div className="notice" role="status">
            {error}
          </div>
        )}
        <div className="dashboard-grid">
          <section className="monitor panel" aria-labelledby="monitor-title">
            <div className="monitor-heading">
              <div>
                <p className="eyebrow">Señal ambiental</p>
                <h2 id="monitor-title">Lecturas en vivo</h2>
              </div>
              <div
                className="interval-control"
                role="group"
                aria-label="Intervalo de las gráficas"
              >
                {[1, 5, 15].map((value) => (
                  <button
                    key={value}
                    type="button"
                    aria-pressed={minutes === value}
                    onClick={() => setMinutes(value)}
                  >
                    {value} min
                  </button>
                ))}
              </div>
            </div>
            <div className="signal-strip">
              <span
                className={`sensor-state ${stale || !connected ? 'stale' : ''}`}
                role="status"
              >
                <span className="status-dot" />
                {sensorStatus}
              </span>
              <span
                className="last-reading"
                title={
                  latest
                    ? `Recibida a las ${timeFormat.format(latest.timestamp)}`
                    : undefined
                }
              >
                Última lectura <b>{ageLabel}</b>
              </span>
            </div>
            <MeasurementChart
              metric="temperature"
              latest={latest}
              points={points}
              start={start}
              now={now}
              stale={stale || !connected}
            />
            <MeasurementChart
              metric="humidity"
              latest={latest}
              points={points}
              start={start}
              now={now}
              stale={stale || !connected}
            />
            <div className="session-footer">
              <span>
                <span className="status-dot" />
                Solo esta sesión
              </span>
              <span>
                Hora de recepción ·{' '}
                {Intl.DateTimeFormat().resolvedOptions().timeZone}
              </span>
            </div>
          </section>
          <aside
            className="control-column"
            aria-label="Controles del dispositivo y análisis"
          >
            <MessagePanel connected={connected} sendMessage={sendMessage} />
            <AnalysisPanel />
          </aside>
        </div>
        <section
          className="session-summary"
          aria-label="Información de la sesión"
        >
          <div>
            <span className="eyebrow">Sesión iniciada</span>
            <strong>{timeFormat.format(startedAt)}</strong>
          </div>
          <div>
            <span className="eyebrow">Lecturas recibidas</span>
            <strong>
              {count.toLocaleString('es-GT')}
              <span>muestras</span>
            </strong>
          </div>
          <div className="topic-summary">
            <span className="eyebrow">Tópico conectado</span>
            <strong>{config.topic || 'Sin configurar'}</strong>
          </div>
          <p>
            Hasta 60 min / 2.000 muestras.
            <br />
            El historial se reinicia al recargar.
          </p>
        </section>
        <footer className="page-footer">
          <span>
            ATMÓSFERA <span className="footer-slash">/</span> Una ventana a tu
            entorno.
          </span>
          <span>
            React + MQTT <span className="footer-dot">·</span> Laboratorio 2026
          </span>
        </footer>
      </main>
    </>
  )
}

export default App
