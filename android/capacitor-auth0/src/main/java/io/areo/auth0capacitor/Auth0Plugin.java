package io.areo.auth0capacitor;

import android.app.Dialog;

import com.auth0.android.Auth0;
import com.auth0.android.authentication.AuthenticationAPIClient;
import com.auth0.android.authentication.AuthenticationException;
import com.auth0.android.authentication.storage.CredentialsManagerException;
import com.auth0.android.authentication.storage.SecureCredentialsManager;
import com.auth0.android.authentication.storage.SharedPreferencesStorage;
import com.auth0.android.authentication.storage.Storage;
import com.auth0.android.callback.BaseCallback;
import com.auth0.android.provider.AuthCallback;
import com.auth0.android.provider.WebAuthProvider;
import com.auth0.android.result.Credentials;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

@NativePlugin(name = "Auth0")
public class Auth0Plugin extends Plugin {
    @PluginMethod()
    public void startWebAuth(final PluginCall call) {
        final Auth0 account = new Auth0(this.getContext());
        account.setOIDCConformant(true);
        WebAuthProvider.Builder builder = WebAuthProvider.init(account);

        if (call.hasOption("audience")) {
            String audience = call.getString("audience", "");
            builder.withAudience(audience);
        }

        if (call.hasOption("scope")) {
            String scope = call.getString("scope", "");
            builder.withScope(scope);
        }

        builder.start(this.getActivity(), new AuthCallback() {
            @Override
            public void onFailure(Dialog dialog) {
                call.error("authentication failed");
            }

            @Override
            public void onFailure(AuthenticationException exception) {
                call.error("authentication failed", exception);
            }

            @Override
            public void onSuccess(Credentials credentials) {
                SecureCredentialsManager manager = credentialsManager();
                manager.saveCredentials(credentials);
                call.success(credentialsResult(credentials));
            }
        });
    }

    @PluginMethod()
    public void getCredentials(final PluginCall call) {
        SecureCredentialsManager manager = credentialsManager();
        manager.getCredentials(new BaseCallback<Credentials, CredentialsManagerException>() {
            public void onSuccess(Credentials credentials) {
                call.success(credentialsResult(credentials));
            }

            public void onFailure(CredentialsManagerException error) {
                call.error("Unable to retrieve credentials", error);
            }
        });
    }

    @PluginMethod()
    public void renew(final PluginCall call) {
        // getCredentials automatically renews access token if expired
        // TODO: allow to force renew when not expired
        getCredentials(call);
    }

    private SecureCredentialsManager credentialsManager() {
        Auth0 account = new Auth0(this.getContext());
        account.setOIDCConformant(true);
        AuthenticationAPIClient authentication = new AuthenticationAPIClient(account);
        Storage storage = new SharedPreferencesStorage(this.getContext());
        SecureCredentialsManager manager = new SecureCredentialsManager(this.getContext(), authentication, storage);
        return manager;
    }

    private JSObject credentialsResult(Credentials credentials) {
        JSObject ret = new JSObject();
        ret.put("accessToken", credentials.getAccessToken());
        ret.put("refreshToken", credentials.getRefreshToken());
        return ret;
    }
}
