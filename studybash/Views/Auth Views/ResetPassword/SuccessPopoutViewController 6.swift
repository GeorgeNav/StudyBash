/*
 
This one for the Password Success popout custom view.
- TODO: Segue from the DoneButton to the Login Screen.
 
*/

import UIKit

class SuccessPopoutViewController: UIViewController {

    @IBOutlet weak var BackgroundWhite: UIImageView!
    @IBOutlet weak var DoneLogo: UIImageView!
    @IBOutlet weak var DoneLabel: UILabel!
    @IBOutlet weak var successText: UILabel!
    @IBOutlet weak var DoneButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
