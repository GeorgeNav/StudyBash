

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    
    func createTextFieldAlert(type: String){
        
        if (type == "email"){
            let alert = UIAlertController(title: "Missing email", message: "Please make sure you enter your email in the two boxes.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            
        else if (type == "emailFormat"){
            let alert = UIAlertController(title: "Invalid Email", message: "Email address is not valid. Please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            
        else if (type == "emailExists"){
            let alert = UIAlertController(title: "Invalid Email", message: "Email address is already in use. Try resetting your password if you forgot it.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        else if (type == "mismatch"){
            let alert = UIAlertController(title: "Email Mismatch", message: "Your emails did not match. Check for typos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
               view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func sendCodeButton(_ sender: Any) {
        
        var email = ""
        var confirmEmail = ""
        
        if (emailTextField.text!.count > 0 || confirmEmailTextField.text!.count > 0){
            email = emailTextField.text!
            confirmEmail = confirmEmailTextField.text!
        }
        else {
            createTextFieldAlert(type: "email")
            return
        }
        
        if (email != confirmEmail) {
            createTextFieldAlert(type: "mismatch")
        }
    }
    
}
