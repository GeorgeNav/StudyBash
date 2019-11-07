

import UIKit
import UserNotifications
import NotificationCenter
import FirebaseAuth
import FirebaseFirestore



class ProfileViewController: UIViewController {
    //Labels
    @IBOutlet weak var myProfileLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    //TextBox Input
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confrimPasswordTextField: UITextField!
    
    var isKeyboardAppear = false
    
    let db: Firestore = Firestore.firestore()
    var auth: Auth = Auth.auth()
    var userDocRef: DocumentReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userDocRef = db.collection("users").document(auth.currentUser!.uid)
        userDocRef?.getDocument(completion: {(snapshot, error) in
            guard snapshot != nil else { print("Error:", error!); return }
            let userData = snapshot!.data()!
            self.firstNameTextField.text = userData["first_name"]! as? String
            self.lastNameTextField.text = userData["last_name"]! as? String
            self.emailTextField.text = userData["email"]! as? String
        })
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func saveUserData(_ sender: Any) {
        userDocRef?.setData([
            "first_name": firstNameTextField.text!,
            "last_name": lastNameTextField.text!,
            "email": emailTextField.text!
        ])
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= 60
                }
            }
            isKeyboardAppear = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if isKeyboardAppear {
            if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                if self.view.frame.origin.y != 0{
                    self.view.frame.origin.y = 0
                }
            }
             isKeyboardAppear = false
        }
    }
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
    }
    


}
