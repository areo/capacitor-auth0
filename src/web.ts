import { WebPlugin } from '@capacitor/core'
import { Auth0Plugin } from './definitions'

export class Auth0PluginWeb extends WebPlugin implements Auth0Plugin {
  constructor() {
    super({
      name: 'Auth0Plugin',
      platforms: ['web']
    })
  }

  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options)
    return options
  }
}

const Auth0Plugin = new Auth0PluginWeb()

export { Auth0Plugin }
