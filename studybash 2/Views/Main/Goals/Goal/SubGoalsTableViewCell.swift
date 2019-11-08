//
//  SubGoalsTableViewCell.swift
//  studybash
//
//  Created by George Navarro on 10/17/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SubGoalsTableViewCell: UITableViewCell {
    @IBOutlet weak var subGoalName: UILabel!
    @IBOutlet weak var deleteSubGoal: UIButton!
    var subGoalDocRef: DocumentReference?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func deleteSubGoalButton(_ sender: Any) {
        print("deleting sub goal")
        subGoalDocRef?.delete()
    }
}
