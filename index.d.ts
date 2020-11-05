declare module '@capacitor/core' {
  interface PluginRegistry {
    Auth0?: Auth0
  }
}

export interface Auth0 {
  startWebAuth(options?: AuthOptions): Promise<Credentials>
  getCredentials(): Promise<Credentials>
  renew(): Promise<Credentials>
}

export interface Credentials {
  accessToken: string
  refreshToken?: string
}

export interface AuthOptions {
  scope?: string
  audience?: string
}
