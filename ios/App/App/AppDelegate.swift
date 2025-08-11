import UIKit
import Capacitor
import WebKit
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let bridge = ApplicationDelegateProxy.shared.bridge,
           let webView = bridge.webView as? WKWebView {
            webView.navigationDelegate = self
            webView.uiDelegate = self

            // Add native share button overlay
            if let rootVC = bridge.viewController {
                let shareButton = UIButton(type: .system)
                shareButton.translatesAutoresizingMaskIntoConstraints = false
                if #available(iOS 13.0, *) {
                    let image = UIImage(systemName: "square.and.arrow.up")
                    shareButton.setImage(image, for: .normal)
                    shareButton.tintColor = .white
                    shareButton.backgroundColor = UIColor(white: 0, alpha: 0.6)
                    shareButton.layer.cornerRadius = 22
                } else {
                    shareButton.setTitle("Share", for: .normal)
                }
                shareButton.addTarget(self, action: #selector(shareCurrentPage), for: .touchUpInside)
                rootVC.view.addSubview(shareButton)

                NSLayoutConstraint.activate([
                    shareButton.widthAnchor.constraint(equalToConstant: 44),
                    shareButton.heightAnchor.constraint(equalToConstant: 44),
                    shareButton.trailingAnchor.constraint(equalTo: rootVC.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                    shareButton.bottomAnchor.constraint(equalTo: rootVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                ])
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Called when the app was launched with a url. Feel free to add additional processing here,
        // but if you want the App API to support tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Called when the app was launched with an activity, including Universal Links.
        // Feel free to add additional processing here, but if you want the App API to support
        // tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

}

extension AppDelegate: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.allow); return }
        if let host = url.host, host.hasSuffix("chartermarket.app") {
            decisionHandler(.allow)
        } else if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Load local offline page if initial navigation fails
        if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            if let baseURL = Bundle.main.url(forResource: "offline", withExtension: "html", subdirectory: "public") {
                webView.loadFileURL(baseURL, allowingReadAccessTo: baseURL)
            }
        }
    }
}

extension AppDelegate: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Handle window.open / target=_blank by showing SFSafariViewController
        if navigationAction.targetFrame == nil || !(navigationAction.targetFrame?.isMainFrame ?? true) {
            if let url = navigationAction.request.url {
                let safari = SFSafariViewController(url: url)
                ApplicationDelegateProxy.shared.bridge?.viewController?.present(safari, animated: true)
            }
            return nil
        }
        return nil
    }
}

extension AppDelegate {
    @objc func shareCurrentPage() {
        guard let bridge = ApplicationDelegateProxy.shared.bridge,
              let webView = bridge.webView as? WKWebView else { return }
        let url = webView.url?.absoluteString ?? "https://chartermarket.app"
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let rootVC = bridge.viewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.width - 40, y: rootVC.view.bounds.height - 40, width: 1, height: 1)
            }
            rootVC.present(activityVC, animated: true)
        }
    }
}
