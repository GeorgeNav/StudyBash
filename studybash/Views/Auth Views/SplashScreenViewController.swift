//
//  ViewController.swift
//  studybash
//
//  Created by George Navarro on 10/6/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import Lottie

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var animationView: UIView!
    var animation : AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimation()
    }
    
    func setupAnimation() {
        animation = AnimationView(name: "time")
        animation?.frame = animationView.bounds
        animationView.addSubview(animation!)
        animation?.loopMode = .loop
        animation?.contentMode = .scaleAspectFit
        animation?.play()
    }
    
}
