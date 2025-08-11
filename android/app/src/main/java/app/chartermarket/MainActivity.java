package app.chartermarket;

import com.getcapacitor.BridgeActivity;
import android.os.Bundle;
import androidx.annotation.Nullable;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.content.Intent;
import android.net.Uri;
import java.util.Set;

public class MainActivity extends BridgeActivity {
  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    WebView webView = getBridge().getWebView();
    if (webView != null) {
      webView.setWebViewClient(new WebViewClient() {
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
          Uri uri = Uri.parse(url);
          String host = uri.getHost() != null ? uri.getHost() : "";
          if (host.endsWith("chartermarket.app")) {
            return false; // open inside webview
          }
          Intent intent = new Intent(Intent.ACTION_VIEW, uri);
          startActivity(intent);
          return true;
        }
      });

      webView.setWebChromeClient(new WebChromeClient());

      // Inject share bridge
      webView.evaluateJavascript(
        "window.CharterMobile = { share: async (title, url) => { return await window.Capacitor?.Plugins?.Share?.share({ title, url }); } }",
        null
      );
    }
  }
}
