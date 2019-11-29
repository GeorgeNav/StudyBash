


import UIKit
import FirebaseFirestore

class SubGoalsTableViewCell: UITableViewCell {
    @IBOutlet weak var subGoalName: UILabel!
    @IBOutlet weak var dueDateL: UILabel!
    @IBOutlet weak var notesL: UILabel!
    @IBOutlet weak var hoursSpentL: UILabel!
    @IBOutlet weak var daysLeftL: UILabel!
    @IBOutlet weak var subType: UILabel!

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
