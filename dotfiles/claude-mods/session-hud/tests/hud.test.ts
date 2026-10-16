import { describe, test, expect } from 'claude-code/testing'
import type { RenderElement } from 'claude-code'

import { colorOf, describePr, pie, resetTime, summarizeChecks } from '../hooks/register'

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
  test('pie steps by quarter and color by threshold', async () => {
    expect([0, 18, 50, 80, 95].map(pie).join('')).toBe('○◔◑◕●')
    expect([10, 70, 90].map(colorOf)).toEqual(['green', 'yellow', 'red'])
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
