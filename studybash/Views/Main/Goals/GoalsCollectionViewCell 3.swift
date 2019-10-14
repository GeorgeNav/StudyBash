//
//  GoalsCollectionViewCell.swift
//  studybash
//
//  Created by George Navarro on 10/12/19.
//  Copyright © 2019 Navality. All rights reserved.
//

import UIKit

class GoalsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var goalName: UILabel!
    @IBOutlet weak var numSubGoalsDueToday: UILabel!
    @IBOutlet weak var subGoalProgress: UILabel!
}
