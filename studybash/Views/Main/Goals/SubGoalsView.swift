//
//  SubGoalsView.swift
//  studybash
//
//  Created by Mustafa AL-Jaburi on 10/13/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import Foundation
import UIKit
import Clocket


class SubGoalsView: UIViewController {
    
    
    @IBOutlet weak var clock: Clocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clock.displayRealTime = true
        clock.startClock()
    }
}
