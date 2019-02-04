import Foundation
import Capacitor
import Auth0

@objc(Auth0Plugin)
public class Auth0Plugin: CAPPlugin {
    @objc func startWebAuth(_ call: CAPPluginCall) {
        let auth0 = Auth0.webAuth()

        let audience = call.getString("audience") ?? ""
        if !audience.isEmpty {
            auth0.audience(audience)
        }

        let scope = call.getString("scope") ?? ""
        if !scope.isEmpty {
            auth0.scope(scope)
        }

        auth0.start { result in
            switch result {
            case .success(let credentials):
                let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
                credentialsManager.store(credentials: credentials)
                call.success([
                    "accessToken": credentials.accessToken,
                    "refreshToken": credentials.refreshToken
                ])
            case .failure(let error):
                call.error("authentication failed")
            }
        }
    }

    @objc func getCredentials(_ call: CAPPluginCall) {
        let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
        credentialsManager.credentials { error, credentials in
            guard error == nil, let credentials = credentials else {
                call.error("Failed to fetch credentials from store")
                return
            }
            call.success([
                "accessToken": credentials.accessToken,
                "refreshToken": credentials.refreshToken
            ])
        }
    }

    @objc func renew(_ call: CAPPluginCall) {
        // TODO: force renew when access token is not expired
        getCredentials(call)
    }
}
