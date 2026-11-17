import { describe, test, expect } from 'claude-code/testing'
import type { RenderElement } from 'claude-code'

import { colorOf, describePr, fableLimit, pie, resetTime, summarizeChecks } from '../hooks/register'

const BAND = {
  component: 'AbovePrompt',
  props: {
    hasSurvey: false,
    isWorking: false,
    maxRows: 10,
    bodyColumns: 120,
    scroll: { offset: 0, bodyRows: 40 },
    view: {},
  },
} as const

describe('formatting', () => {
  test('pie steps by quarter', async () => {
    expect([0, 18, 50, 80, 95].map(pie).join('')).toBe('○◔◑◕●')
  })

  test('color blends from green through yellow to red', async () => {
    expect([0, 75, 100].map(colorOf)).toEqual(['#3fb950', '#d29922', '#f85149'])
    expect(colorOf(37.5)).toBe('#89a939')
    expect(colorOf(87.5)).toBe('#e57536')
    expect([-5, 140].map(colorOf)).toEqual(['#3fb950', '#f85149'])
  })

  test('the Fable window is read from the usage limits', async () => {
    const limits = [
      { kind: 'weekly_scoped', percent: 80, resets_at: null, scope: { model: { display_name: 'Sonnet' } } },
      { kind: 'session', percent: 99, resets_at: null, scope: { model: { display_name: 'Fable' } } },
      { kind: 'weekly_scoped', percent: 12.5, resets_at: '2026-11-20T00:00:00Z', scope: { model: { display_name: 'Fable 5' } } },
    ]
    expect(fableLimit(JSON.stringify({ limits }))).toEqual({
      kind: 'fable',
      percentUsed: 12.5,
      resetsAt: '2026-11-20T00:00:00Z',
    })
    expect(fableLimit(JSON.stringify({ limits: limits.slice(0, 2) }))).toBeUndefined()
    expect(fableLimit(JSON.stringify({ five_hour: {} }))).toBeUndefined()
    expect(fableLimit('<html>')).toBeUndefined()
  })

  test('checks are counted from both CheckRun and StatusContext', async () => {
    const checks = summarizeChecks([
      { status: 'COMPLETED', conclusion: 'SUCCESS' },
      { status: 'IN_PROGRESS', conclusion: '' },
      { state: 'FAILURE' },
      { state: 'PENDING' },
      { status: 'COMPLETED', conclusion: 'SKIPPED' },
    ])
    expect(checks).toEqual({ pass: 2, fail: 1, pending: 2 })
  })

  test('PR says failed before pending', async () => {
    const pr = (pass: number, fail: number, pending: number) =>
      describePr({ number: 7, url: 'https://github.com/o/r/pull/7', checks: { pass, fail, pending } })
    expect(pr(1, 1, 1)).toEqual({ text: 'PR #7 ✗ 1 failed', color: 'red' })
    expect(pr(2, 0, 1)).toEqual({ text: 'PR #7 ⏳ 2/3', color: 'yellow' })
    expect(pr(3, 0, 0)).toEqual({ text: 'PR #7 ✓', color: 'green' })
  })

  test('5h shows the reset time, 7d the date and time', async () => {
    expect(resetTime({ kind: 'five_hour', percentUsed: 1, resetsAt: '2026-10-16T11:30:00Z' })).toMatch(/^\d\d:30$/)
    expect(resetTime({ kind: 'seven_day', percentUsed: 1, resetsAt: '2026-10-16T11:30:00Z' })).toMatch(/^10\/1[67] \d\d:30$/)
    expect(resetTime({ kind: 'seven_day', percentUsed: 1 })).toBeUndefined()
  })
})

test('the band follows session.measure and the PR checks', async ($, on) => {
  const toasts: string[] = []
  let rollup = [{ status: 'IN_PROGRESS', conclusion: '' }]
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return h(Box, { key: 'engine' }) as RenderElement
  })
  on('ui.toast', (_, e) => {
    toasts.push(e.text)
    return { value: undefined } as never
  })
  on('process.run', (_, e) => ({
    value: {
      exitCode: e.argv[0] === 'gh' ? 0 : 1,
      stdout: JSON.stringify({ number: 42, url: 'https://github.com/o/r/pull/42', statusCheckRollup: rollup }),
      stderr: '',
      isStdoutTruncated: false,
      isStderrTruncated: false,
    },
  }))
  on('session.measure', (_, e) => ({ changed: e.changed }))
  on('turn.complete', (_, e) => ({ text: e.answer }))

  const ui = await $.ui.mount({ plugin: 'session-hud', surface: 'terminal', ...BAND })
  const bandText = async () => (await ui.find({ key: 'session-hud' }))?.text ?? ''
  // turn.complete refreshes the PR in the background: read the band until it shows up
  const bandWhen = async (part: string) => {
    let text = ''
    for (let i = 0; i < 200 && !text.includes(part); i++) text = await bandText()
    return text
  }
  expect(await bandText()).toBe('')

  await $.session.measure({
    context: { window: 200000, percent: 75 },
    rateLimits: [{ kind: 'seven_day', percentUsed: 95 }],
    cost: { usd: 1 },
    changed: ['rateLimits'],
  })
  expect(await bandText()).toMatch(/7d.*●.*95%.*ctx.*◕.*75%$/)

  const turn = { reason: 'answer', answer: '', durationMs: 1, isAborted: false, turnId: 't' } as const
  await $.turn.complete(turn)
  expect(await bandWhen('PR #42')).toContain('PR #42 ⏳ 0/1')

  rollup = [{ status: 'COMPLETED', conclusion: 'SUCCESS' }]
  await $.turn.complete(turn)
  expect(await bandWhen('PR #42 ✓')).toContain('PR #42 ✓')
  expect(toasts).toEqual(['PR #42: CI passed'])
  await ui.unmount()

  // desktop draws each pie as SVG instead of a glyph whose size varies by font
  const desktop = await $.ui.mount({ plugin: 'session-hud', surface: 'desktop', ...BAND })
  const svgs = await desktop.findAll({ type: 'Svg' })
  expect(svgs.length).toBe(2)
  expect((await desktop.find({ key: 'session-hud' }))?.text ?? '').not.toMatch(/[○◔◑◕●]/)
  await desktop.unmount()
})

test('the band shows the Fable window the usage endpoint reports', async ($, on) => {
  const requests: { url: string; auth?: string }[] = []
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return h(Box, { key: 'engine' }) as RenderElement
  })
  on('process.run', () => ({
    value: { exitCode: 1, stdout: '', stderr: '', isStdoutTruncated: false, isStderrTruncated: false },
  }))
  let now = 1_000
  on('clock.now', () => ({ value: now }) as never)
  on('session.authorize', () => ({ value: { handle: 'handle-1', kind: 'bearer' } }) as never)
  on('http.fetch', (_, e) => {
    requests.push({ url: e.url, auth: e.init?.auth })
    const limits = [{ kind: 'weekly_scoped', percent: 42, resets_at: null, scope: { model: { display_name: 'Fable' } } }]
    return { value: { status: 200, ok: true, headers: {}, text: JSON.stringify({ limits }) } } as never
  })
  on('turn.complete', (_, e) => ({ text: e.answer }))

  const ui = await $.ui.mount({ plugin: 'session-hud', surface: 'terminal', ...BAND })
  const turn = { reason: 'answer', answer: '', durationMs: 1, isAborted: false, turnId: 't' } as const
  await $.turn.complete(turn)
  let text = ''
  for (let i = 0; i < 200 && !text.includes('fable'); i++) text = (await ui.find({ key: 'session-hud' }))?.text ?? ''
  expect(text).toMatch(/fable.*◑.*42%/)
  expect(requests[0]).toEqual({ url: 'https://api.anthropic.com/api/oauth/usage', auth: 'handle-1' })

  // asked again within the interval: the endpoint is left alone
  await $.turn.complete(turn)
  expect(requests.length).toBe(1)
  now += 5 * 60_000
  await $.turn.complete(turn)
  for (let i = 0; i < 200 && requests.length < 2; i++) await ui.find({ key: 'session-hud' })
  expect(requests.length).toBe(2)
  await ui.unmount()
})
