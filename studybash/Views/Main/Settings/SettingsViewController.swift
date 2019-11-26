import UIKit
import Firebase
import SwiftyUserDefaults
import Lottie
import NotificationCenter
import UserNotifications


class SettingsViewController: UIViewController {
    
    @IBOutlet weak var animationView: UIView!
    var animation : AnimationView?
    

    
    
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
            self.setupAnimation()
            try Auth.auth().signOut()
            Defaults[.isLogin] = false
            Defaults[.email] = nil
            Defaults[.password] = nil
            DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                self.performSegue(withIdentifier: "settings_to_sign_in", sender: self)
            })
        } catch let err {
            print(err)
        }
    }
    
    func setupAnimation() {
        animation = AnimationView(name: "loading")
        animation?.frame = animationView.bounds
        animationView.addSubview(animation!)
        animation?.loopMode = .loop
        animation?.contentMode = .scaleAspectFit
        animation?.play()
    }
    

    
}
