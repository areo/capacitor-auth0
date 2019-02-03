declare global {
  interface PluginRegistry {
    Auth0?: Auth0Plugin
  }
}

export interface Auth0Plugin {
  echo(options: { value: string }): Promise<{ value: string }>
}
