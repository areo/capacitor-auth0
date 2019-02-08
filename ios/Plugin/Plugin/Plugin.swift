import Foundation
import Capacitor
import Auth0
import SimpleKeychain

@objc(Auth0Plugin)
public class Auth0Plugin: CAPPlugin {
    private let storage = A0SimpleKeychain()
    private let storeKey: String = "credentials"

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
        guard
            let credentials = self.retrieveCredentials(),
            let refreshToken = credentials.refreshToken
            else { call.error("Failed to fetch credentials from store"); return }

        let authentication = Auth0.authentication()
        authentication.renew(withRefreshToken: refreshToken, scope: nil).start {
            switch $0 {
            case .success(let credentials):
                let newCredentials = Credentials(accessToken: credentials.accessToken,
                                                 tokenType: credentials.tokenType,
                                                 idToken: credentials.idToken,
                                                 refreshToken: refreshToken,
                                                 expiresIn: credentials.expiresIn,
                                                 scope: credentials.scope)
                let credentialsManager = CredentialsManager(authentication: authentication)
                credentialsManager.store(credentials: newCredentials)
                call.success([
                    "accessToken": newCredentials.accessToken,
                    "refreshToken": newCredentials.refreshToken
                ])
            case .failure(let error):
                call.error("Failed to renew credentials")
            }
        }
    }

    private func retrieveCredentials() -> Credentials? {
        guard
            let data = self.storage.data(forKey: self.storeKey),
            let credentials = NSKeyedUnarchiver.unarchiveObject(with: data) as? Credentials,
            credentials.accessToken != nil,
            credentials.expiresIn != nil,
            credentials.refreshToken != nil
            else { return nil }
        return credentials
    }
}
