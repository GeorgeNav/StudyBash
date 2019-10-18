//
//  GoalViewController.swift
//  studybash
//
//  Created by George Navarro on 10/17/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit

let subGoalCellIdentifier = "sub_goal_cell"

class GoalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var subGoalsTV: UITableView!
    var goalData: [String: Any] = [String: Any]()
    var subGoalsData: [[String: Any]] = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subGoalsTV.dataSource = self
        self.subGoalsTV.delegate = self
        print(subGoalsData)
    }
    
    @IBAction func backButton(_ sender: Any) {
    }
    
    func loadData(subGoalsData: [[String: Any]]) {
        self.subGoalsData = subGoalsData
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subGoalsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = subGoalsTV.dequeueReusableCell(withIdentifier: subGoalCellIdentifier, for: indexPath) as! SubGoalsTableViewCell
        cell.subGoalName.text = (subGoalsData[indexPath.row]["name"]! as! String)
        return cell
    }


}
