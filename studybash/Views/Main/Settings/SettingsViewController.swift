import UIKit
import Firebase


class SettingsViewController: UIViewController {
    
    // Label
    @IBOutlet weak var settingsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func myProfileButton(_ sender: Any) {
    }
    
    @IBAction func aboutButton(_ sender: Any) {
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch let err {
            print(err)
        }
    }
    
    
}
