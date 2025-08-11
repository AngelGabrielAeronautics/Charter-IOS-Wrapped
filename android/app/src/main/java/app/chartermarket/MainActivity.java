package app.chartermarket;

import com.getcapacitor.BridgeActivity;
import android.os.Bundle;
import androidx.annotation.Nullable;
import android.webkit.WebView;
import android.content.Intent;
import android.net.Uri;
import java.util.Set;
import android.os.Build;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceError;
import android.view.ViewGroup;
import android.widget.Button;
import android.view.Gravity;
import android.widget.FrameLayout;

public class MainActivity extends BridgeActivity {
  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    WebView webView = getBridge().getWebView();
    if (webView != null) {
      webView.setWebViewClient(new WebViewClient() {
        @Override
        public void onPageFinished(WebView view, String url) {
          super.onPageFinished(view, url);
          view.evaluateJavascript(
            "(function(){\n" +
            "  if (!window.__charter_patched_open) {\n" +
            "    window.__charter_patched_open = true;\n" +
            "    const originalOpen = window.open;\n" +
            "    window.open = function(u,t,f){\n" +
            "      try {\n" +
            "        if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Browser) {\n" +
            "          window.Capacitor.Plugins.Browser.open({ url: u });\n" +
            "          return null;\n" +
            "        }\n" +
            "      } catch(e) {}\n" +
            "      return originalOpen.call(window, u, t, f);\n" +
            "    };\n" +
            "  }\n" +
            "  window.CharterMobile = { share: async (title, url) => { return await window.Capacitor?.Plugins?.Share?.share({ title, url }); } };\n" +
            "})();\n",
            null
          );
        }

        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
          super.onReceivedError(view, request, error);
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (request.isForMainFrame()) {
              view.loadUrl("file:///android_asset/public/offline.html");
            }
          }
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
          super.onReceivedError(view, errorCode, description, failingUrl);
          view.loadUrl("file:///android_asset/public/offline.html");
        }
      });

      // Add native share button overlay
      ViewGroup parent = (ViewGroup) webView.getParent();
      if (parent instanceof FrameLayout) {
        Button shareButton = new Button(this);
        shareButton.setText("Share");
        shareButton.setAllCaps(false);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
          FrameLayout.LayoutParams.WRAP_CONTENT,
          FrameLayout.LayoutParams.WRAP_CONTENT,
          Gravity.BOTTOM | Gravity.END
        );
        int margin = (int) (16 * getResources().getDisplayMetrics().density);
        lp.setMargins(margin, margin, margin, margin);
        shareButton.setLayoutParams(lp);
        shareButton.setOnClickListener(v -> {
          String currentUrl = webView.getUrl();
          if (currentUrl == null || currentUrl.isEmpty()) {
            currentUrl = "https://chartermarket.app";
          }
          Intent sendIntent = new Intent();
          sendIntent.setAction(Intent.ACTION_SEND);
          sendIntent.putExtra(Intent.EXTRA_TEXT, currentUrl);
          sendIntent.setType("text/plain");
          Intent shareIntent = Intent.createChooser(sendIntent, "Share link");
          startActivity(shareIntent);
        });
        ((FrameLayout) parent).addView(shareButton);
      }

      // Handle initial deep link intent
      handleDeepLinkIntent(getIntent());
    }
  }

  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    setIntent(intent);
    handleDeepLinkIntent(intent);
  }

  private void handleDeepLinkIntent(Intent intent) {
    Uri data = intent != null ? intent.getData() : null;
    WebView webView = getBridge().getWebView();
    if (data == null || webView == null) return;
    String scheme = data.getScheme() != null ? data.getScheme() : "";
    String host = data.getHost() != null ? data.getHost() : "";
    String urlToLoad = null;
    if ("https".equalsIgnoreCase(scheme) && host.endsWith("chartermarket.app")) {
      urlToLoad = data.toString();
    } else if ("charter".equalsIgnoreCase(scheme)) {
      String path = data.getPath() != null ? data.getPath() : "/";
      String query = data.getQuery();
      urlToLoad = "https://chartermarket.app" + path + (query != null ? ("?" + query) : "");
    }
    if (urlToLoad != null) {
      webView.loadUrl(urlToLoad);
    }
  }
}
