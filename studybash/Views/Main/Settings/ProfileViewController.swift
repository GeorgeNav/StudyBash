

import UIKit
import UserNotifications
import NotificationCenter
import FirebaseAuth
import FirebaseFirestore
import SwiftMessages




class ProfileViewController: UIViewController {
    //Labels
    @IBOutlet weak var myProfileLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    
    //TextBox Input
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    
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
    
    
    
    func saveUserData() {
        userDocRef?.setData([
            "first_name": firstNameTextField.text!,
            "last_name": lastNameTextField.text!,
            "email": emailTextField.text!,
        ])
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= 50
                }
            }
            isKeyboardAppear = true
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        let currentUser = Auth.auth().currentUser
        let newEmail = emailTextField.text!
        let newFirstName = firstNameTextField.text!
        let newLastname = lastNameTextField.text!
        
        currentUser?.updateEmail(to: newEmail) { error in
            guard error == nil else { print(error!); return }
            self.userDocRef = self.db.collection("users").document(self.auth.currentUser!.uid)
            self.userDocRef?.updateData(["email": newEmail])
            self.userDocRef?.updateData(["first_name": newFirstName])
            self.userDocRef?.updateData(["last_name": newLastname])
            print("CHANGED")
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Success!", body: "Information has been updated", iconImage: nil, iconText: "✔️", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            self.dismiss(animated: true, completion: nil)
        }

    }
}
