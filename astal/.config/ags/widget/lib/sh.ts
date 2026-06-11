import { execAsync } from "ags/process"

// Fire-and-forget command execution — swallows failures so callers in click
// handlers / signal callbacks don't need a try/catch boilerplate. Use this
// when there's no meaningful action to take on failure (the user already
// sees the missing effect; logging would just be noise).
export function run(cmd: string[]): void {
  execAsync(cmd).catch(() => {})
}
