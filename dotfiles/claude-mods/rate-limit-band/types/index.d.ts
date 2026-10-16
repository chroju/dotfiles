export type RateLimit = { kind: string; percentUsed: number; resetsAt?: string }
export type RateLimits = RateLimit[]

declare module 'claude-code' {
  interface PluginState {
    'rate-limit-band': { limits: RateLimits }
  }
}
