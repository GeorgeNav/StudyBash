//
//  AddGoalViewController.swift
//  studybash
//
//  Created by George Navarro on 10/15/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit

class AddGoalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createGoalButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "add_goal_to_goal", sender: self)
    }
}
