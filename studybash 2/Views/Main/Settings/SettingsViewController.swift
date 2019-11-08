import UIKit
import Firebase


class SettingsViewController: UIViewController {
    
    // Label
    @IBOutlet weak var settingsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func myProfileButton(_ sender: Any) {
        performSegue(withIdentifier: "settings_to_profile", sender: nil)
    }
    
    @IBAction func aboutButton(_ sender: Any) {
        performSegue(withIdentifier: "settings_to_about", sender: nil)
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
