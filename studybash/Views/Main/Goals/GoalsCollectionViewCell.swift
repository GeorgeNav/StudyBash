


import UIKit
import FirebaseFirestore

class GoalsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var goalName: UILabel!
    @IBOutlet weak var numSubGoals: UILabel!
    @IBOutlet weak var deleteGoal: UIButton!
    var goalDocRef: DocumentReference?
    
    @IBAction func deleteGoalButton(_ sender: Any) {
        print("deleting goal")
        goalDocRef?.collection("sub_goals").getDocuments(completion: {(snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            snapshot!.documents.forEach({(doc) in
                doc.reference.delete()
            })
        })
        goalDocRef?.delete()
    }
}
