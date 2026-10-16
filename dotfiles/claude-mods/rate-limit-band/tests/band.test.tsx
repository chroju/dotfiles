import { test, expect, mock } from 'claude-code/testing'

const BAND = {
  component: 'AbovePrompt',
  props: {
    hasSurvey: false,
    isWorking: false,
    maxRows: 10,
    bodyColumns: 80,
    scroll: { offset: 0, bodyRows: 40 },
    view: {},
  },
} as const

const measure = {
  context: { window: 200000 },
  rateLimits: [
    { kind: 'five_hour', percentUsed: 25, resetsAt: '2026-10-16T05:30:00Z' },
    { kind: 'seven_day', percentUsed: 92, resetsAt: '2026-10-20T00:00:00Z' },
  ],
  changed: ['rateLimits'],
}

test('nothing is drawn before a reading', async ($, on) => {
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box key="engine" />
  })
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'rate-limit-band', surface, ...BAND })
    expect(await ui.find({ key: 'rate-limits' })).toBeUndefined()
    await ui.unmount()
  }
})

test('each window shows a bar, percent and time to reset', async ($, on) => {
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box key="engine" />
  })
  on('session.measure', ($, e) => ({ changed: e.changed }))
  mock.clock(on, { now: Date.parse('2026-10-16T03:00:00Z') })
  await $.session.measure(measure as never)
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'rate-limit-band', surface, ...BAND })
    const five = await ui.find({ key: 'limit-five_hour' })
    expect(five?.text).toMatch(/5h███░{9} +25%/)
    expect(five?.text).toMatch(/↻ 2h30m/)
    const seven = await ui.find({ key: 'limit-seven_day' })
    expect(seven?.text).toMatch(/92%/)
    expect(seven?.text).toMatch(/↻ 3d21h/)
    await ui.unmount()
  }
})
