import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { RateLimit, RateLimits } from '../types'

const limits = atom({ plugin: 'rate-limit-band', key: 'limits' } as const, [] as RateLimits)

const LABELS: Record<string, string> = {
  five_hour: '5h',
  seven_day: '7d',
  spend_limit: 'spend',
}

const BAR_WIDTH = 12

const pad = (n: number) => String(n).padStart(2, '0')

export const bar = (percent: number): { filled: string; empty: string } => {
  const cells = Math.round((Math.min(Math.max(percent, 0), 100) / 100) * BAR_WIDTH)
  return { filled: '█'.repeat(cells), empty: '░'.repeat(BAR_WIDTH - cells) }
}

export const formatRemaining = (resetsAt: string | undefined, now: number): string => {
  if (resetsAt === undefined) return ''
  const at = new Date(resetsAt).getTime()
  if (Number.isNaN(at)) return ''
  const minutes = Math.max(0, Math.round((at - now) / 60000))
  const d = Math.floor(minutes / 1440)
  const h = Math.floor((minutes % 1440) / 60)
  const m = minutes % 60
  return d > 0 ? `${d}d${h}h` : h > 0 ? `${h}h${pad(m)}m` : `${m}m`
}

export const formatReset = (kind: string, resetsAt: string | undefined): string => {
  if (resetsAt === undefined) return ''
  const d = new Date(resetsAt)
  if (Number.isNaN(d.getTime())) return ''
  const time = `${pad(d.getHours())}:${pad(d.getMinutes())}`
  return kind === 'five_hour' ? time : `${d.getMonth() + 1}/${d.getDate()} ${time}`
}

const colorOf = (percent: number) => (percent >= 90 ? 'red' : percent >= 70 ? 'yellow' : 'green')

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const result = await next(e)
    const { rateLimits } = await $.session.usage()
    if (rateLimits.length > 0) await update($, limits, () => rateLimits)
    return result
  })

  on('session.measure', async ($, e, next) => {
    if (e.changed.includes('rateLimits')) await update($, limits, () => e.rateLimits)
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const current = await read($, limits)
    if (e.props.hasSurvey || current.length === 0) return next(e)

    const now = await $.clock.now()
    const { Box, Text } = $.ui.resolve(e)
    const hasBorder = e.props.maxRows >= 3

    const windowOf = (l: RateLimit) => {
      const color = colorOf(l.percentUsed)
      const { filled, empty } = bar(l.percentUsed)
      const remaining = formatRemaining(l.resetsAt, now)
      const reset = formatReset(l.kind, l.resetsAt)
      return (
        <Box key={`limit-${l.kind}`} flexDirection="row" columnGap={1}>
          <Text bold>{LABELS[l.kind] ?? l.kind}</Text>
          <Text color={color}>
            {filled}
            <Text dimColor>{empty}</Text>
          </Text>
          <Text bold color={color} tabular>
            {`${l.percentUsed}%`.padStart(6)}
          </Text>
          {remaining ? <Text dimColor>{`↻ ${remaining} (${reset})`}</Text> : null}
        </Box>
      )
    }

    return (
      <Box
        key="rate-limits"
        flexDirection="row"
        flexWrap="wrap"
        columnGap={3}
        paddingX={1}
        borderStyle={hasBorder ? 'round' : undefined}
        borderDimColor
      >
        {current.map(windowOf)}
      </Box>
    )
  })
}
