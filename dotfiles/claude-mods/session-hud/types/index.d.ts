export type Checks = { pass: number; fail: number; pending: number }
export type Pr = { number: number; url: string; checks: Checks }
export type Limit = { kind: string; percentUsed: number; resetsAt?: string }
export type HudView = {
  limits: Limit[]
  contextPercent?: number
  pr?: Pr
  isDatadogOut: boolean
}

declare module 'claude-code' {
  interface PluginState {
    'session-hud': { view: HudView }
  }
}
