import UIKit
import WebKit

class detailWebViewController: UIViewController, WKNavigationDelegate {
        
    @IBOutlet var webView: WKWebView!
    
    let baseURL = "https://en.wikipedia.org/wiki/"
    var extensionURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let extensionURL = extensionURL else { return }
        let url = URL(string: baseURL + extensionURL)!
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}
