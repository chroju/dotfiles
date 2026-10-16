import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, SessionRateLimit } from 'claude-code'

import type { Checks, HudView, Limit, Pr } from '../types'

type CheckItem = { status?: string; conclusion?: string; state?: string }

const PR_POLL_MS = 60_000
const DATADOG_CHECK_MS = 5 * 60_000

const view = atom({ plugin: 'session-hud', key: 'view' } as const, { limits: [], isDatadogOut: false } as HudView)

const pad = (n: number) => String(n).padStart(2, '0')

export const pie = (percent: number): string =>
  percent < 12.5 ? '○' : percent < 37.5 ? '◔' : percent < 62.5 ? '◑' : percent < 87.5 ? '◕' : '●'

export const colorOf = (percent: number) => (percent >= 90 ? 'red' : percent >= 70 ? 'yellow' : 'green')

export const summarizeChecks = (items: readonly CheckItem[]): Checks => {
  const checks = { pass: 0, fail: 0, pending: 0 }
  for (const item of items) {
    const verdict = item.conclusion || item.state || ''
    if (item.status !== undefined && item.status !== 'COMPLETED') checks.pending += 1
    else if (['SUCCESS', 'NEUTRAL', 'SKIPPED'].includes(verdict)) checks.pass += 1
    else if (['PENDING', 'EXPECTED', ''].includes(verdict)) checks.pending += 1
    else checks.fail += 1
  }
  return checks
}

export const describePr = ({ number, checks }: Pr): { text: string; color?: string } => {
  const total = checks.pass + checks.fail + checks.pending
  if (total === 0) return { text: `PR #${number}` }
  if (checks.fail > 0) return { text: `PR #${number} ✗ ${checks.fail} failed`, color: 'red' }
  if (checks.pending > 0) return { text: `PR #${number} ⏳ ${checks.pass}/${total}`, color: 'yellow' }
  return { text: `PR #${number} ✓`, color: 'green' }
}

export const resetTime = (l: Limit): string | undefined => {
  if (l.resetsAt === undefined) return undefined
  const d = new Date(l.resetsAt)
  if (Number.isNaN(d.getTime())) return undefined
  const time = `${pad(d.getHours())}:${pad(d.getMinutes())}`
  return l.kind === 'five_hour' ? time : `${d.getMonth() + 1}/${d.getDate()} ${time}`
}

const SVG_COLORS: Record<string, string> = { green: '#3fb950', yellow: '#d29922', red: '#f85149' }

// A pie drawn as SVG, for surfaces whose fonts draw ○◔◑◕● at different sizes
export const pieSvg = (percent: number): string => {
  const p = Math.min(Math.max(percent, 0), 100) / 100
  const fill = SVG_COLORS[colorOf(percent)]
  const r = 6
  const c = 7
  const track = `<circle cx="${c}" cy="${c}" r="${r}" fill="none" stroke="${fill}" stroke-width="1.5"/>`
  let slice = ''
  if (p >= 1) {
    slice = `<circle cx="${c}" cy="${c}" r="${r}" fill="${fill}"/>`
  } else if (p > 0) {
    const angle = 2 * Math.PI * p
    const x = (c + r * Math.sin(angle)).toFixed(2)
    const y = (c - r * Math.cos(angle)).toFixed(2)
    slice = `<path d="M${c} ${c} L${c} ${c - r} A${r} ${r} 0 ${p > 0.5 ? 1 : 0} 1 ${x} ${y} Z" fill="${fill}"/>`
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14">${track}${slice}</svg>`
}

const label = (kind: string) => (kind === 'five_hour' ? '5h' : kind === 'seven_day' ? '7d' : kind)

// Work that is not drawn: kept in the module, started over on a reload
type Runtime = { poll?: { cancel: () => void }; datadogCheckedAt?: number }

async function setUsage($: EngineInterface, limits: readonly SessionRateLimit[], percent?: number) {
  await update($, view, v => ({ ...v, limits: [...limits], contextPercent: percent }))
}

async function refreshPr($: EngineInterface, rt: Runtime) {
  const before = (await read($, view)).pr
  let pr: Pr | undefined
  try {
    const r = await $.process.run(['gh', 'pr', 'view', '--json', 'number,url,statusCheckRollup'], { timeoutMs: 15_000 })
    if (r.exitCode === 0) {
      const json = JSON.parse(r.stdout) as { number: number; url: string; statusCheckRollup?: CheckItem[] }
      pr = { number: json.number, url: json.url, checks: summarizeChecks(json.statusCheckRollup ?? []) }
    }
  } catch {
    pr = undefined
  }
  await update($, view, v => ({ ...v, pr }))

  const wasPending = before !== undefined && before.number === pr?.number && before.checks.pending > 0
  if (wasPending && pr !== undefined && pr.checks.pending === 0) {
    $.ui.toast(pr.checks.fail > 0 ? `PR #${pr.number}: CI failed (${pr.checks.fail})` : `PR #${pr.number}: CI passed`)
  }

  const shouldPoll = pr !== undefined && pr.checks.pending > 0
  if (shouldPoll && rt.poll === undefined) {
    rt.poll = $.clock.every(PR_POLL_MS, () => refreshPr($, rt))
  } else if (!shouldPoll && rt.poll !== undefined) {
    rt.poll.cancel()
    rt.poll = undefined
  }
}

async function checkDatadog($: EngineInterface, rt: Runtime) {
  const now = await $.clock.now()
  const isOut = (await read($, view)).isDatadogOut
  if (rt.datadogCheckedAt !== undefined && now - rt.datadogCheckedAt < DATADOG_CHECK_MS && !isOut) return
  rt.datadogCheckedAt = now
  try {
    const r = await $.process.run(['pup', 'auth', 'status', '--site', 'datadoghq.com'], { timeoutMs: 15_000 })
    const json = JSON.parse(r.stdout.slice(r.stdout.indexOf('{'))) as { authenticated?: boolean }
    const isNowOut = json.authenticated !== true
    if (isNowOut && !isOut) $.ui.toast('Datadog: not authenticated (pup auth login)')
    await update($, view, v => ({ ...v, isDatadogOut: isNowOut }))
  } catch {
    // pup missing or unreadable output: say nothing rather than guess
  }
}

export const register: Register = on => {
  const rt: Runtime = {}

  on('session.start', async ($, e, next) => {
    const result = await next(e)
    const usage = await $.session.usage()
    await setUsage($, usage.rateLimits, usage.context.percent)
    void refreshPr($, rt)
    return result
  })

  on('session.measure', async ($, e, next) => {
    await setUsage($, e.rateLimits, e.context.percent)
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    void refreshPr($, rt)
    return result
  })

  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    if (/^\s*pup\s/.test(e.command) && !/^\s*pup\s+auth\b/.test(e.command)) await checkDatadog($, rt)
    return next(e)
  }).catch(($, e, next) => next(e))

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const v = await read($, view)
    const hasAny = v.limits.length > 0 || v.contextPercent !== undefined || v.pr || v.isDatadogOut
    if (e.props.hasSurvey || !hasAny) return next(e)

    const elements = $.ui.resolve(e)
    const { Box, Text, Link } = elements
    const Svg = e.surface !== 'terminal' && 'Svg' in elements ? elements.Svg : undefined
    const meter = (key: string, name: string, percent: number, extra?: string) => (
      <Box key={key} flexDirection="row" columnGap={1} alignItems="center">
        <Text bold>{name}</Text>
        {Svg ? (
          <Svg source={pieSvg(percent)} alt={`${Math.round(percent)}%`} width={14} height={14} />
        ) : (
          <Text color={colorOf(percent)}>{pie(percent)}</Text>
        )}
        <Text color={colorOf(percent)}>{`${Math.round(percent)}%`}</Text>
        {extra ? <Text dimColor>{extra}</Text> : null}
      </Box>
    )
    const pr = v.pr ? describePr(v.pr) : undefined

    return (
      <Box key="session-hud" flexDirection="row" flexWrap="wrap" columnGap={3}>
        {v.limits.map(l => meter(`limit-${l.kind}`, label(l.kind), l.percentUsed, resetTime(l)))}
        {v.contextPercent !== undefined ? meter('context', 'ctx', v.contextPercent) : null}
        {v.pr && pr ? (
          <Box key="pr">
            <Link href={v.pr.url}>
              <Text color={pr.color}>{pr.text}</Text>
            </Link>
          </Box>
        ) : null}
        {v.isDatadogOut ? (
          <Box key="datadog">
            <Text color="red">dd ✗ pup auth login</Text>
          </Box>
        ) : null}
      </Box>
    )
  })
}
