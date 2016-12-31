//
//  ImageViewController.swift
//  Cassini
//
//  Created by Chen Cen on 10/2/16.
//  Copyright © 2016 Chen Cen. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    var imageUrl: NSURL? {
        didSet {
            image = nil
            // we only fetch when view is being displayed
            // view.window is a reliable way to test if view is on window
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // this is from delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // we only fetch when the view is about to appear
        if image == nil {
            fetchImage()
        }
    }
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            // action listener
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }

    private func fetchImage() {
        // nil check
        if let url = imageUrl {
            spinner?.startAnimating()
            // do this shit on userInitiated queue(2nd highest priority)
            DispatchQueue.global(qos: .userInitiated).async {
                // fetch - this touches network and is slow
                let contentOfURL = NSData(contentsOf: url as URL)
                // set, do this back in main
                DispatchQueue.main.async {
                    if url == self.imageUrl {
                        if let imageData = contentOfURL {
                            self.image = UIImage(data: imageData as Data)
                        } else {
                            self.spinner?.stopAnimating()
                        }
                    } else {
                        print("ignored data return from url \(url)")
                    }
                }
            }
        }
    }
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            // by this time scrollView might not be initialized yet
            // it's only scrollable after we set its size 
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
        get {
            return imageView.image
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // note we declared this controller contains a scrollView, so instead of using 
        // the default view, we can use this
        scrollView.addSubview(imageView)
    }
}
