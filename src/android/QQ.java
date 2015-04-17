package com.qiudao.cordova.qq;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.tencent.tauth.IUiListener;
import com.tencent.tauth.UiError;

import com.tencent.tauth.Tencent;

public class QQ extends CordovaPlugin {
    private Tencent mTencent = null;

    private static final String APPID_PROPERTY_KEY = "qqappid";
    private static final String SCOPE = "get_user_info,get_info";

    public static final int LOGIN_NO_ACCESS_TOKEN = 1;
    public static final int LOGIN_USER_CANCELLED = 2;
    public static final int LOGIN_ERROR = 3;
    public static final int LOGIN_NO_NETWORK = 4;

    private static final String TAG = "Cordova-QQ-SSO";

	@Override
    public boolean execute(final String action, final JSONArray args, final CallbackContext context) {
        boolean result = false;
        try {
            if (action.equals("login")) {
                this.login(context);
            } else if (action.equals("logout")) {
                this.logout(context);
            }
        }
        catch (Exception e) {
            Log.e(TAG, "Cordova execute error", e);
            context.error(new ErrorMessage(LOGIN_ERROR, e.getMessage()));
            result = false;
        }

        return result;
    }

    /**
     * Login with QQ authentication.
     * @param context
     */
	protected void login(final CallbackContext context) {
        Log.d(TAG, "login");
		final Activity activity = this.cordova.getActivity();
        this.cordova.setActivityResultCallback(this);

		final Tencent tencent = getTencent();
		final IUiListener listener = new AuthListener(context);

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                tencent.login(activity, SCOPE, listener);
            }
        });
	}

    /**
     * Logout of QQ authentication.
     * @param context
     */
    protected void logout(final CallbackContext context) {
        Log.d(TAG, "logout");
        Context appContext = this.cordova.getActivity().getApplicationContext();
        Tencent tencent = getTencent();

        tencent.logout(appContext);

        context.success();
    }

    /**
     * Get Tencent authentication object.
     * @return
     */
    protected synchronized Tencent getTencent() {
        if (mTencent == null) {
            String appId = webView.getPreferences().getString(APPID_PROPERTY_KEY, "");
            Context appContext = this.cordova.getActivity().getApplicationContext();
            mTencent = Tencent.createInstance(appId, appContext);
        }

        return mTencent;
    }

    /**
     * Error message when any errors happen.
     */
    protected class ErrorMessage extends JSONObject {
        public ErrorMessage(int code, String message) {
            try {
                this.put("code", code);
                this.put("message", message);
            } catch (JSONException e) {
                Log.e(TAG, "Json error", e);
                throw new RuntimeException(e);
            }
        }
    }

    /**
     * Listener for login authentication.
     */
    protected class AuthListener implements IUiListener {
        private CallbackContext context;

        public AuthListener(CallbackContext context) {
            this.context = context;
        }

		@Override
		public void onComplete(Object response) {
            final Tencent tencent = getTencent();

            try {
                String uid = tencent.getOpenId();
                String token = tencent.getAccessToken();
                Log.d(TAG, uid + ":" + token);

                JSONObject res = new JSONObject();

                res.put("uid", uid);
				res.put("token", token);
                context.success(res);
			}
            catch (JSONException e) {
                Log.e(TAG, "Get access token error.", e);
				context.error(new ErrorMessage(LOGIN_NO_ACCESS_TOKEN, e.getMessage()));
			}
		}

		@Override
		public void onError(UiError e) {
            context.error(new ErrorMessage(LOGIN_ERROR, e.errorMessage));
		}

		@Override
		public void onCancel() {
            context.error(new ErrorMessage(LOGIN_USER_CANCELLED, null));
		}
	}
}
