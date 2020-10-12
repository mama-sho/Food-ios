//
//  WebViewKitController.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/05.
//

import UIKit
import WebKit

class WebViewKitController: UIViewController {
    
    var url:String = String()

    @IBOutlet weak var WebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //webViewの反映　
        if let URL = URL(string: url) {
            self.WebView.load(URLRequest(url: URL))
        }
    }
}
